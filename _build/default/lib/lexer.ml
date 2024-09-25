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
| TwoExc
| Arrow
| Right
| Left
| Hash
| At
| Dollar
| Ident
| Literal
| OParen
| CParen
| OSquare
| CSquare
| OCurly
| CCurly
| Question
| Colon
| Semicolon
| Ampersands
| Columns
| Dot
| Comma
| TwoSlash

exception LexError of string

type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

let nameof = function 
	| EOF -> "EOF"
	| Unknown -> "unknown"
	| Plus -> "+"
	| Minus -> "-"
	| Star -> "*"
	| Slash -> "/"
	| Modulo -> "%"
	| Greater -> ">"
	| Lesser -> "<"
	| GreatEqual -> ">="
	| LessEqual -> "<="
	| Equal -> "="
	| ConEqual -> ":="
	| EqualEqual -> "=="
	| ExcEqual -> "!="
	| Exclamation -> "!"
	| At -> "@"
	| Colon -> ":"
	| Semicolon -> ";"
	| Ampersands -> "&&"
	| Columns -> "||"
	| TwoExc -> "!!"
	| Arrow -> "->"
	| Right -> ">>"
	| Left -> "<<"
	| Hash -> "#"
	| Dollar -> "$"
	| Ident -> "Identifier"
	| Literal -> "float literal"
	| OParen -> "("
	| CParen -> ")"
	| OSquare -> "["
	| CSquare -> "]"
	| OCurly -> "{"
	| CCurly -> "}"
	| Question -> "?"
	| Dot -> "."
	| Comma -> ","
	| TwoSlash -> "comment"
	
let make raw = {raw; pos=0; line=1}

let peek lexer = 
	if lexer.pos >= (String.length lexer.raw) then (Char.chr 0) else lexer.raw.[lexer.pos]

let forward lexer =
	match peek lexer with
	| c when c = (Char.chr 0) -> lexer
	| '\n' -> {lexer with line=lexer.line+1; pos=lexer.pos+1} 
	| _ -> {lexer with pos=lexer.pos+1}

let rec skip_space lexer = 
	match peek lexer with	
	| '\n' | ' ' | '\t' | '\r' -> skip_space (forward lexer)
	| _ -> lexer

let is_num c = '0' <= c && c <= '9'
let is_alpha c = 'A' <= c && c <= 'Z' || 'a' <= c && c <= 'z'
let is_alnum c = is_num c || is_alpha c

let literal lexer = 
	let rec aux acc dotted lexer =
		match peek lexer with
		| '.' -> if dotted then (acc, lexer) else aux (acc ^ ".") true (forward lexer)
		| c when is_num c -> aux (acc ^ Char.escaped c) dotted (forward lexer)
		| _ -> (acc, lexer)
	in aux "" false lexer 

let ident lexer =
	let rec aux acc lexer =
		let c = peek lexer in
		if is_alnum c || c = '_' then
			aux (acc ^ Char.escaped c) (forward lexer) 
		else 
			(acc, lexer)
	in aux "" lexer

let comment lexer =
	let rec aux acc lexer =
		let c = peek lexer in
		if c <> '\n' then
			aux (acc ^ Char.escaped c) (forward lexer)
		else
			(acc, lexer)
	in aux "" lexer 

let next_token lexer =
	let lexer = skip_space lexer in
	let (typeof, lexer) = match peek lexer with
	| '+' -> (Plus, forward lexer)
	| '*' -> (Star, forward lexer)
	| '%' -> (Modulo, forward lexer)
	| ';' -> (Semicolon, forward lexer)
	| ',' -> (Comma, forward lexer)
	| '.' -> (Dot, forward lexer)
	| '@' -> (At, forward lexer)
	| '#' -> (Hash, forward lexer)
	| '(' -> (OParen, forward lexer)
	| ')' -> (CParen, forward lexer)
	| '[' -> (OSquare, forward lexer)
	| ']' -> (CSquare, forward lexer)
	| '{' -> (OCurly, forward lexer)
	| '}' -> (CCurly, forward lexer)
	| '$' -> (Dollar, forward lexer)
	| '?' -> (Question, forward lexer)
	| '&' -> begin let lexer = forward lexer in match peek lexer with '&' -> (Ampersands, forward lexer) | _ -> (Unknown, lexer) end
	| '|' -> begin let lexer = forward lexer in match peek lexer with '|' -> (Columns, forward lexer) | _ -> (Unknown, lexer) end
	| '=' -> begin let lexer = forward lexer in match peek lexer with '=' -> (EqualEqual, forward lexer) | _ -> (Equal, lexer) end
	| '/' -> begin let lexer = forward lexer in match peek lexer with '/' -> (TwoSlash, forward lexer) | _ -> (Slash, lexer) end
	| '-' -> begin let lexer = forward lexer in match peek lexer with '>' -> (Arrow, forward lexer) | _ -> (Minus, lexer) end
	| '>' -> begin let lexer = forward lexer in match peek lexer with '>' -> (Right, forward lexer) | '=' -> (GreatEqual, forward lexer) | _ -> (Greater, lexer) end
	| '<' -> begin let lexer = forward lexer in match peek lexer with '<' -> (Lesser, forward lexer) | '=' -> (GreatEqual, forward lexer) | _ -> (Left, lexer) end
	| ':' -> begin let lexer = forward lexer in match peek lexer with '=' -> (ConEqual, forward lexer) | _ -> (Colon, lexer) end
	| '!' -> begin let lexer = forward lexer in match peek lexer with '=' -> (ExcEqual, forward lexer) | '!' -> (TwoExc, forward lexer) | _ -> (Exclamation, lexer) end
	| c when c = (Char.chr 0) -> (EOF, lexer)
	| c when is_num c -> (Literal, lexer)
	| c when is_alpha c || c = '_' -> (Ident, lexer)
	| _ -> (Unknown, lexer)
	in
	let (value, lexer) = match typeof with
	| Literal -> literal lexer
	| Ident    -> ident lexer
	| TwoSlash -> comment lexer
	| _        -> (nameof typeof, lexer)
	in
	({pos=lexer.pos;line=lexer.line;value;typeof}, lexer)
let lex lexer =
	let rec aux acc lexer =
		let (tk, lexer) = next_token lexer in
		match tk.typeof with
		| EOF -> tk::acc
		| Unknown -> raise (LexError ("::Unrecognized token '"^tk.value^"' at line: "^(string_of_int tk.line)^"\n"))
		| _ -> aux (tk::acc) lexer
	in List.rev (aux [] lexer)