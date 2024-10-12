open Parser
type t = 
| Float of float
| String of char Resizable.t * bool 
| Bool of bool
| Func of (string, (t * bool)) Environment.t * string list * statement
| NatFunc of int * string list * (t list -> t)
| Arr of t Resizable.t * bool
| Object of (string, (t * bool)) Environment.t 
| Nil

let truth = function
	| Float f -> f <> 0.0
	| String (str, _) -> Resizable.len str > 0
	| Arr (arr, _) -> Resizable.len arr > 0 
	| Bool b -> b
	| Func _ | NatFunc _ | Object _ -> true
	| Nil -> false

let nameof = function
	| String _ -> "string"
	| Float  _ -> "float"
	| Bool _ -> "bool"
	| Func _ -> "function"
	| NatFunc _ -> "native function"
	| Arr _ -> "array"
	| Object _ -> "object"
	| Nil -> "nil"

let make_rez_string str = 
	let rez = Resizable.make () in
	String.iter (fun c -> Resizable.append rez c) str;
	(String (rez, true))

let rec stringify = function
	| String (str, _) -> stringify_str str
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
	| Arr (arr, _) -> 
		stringify_arr arr
	| Object obj -> stringify_object obj

and stringify_object obj =
	let _ = obj in
	"object" (* modify later *)

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

let rec copy_value v =
	match v with 
	| Float _ | Bool _ | Func _ | NatFunc _ | Nil -> v
	| Object env -> copy_object env
	| Arr (rez, _) -> copy_array rez 
	| String (rez, _) -> String (Resizable.copy rez, true)

and copy_object (obj:(string, (t * bool)) Environment.t) =
	let new_obj = Hashtbl.create (Hashtbl.length obj.values) in
	let new_obj = ({values=new_obj; parent=obj.parent}: (string, (t * bool)) Environment.t) in
	Hashtbl.iter (fun k v -> 
		let copied = match fst v with
		| Func (_, params, stmts) -> (Func(new_obj, params, stmts), snd v)
		| value -> (copy_value value, snd v)
	in Hashtbl.add new_obj.values k copied
	) obj.values;
	Object (new_obj)

and copy_array arr =
	let new_arr = Resizable.copy arr in
	for i = 0 to Resizable.len arr - 1 do
		new_arr.arr.(i) <- copy_value arr.arr.(i)
	done;
	Arr (new_arr, true)

let rec constant_value value =
	match value with
	| String (rez, _) -> String (rez, false)
	| Arr (rez, _) -> Arr (rez, false)
	| Object obj -> begin
		Hashtbl.iter (fun k v ->
			Hashtbl.replace obj.values k ((constant_value (fst v)), false)
		) obj.values; Object (obj)
	end
	| _ -> value