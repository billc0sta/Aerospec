open Parser
open Value

exception RuntimeError of string * string * Lexer.token

type state = {return_value: Value.t; returned: bool; breaked: bool; continued: bool; call_depth: int; loop_depth: int}
type t = {imported: string list; path: string; env: (string, (Value.t * bool)) Environment.t; raw: statement list; state: state}

let import_cache = Hashtbl.create 8 

let add_natives env =
  Environment.add "IO" (Natives.module_IO (), false) env;
  Environment.add "Time" (Natives.module_time (), false) env;
  Environment.add "Float" (Natives.module_float (), false) env;
  Environment.add "String" (Natives.module_string (), false) env;
  Environment.add "Array" (Natives.module_array (), false) env;
  Environment.add "Object" (Natives.module_object (), false) env;
  Environment.add "Value" (Natives.module_value (), false) env

let report_error message tk inp =
  raise (RuntimeError (message, inp.path, tk))

let make raw path = 
  let inp = {
	  path;
	  raw;
	  imported=[];
	  env=(Environment.make ());
	  state=
		{return_value=Nil; 
		 returned=false;
		 breaked=false; 
		 continued=false;
		 call_depth=0; 
		 loop_depth=0}} in
  add_natives inp.env;
  inp

let rec evaluate expr inp =
  match expr with
  | FloatLit fl -> Float fl
  | StringLit str -> make_rez_string str 
  | Binary (expr1, op, expr2) -> evaluate_binary expr1 expr2 op inp
  | Unary (op, expr) -> evaluate_unary op expr inp 
  | IdentExpr (tk, global) -> evaluate_ident tk global inp
  | IfExpr (cond, whentrue, whenfalse) -> evaluate_ifexpr cond whentrue whenfalse inp
  | FunCall (target, arglist, tk) -> evaluate_funcall target arglist tk inp
  | LambdaExpr (exprs, body, _) -> evaluate_lambda exprs body inp
  | ArrExpr (exprs, _) -> evaluate_arr exprs inp
  | Subscript (expr, subexpr, tk) -> evaluate_subscript expr subexpr tk inp
  | Range (_, tk, _, _, _) -> report_error "Cannot evaluate range expression in this context" tk inp
  | ObjectExpr stmts -> evaluate_object stmts inp
  | PropertyExpr (expr, ident) -> evaluate_property expr ident inp
  | Builder (range, cond, expr) -> evaluate_builder range cond expr inp
  | NilExpr -> Nil

and evaluate_builder range cond expr inp =
  let (rcond, name, beg, _, dir) = start_range range inp in
  let dir = float_of_int dir in
  let arr = Resizable.make () in
  let iter = ref (float_of_int beg) in
  while truth (evaluate rcond inp) do
	(if truth (evaluate cond inp) then 
	   Resizable.append arr (evaluate expr inp)
	);
	iter := !iter +. dir;
	Environment.replace name (Float (!iter), true) inp.env
  done;
  Environment.remove name inp.env;
  Resizable.shrink arr;
  Arr (arr, false)

and evaluate_property expr ident inp =
  let tk = match ident with IdentExpr (tk, _) -> tk | _ -> assert false; in
  let eval = evaluate expr inp in
  let env = 
	match eval with
	| Object (env, _) -> env
	| _ -> report_error ("Value of type '"^nameof eval^"' has no properties") tk inp
  in

  let found = Environment.find tk.value env in
  match found with
  | None -> report_error ("This object has no such property as '"^tk.value^"' ") tk inp
  | Some (v, _) -> v 

and evaluate_object stmts inp =
  let obj_env = Environment.child_of inp.env in
  run {(make stmts inp.path) with env=obj_env};
  Object(obj_env, false)

and ev_subexpr expr tk inp =
  let ev = evaluate expr inp in
  match ev with 
  | Float fl -> begin
      if Float.is_nan fl
      then report_error ("Cannot index with a 'NaN' value") tk inp
	  else if Float.trunc fl <> fl then
		report_error "Cannot subscript with floating-point number" tk inp
	  else if fl < 0.0 && fl <> Float.neg_infinity then
		report_error "Cannot subscript with a negative number" tk inp
	  else fl 
	end 
  | _ -> report_error ("Cannot subscript with value of type '"^nameof ev^"'") tk inp

