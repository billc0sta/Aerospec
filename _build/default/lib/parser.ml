open Lexer

type expr =
  | ArrLit of expr list
  | FloatLit of float
  | Binary of expr * token * expr
  | Unary of token * expr
  | Grouping of expr

type statement =
  | Print of expr

type t = {
  raw: token list;
  previous: token;
  pos: int;
}

exception ParseError of string * token

let make raw = {raw; previous={value="";typeof=Unknown;line=0;pos=0}; pos=0}

let peek parser = List.hd parser.raw

let forward parser = 
  if (List.hd parser.raw).typeof = EOF then parser else
  {previous=List.hd parser.raw; raw=List.tl parser.raw; pos=parser.pos+1}

let backward parser = 
  {raw=parser.previous::parser.raw; previous={parser.previous with value="";typeof=Unknown}; pos=parser.pos-1}

let consume typeof error parser =
	if (peek parser).typeof = typeof then forward parser else raise (ParseError (error, peek parser))

let chop parser = (peek parser, forward parser)

let rec expression parser = logical parser

and logical parser = build_binary [And; Or] logical equality parser

and equality parser = build_binary [Equal; NotEqual] equality relational parser

and relational parser = build_binary [Greater; GreatEqual; Lesser; LessEqual] relational basic parser

and basic parser = build_binary [Plus; Minus] basic factor parser

and factor parser = build_binary [Slash; Star; Modulo] factor unary parser

and unary parser =
  let tk = peek parser in
  match tk.typeof with
  | Not | Plus | Minus | Hash -> 
  	let (expr, parser) = unary (forward parser) in
    (Unary (tk, expr), parser)
  | _ -> primary parser

and primary parser =
  let (tk, parser) = chop parser in
  match tk.typeof with
  | Literal -> (FloatLit (float_of_string tk.value), parser)
  | OpenParen -> grouping (backward parser)
  | OpenSqr -> arr (backward parser)
  | _ -> raise (ParseError ("::Expected an expression", tk))

and grouping parser =
  let parser = consume OpenParen "::Expected an Opening Parenthesis '('" parser in
  let (expr, parser) = expression parser in
  let parser = consume CloseParen "::Expected a Closing Parenthesis ')'" parser in
  (Grouping expr, parser)

and build_binary ops f1 f2 parser =
  let (expr1, parser) = f2 parser in
  let op = peek parser in
  if List.mem op.typeof ops then
    let (expr2, parser) = f1 (forward parser) in
    (Binary (expr1, op, expr2), parser)
  else
    (expr1, parser)

and arr parser =
  let parser = consume OpenSqr "::Expected an Opening Square Bracket '['" parser in
  let rec aux acc parser =
    let tk = peek parser in
    match tk.typeof with 
    | CloseSqr -> (acc, forward parser)
    | EOF -> raise (ParseError ("::Expected a Closing Square Bracket ']'", tk))
    | _ -> 
      let (expr, parser) = expression parser in
      let parser = if (peek parser).typeof = Comma then forward parser else parser in
      aux (expr::acc) parser
  in 
  let (exprl, parser) = aux [] parser in (ArrLit (List.rev exprl), parser)

let print_stmt parser =
  let parser = consume At "::Expected print statement '@'" parser in
  let (expr, parser) = expression parser in (Print expr, parser)

let parse parser =
  let rec aux acc parser = 
    let tk = peek parser in
    match tk.typeof with
    | At -> let (stmt, parser) = print_stmt parser in aux (stmt::acc) parser
    | EOF -> acc
    | _ -> raise (Failure "TODO: implement 'parse'")
  in List.rev (aux [] parser)

let rec print_expr expr =
  match expr with
  | FloatLit fl ->
      let str = string_of_float fl in
      print_string
        (if String.ends_with ~suffix:"." str then
          String.sub str 0 (String.length str - 1)
        else
          str)
  | Binary (expr1, op, expr2) ->
      print_string "(";
      print_expr expr1;
      print_string (op.value);
      print_expr expr2;
      print_string ")"
  | Unary (op, expr) ->
      print_string (op.value);
      print_expr expr
  | Grouping expr ->
      print_string "(";
      print_expr expr;
      print_string ")"
  | _ -> raise (Failure "TODO: implement 'print_expr'")