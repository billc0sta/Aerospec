open Lexer

type expr = 
  | Float of float
  | Binary of expr * token * expr
  | Unary of token * expr
  | Grouping of expr

type t = {
  raw: token list;
  previous: token;
  pos: int;
}

exception ParseError of (string * token)

let make raw = {raw; previous={value="";typeof=Unknown;line=0;pos=0}; pos=0}

let peek parser = List.hd parser.raw

let forward parser = 
  if (List.hd parser.raw).typeof = EOF then parser else
  {previous=List.hd parser.raw; raw=List.tl parser.raw; pos=parser.pos+1}

let backward parser = 
  {raw=parser.previous::parser.raw; previous={parser.previous with value="";typeof=Unknown}; pos=parser.pos-1}

let consume typeof error parser =
	if (peek parser).typeof = typeof then forward parser else raise (ParseError error)

let chop parser = (peek parser, forward parser)

let rec expression parser = logical parser

and logical parser = build_binary [And; Or] equality parser

and equality parser = build_binary [Equal; NotEqual] relational parser

and relational parser = build_binary [Greater; GreatEqual; Lesser; LessEqual] basic parser

and basic parser = build_binary [Plus; Minus] factor parser

and factor parser = build_binary [Slash; Star; Modulo] unary parser

and unary parser =
  let tk = peek parser in
  match tk.typeof with
  | Hash | Not | At -> 
  	let (expr, parser) = unary (forward parser) in
    (Unary (tk, expr), parser)
  | _ -> primary parser

and primary parser =
  let (tk, parser) = chop parser in
  match tk.typeof with
  | Literal -> (Float (float_of_string tk.value), parser)
  | OpenParen -> grouping (backward parser)
  | _ -> raise (ParseError ("::Expected an expression", tk))

and grouping parser =
  let parser = consume OpenParen ("::Expected an Opening Parenthesis '('", peek parser) parser in
  let (expr, parser) = expression parser in
  let parser = consume CloseParen ("::Expected a Closing Parenthesis ')'", peek parser) parser in
  (Grouping expr, parser)

and build_binary ops f parser =
  let (expr1, parser) = f parser in
  let op = peek parser in
  if List.mem op.typeof ops then
    let (expr2, parser) = f (forward parser) in
    (Binary (expr1, op, expr2), parser)
  else
    (expr1, parser)

let rec print_expr expr =
	match expr with
	| Float fl -> print_string (string_of_float fl)
	| Binary (expr1, op, expr2) -> print_expr expr1; print_string (Lexer.nameof op.typeof); print_expr expr2
	| Unary (op, expr) -> print_string (Lexer.nameof op.typeof); print_expr expr
	| Grouping expr -> print_string "("; print_expr expr; print_string ")"
	;