and evaluate_subscript expr subexpr tk inp =

  match subexpr with
  | (expr1, Some expr2) -> begin
	  let beginning = ev_subexpr expr1 tk inp in
	  let ending    = ev_subexpr expr2 tk inp in
      if beginning > ending then
        report_error ("Range subscript is invalid as the begin value exceeds the end value") tk inp
      else 
        let ev = evaluate expr inp in
		match ev with
		| Arr (rez, _) -> begin
			let beginning = if beginning = Float.neg_infinity then 0 else int_of_float beginning in
			let ending    = if ending = Float.infinity then Resizable.len rez else int_of_float ending in
			try Arr (Resizable.range rez beginning ending, false)
			with Invalid_argument _ -> report_error "Accessing array out of bounds" tk inp
		  end
		| String (rez, _) -> begin
			let beginning = if beginning = Float.neg_infinity then 0 else int_of_float beginning in
			let ending    = if ending = Float.infinity then Resizable.len rez else int_of_float ending in
            
			try String (Resizable.range rez beginning ending, false)
			with Invalid_argument _ -> report_error "Accessing string out of bounds" tk inp
		  end
		| _ -> report_error ("Value of type '"^nameof ev^"' is not subscriptable") tk inp
	end

  | (subexpr, None) -> begin
	  let subscript =
        let v = ev_subexpr subexpr tk inp in
        if abs_float v = Float.infinity
        then report_error ("Cannot index with 'Infinity' value") tk inp
        else int_of_float v
      in
	  let ev = evaluate expr inp in
	  match ev with
	  | Arr (rez, _) -> begin
		  try Resizable.get rez subscript
		  with Invalid_argument _ -> report_error "Accessing array out of bounds" tk inp
		end
	  | String (rez, _) -> begin
		  try make_rez_string (Char.escaped (Resizable.get rez subscript))
		  with Invalid_argument _ -> report_error "Accessing string out of bounds" tk inp
		end
	  | _ -> report_error ("Value of type '"^nameof ev^"' is not subscriptable") tk inp
	end

and evaluate_arr exprs inp = 
  let arr = Resizable.make () in
  List.iter (fun expr -> Resizable.append arr (evaluate expr inp)) exprs;
  (Arr (arr, false))

and evaluate_lambda exprs body inp = 
  let rec aux acc exprs =
	match exprs with
	| [] -> (acc)
	| x::xs -> begin 
		match x with
		| IdentExpr (tk, global) -> 
		   if global then report_error "invalid parameter" tk inp
		   else aux (tk.value::acc) xs
		| _ -> assert false;
	  end
  in
  let params = List.rev (aux [] exprs) in
  Func (inp.env, params, body)

and evaluate_funcall target arglist tk inp =
  let callable = evaluate target inp in
  match callable with
  | Func (env, params, body)  -> evaluate_func env arglist params body tk inp
  | NatFunc (paramc, _, func) -> evaluate_natfunc paramc arglist func tk inp
  | Object (env, locked) -> 
	 if (List.length arglist) <> 0 
	 then report_error "Cannot pass arguments in a call to object" tk inp
	 else copy_object env locked
  | _ -> report_error ("Cannot call a value of type '"^nameof callable^"'") tk inp

and evaluate_func env arglist params body tk inp =
  let param_len = List.length params in
  let arg_len   = List.length arglist in
  if param_len <> arg_len then
	report_error "The number of arguments do not match the number of parameters" tk inp
  else try 
	  let ninp = 
		{inp with env=Environment.child_of env; state={inp.state with call_depth=inp.state.call_depth+1; loop_depth=0}} in
	  let () = List.iter2 (fun arg param -> 
				   let value = evaluate arg inp in
				   Environment.add param (value, true) ninp.env
			     ) arglist params in
	  match body with
	  | Block block -> begin 
		  let ninp = block_stmt block ninp in
		  ninp.state.return_value 
		end 
	  | _ -> assert false;
	with Stack_overflow -> report_error "Stack overflow" tk inp

