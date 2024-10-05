type expr =
  | FloatLit of float
  | StringLit of string
  | Binary of expr * Lexer.token * expr
  | Unary of Lexer.token * expr
  | Grouping of expr
  | IdentExpr of Lexer.token * bool
  | IfExpr of expr * expr * expr
  | FunCall of expr * expr list * Lexer.token
  | LambdaExpr of expr list * statement * Lexer.token
  | ArrExpr of expr list * Lexer.token
  | Subscript of expr * (expr * expr option) * Lexer.token

and statement = 
  | Exprstmt of expr
  | IfStmt of expr * statement * statement option
  | LoopStmt of expr * statement
  | Block of statement list
  | Break of Lexer.token
  | Continue of Lexer.token
  | NoOp of Lexer.token
  | Return of expr * Lexer.token 

type t = {
  raw: Lexer.token list;
  previous: Lexer.token;
  pos: int;
}

exception ParseError of string * Lexer.token

val make: Lexer.token list -> t
val expression: t -> expr * t
val parse: t -> statement list
val _print_parsed: statement list -> unit