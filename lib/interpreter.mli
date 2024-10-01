exception RuntimeError of string * Lexer.token

type t
type value = 
| Float of float
| String of string
| Bool of bool
| Lambda of string list * Parser.statement
| Nil

val make: Parser.statement list -> t

val run: t -> unit
val truth: value -> bool
val evaluate: Parser.expr -> t -> value
val stringify_value: value -> string 