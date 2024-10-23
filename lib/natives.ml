open Value

let print params =
  List.iter (fun value -> print_string (stringify value)) params;
  Nil

let input _ = 
  make_rez_string (read_line ())

let report_error message =
  raise (Invalid_argument ("Invalid Argument: "^message))

let clock _ = 
  Float (Sys.time ()) 

let truth params =
  let v = List.hd params in
  Bool (Value.truth v) 

let string_len params =
  let str = List.hd params in
  match str with
  | String (rez, _) -> Float (float_of_int (Resizable.len rez))
  | _ -> report_error ("String.len only accepts arguments of type 'string'")

let array_len params =
  let arr = List.hd params in
  match arr with
  | Arr (rez, _) -> Float (float_of_int (Resizable.len rez))
  | _ -> report_error ("Expected an array as the 'array' argument to Array.len")

let array_append params =
  let (arr, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let arr = match arr with
	| Arr (rez, locked) ->
       if locked
       then report_error ("Cannot apply Array.append to a locked array")
       else rez
	| _ -> report_error ("Expected an array as the 'array' argument to Array.append")
                           
  in
    List.iter (Resizable.append arr) params; 
    Nil

let string_insert params =
  let (str, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let str = match str with
    | String (rez, locked) ->
       if locked
       then report_error ("Cannot apply String.insert to a locked string")
       else rez
    | _ -> report_error ("Expected a string as the 'str' argument to String.insert")
  in
  let (elem, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let elem = match elem with
    | String (p, _) -> p
    | _ -> report_error ("Expected a string as the 'substr' argument to String.insert")
  in
  let index = match List.hd params with
	| Float fl -> if Float.trunc fl <> fl
                  then report_error ("String.insert cannot be applied with a floating-point number as 'index'")
                  else int_of_float fl
	| _ -> report_error ("Expected a number as the 'index' argument to String.insert")
  in
  try 
    Resizable.insert_rez str elem index; Nil
  with Invalid_argument _ -> report_error ("'index' out of bounds - String.insert")

let array_insert params =
  let (arr, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let arr = match arr with
    | Arr (rez, locked) ->
       if locked
       then report_error ("Cannot apply Array.insert to a locked array")
       else rez
    | _ -> report_error ("Expected an array as the 'array' argument to Array.insert")
  in
  let (elem, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let index = match List.hd params with
	| Float fl -> if Float.trunc fl <> fl
                  then report_error ("Array.insert cannot be applied with a floating-point number as 'index'")
                  else int_of_float fl
	| _ -> report_error ("Expected an array as the 'array' argument to Array.insert")
  in
  try 
    Resizable.insert arr index elem; Nil
  with Invalid_argument _ -> report_error ("'index' out of bounds - String.insert")

let string_extend params =
  let (str1, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let str1 = match str1 with
    | String (rez, locked) ->
       if locked
       then report_error ("Cannot apply String.extend to a locked string")
       else rez
  | _ -> report_error ("Expected a string as the 'str' argument to String.extend")
  in
  List.iter (fun str2 ->
      match str2 with
      | String (str2, _) -> Resizable.extend str1 str2
      | _ -> report_error ("Expected strings as the remaining arguments to String.extend")
    ) params;
  Nil

let array_extend params =
  let (arr1, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let arr1 = match arr1 with
    | Arr (rez, locked) ->
       if locked
       then report_error ("Cannot apply Array.extend to a locked array")
       else rez
  | _ -> report_error ("Expected an array as the 'array' argument to Array.extend")
  in
  List.iter (fun arr2 ->
      match arr2 with
      | Arr (arr2, _) -> Resizable.extend arr1 arr2
      | _ -> report_error ("Expected arrays as the remaining arguments to Array.extend")
    ) params;
  Nil

let string_merge params =
  let init = Resizable.make () in
  let rez = List.fold_left (fun acc str2 ->
      match str2 with
      | String (str2, _) -> (Resizable.merge acc str2)
      | _ -> report_error ("String.merge only accepts arguments of type 'string'")
    ) init params in
  String(rez, false)
  
let array_merge params =
  let init = Resizable.make () in
  let rez = List.fold_left (fun acc arr2 ->
      match arr2 with
      | Arr (arr2, _) -> (Resizable.merge acc arr2)
      | _ -> report_error ("Array.merge only accepts arguments of type 'array'")
    ) init params in
  Arr (rez, false)

let string_index params =
  let (str1, str2) = (match params with x::y::_ -> (x, y) | _ -> assert false;) in
  let (str1, str2) = match (str1, str2) with
  | String (rez1, _), String (rez2, _) -> (rez1, rez2) 
  | _ -> report_error ("String.index only accepts arguments of type 'string'")
  in
  Float (float_of_int (Resizable.index_rez str1 str2))
  
let array_index params =
  let (arr, elem) = (match params with x::y::_ -> (x, y) | _ -> assert false;) in
  let arr = match arr with
    | Arr (rez, _) -> rez
    | _ -> report_error ("Expected an array as the 'array' argument to Array.index")
  in
  Float (float_of_int (Resizable.index arr elem))

let string_pop params =
  let (str, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let str = match str with
    | String (rez, locked) ->
       if locked
       then report_error ("Cannot apply String.pop to a locked string")
       else rez
    | _ -> report_error ("Expected a string as the 'str' argument to String.pop")
  in
  List.iter (fun index ->
      let index = match index with
        | Float fl ->
           if Float.trunc fl <> fl
           then report_error ("Cannot subscript with floating-point number - String.pop") 
	       else int_of_float fl
        | _ -> report_error ("Expected numbers as the remaining arguments to String.pop")
      in
      try 
        Resizable.pop str index
      with Invalid_argument _ -> report_error ("'indices...' out of bounds - String.pop")
    ) params; Nil
                                 
let array_pop params =
  let (arr, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let arr = match arr with
    | Arr (rez, locked) ->
       if locked
       then report_error ("Cannot apply Array.pop to a locked array")
       else rez
    | _ -> report_error ("Expected an array as the 'array' argument to Array.pop")
  in
  List.iter (fun index ->
      let index = match index with
        | Float fl ->
           if Float.trunc fl <> fl
           then report_error ("Cannot subscript with floating-point number - Array.pop") 
	       else int_of_float fl
        | _ -> report_error ("Expected numbers as the remaining arguments to Array.pop")
      in
      try 
        Resizable.pop arr index
      with Invalid_argument _ -> report_error ("'indices...' out of bounds - Array.pop")
    ) params;
  Nil

let string_remove params =
  let (str, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let str = match str with
    | String (rez, locked) ->
       if locked
       then report_error ("Cannot apply String.remove to a locked string")
       else rez
    | _ -> report_error ("String.remove only accepts arguments of type 'string'")
  in
  List.iter (fun str2 ->
      let str2 = match str2 with
        | String (rez, _) -> rez
        | _ -> report_error ("String.remove only accepts arguments of type 'string'")
      in
      Resizable.remove_rez str str2
    ) params;
  Nil

let array_remove params =
  let (arr, params) = (match params with x::xs -> (x, xs) | _ -> assert false;) in
  let arr = match arr with
    | Arr (rez, locked) ->
       if locked
       then report_error ("Cannot apply Array.remove to a locked array")
       else rez
    | _ -> report_error ("Expected an array as the 'array' argument to Array.remove")
  in
  List.iter (Resizable.remove arr) params;
  Nil

let string_clear params =
  let str = List.hd params in
  let str = match str with
    | String (rez, locked) ->
       if locked
       then report_error ("Cannot apply String.clear to a locked string")
       else rez
    | _ -> report_error ("String.clear only accepts arguments of type 'string'")
  in
  Resizable.clear str;
  Nil

let array_clear params =
  let arr = List.hd params in
  let arr = match arr with
    | Arr (rez, locked) ->
       if locked
       then report_error ("Cannot apply Array.clear to a locked array")
       else rez
    | _ -> report_error ("Expected an array as the 'array' argument to Array.clear")
  in
  Resizable.clear arr;
  Nil

let string_count params =
  let (str1, str2) = (match params with x::y::_ -> (x, y) | _ -> assert false;) in
  let (str1, str2) = match (str1, str2) with
    | (String (rez1, _), String (rez2, _)) -> (rez1, rez2)
    | _ -> report_error ("String.count only accepts arguments of type 'string'")
  in
  let lst1 = Resizable.len str1  in
  let lst2 = Resizable.len str2  in
  if lst1 = 0 || lst2 = 0
  then Float (0.0)
  else 
  let rec aux p1 p2 count =
    let (p2, count) = if p2 = lst2 then (0, count+1) else (p2, count) in
    if p1 = lst1
    then count
    else match (Resizable.get str1 p1, Resizable.get str2 p2) with
         | (c1, c2) when c1 = c2 -> aux (p1+1) (p2+1) count
         | _ -> aux (p1+1) 0 count
  in Float (float_of_int (aux 0 0 0))

let array_count params =
  let (arr, elem) = (match params with x::y::_ -> (x, y) | _ -> assert false;) in
  let arr = match arr with
    | Arr(rez, _) -> rez
    | _ -> report_error ("Expected an array as the 'array' argument to Array.count")
  in
  Float (float_of_int (Resizable.count arr elem))

let copy params =
  let value = List.hd params in
  Value.copy_value value 

let fields params =
  let obj = List.hd params in
  let env = match obj with
	| Object (env, _) -> env
	| _ -> report_error ("Expected an object as the 'object' argument to Object.fields")
  in
  let rez = Resizable.make () in
  Hashtbl.iter
	(fun k v -> 
	  let rez2 = Resizable.make () in
	  Resizable.append rez2 (make_rez_string k);
	  Resizable.append rez2 (fst v);
	  Resizable.append rez2 (Bool (snd v));
	  Resizable.append rez (Arr(rez2, false))
	) env.values;
  Arr (rez, false)

let repr params = 
  let value = List.hd params in
  (Value.make_rez_string (Value.stringify value))

let module_IO () =
  let env = Environment.make () in
  Environment.add "print" (NatFunc (256+1, ["params..."], print), false) env;
  Environment.add "input" (NatFunc (0, [], input), false) env;
  Object(env, true)

let module_time () =
  let env = Environment.make () in
  Environment.add "clock" (NatFunc (0, [], clock), false) env;
  Object(env, true)

let module_float () =
  let env = Environment.make () in
  Environment.add "nan" (Float Float.nan, false) env;
  Environment.add "inf" (Float Float.infinity, false) env;
  Object(env, true)

let module_string () =
  let env = Environment.make () in
  Environment.add "len" (NatFunc (1, ["str"], string_len), false) env;
  Environment.add "insert" (NatFunc (3, ["str"; "substr"; "index"], string_insert), false) env;
  Environment.add "extend" (NatFunc (256+2, ["str"; "substrs..."], string_extend), false) env;
  Environment.add "merge" (NatFunc (256+1, ["substrs..."], string_merge), false) env;
  Environment.add "index" (NatFunc (2, ["str"; "substr"], string_index), false) env;
  Environment.add "pop" (NatFunc (256+2, ["str"; "indices..."], string_pop), false) env;
  Environment.add "remove" (NatFunc (256+2, ["str"; "substrs..."], string_remove), false) env;
  Environment.add "clear" (NatFunc (1, ["str"], string_clear), false) env;
  Environment.add "count" (NatFunc (2, ["str"; "substr"], string_count), false) env;
  Environment.add "repr" (NatFunc (1, ["value"], repr), false) env;
  Object(env, true)

let module_array () =
  let env = Environment.make () in
  Environment.add "len" (NatFunc (1, ["array"], array_len), false) env;
  Environment.add "append" (NatFunc (256+2, ["array"; "elements..."], array_append), false) env;
  Environment.add "insert" (NatFunc (3, ["array"; "element"; "index"], array_insert), false) env;
  Environment.add "extend" (NatFunc (256+2, ["array"; "array..."], array_extend), false) env;
  Environment.add "merge" (NatFunc (256+1, ["array..."], array_merge), false) env;
  Environment.add "index" (NatFunc (2, ["array"; "element"], array_index), false) env;
  Environment.add "pop" (NatFunc (256+2, ["array"; "indices..."], array_pop), false) env;
  Environment.add "remove" (NatFunc (256+2, ["array"; "elements..."], array_remove), false) env;
  Environment.add "clear" (NatFunc (1, ["array"], array_clear), false) env;
  Environment.add "count" (NatFunc (2, ["array"; "element"], array_count), false) env;
  Object(env, true)

let module_object () =
  let env = Environment.make () in
  Environment.add "fields" (NatFunc (1, ["object"], fields), false) env;
  Object(env, true)

let module_value () =
  let env = Environment.make () in
  Environment.add "copy" (NatFunc (1, ["value"], copy), false) env;
  Object(env, true)

let module_bool () =
  let env = Environment.make () in
  Environment.add "true" (Bool true, false) env;
  Environment.add "false" (Bool false, false) env;
  Environment.add "truth" (NatFunc (1, ["value"], truth), false) env;
  Object(env, true)
