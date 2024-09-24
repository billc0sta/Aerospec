open Parser
type value = 
| Float of float

exception RuntimeError of string * expr

type t = {raw: statement list; length: int; pos: int}

let make raw = {raw; length=List.length raw; pos=0}
let forward inp = {inp with raw=List.tl inp.raw; pos=inp.pos+1}
let peek inp = List.hd inp.raw
let chop inp = (peek inp, forward inp)

let truth = function
	| Float f -> f != 0.0

let bool_to_float b = if b then 1.0 else 0.0 

let rec evaluate = function
	| FloatLit fl -> Float fl
	| Binary (expr1, op, expr2) -> evaluate_binary expr1 expr2 op 
	| Unary (op, expr) -> evaluate_unary op expr
	| Grouping expr -> evaluate expr
	| _ -> raise (Failure "TODO: implement 'evaluate'")

and evaluate_binary expr1 expr2 op =
	let (ev1, ev2) = (evaluate expr1, evaluate expr2) in
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
		| And -> Float (bool_to_float ((truth (Float fl1)) && (truth (Float fl2)))) 
		| Or  -> Float (bool_to_float ((truth (Float fl1)) || (truth (Float fl2))))
		| _ -> raise (Invalid_argument "evaluate_binary op")
	end

and evaluate_unary op expr =
	let ev = evaluate expr in 
	match ev with
	| Float fl ->
	begin
		match op.typeof with
		| Not -> Float (bool_to_float (truth (Float fl)))
		| Minus -> Float (fl*.(-1.0))
		| Plus -> Float (fl)
		| _ -> raise (RuntimeError ("::operator '"^(Lexer.nameof op.typeof)^"' cannot be applied to value of type 'float'", expr))
	end

let print expr = 
	let valof = evaluate expr in
	match valof with
	| Float fl -> Format.print_float fl

let rec run inp =
	if inp.pos = inp.length then () else
	let (stmt, inp) = chop inp in
	match stmt with
	| Print expr -> print expr
	;
	run inp