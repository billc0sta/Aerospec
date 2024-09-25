open Upl

let rec print_lexed = function
	| [] -> ()
	| x::xs -> Lexer.(Printf.printf "{value=\"%s\"; typeof=\"%s\"; pos=%d; line=%d}\n" x.value (nameof x.typeof) x.pos x.line); print_lexed xs

let lexer = Lexer.make "@121 + 32 + 32"
let lexed = Lexer.lex lexer
let _ = print_lexed
let parser = Parser.make lexed
let parsed = Parser.parse parser
let interpreter = Interpreter.make parsed
let () = Interpreter.run interpreter