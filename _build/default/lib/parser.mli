type expr =
  | FloatLit of float
  | StringLit of string
  | Binary of expr * Lexer.token * expr
  | Unary of Lexer.token * expr
  | Grouping of expr
  | Ident of string

type statement = 
  | Print of expr
  | Assignment of expr * Lexer.token * statement
  | Exprstmt of expr

type t = {
  raw: Lexer.token list;
  previous: Lexer.token;
  pos: int;
}

exception ParseError of string * Lexer.token

val make: Lexer.token list -> t
val expression: t -> expr * t
val parse: t -> statement list
val print_expr: expr -> unit