open Parser
type t = 
| Float of float
| String of string
| Bool of bool
| Func of string list * statement
| NatFunc of int * string list * (t list -> t)
| ArrExpr of value Resizable.t
| Nil

let truth = function
	| Float f -> f <> 0.0
	| String str -> String.length str > 0
	| Bool b -> b
	| Func _ | NatFunc _ -> true 
	| Nil -> false

let nameof = function
	| String _ -> "string"
	| Float  _ -> "float"
	| Bool _ -> "bool"
	| Func _ -> "function"
	| NatFunc _ -> "native function"
	| Nil -> "nil"

let stringify = function
	| String str -> str
	| Float fl -> let str = string_of_float fl in
								if String.ends_with ~suffix:"." str
								then String.sub str 0 (String.length str - 1)
								else str 
	| Bool b -> if b then "true" else "false"
	| Func (params, _) -> 
		("<function ( "^
			(List.fold_left (fun acc param -> (acc ^ param ^ " ")) "" params)
			^")>")
	| Nil -> "nil"
	| NatFunc (_, params, _) -> 
		("<native function ( "^
			(List.fold_left (fun acc param -> (acc ^ param ^ " ")) "" params)
			^")>")