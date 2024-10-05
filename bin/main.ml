open Upl

let rec print_lexed l = 
	match l with
	| [] -> ()
	| x::xs -> Lexer.(Printf.printf "{value=\"%s\"; typeof=\"%s\"; pos=%d; line=%d}\n" x.value (nameof x.typeof) x.pos x.line); print_lexed xs

let print_error from message (token: Lexer.token) program =

	let rec get_line start_pos end_pos =
	  let nstart_pos = if program.[start_pos] = '\n' || start_pos - 1 < 0 then start_pos else start_pos - 1 in
	  let nend_pos = if program.[end_pos] = '\n' || end_pos + 1 >= String.length program then end_pos else end_pos + 1 in
	  if nstart_pos = start_pos && nend_pos = end_pos then
	    (nstart_pos, nend_pos)
	  else
	    get_line nstart_pos nend_pos
	in 

	let line = begin 
		match token.typeof with 
		| EOF -> "End Of File" 
		| _ -> let (start_pos, end_pos) = get_line token.pos token.pos 
					 in String.sub program (start_pos+1) (end_pos - start_pos - 2)
	end in
	print_string ("\n::"^from^"\n");
	print_string ("  at line: "^string_of_int (token.line)^"\n");
	print_string ("  here --\" "^line^" \"-- \n");
	print_string ("  "^message^"\n---------------------------")


let program =
"
mandelbrot := (cx, cy, max_iter) {
    zx = zy = iter = 0
    >> (zx * zx + zy * zy <= 4 && iter < max_iter) {
        xtemp = zx * zx - zy * zy + cx
        zy = 2 * zx * zy + cy
        zx = xtemp
        iter = iter + 1
    }
    -> iter
}

generate_mandelbrot := (width, height, max_iter, x_min, x_max, y_min, y_max) {
    x_range := (x_max - x_min) / width
    y_range := (y_max - y_min) / height
    i = 0
    >> (i < height) {
        j = 0
        >> (j < width) {
            cx = x_min + j * x_range
            cy = y_min + i * y_range
            iter = mandelbrot(cx, cy, max_iter)
            
            ?? (iter == max_iter) print(\"*\")
            :: print(\" \")

            j = j + 1
        }
        print(\"\n\")
        i = i + 1
    }
}

width := 80
height := 40
max_iter := 100
x_min := -2.5
x_max := 1
y_min := -1
y_max := 1

generate_mandelbrot(width, height, max_iter, x_min, x_max, y_min, y_max)
"

let execute program debugging =
	let lexer = Lexer.make program in
	try 
		let lexed = Lexer.lex lexer in
		if debugging then print_lexed lexed;
	let parser = Parser.make lexed in
	try
		let parsed = Parser.parse parser in
		if debugging then begin
			Parser._print_parsed parsed;
		end ;
	let intp = Interpreter.make parsed in
	try 
		Interpreter.run intp
	with
	| Interpreter.RuntimeError (message, token) ->
		print_error "Runtime Error" message token program
	with
	| Parser.ParseError (message, token) -> 
		print_error "Syntax Error" message token program
	with 
	| Lexer.LexError (message, token) ->
		print_error "Syntax Error" message token program

let () = execute program false

(* TODO-list:
1. add index assignment
2. add ranging
3. add builders
4. add sequence native functions
5. add pipeline operator '|>'
*)