open Upl

let rec print_lexed l = 
	match l with
	| [] -> ()
	| x::xs -> Lexer.(Printf.printf "{value=\"%s\"; typeof=\"%s\"; pos=%d; line=%d}\n" x.value (nameof x.typeof) x.pos x.line); print_lexed xs

let rec print_parsed l = 
	let rec aux stmt =
		match stmt with
		| Parser.Print expr -> print_string "print"; Parser.print_expr expr
		| Parser.Assignment (expr, token, stmt) -> Parser.print_expr expr; print_string (Lexer.nameof token.typeof); aux stmt
		| Parser.Exprstmt expr -> Parser.print_expr expr
		; print_string "\n"
	in
	match l with
	| [] -> ()
	| x::xs -> aux x; print_parsed xs

let lexer = Lexer.make 
"
a := x := y := 10
@a + x + y
@y
"
let lexed = Lexer.lex lexer
let _ = print_lexed
let parser = Parser.make lexed
let parsed = Parser.parse parser
let () = print_parsed parsed
let interpreter = Interpreter.make parsed
let () = Interpreter.run interpreter