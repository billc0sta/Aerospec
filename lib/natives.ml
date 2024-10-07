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
	| _ -> raise (Invalid_argument "Non-sequence value was passed to len")

let append params = 
	let (seq, params) = (List.hd params, List.tl params) in
	match seq with
	| String _ | Arr _ -> ()
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to append");
	;
	List.iter (
	fun param -> 
	match param with 
	| String p -> begin 
		match seq with 
		| String r -> Resizable.iter (fun c -> Resizable.append r c) p 
		| Arr r -> Resizable.append r param
		| _ -> assert false;
		end 
	| _ -> begin 
		match seq with 
		| String _ -> raise (Invalid_argument "Cannot append non-string value to a string")
		| Arr r -> Resizable.append r param
		| _ -> assert false;
		end
	) params; 
	Nil

let insert params =
	let (seq, params) = (List.hd params, List.tl params) in
	match seq with
	| String _ | Arr _ -> ()
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to insert");
	;
	let (index, params) = (List.hd params, List.tl params) in
	let index = match index with
	| Float fl -> if Float.trunc fl <> fl then raise (Invalid_argument "Cannot subscript with floating-point number") else int_of_float fl
	| _ -> raise (Invalid_argument "Non-float value was passed as a second parameter to insert")
	in
	let elem = List.hd params in
	let () = try 
		match seq with
		| String rez -> begin 
			match elem with
			| String p -> Resizable.iter (fun c -> Resizable.append rez c) p
			| _ -> raise (Invalid_argument "Cannot insert non-string value to a string")
		end
		| Arr rez -> Resizable.insert rez index elem
		| _ -> assert false;
	with Invalid_argument _ -> raise (Invalid_argument ("Accessing "^nameof seq^" out of bounds"))
	in
	Nil

let extend params =
	let (seq1, params) = (List.hd params, List.tl params) in
	List.iter (fun seq2 ->
		match (seq1, seq2) with
		| (String r1, String r2) -> Resizable.extend r1 r2
		| (Arr r1, Arr r2) -> Resizable.extend r1 r2
		| _ -> raise (Invalid_argument ("Cannot extend value of type '"^nameof seq1^"' with value of type '"^nameof seq2^"'"))
	) params;
	Nil

let merge params = 
	let (seq1, params) = (List.hd params, List.tl params) in

	List.fold_left (fun seq1 seq2 -> 
		match (seq1, seq2) with
		| (String r1, String r2) -> String (Resizable.merge r1 r2)
		| (Arr r1, Arr r2) -> Arr (Resizable.merge r1 r2)
		| _ -> raise (Invalid_argument ("Cannot merge value of type '"^nameof seq1^"' with value of type '"^nameof seq2^"'"));
	) seq1 params

let index params =
	let (seq, params) = (List.hd params, List.tl params) in
	let elem = List.hd params in
	match seq with
	| String rez -> begin 
		match elem with
		| String chr -> if Resizable.len chr <> 1 
			then raise (Invalid_argument "Invalid element character count was passed to index") 
			else Float (float_of_int (Resizable.index rez (Resizable.get chr 0)))
		| _ -> raise (Invalid_argument "Cannot index non-string value from string")
	end
	| Arr rez -> Float (float_of_int (Resizable.index rez elem))
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to index")

let pop params = 
	let (seq, params) = (List.hd params, List.tl params) in
	let () = match seq with
	| String _ | Arr _ -> ()
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to index")
	in

	List.iter (fun index ->
		let index = match index with
			| Float fl -> if Float.trunc fl <> fl then 
				raise (Invalid_argument "Cannot subscript with floating-point number") 
				else int_of_float fl 
			| _ -> raise (Invalid_argument "Cannot subscript with non-float value")
		in
		try
			match seq with
			| String rez -> Resizable.pop rez index
			| Arr rez -> Resizable.pop rez index
			| _ -> assert false;
		with Invalid_argument _ -> raise (Invalid_argument ("Accessing "^nameof seq^" out of bounds"))
	) params; 
	Nil

let remove params =
	let (seq, params) = (List.hd params, List.tl params) in
	let () = match seq with
	| String _ | Arr _ -> ()
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to index")
	in
	List.iter (fun elem -> 
		match seq with
		| String rez -> begin
			match elem with
			| String chr -> if Resizable.len chr <> 1 
				then raise (Invalid_argument "Invalid element character count was passed to remove") 
				else Resizable.remove rez (Resizable.get chr 0)
			| _ -> raise (Invalid_argument "Cannot remove non-string value from string")
		end
		| Arr rez -> Resizable.remove rez elem
		| _ -> assert false;
	) params; 
	Nil

let clear params =	
	let seq = List.hd params in
	let () = match seq with
	| String rez -> Resizable.clear rez
	| Arr rez -> Resizable.clear rez
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to clear");
	in 
	Nil

let count params =
	let (seq, params) = (List.hd params, List.tl params) in
	let elem = List.hd params in
	match seq with
	| String rez -> begin
		match elem with
		| String chr -> if Resizable.len chr <> 1 
			then raise (Invalid_argument "Invalid element character count was passed to count") 
			else Float (float_of_int (Resizable.count rez (Resizable.get chr 0)))
		| _ -> raise (Invalid_argument "Cannot count non-string value in string")
	end
	| Arr rez -> Float (float_of_int (Resizable.count rez elem))
	| _ -> raise (Invalid_argument "Non-sequence value was passed as a first parameter to count");