open Parser
type value = 
| Float of float
| String of string
| Bool of bool
| Lambda of string list * statement
| Nil

exception RuntimeError of string * Lexer.token

module Environment = struct
	type t = {values: (string, (value * bool)) Hashtbl.t; parent: t option;}
	let make () = {values=(Hashtbl.create 16); parent=None}
	let find ident env = Hashtbl.find_opt env.values ident
	let add ident value env = Hashtbl.add env.values ident value
	let replace ident value env = Hashtbl.replace env.values ident value
	
	let child_of env =
		{(make ()) with parent=(Some env)}

	let parent_of env =
		match env.parent with
		| None -> raise (Invalid_argument "Environment.parent_of")
		| Some env -> env
end

let _ = Environment.parent_of 
type state = {return_expr: expr option; returned: bool; breaked: bool; continued: bool; call_depth: int; loop_depth: int}
type t = {env: Environment.t; raw: statement list; state: state}

let make raw = 
	{raw; env=(Environment.make ());
	state={return_expr=None; returned=false;
	breaked=false; continued=false;
	call_depth=0; loop_depth=0}}

let truth = function
	| Float f -> f <> 0.0
	| String str -> String.length str > 0
	| Bool b -> b
	| Lambda _ -> true 
	| Nil -> false

let nameof = function
	| String _ -> "string"
	| Float  _ -> "float"
	| Bool _ -> "bool"
	| Lambda _ -> "lambda"
	| Nil -> "nil"

let stringify_value = function
	| String str -> str
	| Float fl -> let str = string_of_float fl in
								if String.ends_with ~suffix:"." str
								then String.sub str 0 (String.length str - 1)
								else str 
	| Bool b -> if b then "true" else "false"
	| Lambda (params, _) -> 
		("<function ( "^
			(List.fold_left (fun acc param -> (acc ^ param ^ " ")) "" params)
			^")>")
	| Nil -> "nil"

let rec evaluate expr inp =
	match expr with
	| FloatLit fl -> Float fl
	| StringLit str -> String str
	| Binary (expr1, op, expr2) -> evaluate_binary expr1 expr2 op inp
	| Unary (op, expr) -> evaluate_unary op expr inp 
	| Grouping expr -> evaluate expr inp
	| IdentExpr tk -> evaluate_ident tk inp
	| IfExpr (cond, whentrue, whenfalse) -> evaluate_ifexpr cond whentrue whenfalse inp
	| FunCall (target, arglist, tk) -> evaluate_funcall target arglist tk inp
	| LambdaExpr (exprs, body, _) -> evaluate_lambda exprs body

and evaluate_lambda exprs body = 
	let rec aux acc exprs =
		match exprs with
		| [] -> (acc)
		| x::xs -> begin 
			match x with
			| IdentExpr tk -> aux (tk.value::acc) xs
			| _ -> assert false;
		end
	in
	let params = List.rev (aux [] exprs) in
	Lambda (params, body)

and evaluate_funcall target arglist tk inp =
	let lambda = evaluate target inp in
	match lambda with
	| Lambda (params, body) -> begin
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
	end
	| _ -> assert false;

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
		| String str1, String str2 -> String (str1 ^ str2)
		| _ -> raise_error ev1 ev2
		end
	| EqualEqual -> begin
		let (ev1, ev2) = (ev_both expr1 expr2) in 
		match (ev1, ev2) with
		| String str1, String str2 -> Bool (str1 = str2)
		| Float fl1, Float fl2 -> Bool (fl1 = fl2)
		| Bool b1, Bool b2 -> Bool (b1 = b2)
		| _ -> raise_error ev1 ev2 
	end 
	| ExcEqual -> begin
		let (ev1, ev2) = (ev_both expr1 expr2) in 
		match (ev1, ev2) with
		| String str1, String str2 -> Bool (str1 <> str2)
		| Float fl1, Float fl2 -> Bool (fl1 <> fl2)
		| Bool b1, Bool b2 -> Bool (b1 <> b2)
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
	| Tilde -> String (nameof ev) 
	| _ -> assert false;

and evaluate_ident tk inp =
	let rec aux env = 	 
		match Environment.find tk.value env with
		| None -> 
			begin
				match env.parent with
				| None -> raise (RuntimeError ("Unbinded variable '"^tk.value^"' was referenced", tk)) 
				| Some env -> aux env
			end
		| Some (value, _) -> value
	in aux inp.env

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
	let name = match target with | IdentExpr tk -> tk.value | _ -> assert false; in
	let value = evaluate expr inp in
	
	match (Environment.find name inp.env) with
	| None -> Environment.add name (value, mut) inp.env; value
	| Some (_, mut) -> 
		if not mut then raise (RuntimeError ("Cannot re-assign to a constant", token))
		else Environment.replace name (value, mut) inp.env; value

and print_stmt expr inp = 
	let valof = evaluate expr inp in
	print_string (stringify_value valof); inp

and exec_stmt stmt inp =
		match stmt with
	| Print expr -> print_stmt expr inp
	| Exprstmt expr -> ignore (evaluate expr inp); inp
	| IfStmt (cond, whentrue, whenfalse) -> if_stmt cond whentrue whenfalse inp
	| Block stmts -> block_stmt stmts inp
	| LoopStmt (cond, stmt) -> loop_stmt cond stmt inp
	| Break tk -> break_stmt tk inp
	| Continue tk -> continue_stmt tk inp
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