and evaluate_natfunc paramc arglist func tk inp =
  let arg_len   = List.length arglist in
  let param_len = paramc in
  if not (param_len = arg_len || param_len >= 256 && arg_len >= (param_len - 256)) then
	report_error "The number of arguments do not match the number of parameters" tk inp
  else
	let val_list = List.map (fun expr -> evaluate expr inp) arglist in
	try func val_list
	with Invalid_argument message -> report_error message tk inp

and evaluate_binary expr1 expr2 op inp =
  let raise_error =  (fun ev1 ev2 -> 
	  report_error ("Cannot apply operator '"^Lexer.nameof op.typeof^"' to values of types ('"^nameof ev1^"' and '"^nameof ev2^"')") op inp) in
  let ev_both = (fun expr1 expr2 -> (evaluate expr1 inp, evaluate expr2 inp)) in
  let simple_binary = (fun expr1 expr2 op -> let (ev1, ev2) = ev_both expr1 expr2 in
		                                     match (ev1, ev2) with Float fl1, Float fl2 -> (op fl1 fl2) | _ -> raise_error ev1 ev2)
  in
  match op.typeof with
  | Plus -> begin
	  let (ev1, ev2) = ev_both expr1 expr2 in
	  match (ev1, ev2) with
	  | Float fl1, Float fl2 -> Float (fl1 +. fl2)
	  | String (str1, _), String (str2, _) -> String (Resizable.merge str1 str2, false)
	  | Arr (arr1, _), Arr (arr2, _) -> Arr (Resizable.merge arr1 arr2, false)
	  | _ -> raise_error ev1 ev2
	end
  | EqualEqual -> begin
	  let (ev1, ev2) = (ev_both expr1 expr2) in 
	  match (ev1, ev2) with
	  | String (str1, _), String (str2, _) -> Bool (Resizable.equal str1 str2)
	  | Float fl1, Float fl2 -> Bool (fl1 = fl2)
	  | Bool b1, Bool b2 -> Bool (b1 = b2)
	  | Arr (arr1, _), Arr (arr2, _) -> Bool (Resizable.equal arr1 arr2) 
	  | _ -> (Bool false) 
	end 
  | ExcEqual -> begin
	  let (ev1, ev2) = (ev_both expr1 expr2) in 
	  match (ev1, ev2) with
	  | String (str1, _), String (str2, _) -> Bool (not (Resizable.equal str1 str2))
	  | Float fl1, Float fl2 -> Bool (fl1 <> fl2)
	  | Bool b1, Bool b2 -> Bool (b1 <> b2)
	  | Arr (arr1, _), Arr (arr2, _) -> Bool (not (Resizable.equal arr1 arr2)) 
	  | _ -> (Bool false)
	end
  | Minus -> Float (simple_binary expr1 expr2 (-.))
  | Star -> Float (simple_binary expr1 expr2 ( *. ))
  | Slash -> Float (simple_binary expr1 expr2 (/.))
  | Modulo -> Float (simple_binary expr1 expr2 (fun a b -> a -. (b *. (floor (a /. b)))))
  | Greater -> begin
     let (ev1, ev2) = (ev_both expr1 expr2) in
     match (ev1, ev2) with
     | String (str1, _), String (str2, _) ->
        (Bool ((Resizable.compare (fun c1 c2 -> (Char.code c1) - (Char.code c2)) str1 str2) > 0))
     | Float fl1, Float fl2 -> Bool (fl1 > fl2)
     | _ -> raise_error ev1 ev2
     end
  | Lesser -> begin
     let (ev1, ev2) = (ev_both expr1 expr2) in
     match (ev1, ev2) with
     | String (str1, _), String (str2, _) ->
        (Bool ((Resizable.compare (fun c1 c2 -> (Char.code c1) - (Char.code c2)) str1 str2) < 0))
     | Float fl1, Float fl2 -> Bool (fl1 < fl2)
     | _ -> raise_error ev1 ev2
     end
  | GreatEqual -> begin
     let (ev1, ev2) = (ev_both expr1 expr2) in
     match (ev1, ev2) with
     | String (str1, _), String (str2, _) ->
        (Bool ((Resizable.compare (fun c1 c2 -> (Char.code c1) - (Char.code c2)) str1 str2) >= 0))
     | Float fl1, Float fl2 -> Bool (fl1 >= fl2)
     | _ -> raise_error ev1 ev2
     end
  | LessEqual -> begin
     let (ev1, ev2) = (ev_both expr1 expr2) in
     match (ev1, ev2) with
     | String (str1, _), String (str2, _) ->
        (Bool ((Resizable.compare (fun c1 c2 -> (Char.code c1) - (Char.code c2)) str1 str2) <= 0))
     | Float fl1, Float fl2 -> Bool (fl1 <= fl2)
     | _ -> raise_error ev1 ev2
     end
  | TwoAmper -> 
	 let ev1 = evaluate expr1 inp in
	 if truth ev1 then evaluate expr2 inp else ev1
  | Columns -> 
	 let ev1 = evaluate expr1 inp in
	 if truth ev1 then ev1 else evaluate expr2 inp
  | Equal | ConEqual -> assignment expr1 expr2 op inp
  | _ -> assert false

