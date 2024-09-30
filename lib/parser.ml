open Lexer

type expr =
  | FloatLit of float
  | StringLit of string
  | Binary of expr * token * expr
  | Unary of token * expr
  | Grouping of expr
  | IdentExpr of token
  | IfExpr of expr * expr * expr
  | FunCall of expr * expr list 
  | LambdaExpr of expr list * statement

and statement = 
  | Print of expr
  | Exprstmt of expr
  | IfStmt of expr * statement * statement option
  | LoopStmt of expr * statement
  | Block of statement list
  | Break of token
  | Continue of token

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

(*test*)
let rec _print_expr expr =
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
      _print_expr expr1;
      print_string (op.value);
      _print_expr expr2;
      print_string ")"
  | Unary (op, expr) ->
      print_string (op.value);
      _print_expr expr
  | Grouping expr ->
      print_string "(";
      _print_expr expr;
      print_string ")"
  | IfExpr (cond, whentrue, whenfalse) -> 
    print_string "if "; _print_expr cond;
    print_string " then "; _print_expr whentrue; print_string " else ";
    _print_expr whenfalse  
  | StringLit str -> print_string str;
  | IdentExpr tk -> print_string tk.value
  | FunCall (expr, arglist) -> 
    print_string "(funcall ";
    print_expr expr;
    print_string "(arguments";
    List.iter _print_expr arglist;
    print_string ")";
  | LambdaExpr (params, _) ->
    print_string "(lambda (parameters";
    List.iter _print_expr params;
    print_string "))";

let rec expression parser = assignexpr parser

and assignexpr parser = 
  let (expr, parser) = ifexpr parser in
  let rec aux expr parser = 
    let tk = peek parser in
    match tk.typeof with
    | Equal | ConEqual -> 
    begin
      let parser = forward parser in
      match expr with
      | IdentExpr _ -> let (expr2, parser) = ifexpr parser in aux (Binary (expr, tk, expr2)) parser
      | _ -> raise (ParseError ("Cannot assign to an expression", tk))
    end
    | _ -> (expr, parser)
  in aux expr parser

and ifexpr parser =
  let (expr1, parser) = logical_or parser in
  if (peek parser).typeof = Question then begin
    let (expr2, parser) = ifexpr (forward parser) in
    let parser = consume Colon "Expected an else branch (colon ':')" parser in 
    let (expr3, parser) = ifexpr parser in
    (IfExpr (expr1, expr2, expr3), parser)
  end else 
    (expr1, parser) 

and logical_or parser = build_binary [Columns] logical_and parser

and logical_and parser = build_binary [Ampersands] equality parser

and equality parser = build_binary [EqualEqual; ExcEqual] relational parser

and relational parser = build_binary [Greater; GreatEqual; Lesser; LessEqual] basic parser

and basic parser = build_binary [Plus; Minus] factor parser

and factor parser = build_binary [Slash; Star; Modulo] unary parser

and unary parser =
  let tk = peek parser in
  match tk.typeof with
  | Exclamation | Plus | Minus | Hash -> 
  	let (expr, parser) = unary (forward parser) in
    (Unary (tk, expr), parser)
  | _ -> postary parser

and postary parser =
  let rec aux expr parser = 
    let tk = peek parser in
    match tk.typeof with
    | OParen -> begin
      match expr with
      | IdentExpr _ | FunCall _ | LambdaExpr _ ->
      let (expr, parser) = funcall expr (forward parser) in aux expr parser
      | _ -> raise (ParseError ("This value is not callable", tk))
    end
    | _ -> (expr, parser) 
      (* will add arrays indexing here later *)
  in
  let expr = primary parser in
  aux expr parser

