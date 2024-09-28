type expr =
  | FloatLit of float
  | StringLit of string
  | Binary of expr * Lexer.token * expr
  | Unary of Lexer.token * expr
  | Grouping of expr
  | IdentExpr of Lexer.token
  | IfExpr of expr * expr * expr

type statement = 
  | Print of expr
  | Exprstmt of expr
  | IfStmt of expr * statement * statement option
  | LoopStmt of expr * statement
  | Block of statement list
  | Break
  | Continue

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