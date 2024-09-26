open Upl

let rec print_lexed l = 
	match l with
	| [] -> ()
	| x::xs -> Lexer.(Printf.printf "{value=\"%s\"; typeof=\"%s\"; pos=%d; line=%d}\n" x.value (nameof x.typeof) x.pos x.line); print_lexed xs

let rec print_parsed l = 
	let rec aux stmt =
		match stmt with
		| Parser.Print expr -> print_string "print"; Parser.print_expr expr; print_string "\n"
		| Parser.Assignment (expr, token, stmt) -> Parser.print_expr expr; print_string (Lexer.nameof token.typeof); aux stmt
		| Parser.Exprstmt expr -> Parser.print_expr expr
		| Parser.IfStmt (expr, whentrue, whenfalse) -> 
			print_string "if "; 
			Parser.print_expr expr; 
			print_string " do \n"; 
			aux whentrue;
			begin
			match whenfalse with
			| None -> ()
			| Some block -> print_string "else do \n"; aux block
			end
		| Parser.Block block -> print_parsed block;
		; print_string "\n"
	in
	match l with
	| [] -> ()
	| x::xs -> aux x; print_parsed xs

let program = 
"
arr = 1
? (1 + 1 == 2) {arr = 1} : {arr = 0}
a = x := 2
@1
1 + 21
"

let _ = print_lexed
let lexer = Lexer.make program
let lexed = Lexer.lex lexer
let parser = Parser.make lexed
let parsed = Parser.parse parser
let () = print_parsed parsed
let () = print_int (List.length parsed)
(*
let analyzer = Analyzer.make parsed
let () = Analyzer.analyze analyzer
let interpreter = Interpreter.make parsed
let () = Interpreter.run interpreter
*)