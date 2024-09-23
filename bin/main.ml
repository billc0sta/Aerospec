open Upl


(*"
factorial(n) -> | n == 0 ? 1 | n > 0 ? n * factorial(n - 1)

fibonacci(n) -> | n == 0 ? 0 | n == 1 ? 1 | fibonacci(n - 1) + fibonacci(n - 2)

power(base, exp) -> | exp == 0 ? 1 | base * power(base, exp - 1)

sumArray(arr) -> (0 < i < #arr; ; arr.i + sumArray(arr.i + 1))

maxArray(arr) -> (0 < i < #arr; ; | arr.i > maxArray(arr.i + 1) ? arr.i | maxArray(arr.i + 1))
"*)

(*
let rec print_all = function
	| [] -> ()
	| x::xs -> print_string (Lexer.(nameof x.typeof)); print_all xs
*)

let (expr, _) = Parser.expression parser
let () = Parser.print_expr expr