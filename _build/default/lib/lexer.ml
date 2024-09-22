type tokentype = EOF | Unknown | PHLD
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
| GreaterEqual 
| Assign 
| BodyAssign 
| Question 
| Sizeof 
| Column 
| OpenParen 
| CloseParen


type token = {value: string; line: int; pos: int; typeof: tokentype}
type t = {raw: string; pos: int; line: int;}

let nameof = function 
	| EOF -> "end of file" 
	| Unknown -> "unknown"
	| Literal -> "literal"
	| Ident -> "identifier"
	| Dot -> "."
	| Semicolon -> ";"
	| Plus -> "+"
	| Minus -> "-"
	| Star -> "*"
	| Slash -> "/"
	| Modulo -> "%"
	| Comma -> ","
	| Not -> "!"
	| And -> "&&"
	| Or -> "||"
	| Equal -> "=="
	| NotEqual -> "!="
	| Lesser -> "<"
	| Greater -> ">"
	| LessEqual -> "<="
	| GreaterEqual -> ">="
	| Assign -> "="
	| BodyAssign -> "->"
	| Question -> "?"
	| Sizeof -> "#"
	| Column -> "|"
	| OpenParen -> "("
	| CloseParen -> ")"
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
let is_ascii c = 'A' <= c && c <= 'Z' || 'a' <= c && c <= 'z'
let is_alnum c = is_num c || is_ascii c

let consume_literal lexer = consume_while (fun c -> is_num c || c = '.') lexer

let consume_ident lexer = consume_while (fun c -> is_alnum c || c = '_') lexer

let string_count str c =
	let rec aux acc i =
		if i = String.length str then i else
		if str.[i] = c then aux (acc+1) (i+1) else
		aux acc (i+1)
	in aux 0 0

let valid_literal str =
	String.length str > 0 &&
	String.for_all (fun c -> is_num c || c = '.') str &&
	not (String.contains str '.') ||
	string_count str '.' = 1 &&
	String.length str > 3 &&
	String.index str '.' > 0

let next_token lexer =
	if lexer.pos = String.length lexer.raw then (lexer, {value="";line=lexer.line;pos=lexer.pos;typeof=EOF}) else
	let (lexer, c) = chop_char (skip_space lexer) in
	let (lexer, typeof) = match c with
	| '.' -> (lexer, Dot)
	| ';' -> (lexer, Semicolon)
	| '(' -> (lexer, OpenParen)
	| ')' -> (lexer, CloseParen)
	| '#' -> (lexer, Sizeof)
	| '?' -> (lexer, Question)
	| '+' -> (lexer, Plus)
	| '*' -> (lexer, Star)
	| '/' -> (lexer, Slash)
	| '%' -> (lexer, Modulo)
	| ',' -> (lexer, Comma)
	| '-' -> follows '>' BodyAssign Minus lexer
	| '=' -> follows '=' Equal Assign lexer
	| '>' -> follows '=' GreaterEqual Greater lexer
	| '<' -> follows '=' LessEqual Lesser lexer
	| '!' -> follows '=' NotEqual Not lexer
	| '&' -> follows '&' And Unknown lexer
	| '|' -> follows '|' Or Column lexer
	| c when is_num c -> (lexer, Literal)
	| c when is_ascii c || c = '_' -> (lexer, Ident)
	| _ -> (lexer, Unknown)
	in

	let (lexer, value) = match typeof with
	| Literal -> consume_literal (unchop_char lexer)
	| Ident -> consume_ident (unchop_char lexer)
	| _ -> (lexer, nameof typeof)
	in

	let typeof = if typeof = Literal && not (valid_literal value) then Unknown else typeof in

	(lexer, {value; typeof; pos=(lexer.pos - (String.length value)); line=lexer.line})

let pretty tkn = 
	Printf.printf "{value: %s $ pos: %d $ line: %d $ typeof: %s}\n" tkn.value tkn.pos tkn.line (nameof tkn.typeof)

let print_value tkn =
	print_string tkn.value; print_string " "

let print_all ppf lexer =
	let rec loop lexer =
		let (lexer, tkn) = next_token lexer in
		match tkn.typeof with
		| EOF -> ()
		| _ -> ppf tkn; loop lexer
	in loop lexer
