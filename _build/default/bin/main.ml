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

let parser = Parser.make [
  {value="3"; typeof=Literal; line=1; pos=1};         (* Simple literal *)
  {value="+"; typeof=Plus; line=1; pos=2};            (* Addition *)
  {value="4"; typeof=Literal; line=1; pos=3};         (* Another literal *)
  {value="*"; typeof=Star; line=1; pos=4};            (* Multiplication *)
  {value="2"; typeof=Literal; line=1; pos=5};         (* Another literal *)
  {value="-"; typeof=Minus; line=1; pos=6};           (* Subtraction *)
  {value="("; typeof=OpenParen; line=1; pos=7};       (* Opening parenthesis *)
  {value="5"; typeof=Literal; line=1; pos=8};         (* Another literal inside grouping *)
  {value=")"; typeof=CloseParen; line=1; pos=9};      (* Closing parenthesis *)
  {value=""; typeof=EOF; line=1; pos=10}               (* End of file *)
]


let (expr, _) = Parser.expression parser
let () = Parser.print_expr expr