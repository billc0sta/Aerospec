open Lexer

type expr =
  | FloatLit of float
  | StringLit of string
  | Binary of expr * token * expr
  | Unary of token * expr
  | IdentExpr of token * bool
  | IfExpr of expr * expr * expr
  | FunCall of expr * expr list * token
  | LambdaExpr of expr list * statement * token
  | ArrExpr of expr list * token
  | Subscript of expr * (expr * expr option) * token
  | Range of expr * token * expr * token * expr
  | ObjectExpr of statement list
  | PropertyExpr of expr * expr
  | Builder of expr * expr * expr
  | NilExpr

and statement = 
  | Exprstmt of expr
  | IfStmt of expr * statement * statement option
  | LoopStmt of expr * statement
  | Block of statement list
  | Break of token
  | Continue of token
  | NoOp of token
  | Return of expr * token

type t = {
  raw: token list;
  previous: token;
  pos: int;
  path: string;
  program: string;
  errors: exn list;
}

exception ParseError of string * string * string * int
exception ParseErrors of exn list

let make raw path program = {program; raw; path; errors=[]; previous={value="";typeof=Unknown;line=0;pos=0}; pos=0}

let peek parser = List.hd parser.raw

let forward parser = 
  if (List.hd parser.raw).typeof = EOF then parser else
  {parser with previous=List.hd parser.raw; raw=List.tl parser.raw; pos=parser.pos+1}

let report_error message parser = 
  let tk = peek parser in
  let lineof = Utils.get_line tk.pos parser.program in
  raise (ParseError(message, parser.path, lineof, tk.line))

let consume typeof error parser =
	if (peek parser).typeof = typeof then forward parser else report_error error parser

let next_stmt parser =
  let rec aux parser =
    match (peek parser).typeof with 
    | Right       | OCurly  | Semicolon 
    | TwoQuestion | TwoStar | Left 
    | Arrow       | EOF     | CCurly -> parser
    | _  -> aux (forward parser)
  in aux parser

let rec print_parsed l = 
  let rec aux stmt =
    match stmt with
    | Exprstmt expr -> print_expr expr; print_string "\n"
    | IfStmt (expr, whentrue, whenfalse) -> 
      print_string "if "; 
      print_expr expr; 
      print_string " do \n"; 
      aux whentrue;
      begin
      match whenfalse with
      | None -> ()
      | Some block -> print_string "else do \n"; aux block
      end;
      print_string "if_end\n"
    | Block block -> print_parsed block;
    | LoopStmt (cond, block) -> 
      print_string "loop ";
      print_expr cond;
      print_string " do \n";
      aux block;
      print_string "loop_end";
    | Break _ -> print_string "break\n"
    | Continue _ -> print_string "continue\n"
    | NoOp _ -> print_string "no op\n"
    | Return (expr, _) -> print_string "return "; print_expr expr; print_string "\n";
    ;
  in
  match l with
  | [] -> ()
  | x::xs -> aux x; print_parsed xs

