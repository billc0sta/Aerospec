open Parser

type anz = {raw: statement list; inp: Interpreter.t; in_loop: bool; in_if: bool	}

exception AnalyzeError of string * Lexer.token
exception AnalyzeWarning of string * Lexer.token

let make raw = {raw; inp=Interpreter.make raw; in_loop=false; in_if=false}

let rec analyze_expr expr anz =
	match expr with
	| Binary (expr1, op, expr2) -> begin
		match op.typeof with
		| Equal | ConEqual -> assign_expr expr1 expr2 anz  
		| _ -> analyze_expr expr1 anz; analyze_expr expr2 anz
		end
	| Unary (_, expr) -> analyze_expr expr anz
	| Grouping expr -> analyze_expr expr anz
	| IfExpr (expr1, expr2, expr3) -> ifexpr expr1 expr2 expr3 anz
	| _ -> assert false;

and ifexpr expr1 expr2 expr3 anz = 
	try
		let ev = (Interpreter.truth (Interpreter.evaluate expr1 anz.inp)) in
		let strified = Interpreter.stringify_expr ev in
		raise (AnalyzeWarning (("::This condition will always evaluate to "^strified), ))
	with Interpreter.RuntimeError _
		-> analyze_expr expr2 anz; analyze_expr expr3 anz

and assignexpr expr1 expr2 anz =
	match expr1 with
	| IdentExpr _ -> analyze_expr expr2 anz
	| _ -> raise (AnalyzeError ("::Cannot assign to an expression"))

let rec analyze_statement stmt anz =
 	match stmt with
	| Print expr -> analyze_expr expr anz
	| Exprstmt expr -> analyze_expr expr anz
	| IfStmt (cond, whentrue, whenfalse) -> begin
		let anz = {anz with in_if=true} in
		analyze_expr (IfExpr (cond, FloatLit 1.0, FloatLit 1.0)) anz;
		analyze_statement whentrue anz;
		match whenfalse with 
		| None -> () 
		| Some statement -> analyze_statement statement anz 
		end
	| Block stmts -> analyze {anz with raw=stmts}
	| LoopStmt (cond, block) -> begin
		let anz = {anz with in_loop=true} in
		analyze_expr cond anz;
	  analyze_statement block anz
		end 
	| Break -> begin 
		if not anz.in_loop 
			then raise (AnalyzeError ("::Break statement outside of loop"))
		else if not anz.in_if then
			raise (AnalyzeError ("::Some parts of code is unreachable")) 
	end
	| Continue -> begin
		if not anz.in_loop then
			raise (AnalyzeError ("::Continue statement outside of loop"))
		else if not anz.in_if then
			raise (AnalyzeError ("::Some parts of code is unreachable"))
	end

and analyze anz =
	let rec aux = function
		| [] -> ()
		| x::xs -> analyze_statement x anz; aux xs
	in aux anz.raw