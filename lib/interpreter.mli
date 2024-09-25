exception RuntimeError of string

type t

val make: Parser.statement list -> t

val run: t -> unit