and print_expr expr =
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
  | IfExpr (cond, whentrue, whenfalse) -> 
    print_string "if "; print_expr cond;
    print_string " then "; print_expr whentrue; print_string " else ";
    print_expr whenfalse  
  | StringLit str -> print_string ("\""^str^"\"");
  | IdentExpr (tk, global) -> if global then print_string "global "; print_string tk.value
  | FunCall (expr, arglist, _) -> 
    print_string "(funcall (name ";
    print_expr expr;
    print_string ")";
    print_string "(arguments";
    List.iter (fun expr -> print_string " "; print_expr expr) arglist;
    print_string "))";
  | LambdaExpr (params, body, _) ->
    print_string "(lambda (parameters";
    List.iter (fun expr -> print_string " "; print_expr expr) params;
    print_string ") (body ";
    begin
    match body with
    | Block stmts -> print_parsed stmts;
    | _ -> assert false;
    end;
    print_string "))"
  | ArrExpr (exprs, _) ->
    print_string "[";
    List.iter (fun expr -> print_string " "; print_expr expr) exprs;
    print_string " ]"
  | Subscript (expr, subexpr, _) ->
    print_expr expr;
    print_string "(subscript [";
    print_expr (fst subexpr);
    let () = match (snd subexpr) with
    | None -> ()
    | Some expr -> print_string ":"; print_expr expr in
    print_string "])"
  | Range (expr1, tk1, ident, tk2, expr2) ->
    print_string "(range ";
    print_expr expr1;
    print_string (nameof tk1.typeof);
    print_expr ident;
    print_string (nameof tk2.typeof);
    print_expr expr2;
    print_string ")"
  | ObjectExpr stmts ->
    print_string "(object \n";
    print_parsed stmts;
    print_string ")"
  | PropertyExpr (expr, ident) ->
    print_string "(access property ";
    print_expr ident;
    print_string " of ";
    print_expr expr;
    print_string ")"
  | NilExpr ->
    print_string "nil"
  | Builder (range, cond, expr) ->
    print_string "(builder ";
    print_expr range;
    print_string ";";
    print_expr cond;
    print_string ";";
    print_expr expr;
    print_string ")"
    
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
      | Subscript (_, (_, None), _) | IdentExpr _ | PropertyExpr _ -> 
        let (expr2, parser) = assignexpr parser in 
        aux (Binary (expr, tk, expr2)) parser
      | _ -> report_error "Cannot assign to an expression" parser 
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

and logical_and parser = build_binary [TwoAmper] equality parser

and equality parser = build_binary [EqualEqual; ExcEqual] relational parser

and relational parser = 
  let (expr, parser) = basic parser in
  let tk1 = peek parser in
  match tk1.typeof with
  | Greater | GreatEqual | Lesser | LessEqual -> 
  begin
    let (expr2, parser) = basic (forward parser) in
    let tk2 = peek parser in
    match tk2.typeof with
    | Greater | GreatEqual | Lesser | LessEqual ->
    begin
      let ident = match expr2 with
      | IdentExpr (_, global) -> 
        if global then report_error "Global identifier cannot be used in this context" parser
        else expr2
      | _ -> report_error "Expected an identifier" parser
      in
      let () = match (tk1.typeof, tk2.typeof) with
        | (Lesser, Lesser)
        | (LessEqual, Lesser)
        | (Lesser, LessEqual)
        | (LessEqual, LessEqual)
        | (Greater, Greater)
        | (Greater, GreatEqual)
        | (GreatEqual, Greater)
        | (GreatEqual, GreatEqual) -> ()
        | _ -> 
          report_error ("operators '"^Lexer.nameof tk1.typeof^"' and '"^Lexer.nameof tk2.typeof^"' cannot be in the same range expression") parser
      in
      let (expr3, parser) = basic (forward parser) in
      (Range (expr, tk1, ident, tk2, expr3), parser)
    end
    | _ -> (Binary (expr, tk1, expr2), parser)
  end
  | _ -> (expr, parser)

and basic parser = build_binary [Plus; Minus] factor parser

and factor parser = build_binary [Slash; Star; Modulo] unary parser

and unary parser =
  let tk = peek parser in
  match tk.typeof with
  | Exclamation | Plus | Minus | Tilde | Amper | TwoAmper -> 
     let (expr, parser) = unary (forward parser) in
    (Unary (tk, expr), parser)
  | Hash -> 
    let (expr, parser) = primary (forward parser) in
    (Unary (tk, expr), parser) 
  | _ -> postary parser

and postary parser =
  let rec aux expr parser = 
    let tk = peek parser in
    match tk.typeof with
    | OParen -> begin
      match expr with
      | StringLit _ | FloatLit _ | Binary _ | Unary _ | ArrExpr _ | Range _ | NilExpr
        -> report_error "This value is not callable" parser
      | _ -> let (expr, parser) = funcall expr (forward parser) in aux expr parser
    end
    | OSquare ->
      let (expr, parser) = subscript expr (forward parser) in aux expr parser
    | Dot -> begin
      let (expr2, parser) = primary (forward parser) in
      match expr2 with
      | IdentExpr (_, global) -> 
        if global 
        then report_error "Global identifier cannot be used in this context" parser 
        else aux (PropertyExpr (expr, expr2)) parser
      | _ ->
        report_error "Expected an identifier" parser 
    end
    | _ -> (expr, parser) 
  in
  let (expr, parser) = primary parser in
  aux expr parser

