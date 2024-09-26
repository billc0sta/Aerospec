exception RuntimeError of string

type t
type value = 
| Float of float
| String of string

val make: Parser.statement list -> t

val run: t -> unit
val truth: value -> bool
val evaluate: Parser.expr -> t -> value
val assignment_stmt: Parser.expr -> Parser.statement -> Lexer.token -> t -> unit
