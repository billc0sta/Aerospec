open Parser
type value = 
| Float of float
| String of string

exception RuntimeError of string

type environment = {values: (string, (value * bool)) Hashtbl.t;}

let env_make () = {values=(Hashtbl.create 16)}

let env_find ident env = Hashtbl.find_opt env.values ident

let env_add ident value env = Hashtbl.add env.values ident value

let env_replace ident value env = Hashtbl.replace env.values ident value

type t = {env: environment; raw: statement list; length: int; pos: int}

let make raw = {env=(env_make ()); raw; length=List.length raw; pos=0}
let forward inp = {inp with raw=List.tl inp.raw; pos=inp.pos+1}
let peek inp = List.hd inp.raw

let truth = function
	| Float f -> f != 0.0
	| String str -> String.length str > 0

let bool_to_float b = if b then 1.0 else 0.0 

let rec evaluate expr inp =
	match expr with
	| FloatLit fl -> Float fl
	| StringLit str -> String str
	| Binary (expr1, op, expr2) -> evaluate_binary expr1 expr2 op inp
	| Unary (op, expr) -> evaluate_unary op expr inp 
	| Grouping expr -> evaluate expr inp
	| Ident name -> evaluate_ident name inp

and evaluate_binary expr1 expr2 op inp =
	let (ev1, ev2) = (evaluate expr1 inp, evaluate expr2 inp) in
	match (ev1, ev2) with
	| Float fl1, Float fl2 -> 
	begin
		match op.typeof with
		| Plus -> Float (fl1 +. fl2)
		| Minus -> Float (fl1 -. fl2)
		| Star -> Float (fl1 *. fl2)
		| Slash -> Float (fl1 /. fl2)
		| Modulo -> Float (mod_float fl1 fl2)
		| Greater -> Float (bool_to_float (fl1 > fl2))
		| Lesser -> Float (bool_to_float (fl1 < fl2))
		| Equal -> Float (bool_to_float (fl1 = fl2))
		| GreatEqual -> Float (bool_to_float (fl1 >= fl2)) 
		| LessEqual -> Float (bool_to_float (fl1 <= fl2))
		| Ampersands -> Float (bool_to_float ((truth (Float fl1)) && (truth (Float fl2)))) 
		| Columns  -> Float (bool_to_float ((truth ev1) || (truth ev2)))
		| _ -> assert false;
	end
	| String str1, String str2 ->
	begin
		match op.typeof with
		| Plus -> String (str1 ^ str2)
		| Ampersands -> Float (bool_to_float (truth ev1 && truth ev2))
		| Columns -> Float (bool_to_float (truth ev1 || truth ev2))
		| _ -> assert false;
	end
	| String _, Float _ | Float _, String _ ->
	begin
		match op.typeof with
		| Ampersands -> Float (bool_to_float (truth ev1 && truth ev2))
		| Columns -> Float (bool_to_float (truth ev1 || truth ev2))
		| _ -> raise (RuntimeError ("::Cannot apply operator '"^Lexer.nameof op.typeof^"' between types 'float' and 'string'"))
	end

and evaluate_unary op expr inp =
	let ev = evaluate expr inp in 
	match ev with
	| Float fl ->
	begin
		match op.typeof with
		| Exclamation -> Float (bool_to_float (truth ev))
		| Minus -> Float (fl*.(-1.0))
		| Plus -> Float (fl)
		| _ -> raise (RuntimeError ("::Operator '"^(Lexer.nameof op.typeof)^"' cannot be applied to value of type 'float'"))
	end
	| String _ ->
	begin
		match op.typeof with
		| Exclamation -> Float (bool_to_float (truth ev))
		| _ -> raise (RuntimeError ("::Operator '"^(Lexer.nameof op.typeof)^"' cannot be applied to value of type 'string'"))
	end

and evaluate_ident name inp =
	match env_find name inp.env with
	| None -> raise (RuntimeError ("::Unbinded variable '"^name^"' was referenced"))
	| Some (value, _) -> value

let print expr inp = 
	let valof = evaluate expr inp in
	match valof with
	| Float fl -> Format.print_float fl
	| String str -> print_string str

let assignment target stmt token inp =
	let rec aux target stmt token inp =
		let value = match stmt with
			| Exprstmt expr -> evaluate expr inp
			| Assignment (expr, tk, stmt) -> aux expr stmt tk inp
			| _ -> assert false;
		in

		let mut = match token.typeof with
		| Equal -> true
		| ConEqual -> false
		| _ -> assert false;
		in

		match target with
		| Ident name ->
		begin 
			match (env_find name inp.env) with
			| None -> env_add name (value, mut) inp.env; value
			| Some (_, mut) -> 
				if not mut then
					raise (RuntimeError "::Cannot re-assign to a constant")
				else
					env_replace name (value, mut) inp.env; value
		end
		| _ -> assert false; 
	in 
	ignore (aux target stmt token inp)

let rec run inp =
	if inp.pos = inp.length then () else
	let (stmt, inp) = (peek inp, forward inp) in
	match stmt with
	| Print expr -> print expr inp
	| Exprstmt expr -> ignore (evaluate expr inp)
	| Assignment (target, token, stmt) -> assignment target stmt token inp
	;
	run inp