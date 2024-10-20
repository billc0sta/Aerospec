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
  | Columns
  | Amper
  | Dot
  | Comma
  | TwoAmper
  | TwoSlash
  | TwoStar
  | TwoQuestion
  | TwoColon
  | Tilde
  | Underscore

type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int; path: string; errors: exn list}

val make: string -> string -> t 
val lex: t -> token list
val nameof: tokentype -> string
val print_lexed: token list -> unit

exception LexError of string * string * string * int * int
exception LexErrors of exn list