and subscript expr parser =
  let tk = peek parser in
  let (subexpr, parser) =
    let (beginning, parser) = 
    match tk.typeof with
    | Colon -> (FloatLit (Float.neg_infinity), parser)
    | _ -> expression parser in
    let (endof, parser) =
    match (peek parser).typeof with
    | Colon -> begin
      let parser = forward parser in
      match (peek parser).typeof with
      | CSquare -> (Some (FloatLit (Float.infinity)), parser)
      | _ -> let (expr, parser) = expression parser in (Some expr, parser)
    end
    | _ -> (None, parser)
    in ((beginning, endof), parser)
  in
  let parser = consume CSquare "Expected a Closing Square Bracket here? ']'" parser in
  (Subscript (expr, subexpr, tk), parser)

and funcall expr parser = 
  let tk = peek parser in
  let rec aux acc parser =
    let tk = peek parser in
    match tk.typeof with
    | CParen -> (acc, forward parser)
    | EOF -> report_error "Expected a Closing Parenthesis ')'" parser
    | _ -> begin 
      let (expr, parser) = expression parser in
      let tk = (peek parser) in 
      let parser =  
        match tk.typeof with 
        | Comma -> forward parser 
        | CParen -> parser 
        | _ -> report_error "Expected a Comma ','" parser in 
      aux (expr::acc) parser
    end 
  in 
  let (l, parser) = aux [] parser in
  (FunCall (expr, List.rev l, tk), parser)

and primary parser =
  let tk = peek parser in
  match tk.typeof with
  | FloatLiteral -> (FloatLit (float_of_string tk.value), forward parser)
  | StringLiteral -> (StringLit tk.value, forward parser)
  | Ident -> (IdentExpr (tk, false), forward parser)
  | OParen -> lambda_expr (forward parser)
  | OSquare -> array_expr (forward parser)
  | OCurly -> object_expr parser 
  | Dollar -> begin
    let parser = forward parser in
    let token = peek parser in
    match token.typeof with
    | Ident -> (IdentExpr (token, true), forward parser)
    | _ -> report_error "Expected an identifier" parser
  end
  | Underscore -> (NilExpr, forward parser)
  | _ -> report_error "Expected an expression" parser

and object_expr parser =
  let (block, parser) = block_stmt parser in
  match block with
  | Block stmts -> (ObjectExpr stmts, parser)
  | _ -> assert false;

and array_expr parser =
  let rec aux exprs parser =
    let tk = peek parser in
    match tk.typeof with
    | CSquare -> (exprs, forward parser)
    | Comma -> begin
        let (expr, parser) = expression (forward parser) in
        aux (expr::exprs) parser 
        end
    | _ -> report_error "Expected a Comma ',' or a Closing Square Bracket ']'" parser
  in

  let tk = peek parser in
  match tk.typeof with
  | CSquare -> (ArrExpr([], tk), forward parser)
  | _ ->
    let (expr, parser) = expression parser in
    if match expr with Range _ -> true | _ -> false
    then builder_expr expr parser 
    else
  let (exprs, parser) = aux [expr] parser in
  (ArrExpr (List.rev exprs, tk), parser)

and builder_expr range parser =
  let parser = consume Semicolon "Expected a semicolon ';'" parser in
  let (condition, parser) = 
    match (peek parser).typeof with
    | Semicolon -> (FloatLit 1.0, parser)
    | _ -> expression parser
  in
  let parser = consume Semicolon "Expected a semicolon ';'" parser in
  let (expr, parser) = expression parser in
  let parser = consume CSquare "Expected a Closing Square Bracket ']'" parser in
  (Builder (range, condition, expr), parser)


