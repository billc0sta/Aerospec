exception RuntimeError of string * Lexer.token

type t

val make: Parser.statement list -> t

val run: t -> unit
val evaluate: Parser.expr -> t -> Value.t