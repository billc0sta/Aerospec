open Upl

let test_no_failure name program path =
	print_string "\n--- test_no_failure: "; 
	print_string name;
	print_string " ---\n"; 
	let lexer  = Lexer.make program  in
	let lexed  = Lexer.lex lexer     in
	let parser = Parser.make lexed path in
	let parsed = Parser.parse parser in
	let interpreter = Interpreter.make parsed in
	Interpreter.run interpreter

let () = 
	test_no_failure "if statements"
	"
	print(\"(expression=true), no else\\n\")
	print(\"expected: Hello!\\n\")
	print(\"output: \")
	?? (1) print(\"Hello!\\n\")
	print(\"\\n\")

	print(\"(expression=false), no else\\n\")
	print(\"expected: \\n\")
	print(\"output: \")
	?? (0) print(\"Hello!\\n\")
	print(\"\\n\")

	print(\"(expression=true), with else\\n\")
	print(\"expected: Hello!\\n\")
	print(\"output: \")
	?? (1) print(\"Hello!\\n\")
	:: print(\"Bye!\\n\")
	print(\"\\n\")

	print(\"(expression=false), with else\\n\")
	print(\"expected: Bye!\\n\")
	print(\"output: \")
	?? (0) print(\"Hello!\\n\")
	:: print(\"Bye!\\n\")
	" "";

	test_no_failure "loops"
	"
	i = 0
	print(\"expression=(0=(falsy))\\n\")
	print(\"expected: 0\\n\")
	print(\"output: \")
	>> 0 i = 1
	print(i, \"\\n\\n\")

	i = 0
	print(\"i=0, expression=(i<1=(truthy))\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \")
	>> i<1 i = 1
	print(i, \"\\n\\n\")

	i = 0
	print(\"i=0, expression=(i<100=(truthy))\\n\")
	print(\"expected: 100\\n\")
	print(\"output: \")
	>> i<100 i = i + 1
	print(i, \"\\n\\n\")
	" "";

	test_no_failure "return statements"
	"
	print(\"() {} - implicit nil return\\n\")
	print(\"expected: nil\\n\")
	print(\"output: \", (){}(), \"\\n\\n\")

	print(\"() {-> 1} - returns 1\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", (){-> 1}(), \"\\n\\n\")

	print(\"() {?? 0 -> 1} - conditional return with false\\n\")
	print(\"expected: nill\\n\")
	print(\"output: \", (){?? 0 -> 1}(), \"\\n\\n\")

	print(\"() {?? 1 -> 1} - conditional return with true\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", (){?? 1 -> 1}(), \"\\n\\n\")

	print(\"() {-> 1 -> 0} - non-reachable return \\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", (){-> 1 -> 0}(), \"\\n\\n\")
	" "";

	test_no_failure "break statements"
	"
	i = 0
	print(\"non-conditional break\\n\")
	print(\"expected: 0\\n\")
	print(\"output: \")
	>> 1 {** i = 1}
	print(i, \"\\n\\n\")

	i = 0
	print(\"conditional break with false\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \")
	>> i<1 {?? 0 ** i = 1}
	print(i, \"\\n\\n\")

	i = 0
	print(\"conditional break with true\\n\")
	print(\"expected: 0\\n\")
	print(\"output: \")
	>> 1 {?? 1 ** i = 1}
	print(i, \"\\n\\n\")
	" "";

	test_no_failure "continue statements"
	"
	i = 0
	print(\"non-coditional continue\\n\")
	print(\"expected: 100\\n\")
	print(\"output: \")
	>> i < 100 {i = i + 1 <<}
	print(i, \"\\n\\n\")

	i = 0
	print(\"coditional continue - skip odd numbers\\n\")
	print(\"expected: 02468\\n\")
	print(\"output: \")
	>> i < 9 { ?? (i % 2 == 1) {i = i + 1 <<} print(i) i = i + 1 }
	print(\"\\n\\n\")
	" "";

	test_no_failure "assignments"
	"
	x = 1 y = 2 z = 3
	print(\"simple assignment - x = 1 y = 2 z = 3\\n\")
	print(\"expected: 1, 2, 3\\n\")
	print(\"output: \", x, \", \", y, \", \", z, \"\\n\\n\")

	x = y = z = 1
	print(\"chained assignment - x = y = z =1\\n\")
	print(\"expected: 1, 1, 1\\n\")
	print(\"output: \", x, \", \", y, \", \", z, \"\\n\\n\")

	print(\"constant assignment - y := 2\\n\")
	print(\"expected: 2\\n\")
	print(\"output: \", y := 2, \"\\n\\n\")

	print(\"assignment in expression - >> (z = z + 1) < 100;\\n\")
	print(\"expected: 100\\n\")
	>> (z = z + 1) < 100;	
	print(\"output: \", z, \"\\n\\n\")

	print(\"nonlocal scope assignment - $x = 2\\n\")
	print(\"expected: 2\\n\")
	;() {$x=2}()
	print(\"output: \", x, \"\\n\")
	" "";

	test_no_failure "if expression"
	"
	res = 1 ? 1 : 0
	print(\"expression truthy\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", res, \"\\n\\n\")
	
	res = 0 ? 1 : 0
	print(\"expression falsy\\n\")
	print(\"expected: 0\\n\")
	print(\"output: \", res, \"\\n\\n\")

	res = 1 ? 1 ? 1 : 0 : 1 ? 1 : 0
	print(\"nested truthy/truthy\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", res, \"\\n\\n\")

	res = 1 ? 0 ? 1 : 0 : 1 ? 1 : 0
	print(\"nested truthy/falsy\\n\")
	print(\"expected: 0\\n\")
	print(\"output: \", res, \"\\n\\n\")
	
	res = 0 ? 1 ? 1 : 0 : 1 ? 1 : 0
	print(\"nested falsy/truthy\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", res, \"\\n\\n\")

	res = 0 ? 0 ? 1 : 0 : 0 ? 1 : 0
	print(\"nested falsy/falsy\\n\")
	print(\"expected: 0\\n\")
	print(\"output: \", res, \"\\n\")
	" "";

	test_no_failure "arrays"
	"
	arr = [1, 2, 3, 4, 5, 6]
	print(\"printing\\n\")
	print(\"expected: [1, 2, 3, 4, 5, 6]\\n\")
	print(\"output: \", arr, \"\\n\\n\")

	print(\"indexing - 1\\n\")
	print(\"expected: 2\\n\")
	print(\"output: \", arr[1], \"\\n\\n\")

	print(\"ranging - arr[:] begin and end omitted\\n\")
	print(\"expected: [1, 2, 3, 4, 5, 6]\\n\")
	print(\"output: \", arr[:], \"\\n\\n\")

	print(\"ranging - arr[1:] end omitted\\n\")
	print(\"expected: [2, 3, 4, 5, 6]\\n\")
	print(\"output: \", arr[1:], \"\\n\\n\")

	print(\"ranging - arr[:3] begin omitted\\n\")
	print(\"expected: [1, 2, 3]\\n\")
	print(\"output: \", arr[:3], \"\\n\\n\")

	arr[3] = 100
	print(\"index assigning - arr[3] = 100\\n\")
	print(\"expected: [1, 2, 3, 100, 5, 6]\\n\")
	print(\"output: \", arr, \"\\n\\n\")

	print(\"len()\\n\")
	print(\"expected: 6\\n\")
	print(\"output: \", len(arr), \"\\n\")
	" "";

	test_no_failure "lambdas (functions)"
	"
	itself := (x) {-> x}
	square := (x) {-> x*x}
	sumall := (x) {res = 0 i = 0 >> i < len(x) {res = res + x[i] i = i + 1} -> res}
	multiply := (x, y) {-> x*y}
	recursive := (x) {?? x >= 10 -> x :: -> recursive(x+1)}
	
	print(\"one argument - returns parameter\\n\")
	print(\"expected: 1\\n\")
	print(\"output: \", itself(1), \"\\n\\n\")

	print(\"one argument - squares parameter\\n\")
	print(\"expected: 25\\n\")
	print(\"output: \", square(5), \"\\n\\n\")
	
	print(\"one argument - sums sequence parameter\\n\")
	print(\"expected: 10\\n\")
	print(\"output: \", sumall([1,2,3,4]), \"\\n\\n\")

	print(\"two argument - multiplies two parameters\\n\")
	print(\"expected: 200\\n\")
	print(\"output: \", multiply(10, 20), \"\\n\\n\")

	print(\"one argument - recurses upon parameter until reaches 10\\n\")
	print(\"expected: 10\\n\")
	print(\"output: \", recursive(0), \"\\n\")
	" "";