and lambda_expr parser =
  let (params, parser) = parameters parser in
  let length = List.length params in
  let tk = peek parser in
  let block_follows = match tk.typeof with OCurly -> true | _ -> false in
  match length with
  | 0 -> begin
      if not block_follows 
      then report_error "Expected an expression between parenthesis" parser 
      else
        let (body, parser) = block_stmt parser in 
        (LambdaExpr (params, body, tk), parser) 
    end
  | 1 -> begin
      let is_ident = match List.hd params with IdentExpr (_, false) -> true | _ -> false in 
      if is_ident && block_follows then
        let (body, parser) = block_stmt parser in
        (LambdaExpr (params, body, tk), parser)
      else
        (List.hd params, parser)
    end 
  | len when len > 255 -> report_error "No more than 255 parameters are allowed" parser
  | _ -> begin
      let dup =
        Utils.list_dup_at (fun e -> match e with | IdentExpr (tk, false) -> tk.value | _ -> assert false;)
                          params
      in
      let () = match dup with
      | None -> ()
      | Some name -> report_error ("Duplicate parameter name '"^name^"' in function definition") parser
      in
      let (body, parser) = block_stmt parser in 
      (LambdaExpr (params, body, tk), parser) 
    end
and parameters parser =
  let rec aux acc parser =
    let tk = peek parser in
    match tk.typeof with
    | CParen -> (acc, forward parser) 
    | EOF -> report_error "Expected a Closing Parenthesis ')'" parser
    | _ -> begin
        let (expr, parser) = expression parser in
        match expr with
        | IdentExpr (_, false) -> begin
            let tk = peek parser in
            let parser = match tk.typeof with
              | CParen -> parser
              | Comma -> forward parser
              | _ -> report_error "Expected a Closing Parenthesis ')'" parser
            in aux (expr::acc) parser 
          end
        | _ -> if List.length acc <> 0 then
                 report_error "Unexpected expression in parameter list" parser
               else
                 (expr::acc, consume CParen "Expected a Closing Parenthesis ')'" parser)
      end
  in let (params, parser) = aux [] parser in (List.rev params, parser)

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

and statement parser =
  let tk = peek parser in
  try
    match tk.typeof with
    | EOF -> report_error "Expected a statement" parser
    | Right -> loop_stmt (forward parser)
    | OCurly -> block_stmt parser
    | TwoQuestion -> if_stmt (forward parser)
    | TwoStar -> (Break tk, forward parser)
    | Left -> (Continue tk, forward parser)
    | Arrow -> let (expr, parser) = expression (forward parser) in (Return (expr, tk), parser)
    | Semicolon -> ((NoOp tk), (forward parser))
    | _  -> expr_stmt parser
  with ParseError (message, path, lineof, linenum) -> 
    (Exprstmt (NilExpr), next_stmt {(forward parser) with errors=(ParseError (message, path, lineof, linenum))::parser.errors})

and loop_stmt parser =
  let (cond, parser)  = expression parser in
  let (block, parser) = statement parser in
  (LoopStmt (cond, block), parser)

and expr_stmt parser = 
  let (expr, parser) = expression parser in
  let rec aux expr =
    match expr with
    | Builder (range, cond, expr) ->
      let instmt = aux expr in 
      let stmt = match cond with 
        | FloatLit 1.0 -> instmt (* 1.0 is a sentinel for omittion *) 
        | _ -> IfStmt (cond, instmt, None) 
      in
      (LoopStmt (range, stmt))
    | _ -> Exprstmt expr
  in (aux expr, parser)
  
and block_stmt parser =
  let parser = consume OCurly "Expected a block (opening curly bracket '{')" parser in
  let rec aux acc parser =
    let tk = (peek parser) in 
    match tk.typeof with
    | CCurly -> (acc, forward parser)
    | EOF -> report_error "Expected a Closing Curly Bracket '}'" parser 
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

and parse parser =
  let rec aux acc parser =
    if (peek parser).typeof = EOF then (acc, parser.errors) else
    let (stmt, parser) = statement parser in 
    let acc = match stmt with NoOp _ -> acc | _ -> stmt::acc 
    in aux acc parser
  in 
  let (stmts, errors) = aux [] parser in
  if errors <> [] then raise (ParseErrors (List.rev errors))
  else List.rev stmts 
