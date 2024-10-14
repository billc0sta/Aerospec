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
  | Range of expr * Lexer.token * expr * Lexer.token * expr
  | ObjectExpr of statement list
  | PropertyExpr of expr * expr
  | Builder of expr * expr * expr
  | NilExpr

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
  path: string;
  imported: string list;
  errors: exn list;
}

exception ParseError of string * string * int * int
exception ParseErrors of exn list

val make: Lexer.token list -> string -> t
val expression: t -> expr * t
val parse: t -> statement list
val _print_parsed: statement list -> unit