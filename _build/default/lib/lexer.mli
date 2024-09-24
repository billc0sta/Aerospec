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
| Question 
| Hash
| Colon
| OpenParen
| CloseParen 
| OpenCurly
| CloseCurly
| OpenSqr
| CloseSqr

type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

val make: string -> t 
val lex: t -> token list
val nameof: tokentype -> string

exception LexError of string