and evaluate_unary op expr inp =
  let raise_error = (fun ev -> report_error 
		                         ("Cannot apply operator '"^Lexer.nameof op.typeof^"' to values of type '"^nameof ev^"'") op inp) in
  let ev = evaluate expr inp in
  match op.typeof with
  | Exclamation -> Bool (not (truth ev))
  | Plus     -> begin match ev with Float fl -> Float fl | _ -> raise_error ev end
  | Minus    -> begin match ev with Float fl -> Float (fl*.(-1.)) | _ -> raise_error ev end
  | Tilde    -> (make_rez_string (nameof ev))
  | Hash     -> evaluate_import op expr inp
  | Amper    -> shallow_lock (evaluate expr inp)
  | TwoAmper -> deep_lock (evaluate expr inp)
  | _ -> assert false;

and evaluate_import tk expr inp =
  let fp = match expr with
	| StringLit fp -> fp
	| _ -> assert false;
  in

  let file_path = (Filename.dirname inp.path ^ "/") ^ fp in
  let find = Hashtbl.find_opt import_cache file_path in
  match find with
  | Some imp_obj -> (Object (imp_obj, false))
  | None -> begin
      if inp.path = file_path
      then report_error "Cannot import a file in itself" tk inp
      else

        if List.mem file_path inp.imported
        then report_error ("Import cycle detected between '"^file_path^"' and '"^inp.path^"'") tk inp
        else 

          let ch = 
            try open_in_bin file_path 
            with Sys_error _ -> report_error ("No such file as '"^file_path^"' in the current directory") tk inp
          in 
          let s = really_input_string ch (in_channel_length ch) in
          close_in ch;

          let lexer  = Lexer.make s file_path in
          let lexed  = Lexer.lex lexer in
          let parser = Parser.make lexed file_path s in
          let parsed = Parser.parse parser in

          let imp_obj = Environment.make () in
          let ninp   = {(make parsed file_path) with imported=(file_path::inp.imported); env=imp_obj} in
          run ninp;

          Hashtbl.add import_cache file_path imp_obj;
          (Object (imp_obj, false))
	end

and evaluate_ident tk global inp =
  let rec aux env =
	match Environment.find tk.value env with
	| None -> 
	   begin
		 let env = 
		   try Environment.parent_of env 
		   with Invalid_argument _ -> report_error ("Unbinded variable '"^tk.value^"' was referenced") tk inp 
		 in aux env
	   end
	| Some (value, _) -> value

  in let env = if global then 
		         try Environment.parent_of inp.env
		         with Invalid_argument _ ->
			       report_error ("Global variable '"^tk.value^"' was referenced in global scope") tk inp
		       else inp.env in
	 aux env

and evaluate_ifexpr cond whentrue whenfalse inp =
  let ev = evaluate cond inp in
  let trued = truth (ev) in
  if trued then evaluate whentrue inp
  else evaluate whenfalse inp	

