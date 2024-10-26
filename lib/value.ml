open Parser
type t = 
  | Float of float
  | String of char Resizable.t * bool 
  | Bool of bool
  | Func of (string, (t * bool)) Environment.t * string list * statement
  | NatFunc of int * string list * (t list -> t)
  | Arr of t Resizable.t * bool
  | Object of (string, (t * bool)) Environment.t * bool
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
  (String (rez, false))

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
  | Object (obj, _) -> stringify_object obj

and stringify_object obj =
  let _ = obj in
  "<object>" (* modify later *)

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
  | Object (env, locked) -> copy_object env locked
  | Arr (rez, locked) -> copy_array rez locked 
  | String (rez, locked) -> String (Resizable.copy rez, locked)

and copy_object env locked =
  let new_obj = Hashtbl.create (Hashtbl.length env.values) in
  let new_obj = ({values=new_obj; parent=env.parent}: (string, (t * bool)) Environment.t) in
  Hashtbl.iter (fun k v -> 
	  let copied = match fst v with
		| Func (_, params, stmts) -> (Func(new_obj, params, stmts), snd v)
		| value -> (copy_value value, snd v)
	  in Hashtbl.add new_obj.values k copied
	) env.values;
  Object (new_obj, locked)

and copy_array arr locked =
  let new_arr = Resizable.copy arr in
  for i = 0 to Resizable.len arr - 1 do
	new_arr.arr.(i) <- copy_value arr.arr.(i)
  done;
  Arr (new_arr, locked)

let shallow_lock value =
  match value with
  | String (rez, _) -> String (rez, true)
  | Arr (rez, _) -> Arr (rez, true)
  | Object (obj, _) -> Object (obj, true)
  | _ -> value

let rec deep_lock value =
  match value with
  | String (rez, _) -> String (rez, true)
  | Arr (rez, _) -> 
	 if Resizable.len rez = 0 then
	   Arr (rez, true)
	 else 
	   let new_rez = Resizable.make () in
	   Resizable.resize new_rez rez.size rez.arr.(0);
	   for i = 0 to rez.size - 1 do
		 new_rez.arr.(i) <- deep_lock rez.arr.(i)
	   done;
	   new_rez.size <- rez.size;
	   Arr (new_rez, true)
  | Object (obj, _) -> begin
	  let new_obj = Environment.make () in
	  Hashtbl.iter (fun k v ->
          let v = match deep_lock (fst v) with
            | Func (_, params, stmts) -> Func (new_obj, params, stmts)
            | v -> v
          in
		  Hashtbl.add new_obj.values k (v, false)
		) obj.values; Object (new_obj, true)
	end
  | _ -> value

let rec equal value1 value2 =
  let rec arr_eq arr1 arr2 i =
    if i = Resizable.len arr1 then true
    else 
      equal (Resizable.get arr1 i) (Resizable.get arr2 i) && arr_eq arr1 arr2 (i+1)
  in
  match (value1, value2) with
  | String (str1, _), String (str2, _) -> Resizable.equal str1 str2
  | Float fl1, Float fl2 -> fl1 = fl2
  | Bool b1, Bool b2 -> b1 = b2
  | Arr (arr1, _), Arr (arr2, _) -> (Resizable.len arr1) = (Resizable.len arr2) && arr_eq arr1 arr2 0 
  | Nil, Nil -> true
  | _ -> false 
