type tokentype = EOF | Unknown | PHLD
| Dot
| Semicolon
| Literal
| Ident
| Plus 
| Minus 
| Star 
| Slash 
| Modulo
| Comma
| Not 
| And 
| Or 
| Equal 
| NotEqual 
| Lesser
| Greater 
| LessEqual 
| GreaterEqual 
| Assign 
| BodyAssign 
| Question 
| Sizeof 
| Column 
| OpenParen 
| CloseParen

type token
type t

val next_token: t -> t * token
val make: string -> t 
val pretty: token -> unit
val print_value: token -> unit
val print_all: (token -> unit) -> t -> unit 