type tokentype = EOF | Unknown | PHLD
| At
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
| GreatEqual 
| Assign 
| BodyAssign 
| Question 
| Hash
| Column 
| OpenParen
| CloseParen 

type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

val make: string -> t 
val lex: t -> token list
val nameof: tokentype -> string