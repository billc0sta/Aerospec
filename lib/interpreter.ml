open Parser
open Value

exception RuntimeError of string * Lexer.token

type state = {return_expr: expr option; returned: bool; breaked: bool; continued: bool; call_depth: int; loop_depth: int}
type t = {env: Environment.t; raw: statement list; state: state}

let add_natives env =
	Environment.add "print" (NatFunc (256, ["params..."], Natives.print), true) env; 
	Environment.add "input" (NatFunc (0, [], Natives.input), true) env; 
	Environment.add "clock" (NatFunc (0, [], Natives.clock), true) env

let make raw = 
	let inp = {raw; env=(Environment.make ());
	state={return_expr=None; returned=false;
	breaked=false; continued=false;
	call_depth=0; loop_depth=0}} in
	add_natives inp.env;
	inp

let rec evaluate expr inp =
	match expr with
	| FloatLit fl -> Float fl
	| StringLit str -> make_rez_string str 
	| Binary (expr1, op, expr2) -> evaluate_binary expr1 expr2 op inp
	| Unary (op, expr) -> evaluate_unary op expr inp 
	| Grouping expr -> evaluate expr inp
	| IdentExpr (tk, global) -> evaluate_ident tk global inp
	| IfExpr (cond, whentrue, whenfalse) -> evaluate_ifexpr cond whentrue whenfalse inp
	| FunCall (target, arglist, tk) -> evaluate_funcall target arglist tk inp
	| LambdaExpr (exprs, body, _) -> evaluate_lambda exprs body
	| ArrExpr (exprs, _) -> evaluate_arr exprs inp
	| Subscript (expr, subexpr, tk) -> evaluate_subscript expr subexpr tk inp

and evaluate_subscript expr subexpr tk inp =
	let sub_ev = evaluate subexpr inp in
	let subscript = 
		match sub_ev with Float fl -> fl | _ -> raise (RuntimeError (("Cannot subscript with value of type '"^nameof sub_ev^"'"), tk)) in
	if Float.trunc subscript <> subscript then
		raise (RuntimeError ("Cannot subscript with floating-point number", tk))
	else 
		let expr_ev = evaluate expr inp in
		match expr_ev with
		| Arr rez -> begin
			try Resizable.get rez (int_of_float subscript)
			with Invalid_argument _ -> raise (RuntimeError ("Accessing array out of bounds", tk))
		end
		| String rez -> begin
			try make_rez_string (Char.escaped (Resizable.get rez (int_of_float subscript)))
			with Invalid_argument _ -> raise (RuntimeError ("Accessing out of bounds", tk))
		end
		| _ -> raise (RuntimeError (("Value of type '"^nameof expr_ev^"' is not subscriptable"), tk))

and evaluate_arr exprs inp = 
	let arr = Resizable.make () in
	List.iter (fun expr -> Resizable.append arr (evaluate expr inp)) exprs;
	(Arr arr)

and evaluate_lambda exprs body = 
	let rec aux acc exprs =
		match exprs with
		| [] -> (acc)
		| x::xs -> begin 
			match x with
			| IdentExpr (tk, global) -> 
				if global then raise (RuntimeError ("invalid parameter", tk))
				else aux (tk.value::acc) xs
			| _ -> assert false;
		end
	in
	let params = List.rev (aux [] exprs) in
	Func (params, body)

and evaluate_funcall target arglist tk inp =
	let lambda = evaluate target inp in
	match lambda with
	| Func (params, body) -> evaluate_func arglist params body tk inp
	| NatFunc (paramc, _, func) -> evaluate_natfunc paramc arglist func tk inp
	| _ -> assert false;

and evaluate_func arglist params body tk inp =
	let param_len = List.length params in
	let arg_len   = List.length arglist in
	if param_len <> arg_len then
		raise (RuntimeError ("The number of arguments do not match the number of parameters", tk))
	else 
		let inp = 
		{inp with env=Environment.child_of inp.env; state={inp.state with call_depth=inp.state.call_depth+1; loop_depth=0}} in
			List.iter2 (fun arg param -> 
				let value = evaluate arg inp in
				Environment.add param (value, true) inp.env
			) arglist params;
		match body with
		| Block block -> begin 
			let inp = block_stmt block inp in
			match inp.state.return_expr with
			| Some expr -> evaluate expr inp
			| None -> Nil
		end 
		| _ -> assert false;

and evaluate_natfunc paramc arglist func tk inp =
	let arg_len   = List.length arglist in
	let param_len = paramc in
	if param_len <> 256 && param_len <> arg_len then
		raise (RuntimeError ("The number of arguments do not match the number of parameters", tk))
	else
		let val_list = List.map (fun expr -> evaluate expr inp) arglist in
		func val_list