and funcall expr parser = 
  let rec aux acc parser =
    let tk = peek parser in
    match tk.typeof with
    | CParen -> (acc, forward parser)
    | EOF -> raise (ParserError ("Expected a Closing Parenthesis ')'", tk))
    | _ -> begin 
      let (expr, parser) = expression parser in
      let tk = (peek parser) in 
      let parser =  
        match tk.typeof with 
        | Comma -> forward parser 
        | CParen -> parser 
        | _ -> (ParseError ("Expected a Comma ','", tk)) in 
      aux (expr::acc) parser
    end 
  in 
  let (l, parser) = aux [] parser in
  (FunCall (expr, List.rev l), parser)

and primary parser =
  let tk = peek parser in
  match tk.typeof with
  | FloatLiteral -> (FloatLit (float_of_string tk.value), forward parser)
  | StringLiteral -> (StringLit tk.value, forward parser)
  | Ident -> (IdentExpr tk, forward parser)
  | OParen -> lambda (forward parser)
  | _ -> raise (ParseError ("Expected an expression", tk))

and lambda parser =
  let (params, parser) = parameters parser in
  let length = List.length params in
  let tk = peek parser in
  let block_follows = match tk.typeof with OCurly -> true | _ -> false in
  match length with
  | 0 -> 
    if not block_follows 
      then raise (ParseError ("Expected an expression", tk)) 
    else
      let (body, parser) = block_stmt parser in 
      (Lambda (params, body), parser)
  | 1 -> 
    let is_ident = match List.hd params with IdentExpr _ -> true | _ -> false in 
    if is_ident && block_follows then
      let (body, parser) = block_stmt parser in
      (Lambda (params, body), parser)
    else
      (Grouping (List.hd params), parser)
  | len when len > 255 -> raise (ParseError ("No more than 255 parameters are allowed", tk))

and parameters parser =
  let rec aux acc parser =
    let tk = peek parser in
    match tk.typeof with
    | CParen -> (acc, forward parser) 
    | EOF -> raise (ParseError ("Expected a Closing Parenthesis ')'", tk))
    | _ -> begin
      let (expr, parser) = expression parser in
      match expr with
      | IdentExpr _ -> begin
        let tk = peek parser in
        let parser = match tk.typeof with
        | CParen -> parser
        | Comma -> forward parser
        | _ -> raise (ParseError ("Expected a Closing Parenthesis ')'", tk))
        in aux (expr::acc) parser 
      end
      | _ -> (acc, consume CParen "Expected a Closing Parenthesis ')'" parser)
    end
  in let (params, parser) = aux [] parser in (List.rev params, parser)

and grouping parser =
  let (expr, parser) = expression parser in
  let parser = consume CParen "Expected a Closing Parenthesis ')'" parser in
  (Grouping expr, parser)

and build_binary ops f parser =
  let (expr, parser) = f parser in 
  let rec aux expr parser =
    let op = peek parser in
    if List.mem op.typeof ops then
      let (expr2, parser) = f (forward parser) in
      let expr = (Binary (expr, op, expr2)) in
      aux expr parser
    else
      (expr, parser)
  in aux expr parser

let print_stmt parser = 
  let (expr, parser) = expression parser in (Print expr, parser)

let rec statement parser =
  let tk = peek parser in
    match tk.typeof with
    | EOF -> raise (ParseError ("Expected a statement", tk))
    | At -> print_stmt (forward parser)
    | Right -> loop_stmt (forward parser)
    | OCurly -> block_stmt parser
    | TwoQuestion -> if_stmt (forward parser)
    | TwoStar -> (Break tk, forward parser)
    | Left -> (Continue tk, forward parser)
    | _  -> expr_stmt parser

and loop_stmt parser =
  let (cond, parser)  = expression parser in
  let (block, parser) = statement parser in
  (LoopStmt (cond, block), parser)

and expr_stmt parser = 
  let (expr, parser) = expression parser in
  (Exprstmt expr, parser) 
  
and block_stmt parser =
  let parser = consume OCurly "Expected a block (opening curly bracket '{')" parser in
  let rec aux acc parser =
    let tk = (peek parser) in 
    match tk.typeof with
    | CCurly -> (acc, forward parser)
    | EOF -> raise (ParseError ("Expected a block limit (closing curly bracket '}')", tk)) 
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