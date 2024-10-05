open Value

let print params =
	List.iter (fun value -> print_string (stringify value)) params;
	Nil

let input _ = 
	make_rez_string (read_line ())

let clock _ = 
	Float (Sys.time ()) 

let len params =
	let seq = List.hd params in
	match seq with
	| String rez -> Float (float_of_int (Resizable.len rez)) 
	| Arr rez -> Float (float_of_int (Resizable.len rez))
	| _ -> raise (Invalid_argument "non-sequence value was passed to len()")