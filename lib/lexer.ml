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
| At
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
| Ampersands
| Columns
| Dot
| Comma
| TwoSlash
| TwoStar
| TwoQuestion
| TwoColon
| Tilde
| Underscore


type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

exception LexError of string * token

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
	| Arrow -> "->"
	| Right -> ">>"
	| Left -> "<<"
	| Hash -> "#"
	| Dollar -> "$"
	| Ident -> "Identifier"
	| FloatLiteral -> "float literal"
	| StringLiteral -> "string literal"
	| OParen -> "("
	| CParen -> ")"
	| OSquare -> "["
	| CSquare -> "]"
	| OCurly -> "{"
	| CCurly -> "}"
	| Question -> "?"
	| Dot -> "."
	| Comma -> ","
	| TwoSlash -> "//"
	| TwoStar -> "**"
	| TwoQuestion -> "??"
	| TwoColon -> "::"
	| Tilde -> "~"
	| Underscore -> "_"
	
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

let float_literal lexer = 
	let rec aux acc dotted lexer =
		match peek lexer with
		| '.' -> if dotted then (acc, lexer) else aux (acc + 1) true (forward lexer)
		| c when is_num c -> aux (acc + 1) dotted (forward lexer)
		| _ -> (acc, lexer)
	in let (count, lexer) = aux 0 false lexer in
	(String.sub lexer.raw (lexer.pos - count) count, lexer)

let string_literal lexer =
	let rec count acc escaped lexer =
		match peek lexer with
		| '"' -> if escaped then count (acc+1) false (forward lexer) else (acc, lexer) 
		| '\\' -> count (acc+1) (not escaped) (forward lexer) 
		| c when c = (Char.chr 0) -> 
			raise (LexError("Non-terminated string", {value=""; typeof=StringLiteral; pos=lexer.pos; line=lexer.line}))
		| _ -> count (acc+1) false (forward lexer)
	in let (length, lexer) = count 0 false lexer in
	if length = 0 then ("", forward lexer) else 
	let bytes = Bytes.create length in
	let rec blit wp rp escaped =
		if rp >= length then wp else
		let c = lexer.raw.[rp+(lexer.pos-length)] in 
		match c with
		| '\\' -> if escaped then (Bytes.set bytes wp c; blit (wp+1) (rp+1) false) else (blit wp (rp+1) true)
		| 'b' -> let c = if escaped then (Char.chr 8) else 'b' in
		         Bytes.set bytes wp c; blit (wp+1) (rp+1) false
		| 't' -> let c = if escaped then (Char.chr 9) else 't' in
		         Bytes.set bytes wp c; blit (wp+1) (rp+1) false
		| 'n' -> let c = if escaped then (Char.chr 10) else 'n' in
		         Bytes.set bytes wp c; blit (wp+1) (rp+1) false
		| 'v' -> let c = if escaped then (Char.chr 11) else 'v' in
		         Bytes.set bytes wp c; blit (wp+1) (rp+1) false
		| 'f' -> let c = if escaped then (Char.chr 12) else 'f' in
		         Bytes.set bytes wp c; blit (wp+1) (rp+1) false
		| 'r' -> let c = if escaped then (Char.chr 13) else 'r' in
		         Bytes.set bytes wp c; blit (wp+1) (rp+1) false
		| _ -> Bytes.set bytes wp c; blit (wp+1) (rp+1) false
	in 
	let written = blit 0 0 false in
	let str = Bytes.sub_string bytes 0 written in
	(str, forward lexer)
 
let builder f lexer = 
	let rec aux acc lexer =
		let c = peek lexer in
		if f c then
			aux (acc+1) (forward lexer)
		else
			(acc, lexer) 
	in let (count, lexer) = aux 0 lexer in
	(String.sub lexer.raw (lexer.pos - count) count, lexer)

let ident = builder (fun c -> is_alnum c || c = '_')

let comment = builder (fun c -> c <> '\n' && c <> Char.chr 0)
	
let next_token lexer =
	let lexer = skip_space lexer in
	let (typeof, lexer) = match peek lexer with
	| '+' -> (Plus, forward lexer)
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
	| '"' -> (StringLiteral, forward lexer)
	| '~' -> (Tilde, forward lexer)
	| '?' -> begin let lexer = forward lexer in match peek lexer with '?' -> (TwoQuestion, forward lexer) | _ -> (Question, lexer) end
	| '*' -> begin let lexer = forward lexer in match peek lexer with '*' -> (TwoStar, forward lexer) | _ -> (Star, lexer) end
	| '&' -> begin let lexer = forward lexer in match peek lexer with '&' -> (Ampersands, forward lexer) | _ -> (Unknown, lexer) end
	| '|' -> begin let lexer = forward lexer in match peek lexer with '|' -> (Columns, forward lexer) | _ -> (Unknown, lexer) end
	| '=' -> begin let lexer = forward lexer in match peek lexer with '=' -> (EqualEqual, forward lexer) | _ -> (Equal, lexer) end
	| '/' -> begin let lexer = forward lexer in match peek lexer with '/' -> (TwoSlash, forward lexer) | _ -> (Slash, lexer) end
	| '-' -> begin let lexer = forward lexer in match peek lexer with '>' -> (Arrow, forward lexer) | _ -> (Minus, lexer) end
	| '>' -> begin let lexer = forward lexer in match peek lexer with '>' -> (Right, forward lexer) | '=' -> (GreatEqual, forward lexer) | _ -> (Greater, lexer) end
	| '<' -> begin let lexer = forward lexer in match peek lexer with '<' -> (Left, forward lexer) | '=' -> (LessEqual, forward lexer) | _ -> (Lesser, lexer) end
	| ':' -> begin let lexer = forward lexer in match peek lexer with '=' -> (ConEqual, forward lexer) | ':' -> (TwoColon, forward lexer) | _ -> (Colon, lexer) end
	| '!' -> begin let lexer = forward lexer in match peek lexer with '=' -> (ExcEqual, forward lexer) | _ -> (Exclamation, lexer) end
	| c when c = (Char.chr 0) -> (EOF, lexer)
	| c when is_num c -> (FloatLiteral, lexer)
	| c when is_alpha c || c = '_' -> (Ident, lexer)
	| _ -> (Unknown, lexer)
	in
	let (value, lexer) = match typeof with
	| FloatLiteral  -> float_literal lexer 
	| StringLiteral -> string_literal lexer
	| Ident    -> ident lexer
	| TwoSlash -> comment lexer
	| _        -> (nameof typeof, lexer)
	in
	let (typeof, value) = 
		match typeof with Ident -> if value = "_" then (Underscore, "") else (typeof, value) | _ -> (typeof, value)
	in
	({pos=lexer.pos;line=lexer.line;value;typeof}, lexer)

let lex lexer =
	let rec aux acc lexer =
		let (tk, lexer) = next_token lexer in
		match tk.typeof with
		| EOF -> tk::acc
		| Unknown -> raise (LexError ("Unrecognized token '"^tk.value^"'", tk))
		| TwoSlash -> aux acc lexer
		| _ -> aux (tk::acc) lexer
	in List.rev (aux [] lexer)
