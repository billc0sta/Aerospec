type tokentype = EOF | Unknown | PHLD
| At
| Dot
| Semicolon
| Literal
| Ident
| Plus 
| Minus 
| Star 
| Slash 
| Modulo
| Comma
| Not 
| And 
| Or 
| Equal 
| NotEqual 
| Lesser
| Greater 
| LessEqual 
| GreatEqual 
| Assign 
| Question 
| Hash
| Colon
| OpenParen
| CloseParen 
| OpenCurly
| CloseCurly
| OpenSqr
| CloseSqr

exception LexError of string

type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

let nameof = function 
	| EOF -> "EOF" 
	| Unknown -> "unknown"
	| Literal -> "literal"
	| Ident -> "identifier"
	| At -> "@"
	| Dot -> "."
	| Semicolon -> ";"
	| Plus -> "+"
	| Minus -> "-"
	| Star -> "*"
	| Slash -> "/"
	| Modulo -> "%"
	| Comma -> ","
	| Not -> "!"
	| And -> "&"
	| Or -> "|"
	| Equal -> "=="
	| NotEqual -> "!="
	| Lesser -> "<"
	| Greater -> ">"
	| LessEqual -> "<="
	| GreatEqual -> ">="
	| Assign -> "="
	| Question -> "?"
	| Hash -> "#"
	| Colon -> ":"
	| OpenParen -> "("
	| CloseParen -> ")"
	| OpenCurly -> "{"
	| CloseCurly -> "}"
	| OpenSqr -> "["
	| CloseSqr -> "]"
	| _ -> raise (failwith "unrecognized tokentype")

let make raw = {raw; pos=0; line=1}

let peek_char lexer = 
	if lexer.pos >= (String.length lexer.raw) then (Char.chr 0) else lexer.raw.[lexer.pos]

let advance lexer =
	match peek_char lexer with
	| c when c = (Char.chr 0) -> lexer
	| '\n' -> {lexer with line=lexer.line+1; pos=lexer.pos+1} 
	| _ -> {lexer with pos=lexer.pos+1}

let chop_char lexer = let c = peek_char lexer in (advance lexer, c)

let unchop_char lexer =
	if lexer.pos = 0 || (lexer.pos - 1) = -1 then lexer else 
		if lexer.raw.[lexer.pos-1] = '\n'
		then {lexer with line=lexer.line-1; pos=lexer.pos-1}
		else {lexer with pos=lexer.pos-1}

let rec skip_space lexer = 
	match peek_char lexer with	
	| '\n' | ' ' | '\t' | '\r' -> skip_space (advance lexer)
	| _ -> lexer

let follows c expected default lexer =
	if (peek_char lexer) = c then (advance lexer, expected) else (lexer, default)

let consume_while f lexer =
	let rec aux acc lexer =
		let c = peek_char lexer in
		if f c then aux (acc ^ Char.escaped c) (advance lexer)
		else (lexer, acc)
	in aux "" lexer

let is_num c = '0' <= c && c <= '9'
let is_alpha c = 'A' <= c && c <= 'Z' || 'a' <= c && c <= 'z'
let is_alnum c = is_num c || is_alpha c

let consume_literal lexer = consume_while (fun c -> is_num c || c = '.') lexer

let consume_ident lexer = consume_while (fun c -> is_alnum c || c = '_') lexer

(*
let string_count str c =
	let rec aux acc i =
		if i = String.length str then i else
		if str.[i] = c then aux (acc+1) (i+1) else
		aux acc (i+1)
	in aux 0 0
*)
let valid_literal str =
	String.length str > 0 &&
	String.for_all (fun c -> is_num c || c = '.') str (*&&
	not (String.contains str '.') || 
	string_count str '.' = 1 && 
	String.length str >= 3 && 
	String.index str '.' > 0
	*)
let next_token lexer =
	let (lexer, c) = chop_char (skip_space lexer) in
	let (lexer, typeof) = match c with
	| '@' -> (lexer, At)
	| '.' -> (lexer, Dot)
	| ';' -> (lexer, Semicolon)
	| '(' -> (lexer, OpenParen)
	| ')' -> (lexer, CloseParen)
	| '#' -> (lexer, Hash)
	| '?' -> (lexer, Question)
	| '+' -> (lexer, Plus)
	| '-' -> (lexer, Minus)
	| '*' -> (lexer, Star)
	| '/' -> (lexer, Slash)
	| '%' -> (lexer, Modulo)
	| ',' -> (lexer, Comma)
	| '|' -> (lexer, Or)
	| '&' -> (lexer, And)
	| ':' -> (lexer, Colon)
	| '{' -> (lexer, OpenCurly)
	| '}' -> (lexer, CloseCurly)
	| '[' -> (lexer, OpenSqr)
	| ']' -> (lexer, CloseSqr)
	| '=' -> follows '=' Equal Assign lexer
	| '>' -> follows '=' GreatEqual Greater lexer
	| '<' -> follows '=' LessEqual Lesser lexer
	| '!' -> follows '=' NotEqual Not lexer
	| c when is_num c -> (lexer, Literal)
	| c when is_alpha c || c = '_' -> (lexer, Ident)
	| c when c = Char.chr 0 || lexer.pos = String.length lexer.raw -> (lexer, EOF)
	| _ -> (lexer, Unknown)
	in

	let (lexer, value) = match typeof with
	| Literal -> consume_literal (unchop_char lexer)
	| Ident -> consume_ident (unchop_char lexer)
	| _ -> (lexer, nameof typeof)
	in

	let typeof = if typeof = Literal && not (valid_literal value) then Unknown else typeof in

	(lexer, {value; typeof; pos=lexer.pos; line=lexer.line})

let lex lexer =
	let rec aux acc lexer =
		let (lexer, tk) = next_token lexer in
		match tk.typeof with
		| EOF -> tk::acc
		| Unknown -> raise (LexError ("::Unrecognized token '"^tk.value^"' at line: "^(string_of_int tk.line)^"\n"))
		| _ -> aux (tk::acc) lexer
	in List.rev (aux [] lexer)