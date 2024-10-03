open Value

let print values =
	List.iter (fun value -> print_string (stringify value)) values;
	Nil

let input _ = 
	make_rez_string (read_line ())

let clock _ = 
	Float (Sys.time ()) 