and assignment target expr token inp =
  let mut = match token.typeof with
	| Equal -> true
	| ConEqual -> false
	| _ -> assert false;
  in
  match target with 
  | IdentExpr (tk, global) -> if global then ignore(evaluate_ident tk global inp); assign_ident mut expr target inp
  | Subscript (target, (index, None), tk) -> 
	 if not mut then report_error "Cannot constant-assign an index" tk inp
	 else assign_subscript expr target index inp
  | PropertyExpr (obj, target) -> assign_property obj target expr mut inp 
  | _ -> assert false

and assign_property obj target expr ismut inp =
  let tk = match target with IdentExpr (tk, _) -> tk | _ -> assert false; in
  let env = 
	match evaluate obj inp with
	| Object (env, locked) -> 
	   if locked then report_error "Cannot assign property to a locked object" tk inp else env
	| eval -> report_error ("Value of type '"^nameof eval^"' has no properties") tk inp
  in
  
  let ev_expr expr = 
	match evaluate expr inp with
	| Func (_, params, stmts) -> Func (env, params, stmts)
	| eval -> eval
  in

  match (Environment.find tk.value env) with
  | None -> begin
	  let value = ev_expr expr in
	  Environment.add tk.value (value, ismut) env; value
	end
  | Some (_, mut) -> begin 
	  if not mut then report_error "Cannot re-assign to a constant" tk inp
	  else 
		let value = ev_expr expr in
		Environment.replace tk.value (value, ismut) env; value
	end

and assign_subscript expr target index inp =
  let (rez, token) =
    match target with
    | IdentExpr(tk, global) -> (evaluate_ident tk global inp, tk)
    | Subscript(expr, subexpr, tk) -> (evaluate_subscript expr subexpr tk inp, tk) 
    | _ -> assert false
  in
  match rez with
  | Arr (rez, locked) ->
  	 if locked then
  	   report_error "Cannot assign to a subscript of a locked array" token inp 
     else 
       let index = int_of_float (ev_subexpr index token inp) in
       let value = evaluate expr inp in
       begin
         try Resizable.putat rez index value; value
         with Invalid_argument _ ->
           report_error "Accessing array out of bounds" token inp
       end

  | String (rez, locked) ->
     if locked then
  	   report_error "Cannot assign to a subscript of a locked string" token inp 
     else 
       let index = int_of_float (ev_subexpr index token inp) in
       let value = evaluate expr inp in
       begin
         match value with
         | String (chr, _) ->
            let length = Resizable.len chr in
            if length <> 1 then
              report_error "Assigning invalid character count value to a string index" token inp
            else
        	  begin
                try Resizable.putat rez index (Resizable.get chr 0); value
                with Invalid_argument _ ->
                  report_error "Accessing string out of bounds" token inp
      		  end
         | _ ->
            report_error ("Cannot assign to a string index with value of type '" ^ nameof value ^ "'") token inp
       end
  | _ -> report_error ("Value of type '"^nameof rez^"' is not subscriptable") token inp

and assign_ident ismut expr ident inp =

  let (name, global, token) = 
	match ident with
	| IdentExpr(tk, global) -> (tk.value, global, tk)
	| _ -> assert false;
  in
  if global && not ismut then
    report_error ("Cannot constant-assgin a global variable") token inp
  else
    let env = if global then
		        try Environment.parent_of inp.env
		        with Invalid_argument _ -> 
			      report_error ("Global variable '"^token.value^"' was referenced in global scope") token inp
		      else inp.env 
    in
    match (Environment.find name env) with
    | None -> begin
	    let value = evaluate expr inp in
	    Environment.add name (value, ismut) env; value
	  end
    | Some (_, mut) -> begin 
	    if not mut then report_error "Cannot re-assign to a constant" token inp
	    else 
		  let value = evaluate expr inp in
		  Environment.replace name (value, ismut) env; value
	  end

and exec_stmt stmt inp =
  match stmt with
  | Exprstmt expr -> ignore (evaluate expr inp); inp
  | IfStmt (cond, whentrue, whenfalse) -> if_stmt cond whentrue whenfalse inp
  | Block stmts -> block_stmt stmts inp
  | LoopStmt (cond, stmt) -> loop_stmt cond stmt inp
  | Break tk -> break_stmt tk inp
  | Continue tk -> continue_stmt tk inp
  | NoOp _ -> inp
  | Return (expr, tk) -> return_stmt expr tk inp

