open Upl

let rec print_lexed = function
	| [] -> ()
	| x::xs -> Lexer.(Printf.printf "{value=\"%s\"; typeof=\"%s\"; pos=%d; line=%d}\n" x.value (nameof x.typeof) x.pos x.line); print_lexed xs

let rec print_parsed = function
	| [] -> ()
	| x::xs ->
	begin
		match x with
		| Parser.Print expr -> print_string "print"; Parser.print_expr expr
	end; print_parsed xs

let lexer = Lexer.make "@112 - 10"
let lexed = Lexer.lex lexer
let () = print_lexed lexed; print_string "\n"
let parser = Parser.make lexed
let parsed = Parser.parse parser
let () = print_parsed parsed; print_string "\n"
let interpreter = Interpreter.make parsed
let () = Interpreter.run interpreter