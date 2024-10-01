open Value

let print values =
	List.iter (fun value -> print_string (stringify value)) values;
	Nil

let input _ = 
	String (read_line ())

let clock _ = 
	Float (Sys.time ()) 
