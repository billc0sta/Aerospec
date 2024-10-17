let print_error from message ?path ?lineof linenum =

	print_string ("\n::"^from^"\n");
	(match path with | None -> () | Some path -> print_string ("  at file: "^path^"\n"));
	print_string ("  at line: "^string_of_int (linenum)^"\n");
	(match lineof with | None -> () | Some line -> print_string ("  here --\" "^line^" \"-- \n"));
	print_string ("  "^message^".\n---------------------------")

let execute program path debugging =
  let lexer = Lexer.make program path in
  try
    let lexed = Lexer.lex lexer in
    if debugging then Lexer.print_lexed lexed;
    
    let parser = Parser.make lexed path program in
    try
      let parsed = Parser.parse parser in
      if debugging then Parser.print_parsed parsed;
      
      let intp = Interpreter.make parsed path in
      try
        Interpreter.run intp
      with 
      | Interpreter.RuntimeError (message, path, tk) ->
        print_error "RuntimeError" message tk.line ~path 
    with
    | Parser.ParseErrors l ->
      List.iter (fun err ->
        match err with
        | Parser.ParseError (message, path, lineof, linenum) ->
          print_error "Syntax Error" message linenum ~lineof ~path
        | _ -> assert false
      ) l
  with
  | Lexer.LexErrors l ->
    List.iter (fun err ->
      match err with
      | Lexer.LexError (message, path, lineof, linenum, _) ->
        print_error "Syntax Error" message linenum ~lineof ~path
      | _ -> assert false
    ) l