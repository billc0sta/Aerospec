open Upl

let rec print_lexed l = 
	match l with
	| [] -> ()
	| x::xs -> Lexer.(Printf.printf "{value=\"%s\"; typeof=\"%s\"; pos=%d; line=%d}\n" x.value (nameof x.typeof) x.pos x.line); print_lexed xs

let print_error from message line pos ?path program =

	let rec get_line start_pos end_pos =
	  let nstart_pos = if start_pos - 1 < 0 || program.[start_pos-1] = '\n' then start_pos else start_pos - 1 in
	  let nend_pos = if end_pos + 1 >= String.length program || program.[end_pos+1] = '\n' then end_pos else end_pos + 1 in
	  if nstart_pos = start_pos && nend_pos = end_pos then
	    (nstart_pos, nend_pos)
	  else
	    get_line nstart_pos nend_pos
	in 

	let lineof = 
		let (start_pos, end_pos) = get_line pos pos 
		in String.sub program (start_pos) (end_pos - start_pos)
	in
	print_string ("\n::"^from^"\n");
	match path with | None -> () | Some path -> print_string ("  at file: "^path^"\n");
	print_string ("  at line: "^string_of_int (line)^"\n");
	print_string ("  here --\" "^lineof^" \"-- \n");
	print_string ("  "^message^".\n---------------------------")

let read_whole_file filename =
  let ch = open_in_bin filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let execute program path debugging =
	let lexer = Lexer.make program path in
	try 
		let lexed = Lexer.lex lexer in
		if debugging then print_lexed lexed;
	let parser = Parser.make lexed path in
	try
		let parsed = Parser.parse parser in
		if debugging then Parser._print_parsed parsed;
	let intp = Interpreter.make parsed in
	try 
		Interpreter.run intp
	with
	| Interpreter.RuntimeError (message, tk) ->
		print_error "RuntimeError" message tk.line tk.pos program

	with
	| Parser.ParseErrors l ->
		List.iter (fun err ->
			match err with
			| Parser.ParseError (message, path, line, pos) ->
				print_error "Syntax Error" message line pos ~path program
			| _ -> assert false;
		) l

	with 
	| Lexer.LexErrors l ->
		List.iter (fun err ->
			match err with
			| Lexer.LexError (message, path, tk) ->
				print_error "Syntax Error" message tk.line tk.pos ~path program
			| _ -> assert false;
		) l

let () = if Array.length Sys.argv < 2 then
  print_string "Aerospec: No program file was provided\n"
else
	try 
	let file_path = Sys.argv.(1) in
  let program   = read_whole_file file_path in
  execute program file_path false
	with Sys_error _ -> print_string "Aerospec: No such file"


(* TODO-list:
1. add ranging
2. add builders
3. add sequence native functions
4. add objects
5. add importing
*)