and break_stmt tk inp =
  if inp.state.loop_depth = 0 then report_error "Break statement ('**') outside of loop" tk inp
  else {inp with state={inp.state with breaked = true}}

and continue_stmt tk inp =
  if inp.state.loop_depth = 0 then report_error "Continue statement ('<<') outside of loop" tk inp
  else {inp with state={inp.state with continued = true}}

and return_stmt expr tk inp =
  if inp.state.call_depth = 0 then report_error "Return statement ('->') outside of function" tk inp
  else {inp with state={inp.state with returned = true; return_value=evaluate expr inp}}

and block_stmt stmts inp =
  let rec aux stmts inp =
	match stmts with
	| [] -> inp
	| x::xs -> begin
		let inp = exec_stmt x inp in
		if inp.state.returned || inp.state.continued || inp.state.breaked 
		then inp
		else aux xs inp
	  end
  in aux stmts inp

and if_stmt cond whentrue whenfalse inp =
  if truth (evaluate cond inp) then exec_stmt whentrue inp 
  else match whenfalse with
	   | None -> inp
	   | Some block -> exec_stmt block inp

and loop_stmt cond stmt inp =
  let inp = {inp with state={inp.state with loop_depth=inp.state.loop_depth+1}} in
  match cond with
  | Range _ -> range_loop cond stmt inp
  | _ -> normal_loop cond stmt inp

and range_loop range stmt inp =
  let (cond, name, beg, _, dir) = start_range range inp in
  let (beg, dir) = (float_of_int beg, float_of_int dir) in
  let rec aux iter inp =
	if truth (evaluate cond inp) then
	  let inp = exec_stmt stmt inp in
	  let iter = iter+.dir in
	  Environment.replace name (Float (iter), true) inp.env;
	  if inp.state.breaked then {inp with state={inp.state with breaked=false}}
	  else if inp.state.continued then aux iter {inp with state={inp.state with continued=false}}
	  else aux iter inp
	else inp
  in 
  let inp = aux beg inp in
  Environment.remove name inp.env;
  inp

and normal_loop cond stmt inp =
  let rec aux inp =
	if truth (evaluate cond inp) then
	  let inp = exec_stmt stmt inp in
	  if inp.state.breaked then {inp with state={inp.state with breaked=false}}
	  else if inp.state.continued then aux {inp with state={inp.state with continued=false}}
	  else aux inp
	else inp
  in aux inp

and start_range range inp =

  let (expr1, tk1, ident, tk2, expr2) = match range with
	| Range (expr1, tk1, ident, tk2, expr2) -> (expr1, tk1, ident, tk2, expr2) 
	| _ -> assert false;
  in

  let ev_expr expr = 
	match evaluate expr inp with
	| Float fl -> 
	   if Float.trunc fl <> fl 
	   then report_error "Cannot use floating-point number in range expression" tk1 inp
	   else int_of_float fl
	| ev ->  
	   report_error ("Cannot use value of type '"^Value.nameof ev^"' in range expression") tk1 inp
  in

  let (beg, dir) = 
	match tk1.typeof with
	| Greater    -> ((ev_expr expr1)-1, -1)
	| GreatEqual -> ((ev_expr expr1),   -1)
	| Lesser     -> ((ev_expr expr1)+1,  1)
	| LessEqual  -> ((ev_expr expr1),    1)
	| _ -> assert false;
  in
  let endof = (ev_expr expr2) in
  let () = if dir = 1 && not (beg < endof) then
		     report_error "Beginning should be less than ending of range expression" tk1 inp
		   else if dir = -1 && not (beg > endof) then
		     report_error "Beginning should be greter than ending of range expression" tk1 inp
		   else ()
  in
  let name = match ident with IdentExpr (tk, _) -> tk.value | _ -> assert false; in
  Environment.add name (Float (float_of_int beg), true) inp.env;
  (Binary (ident, tk2, FloatLit (float_of_int endof)), name, beg, endof, (dir:int))

and run inp = 
  ignore (exec_stmt (Block inp.raw) inp)
