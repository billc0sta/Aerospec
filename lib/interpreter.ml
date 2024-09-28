open Parser
type value = 
| Float of float
| String of string
| Bool of bool

exception RuntimeError of string * Lexer.token

type environment = {values: (string, (value * bool)) Hashtbl.t; parent: environment option;}

let env_make () = {values=(Hashtbl.create 16); parent=None}

let env_find ident env = Hashtbl.find_opt env.values ident

let env_add ident value env = Hashtbl.add env.values ident value

let env_replace ident value env = Hashtbl.replace env.values ident value

type t = {env: environment; raw: statement list;}

let make raw = {env=(env_make ()); raw}

let enter_scope inp =
	let new_env = {(env_make ()) with parent=(Some inp.env)}
	in {inp with env=new_env}

let exit_scope inp =
	match inp.env.parent with
	| None -> assert false;
	| Some env -> {inp with env}

let truth = function
	| Float f -> f <> 0.0
	| String str -> String.length str > 0
	| Bool b -> b 

let nameof value =
	match value with
	| String _ -> "string"
	| Float  _ -> "float"
	| Bool _ -> "bool"

let rec evaluate expr inp =
	match expr with
	| FloatLit fl -> Float fl
	| StringLit str -> String str
	| Binary (expr1, op, expr2) -> evaluate_binary expr1 expr2 op inp
	| Unary (op, expr) -> evaluate_unary op expr inp 
	| Grouping expr -> evaluate expr inp
	| IdentExpr tk -> evaluate_ident tk inp
	| IfExpr (cond, whentrue, whenfalse) -> evaluate_ifexpr cond whentrue whenfalse inp

and evaluate_binary expr1 expr2 op inp =
	let raise_error =  (fun ev1 ev2 -> raise (RuntimeError 
		("::Cannot apply operator '"^Lexer.nameof op.typeof^"' to values of types ('"^nameof ev1^"' and '"^nameof ev2^"')", op))) in
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
		("::Cannot apply operator '"^Lexer.nameof op.typeof^"' to values of type '"^nameof ev^"'", op))) in
	let ev = evaluate expr inp in
	match op.typeof with
	| Exclamation -> Bool (not (truth ev))
	| Plus -> begin match ev with Float fl -> Float fl | _ -> raise_error ev end
	| Minus -> begin match ev with Float fl -> Float (fl*.(-1.)) | _ -> raise_error ev end
	| _ -> assert false;

and evaluate_ident tk inp =
	let rec aux env = 	 
		match env_find tk.value env with
		| None -> 
			begin
				match env.parent with
				| None -> raise (RuntimeError ("::Unbinded variable '"^tk.value^"' was referenced", tk)) 
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
	
	match (env_find name inp.env) with
	| None -> env_add name (value, mut) inp.env; value
	| Some (_, mut) -> 
		if not mut then raise (RuntimeError ("::Cannot re-assign to a constant", token))
		else env_replace name (value, mut) inp.env; value

let print_stmt expr inp = 
	let valof = evaluate expr inp in
	let () = match valof with
	| Float fl -> print_float fl
	| String str -> print_string str
	| Bool b -> print_string (if b then "true" else "false") in
	inp

let rec exec_stmt stmt inp =
	match stmt with
	| Print expr -> print_stmt expr inp
	| Exprstmt expr -> ignore (evaluate expr inp); inp
	| IfStmt (cond, whentrue, whenfalse) -> if_stmt cond whentrue whenfalse inp
	| Block stmts -> block_stmt stmts inp
	| LoopStmt (cond, stmt) -> loop_stmt cond stmt inp
	| Break | Continue -> assert false; (*Break and Continue are checked at analyzing-time*)

and block_stmt stmts inp =
	let rec aux stmts inp =
		match stmts with
		| [] -> inp
		| x::xs -> let inp = exec_stmt x inp in aux xs inp
	in aux stmts inp

and if_stmt cond whentrue whenfalse inp =
	if truth (evaluate cond inp) then exec_stmt whentrue inp 
	else
		match whenfalse with
		| None -> inp
		| Some block -> exec_stmt block inp

and loop_stmt cond stmt inp =
	let rec execute_body block inp =
		match block with
		| [] -> (false, inp)
		| x::xs -> begin
			match x with 
			| Break -> (false, inp)
			| Continue -> (true, inp)
			| _ ->  let inp = exec_stmt x inp in execute_body xs inp
		end
	in
	let rec aux inp =
		if (truth (evaluate cond inp)) then
			let (continue, inp) = match stmt with
				| Block block -> execute_body block inp
				| _ -> execute_body [stmt] inp
			in if continue then aux inp else inp
		else inp
	in aux inp

let run inp = ignore (block_stmt inp.raw inp)

let _ = (enter_scope, exit_scope)