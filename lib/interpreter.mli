exception RuntimeError of string * string * Lexer.token

type t

val make: Parser.statement list -> string -> t

val run: t -> unit
val evaluate: Parser.expr -> t -> Value.t