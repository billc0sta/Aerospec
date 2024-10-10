type tokentype = 
| EOF 
| Unknown
| Plus
| Minus
| Star
| Slash
| Modulo
| Greater
| Lesser
| GreatEqual
| LessEqual
| Equal
| ConEqual
| EqualEqual
| ExcEqual
| Exclamation
| Arrow
| Right
| Left
| Hash
| At
| Dollar
| Ident
| FloatLiteral
| StringLiteral
| OParen
| CParen
| OSquare
| CSquare
| OCurly
| CCurly
| Question
| Colon
| Semicolon
| Ampersands
| Columns
| Dot
| Comma
| TwoSlash
| TwoStar
| TwoQuestion
| TwoColon
| Tilde
| Underscore

type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

val make: string -> t 
val lex: t -> token list
val nameof: tokentype -> string

exception LexError of string * token