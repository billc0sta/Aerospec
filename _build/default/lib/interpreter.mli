type value = 
| Float of float

exception RuntimeError of string * Parser.expr

type t = {raw: Parser.statement list; length: int; pos: int}

val make: Parser.statement list -> t
val run: t -> unit
