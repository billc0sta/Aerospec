Aerospec is a programming language that blends between functional and imperative programming in a natural manner. it supports imperative, procedural, functional and a flavor of prototype-based OOP. with a minimal symbolic syntax; it heavily encourages declarative and "golfy" coding
## Table of contents
1. [Installation](#Installation)
2. [Usage](#Usage)
3. [Syntax](#Syntax)
4. [Comments](#Comments)
5. [Identifiers](#Identifiers)
6. [Assignment](#Assignment)
	1. [Variable assignment](#Variable%20assignment)
	2. [Constant assignment](#Constant%20assignment)
	3. [Chaining assignments](#Chaining%20assignments)
7. [Data-Types](#Data-Types)
8. [Type-of operator](#Type-of%20operator)
9. [Floats](#Floats)
	1. [Basic arithmetic](#Basic%20arithmetic)
	2. [Float standard library](#Float%20standard%20library)
		1. [Float.inf](#Float.inf)
		2. [Float.nan](#Float.nan)
10. [Booleans](#Booleans)
	1. [Equality](#Equality)
	2. [Comparison](#Comparison)
	3. [Logical not](#Logical%20not)
	4. [Bool standard library](#Bool%20standard%20library)
		1. [Bool.false](#Bool.false)
		2. [Bool.true](#Bool.true)
		3. [Bool.truth](#Bool.truth)
11. [Strings](#Strings)
	1. [String indexing](#String%20indexing)
	2. [String slicing](#String%20slicing)
	3. [String concatenation](#String%20concatenation)
	4. [String index-assignment](#String%20index-assignment)
	5. [String locking](#String%20locking)
	6. [String utf-8 encoding](#String%20utf-8%20encoding)
	7. [String escape characters](#String%20escape%20characters)
	8. [String standard library](#String%20standard%20library)
		1. [String.len](#String.len)
		2. [String.insert](#String.insert)
		3. [String.extend](#String.extend)
		4. [String.merge](#String.merge)
		5. [String.index](#String.index)
		6. [String.pop](#String.pop)
		7. [String.remove](#String.remove)
		8. [String.clear](#String.clear)
		9. [String.count](#String.count)
		10. [String.repr](#String.repr)
12. [Operators](#Operators)
13. [Arrays](#Arrays)
	1. [Array indexing](#Array%20indexing)
	2. [Array slicing](#Array%20slicing)
	3. [Array concatenation](#Array%20concatenation)
	4. [Array index-assignment](#Array%20index-assignment)
	5. [Array locking](#Array%20locking)
	6. [Array deep-locking](#Array%20deep-locking)
	7. [Array standard library](#Array%20standard%20library)
		1. [Array.len](#Array.len)
		2. [Array.append](#Array.append)
		3. [Array.extend](#Array.extend)
		4. [Array.merge](#Array.merge)
		5. [Array.index](#Array.index)
		6. [Array.pop](#Array.pop)
		7. [Array.remove](#Array.remove)
		8. [Array.clear](#Array.clear)
		9. [Array.count](#Array.count)
14. [Nil](#Nil)
15. [Block statement](#Block%20statement)
16. [If...else statement](#If_else%20statement)
17. [If...else expression](#If_else%20expression)
18. [Loop](#Loop)
19. [Continue](#Continue)
20. [Break](#Break)
21. [Range loop](#Range%20loop)
22. [Builder](#Builder)
23. [Scope](#Scope)
24. [Functions](#Functions)	
	1. [Parameters](#Parameters)
	2. [Function calls](#Function%20calls)
	3. [First-class](#First-class)
	4. [Return](#Return)
	5. [Native functions](#Native%20functions)
	6. [Closures (nested functions)](#Closures%20nested%20functions)
	7. [Recursion](#Recursion)
25. [Global access](#Global%20access)
26. [Global assignment](#Global%20assignment)
27. [NO-OP statement](#NO-OP%20statement)
28. [Objects](#Objects)
	1. [Object initialization](#Object%20initialization)
	2. [Object copying](#Object%20copying)
	3. [Methods](#Methods)
	4. [Property access](#Property%20access)
	5. [Property assignment](#Property%20assignment)
	6. [Object locking](#Object%20locking)
	7. [Object deep-locking](#Object%20deep-locking)
	8. [Object standard library](#Object%20standard%20library)
		1. [Object.fields](#Object.fields)
29. [Importing](#Importing)
30. [Miscellaneous standard libraries](#Miscellaneous%20standard%20libraries)
	1. [IO standard library](#IO%20standard%20library)
	2. [Time standard library](#Time%20standard%20library)
	3. [Value standard library](#Value%20standard%20library)
31. [Ideas for future releases](#Ideas%20for%20future%20releases)
32. [Implementation](#Implementation)
## Installation
Go to [Releases](https://github.com/billc0sta/Aerospec/releases/) page and download the latest version.   
for now, Aerospec is only compiled for Windows.  
it needs to be re-built if you're using another OS.
## Usage
To run programs:
```
Aerospec program.aero
```
as of v0.1.0, Aerospec doesn't yet support command line arguments, See [Ideas for future releases](#Ideas_for_future_releases).
## Syntax
Aerospec favors minimal symbolic syntax over traditional keyword-based syntax, for example:
```
separate_evens_odds := (arr) {
    evens := []
    odds  := []
    >> (0 <= i < Array.len(arr)) {
		?? (arr[i] % 2 == 0) Array.append(evens, arr[i])
		:: Array.append(odds, arr[i]) 
	}
	-> [evens, odds]
}
```
is equivalent to Python's
```Python
def separate_evens_odds(arr: list[int]) -> list[list[int]]:
	evens = []
	odds  = []
	for i in range(len(arr)):
		if arr[i] % 2 == 0: evens.append(arr[i])
		else: odds.append(arr[i])
	return [evens, odds]
```
whitespace is optional and of no significance.   
it favors braces over `do...end` clauses.
there's no special syntax for function definitions (`def`, `func`, etc.); functions are nothing but lambda values bound to variable or constant names, emphasizing the first-class nature of functions.   
aerospec syntax is designed in a way that makes it unnecessary to have any statement separation;
this is allowed: `a = 0 IO.print(a)`.   
however, there might be times where there's syntactic ambiguity:
```
a = b [1] // (a = b[1]) or (a = b) ([1])??
```
for that use a [NO-OP](#NO-OP) statement or simply put the expression between parenthesis.
## Comments
Aerospec adopts C-like commenting style, example:
```
// Here starts the program

// prints "Hello, World!" to the command line
IO.print("Hello, World!") // print from IO stdlib

// Here ends the program 
```
as of v0.1.0, there's no multiline comments in aerospec.
## Identifiers
In aerospec, Identifiers are case-sensitive names bound to values and can be used wherever an expression is allowed.   
starts with either Underscore (`_`) or an alpha character (`A->Z`, `a->z`).   
cannot have their first character as a digit, but is allowed in the remaining of the identifier.  
cannot be named `_`, because it's a reserved constant for the [Nil](#Nil) value.
## Assignment
Assignment is the operation of binding a value to an identifier in the current [Scope](#Scope). 
In Aerospec, Variables and Constants are implicitly declared, i.e. There's no specialized operation to declare a variable, Assigning to an unbound identifier pops it into existence.   
Following C-like languages; assignment is an expression, not a statement: this is allowed
```
a = 0
>> (a = a + 1) < 10
    IO.print(a, "\n")
```
### Variable assignment
Variable assignment is binding a value to a either a non-existent or a non-constant Identifier which can later be re-assigned in the same scope.    
example:
```
a = 5
b = a * a
a = 15
IO.print(b + a) // 40
```
### Constant assignment
Constant assignment is binding a value to non-existent or a non-constant Identifier which
cannot later be assigned in the same scope.
Variables can be re-assigned as constants in the same scope but not vice versa.
Constant assignment does not prevent mutation of reference values (Strings, Array, Objects);
and only prevents re-assignment of the identifier in the same scope.   
Constants can be re-assigned in a different scope
example:
```
a := "Hello, World" // `:=` is for constant assignment
a := "Goo" // error

b = 123 // is a variable
b = 0   // can be re-assigned

b := 123 // now a constant for good
b  = 0   // error
```
### Chaining assignments
Chaining assignments is allowed.   
example:
```
a = b := c = d = 10
IO.print(a + b + c + d) // 40
```

Be careful when using a reference value as the right-hand of a chained assignment, since it binds all the identifiers to the same value:
```
a = b = c = []
Array.append(a, 123)
IO.print("a: ", a, "\n") // [123]
IO.print("b: ", b, "\n") // [123]
IO.print("c: ", c, "\n") // [123]
```
## Data-Types
As of v0.1.0, Aerospec has 8 eight built-in data types, which are:
1. Floats
2. Booleans
3. Strings
4. Arrays
5. Functions
6. Native Functions
7. Objects
8. Nil
Aerospec is dynamically and strongly typed, although somehow flexible, it doesn't try to suppress type errors at all costs.
## Type-of operator
Type-of operator is a unary operator which evaluates to the type name of the value in a string representation, mostly used for runtime type-checking.  
example:
```
IO.print(~123, "\n")            // float
IO.print(~123.23, "\n")         // float
IO.print(~"Hello, World", "\n") // string
IO.print(~IO.print, "\n")       // native
IO.print(~(){}, "\n")           // function
IO.print(~{}, "\n")             // object
IO.print(~true, "\n")           // bool
IO.print(~_, "\n")              // nil
```
## Floats
although integer literals exist, as of v0.1.0, All numeric values are represented as 64bit float, This is might change in the future, See [Ideas for future releases](#Ideas%20for%20future%20releases).
### Basic arithmetic
Floats supports the gang of five binary arithmetic operators, which are:
- Plus (`+`)
- Minus (`-`)
- Multiply (`*`)
- Divide (`/`)
- Modulo (`%`)
and the unary operators: `-` and `+`.
### Float standard library
the standard library for float utilities
#### Float.inf
infinity trap value, negative version can simply be obtained as: `-Float.inf`
#### Float.nan
NaN trap value

example:
```
a := 4 + 18 / (3 * 2) - 5
b := (15 % 4) * 5
IO.print(a + b) // 15
IO.print(Float.nan == Float.nan) // false
```
## Booleans
Booleans are types with two possible values representing truth and falsity,  
It's the resulting value of Equality, Relational comparison and Logical not operators,
there are no `true`,`false` keywords in aerospec, instead they're replaced by the Bool standard library constants `true` and `false`
### Equality
Equality operators are: Equal(`==`), Not-Equal(`!=`), Used to check the equality of two values.  
- Two floats are equal if they're equal to each other and not `NaN`.
- Two Booleans are equal if they're both `false` or `true`.
- Two strings are equal if both contain the same characters in the same positions.
- Two arrays are equal if the length of both arrays are equal and `arr1[i] == arr2[i]` for every `i` in length.
- Two Nils are equal.
- Function is never equal to any function, even itself.
- Native is never equal to any native, even itself.
- Object is never equal to other object, even itself.
- Values of different types are never equal.
rules are inverted for Not-Equal (`!=`)
### Comparison
Comparison operators are:
- Greater-Than (`>`)
- Lesser-than (`<`)
- Greater-Equal (`>=`)
- Lesser-Equal (`<=`)
Used to check how two values compare to each other based on specified rules.  
- Two floats are obvious.
- Two strings are compared [lexicographically](https://en.wikipedia.org/wiki/Lexicographic_order).
- Anything else raises a runtime error.
### Logical not
Logical not (`!`) is a unary operator that inverts whether a value is truthy  
A truth value of a value can be obtained using `!!expression`.   
A value is truthy if
- It's a float and is not equal to: `0.0`.
- It's a Boolean whose value is `true`.
- It's a string whose length is greater than zero.
- It's an array whose length is greater than zero.
- It's a function, native or object
- It's not a nil
### Bool standard library
the standard library for Boolean utilities
#### Bool.true
the constant `true`
#### Bool.false
the constant `false`
#### Bool.truth
`Bool.truth(v)` is the truth value of `v`

example:
```
IO.print("abc" < "def", "\n") // true
IO.print(123 > 12.3, "\n") // true
IO.print([1, 2, [3, 4]] == [1, 2, [3, 4]]) // true
```
## Strings
A string is a data type that is a sequence of characters.  
In Aerospec, strings are indexable, mutable and resizable.  
example of initialization:
```
str := "Hello, World!\n"
IO.print(str)
```
### String indexing
indices are bound-checked positive floats, indices cannot contain a decimal part, otherwise a runtime error is raised.   
as of v0.1.0, relative (negative) indexing is not available and indices must be positive.
example:
```
str := "Hello!"

IO.print(str[0], "\n") // H
IO.print(str[1], "\n") // e
IO.print(str[2], "\n") // l
IO.print(str[3], "\n") // l
IO.print(str[4], "\n") // o
IO.print(str[5], "\n") // !

IO.print(str[6], "\n") // error
```
### String slicing
a slice is a substring specified by two positive `begin:end` non-decimal floats.   
begin is inclusive and must be `>= 0`. negative infinity `-Float.inf` denotes the first index (`0`).   
end is non-inclusive and must be less or equal to the length of the string, `Float.inf` denotes the length of the string.   
`begin` must be smaller or equal to `end`.    
both `begin` and `end` can be omitted, defaulting to `0` and length of string respectively.   
example:
```
str := "Hello, World!"
IO.print(str[:5], "\n") // "Hello"
IO.print(str[7:], "\n") // "World!"
IO.print(str[3:12], "\n") // "lo, World"
IO.print(str[-Float.inf:Float.inf], "\n") // "Hello, World!"
IO.print(str[0:0], "\n") // ""
```
### String concatenation
String concatenation is the operation of concatenating two strings into a new one.  
the resulting string is always unlocked, See [String locking](#String%20locking).   
example:
```
IO.print("Hello, " + " World" + "!\n") // "Hello,  World!\n"
IO.print("123" + "456" + "\n") // "123456\n"
IO.print("ha" + "ha" + "ha\n") // "hahaha\n"
IO.print("こんにちは" + " " + "世界" + "\n") // こんにちは 世界
```
### String index-assignment
index-assignment is the operation of changing a single byte at a specified index.  
all index rules also apply for index-assignment.  
the right hand string must be of length 1, this behavior might change in later versions.
the left hand string must be of length greater than index.   
indices cannot be constant assigned.   
example:
```
str := "Gollum"
str[0] = "S"
str[1] = "m"
str[2] = "e"
str[3] = "g"
str[4] = "o"
str[5] = "l"
IO.print(str, "\n") // Smegol

str[0] = "Hello" // error (v0.1.0)
```
### String locking
In Aerospec, locking operator `&` is a unary operator that returns a locked version of the value it is applied to, which prevents any modification on this locked value.   
there are two types of locking: shallow-locking and deep-locking, for strings, there's only shallow-locking, and deep-locking has no other effect over shallow-locking, more on locking later.
when applied to a string, it returns a locked version, which cannot be index-assigned, and cannot be used with String standard library's modifying natives like `String.extend` or `String.insert`.   
string locking does not copy the string, but simply creates a locked reference to the same string.   
example:
```
str := &"Aerospec"
str[0] = "n" // error
String.extend(str, " Hello") // error
```
