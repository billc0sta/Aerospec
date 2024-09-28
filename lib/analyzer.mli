type anz

exception AnalyzeError of string * Lexer.token
exception AnalyzeWarning of string * Lexer.token

val make: Parser.statement list -> anz
val analyze: anz -> unit