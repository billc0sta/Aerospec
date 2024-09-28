open Lexer

type expr =
  | FloatLit of float
  | StringLit of string
  | Binary of expr * token * expr
  | Unary of token * expr
  | Grouping of expr
  | IdentExpr of token
  | IfExpr of expr * expr * expr

type statement = 
  | Print of expr
  | Exprstmt of expr
  | IfStmt of expr * statement * statement option
  | LoopStmt of expr * statement
  | Block of statement list
  | Break
  | Continue

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

let consume typeof error parser =
	if (peek parser).typeof = typeof then forward parser else raise (ParseError (error, peek parser))

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
  | IfExpr (cond, whentrue, whenfalse) -> 
    print_string "if "; print_expr cond;
    print_string " then "; print_expr whentrue; print_string " else ";
    print_expr whenfalse  
  | StringLit str -> print_string str;
  | IdentExpr tk -> print_string tk.value

let rec expression parser = assignexpr parser

and assignexpr parser = build_binary [Equal; ConEqual] assignexpr ifexpr parser

and ifexpr parser =
  let (expr1, parser) = logical parser in
  if (peek parser).typeof = Question then begin
    let (expr2, parser) = ifexpr (forward parser) in
    let parser = consume Colon "::Expected an else branch (colon ':')" parser in 
    let (expr3, parser) = ifexpr parser in
    (IfExpr (expr1, expr2, expr3), parser)
  end else 
    (expr1, parser) 

and logical parser = build_binary [Ampersands; Columns] logical equality parser

and equality parser = build_binary [EqualEqual; ExcEqual] equality relational parser

and relational parser = build_binary [Greater; GreatEqual; Lesser; LessEqual] relational basic parser

and basic parser = build_binary [Plus; Minus] basic factor parser

and factor parser = build_binary [Slash; Star; Modulo] factor unary parser

and unary parser =
  let tk = peek parser in
  match tk.typeof with
  | Exclamation | Plus | Minus | Hash -> 
  	let (expr, parser) = unary (forward parser) in
    (Unary (tk, expr), parser)
  | _ -> primary parser

and primary parser =
  let tk = peek parser in
  match tk.typeof with
  | FloatLiteral -> (FloatLit (float_of_string tk.value), forward parser)
  | StringLiteral -> (StringLit tk.value, forward parser)
  | Ident -> (IdentExpr tk, forward parser)
  | OParen -> grouping (forward parser)
  | _ -> raise (ParseError ("::Expected an expression", tk))

and grouping parser =
  let (expr, parser) = expression parser in
  let parser = consume CParen "::Expected a Closing Parenthesis ')'" parser in
  (Grouping expr, parser)

and build_binary ops f1 f2 parser =
  let (expr1, parser) = f2 parser in
  let op = peek parser in
  if List.mem op.typeof ops then
    let (expr2, parser) = f1 (forward parser) in
    (Binary (expr1, op, expr2), parser)
  else
    (expr1, parser)

let print_stmt parser = let (expr, parser) = expression parser in (Print expr, parser)

let rec statement parser =
  let tk = peek parser in
    match tk.typeof with
    | EOF -> raise (ParseError ("::Expected a statement", tk))
    | At -> print_stmt (forward parser)
    | Right -> loop_stmt (forward parser)
    | OCurly -> block_stmt parser
    | TwoQuestion -> if_stmt (forward parser)
    | TwoStar -> (Break, forward parser)
    | Left -> (Continue, forward parser)
    | _  -> expr_stmt parser

and loop_stmt parser =
  let (cond, parser)  = expression parser in
  let (block, parser) = statement parser in
  (LoopStmt (cond, block), parser)

and expr_stmt parser = 
  let (expr, parser) = expression parser in
  (Exprstmt expr, parser) 
  
and block_stmt parser =
  let parser = consume OCurly "::Expected a block (opening curly bracket '{')" parser in
  let rec aux acc parser =
    let tk = (peek parser) in 
    match tk.typeof with
    | CCurly -> (acc, forward parser)
    | EOF -> raise (ParseError ("::Expected a block limit (closing curly bracket '}')", tk)) 
    | _ -> let (stmt, parser) = statement parser in aux (stmt::acc) parser
  in let (acc, parser) = aux [] parser in
  (Block (List.rev acc), parser)

and if_stmt parser = 
  let (cond, parser) = expression parser in
  let (whentrue, parser) = statement parser in
  if (peek parser).typeof = TwoColon then
    let (whenfalse, parser) = statement (forward parser) in
    (IfStmt (cond, whentrue, (Some whenfalse)), parser)
  else 
    (IfStmt (cond, whentrue, None), parser)

let parse parser =
  let rec aux acc parser =
    if (peek parser).typeof = EOF then acc else
    let (stmt, parser) = statement parser in aux (stmt::acc) parser 
  in List.rev (aux [] parser)