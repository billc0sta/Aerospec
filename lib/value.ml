open Parser
type t = 
| Float of float
| String of char Resizable.t 
| Bool of bool
| Func of (string, (t * bool)) Environment.t * string list * statement
| NatFunc of int * string list * (t list -> t)
| Arr of t Resizable.t
| Nil

let truth = function
	| Float f -> f <> 0.0
	| String str -> Resizable.len str > 0
	| Bool b -> b
	| Func _ | NatFunc _ -> true
	| Arr arr -> Resizable.len arr > 0 
	| Nil -> false

let nameof = function
	| String _ -> "string"
	| Float  _ -> "float"
	| Bool _ -> "bool"
	| Func _ -> "function"
	| NatFunc _ -> "native function"
	| Arr _ -> "array"
	| Nil -> "nil"

let make_rez_string str = 
	let rez = Resizable.make () in
	String.iter (fun c -> Resizable.append rez c) str;
	(String rez)

let rec stringify = function
	| String str -> stringify_str str
	| Float fl -> let str = string_of_float fl in
								if String.ends_with ~suffix:"." str
								then String.sub str 0 (String.length str - 1)
								else str 
	| Bool b -> if b then "true" else "false"
	| Func (_, params, _) -> 
		("<function ( "^
			(List.fold_left (fun acc param -> (acc ^ param ^ " ")) "" params)
			^")>")
	| Nil -> "nil"
	| NatFunc (_, params, _) -> 
		("<native ( "^
			(List.fold_left (fun acc param -> (acc ^ param ^ " ")) "" params)
			^")>")
	| Arr arr -> 
		stringify_arr arr

and stringify_str str =
	String.init (Resizable.len str) (fun i -> (Resizable.get str i))

and stringify_arr arr =
	let builder = Resizable.make () in
	Resizable.append builder '[';
	for i=0 to (Resizable.len arr - 1) do
		let strval = stringify (Resizable.get arr i) in
		String.iter (fun c -> Resizable.append builder c) strval;
		if i < ((Resizable.len arr) - 1) then 
			(Resizable.append builder ','; 
			Resizable.append builder ' ');
	done;
	Resizable.append builder ']';
	stringify_str builder