and evaluate_binary expr1 expr2 op inp =
	let raise_error =  (fun ev1 ev2 -> raise (RuntimeError 
		("Cannot apply operator '"^Lexer.nameof op.typeof^"' to values of types ('"^nameof ev1^"' and '"^nameof ev2^"')", op))) in
	let ev_both = (fun expr1 expr2 -> (evaluate expr1 inp, evaluate expr2 inp)) in
	let simple_binary = (fun expr1 expr2 op -> let (ev1, ev2) = ev_both expr1 expr2 in
		match (ev1, ev2) with Float fl1, Float fl2 -> (op fl1 fl2) | _ -> raise_error ev1 ev2)
	in
	match op.typeof with
	| Plus -> begin
		let (ev1, ev2) = ev_both expr1 expr2 in
		match (ev1, ev2) with
		| Float fl1, Float fl2 -> Float (fl1 +. fl2)
		| String str1, String str2 -> String (Resizable.merge str1 str2)
		| Arr arr1, Arr arr2 -> Arr (Resizable.merge arr1 arr2)
		| _ -> raise_error ev1 ev2
		end
	| EqualEqual -> begin
		let (ev1, ev2) = (ev_both expr1 expr2) in 
		match (ev1, ev2) with
		| String str1, String str2 -> Bool (str1 = str2)
		| Float fl1, Float fl2 -> Bool (fl1 = fl2)
		| Bool b1, Bool b2 -> Bool (b1 = b2)
		| Arr arr1, Arr arr2 -> Bool (arr1.arr = arr2.arr) 
		| _ -> raise_error ev1 ev2 
	end 
	| ExcEqual -> begin
		let (ev1, ev2) = (ev_both expr1 expr2) in 
		match (ev1, ev2) with
		| String str1, String str2 -> Bool (str1 <> str2)
		| Float fl1, Float fl2 -> Bool (fl1 <> fl2)
		| Bool b1, Bool b2 -> Bool (b1 <> b2)
		| Arr arr1, Arr arr2 -> Bool (arr1 <> arr2) 
		| _ -> raise_error ev1 ev2
	end
	| Minus -> Float (simple_binary expr1 expr2 (-.))
	| Star -> Float (simple_binary expr1 expr2 ( *. ))
	| Slash -> Float (simple_binary expr1 expr2 (/.))
	| Modulo -> Float (simple_binary expr1 expr2 (fun a b -> a -. (b *. (floor (a /. b)))))
	| Greater -> Bool (simple_binary expr1 expr2 (>))
	| Lesser -> Bool (simple_binary expr1 expr2 (<))
	| GreatEqual -> Bool (simple_binary expr1 expr2 (>=))
	| LessEqual -> Bool (simple_binary expr1 expr2 (<=))
	| Ampersands -> Bool (truth(evaluate expr1 inp) && truth(evaluate expr2 inp))
	| Columns -> Bool (truth(evaluate expr1 inp) || truth(evaluate expr2 inp))
	| Equal | ConEqual -> assignment expr1 expr2 op inp
	| _ -> assert false

and evaluate_unary op expr inp =
	let raise_error = (fun ev -> raise (RuntimeError 
		("Cannot apply operator '"^Lexer.nameof op.typeof^"' to values of type '"^nameof ev^"'", op))) in
	let ev = evaluate expr inp in
	match op.typeof with
	| Exclamation -> Bool (not (truth ev))
	| Plus -> begin match ev with Float fl -> Float fl | _ -> raise_error ev end
	| Minus -> begin match ev with Float fl -> Float (fl*.(-1.)) | _ -> raise_error ev end
	| Tilde -> (Value.make_rez_string (nameof ev))
	| At -> (Value.make_rez_string (Value.stringify ev))
	| _ -> assert false;

and evaluate_ident tk global inp =
	let rec aux env =
		match Environment.find tk.value env with
		| None -> 
			begin
				let env = 
				try Environment.parent_of env 
				with Invalid_argument _ -> raise (RuntimeError ("Unbinded variable '"^tk.value^"' was referenced", tk)) 
				in aux env
			end
		| Some (value, _) -> value

	in let env = if global then 
		try Environment.parent_of inp.env
		with Invalid_argument _ ->
			raise (RuntimeError ("Global variable '"^tk.value^"' was referenced in global scope", tk))
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
	let (name, global) = match target with | IdentExpr (tk, global) -> (tk.value, global) | _ -> assert false; in
	let value = evaluate expr inp in
	let env = if global then
		try Environment.parent_of inp.env
		with Invalid_argument _ -> 
			raise (RuntimeError ("Global variable '"^token.value^"' was referenced in global scope", token))
		else inp.env in
	match (Environment.find name env) with
	| None -> Environment.add name (value, mut) env; value
	| Some (_, mut) -> 
		if not mut then raise (RuntimeError ("Cannot re-assign to a constant", token))
		else Environment.replace name (value, mut) env; value

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
		if inp.state.loop_depth = 0 then raise (RuntimeError ("Break statement ('**') outside of loop", tk))
		else {inp with state={inp.state with breaked = true}}

and continue_stmt tk inp =
		if inp.state.loop_depth = 0 then raise (RuntimeError ("Continue statement ('<<') outside of loop", tk))
		else {inp with state={inp.state with continued = true}}

and return_stmt expr tk inp =
		if inp.state.call_depth = 0 then raise (RuntimeError ("Return statement ('->') outside of function", tk))
		else {inp with state={inp.state with returned = true; return_expr = Some expr}}

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
	else
		match whenfalse with
		| None -> inp
		| Some block -> exec_stmt block inp

and loop_stmt cond stmt inp =
	let rec aux inp =
		let inp = {inp with state={inp.state with loop_depth=inp.state.loop_depth+1}} in
		if truth (evaluate cond inp) then
			let inp = exec_stmt stmt inp in
			if inp.state.breaked then inp
			else aux inp
		else inp
	in aux inp 

let run inp = ignore (exec_stmt (Block inp.raw) inp)