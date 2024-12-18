Aerospec is a programming language that blends between functional and imperative programming in a natural manner. it supports imperative, procedural, functional and a flavor of prototype-based OOP. with a minimal symbolic syntax; it heavily encourages declarative and "golfy" coding
## Table of contents
1. [Installation](#Installation)
2. [Usage](#Usage)
3. [Syntax](#Syntax)
4. [Comments](#Comments)
5. [Identifiers](#Identifiers)
6. [Assignment](#Assignment)
	1. [Variable assignment](#variable-assignment)
	2. [Constant assignment](#constant-assignment)
	3. [Chaining assignments](#chaining-assignments)
7. [Data-Types](#data-Types)
8. [Type-of operator](#type-of-operator)
9. [Floats](#Floats)
	1. [Basic arithmetic](#basic-arithmetic)
	2. [Float standard library](#float-standard-library)
		1. [Float.inf](#floatinf)
		2. [Float.nan](#floatnan)
10. [Booleans](#booleans)
	1. [Equality](#equality)
	2. [Comparison](#comparison)
	3. [Logical not](#logical-not)
	4. [Bool standard library](#bool-standard-library)
		1. [Bool.false](#boolfalse)
		2. [Bool.true](#booltrue)
		3. [Bool.truth](#booltruth)
11. [Strings](#strings)
	1. [String indexing](#string-indexing)
	2. [String slicing](#string-slicing)
	3. [String concatenation](#string-concatenation)
	4. [String index-assignment](#string-index-assignment)
	5. [String locking](#string-locking)
	6. [String escape characters](#string-escape-characters)
	7. [String multi-line](#string-multi-line)
	8. [String copying](#string-copying)
	9. [String standard library](#string-standard-library)
		1. [String.len](#stringlen)
		2. [String.insert](#stringinsert)
		3. [String.extend](#stringextend)
		4. [String.merge](#stringmerge)
		5. [String.index](#stringindex)
		6. [String.pop](#stringpop)
		7. [String.remove](#stringremove)
		8. [String.clear](#stringsclear)
		9. [String.count](#stringcount)
		10. [String.repr](#stringrepr)
12. [Operators](#operators)
13. [Arrays](#arrays)
	1. [Array indexing](#array-indexing)
	2. [Array slicing](#array-slicing)
	3. [Array concatenation](#array-concatenation)
	4. [Array index-assignment](#array-index-assignment)
	5. [Array locking](#array-locking)
	6. [Array deep-locking](#array-deep-locking)
	7. [Array copying](#array-copying)
	8. [Array standard library](#array-standard-library)
		1. [Array.len](#arraylen)
		2. [Array.append](#arrayappend)
		3. [Array.insert](#arrayinsert)
		4. [Array.extend](#arrayextend)
		5. [Array.merge](#arraymerge)
		6. [Array.index](#arrayindex)
		7. [Array.pop](#arraypop)
		8. [Array.remove](#arrayremove)
		9. [Array.clear](#arrayclear)
		10. [Array.count](#arraycount)
14. [Nil](#Nil)
15. [Block statement](#block-statement)
16. [If...else statement](#if-else-statement)
17. [Ternary expression](#ternary-expression)
18. [Logical && and ||](#logical-&&-and-||)
19. [Range expression](#range-expression)
20. [Loop](#loop)
	 1. [Regular loop](#regular-loop)
	 2. [Range loop](#range-loop)
	 3. [Continue](#continue)
	 4. [Break](#break)
21. [Builder](#builder)
22. [Scope](#scope)
23. [Functions](#functions)	
	1. [Parameters](#parameters)
	2. [Function calls](#function-calls)
	3. [Return](#return)
	4. [First-class](#first-class)
	5. [Native functions](#native-functions)
	6. [Closures (nested functions)](#closures-nested-functions)
	7. [Recursion](#recursion)
24. [Global access operator](#global-access-operator)
	1. [Global access](#global-access)
	2. [Global assignment](#global-assignment)
25. [NO-OP statement](#no-op-statement)
26. [Objects](#objects)
	1. [Object initialization](#object-initialization)
	2. [Object copying](#object-copying)
	3. [Methods](#methods)
	4. [Field access](#field-access)
	5. [Field assignment](#Field-assignment)
	6. [Object locking](#object-locking)
	7. [Object deep-locking](#object-deep-locking)
	8. [Object standard library](#object-standard-library)
		1. [Object.fields](#objectfields)
27. [Importing](#importing)
28. [Miscellaneous standard libraries](#miscellaneous-standard-libraries)
	1. [IO standard library](#io-standard-library)
		1. [IO.print](#ioprint)
		2. [IO.input](#ioinput)
	2. [Time standard library](#time-standard-library)
		1. [Time.clock](#timeclock)
	3. [Value standard library](#value-standard-library)
		1. [Value.copy](#valuecopy)
29. [Ideas for future releases](#ideas-for-future-releases)
30. [Implementation](#implementation)
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
Aerospec does not have entry function. it executes the code in the global [scope](#Scope).
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
- Plus `+`
- Minus `-`
- Multiply `*`
- Divide `/`
- Modulo `%`   
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
rules are inverted for Not-Equal `!=`
### Comparison
Comparison operators are:
- Greater-Than `>`
- Lesser-than `<`
- Greater-Equal `>=`
- Lesser-Equal `<=`   
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
locking does not copy the string, but simply creates a locked reference to the same string.   
example:
```
str := &"Aerospec"
str[0] = "n" // error
String.extend(str, " Hello") // error
```
### String escape characters
Strings support the escape characters of
- Double Quote `\"`
- Backslash `\\`
- New line `\n`
- Carriage Return `\r`
- Tab `\t`
- Vertical Tab `\t`
- Form Feed `\f`
- Backspace `\b`   
if any other letter has occurred after the backslash, then the backslash gets ignored.   
as of v0.1.0, Aerospec doesn't support hexadecimal, octal or any other digital representation of escape characters.   
example:
```
IO.print("Hello\nWorld!")
// Hello
// World!
```
### String multi-line
In Aerospec, multi-line strings are allowed and the string will contain a new-line character at the position of the new-line:
```
mstr := 
"
multi-line
string
"

IO.print(mstr)
// multi-line
// string
```
### String copying
String is a mutable type, for known performance reasons, assigning with a string does not copy the string, but merely a reference to it, which means any modification to the new string are also applied to the original one, if this behavior is not desired, use [Value.copy](#Value.copy).
### String standard library
the standard library for String utilities
#### String.len
`String.len(str)` is the length of the string `str`.   
a runtime error is raised if:
- `str` is not of type string.   
example:
```
IO.print(String.len("Hello, World!"), "\n") // 13
IO.print(String.len("Aerospec"), "\n") // 8
IO.print(String.len(""), "\n") // 0
```
#### String.insert
`String.insert(str, substr, index)` insert `substr` string at index `index` of string `str`.   
a runtime error is raised if:
- `str` is not of type string.
- `substr` is not of type string.
- `str` is a locked string.   
- `index` greater than the length of `str`
example:
```
str = "Lorem  "
String.insert(str, "ipsum", 6)
IO.print(str, "\n") // Lorem ipsum

str = "Beginning"
String.insert(str, "Start: ", 0)
IO.print(str) // Start: Beginning
```
#### String.extend
`String.extend(str, substrs...)` extends the string `str` with [variable argument](#Variable%20arguments) `substrs...`
a runtime error is raised if: 
- `str` is not of type string.
- one of `substrs...` is not of type string.
- `str` is a locked string.   
example:
```
str = "Hello"
String.extend(str, ", ", "World", "!")
IO.print(str, "\n") // Hello, World!

str = "Добро"
String.extend(str, " пожаловать") 
IO.print(str, "\n") // Добро пожаловать 
```
#### String.merge
`String.merge(substrs...)` concatenates variable argument `substrs...` into a new one.   
a runtime error is raised if: 
- one of `substrs...` is not of type string.   
`String.merge(str1, str2, str3)` takes the same effect as: `str1 + str2 + str3`.   
example:
```
str1 := "Hello, "
str2 := "World!"
str3 := String.merge(str1, str2)
IO.print(str3, "\n") // Hello, World!

str4 := str1 + str2
IO.print(str4, "\n") // Hello, World!
```
#### String.index
`String.index(str, substr)` is the index of the first occurrence of `substr` in `str`. 
if `substr` doesn't occur in `str`, then it results in `-1`.   
a runtime error is raised if:
- `str` is not of type string.
- `substr` is not of type string.   
example:
```
str = "Hello, world!"
IO.print(String.index(str, "world"), "\n") // 7 
IO.print(String.index(str, "Hello"), "\n") // 0

str = "Short"
IO.print(String.index(str, "LongerSubstring"), "\n") // -1

str = "こんにちは、世界！"
index1 := String.index(str, "世界")
index2 := String.index(str, "こ")
IO.print(str[index1:], "\n") // 世界！
IO.print(str[index2:], "\n") // こんにちは、世界！
```
#### String.pop
`String.pop(str, indices...)` removes and shifts characters at each index of `indices...` from `str`.   
note that `indices...` are not accumulated, rather each index is removed independently and the next indices treat the string as a full one: `String.pop("Hello", 0, 1) // "elo", not "llo"`.   
a runtime error is raised if:
- `str` is not of type string.
- one of the `indices...` is not of type float or has a decimal part.
- one of `indices...` is out of bounds.
- `str` is a locked string.   
example:
```
str = "Abjad Hawaz"
String.pop(str, 0, 0)
IO.print(str, "\n") // jad Hawaz

str = "Lorem Ipsum"
String.pop(str, 4)
IO.print(str, "\n") // Lore Ipsum
```
#### String.remove
`String.remove(str, substrs...)` removes the first occurrence of each `substrs...` from `str`.
if a substring is not occurring in `str`, it gets skipped.   
a runtime error is raised if:
- `str` is not of type string.
- one of `substrs...` is not of type string.
- `str` is a locked string.   
example:
```
str = "dollar for each one"
String.remove(str, "dollar", "one")
IO.print(str, "\n") // for each

str = "쓰레기통"
String.remove(str, "레기")
IO.print(str, "\n") // 쓰통
```
#### String.clear
`String.clear(str)` clears `str` and sets it's size to 0 without deallocating it's capacity, this is useful if `str` will be later used.   
a runtime error is raised if:
- `str` is not of type string.   
example:
```
str = "!dlroW ,olleH"
String.clear(str)
IO.print(str, "\n") // ""
```
#### String.count
`String.count(str, substr)` is the how many times `substr` occurs in `str`.   
a runtime error is raised if:
- `str` is not of type string.
- `substr` is not of type string.   
example:
```
str = "123123123"
IO.print(String.count(str, "123"), "\n") // 3
IO.print(String.count(str, "4"), "\n") // 0 
```
#### String.repr
`String.repr(value)` is the string representation of `value`, where `value` can be of any type.
note that `IO.print` uses the representation of the value by default, a call to `String.repr` is not necessary.   
example:
```
arr := [1, 2, [3, 4]]
IO.print(String.repr(arr), "\n") // [1, 2, [3, 4]]

IO.print(String.repr(IO.print)) // <native ( params... )>
```
## Operators
Aerospec follows the traditional precedence rules of C-like languages.   
as of v0.1.0, Aerospec does not have bitwise or augmented assignment operators, this is expected to change in future releases.

| precedence | operator | description          | associativity |
| ---------- | -------- | -------------------- | ------------- |
| 1          | `()`     | grouping parenthesis | LTR           |
| 1          | `()`     | function call        | LTR           |
| 1          | `[]`     | subscript            | LTR           |
| 1          | `$`      | global access        | LTR           |
| 1          | `.`      | field access         | LTR           |
| 2          | `!`      | logical not          | RTL           |
| 2          | `+`      | unary plus           | RTL           |
| 2          | `-`      | unary minus          | RTL           |
| 2          | `~`      | type-of              | RTL           |
| 2          | `&`      | locking              | RTL           |
| 2          | `&&`     | deep-locking         | RTL           |
| 2          | `#`      | import               | RTL           |
| 3          | `/`      | division             | LTR           |
| 3          | `*`      | multiplication       | LTR           |
| 3          | `%`      | modulo               | LTR           |
| 4          | `+`      | addition             | LTR           |
| 4          | `-`      | subtraction          | LTR           |
| 5          | `>`      | greater-than         | LTR           |
| 5          | `<`      | lesser-than          | LTR           |
| 5          | `>=`     | great-equal          | LTR           |
| 5          | `<=`     | less-equal           | LTR           |
| 6          | `==`     | is-equal             | LTR           |
| 6          | `!=`     | is-not-equal         | LTR           |
| 7          | `&&`     | logical and          | LTR           |
| 8          | `\|\|`   | logical or           | LTR           |
| 9          | `?:`     | ternary conditional  | RTL           |
| 10         | `=`      | variable assignment  | RTL           |
| 10         | `:=`     | constant assignment  | RTL           |
   
## Arrays
in Aerospec, arrays are homogeneous, indexable, mutable and resizable.
in array initialization, trailing commas are not allowed.   
 a simple array is initialized like this:
```
arr := [1, 2, 3, 4] 
```
### Array indexing
Array indexing works identically to string's; indices are zero-based positive non-trap floats with no decimal part that must be less than the length of the array.   
example:
```
arr := [1, 2, 3, 4]
IO.print(arr, "\n") // [1, 2, 3, 4] 
IO.print(arr[0], "\n") // 1
IO.print(arr[3], "\n") // 4
```
### Array slicing
all slicing rules of [String slicing](#String%20slicing) applies to array slicing.  
example:
```
arr := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
IO.print(arr[:5], "\n")  // [1, 2, 3, 4, 5]
IO.print(arr[5:], "\n")  // [6, 7, 8, 9, 10]
IO.print(arr[3:8], "\n") // [4, 5, 6, 7, 8, 9]

IO.print(arr[-Float.inf:Float.inf], "\n") // [1, 2, ... 9, 10]
IO.print(arr[0:0], "\n") // []
```
### Array concatenation
Array concatenation is the operation of merging two arrays into a new one.  
be careful, concatenation does not deep-copy reference values within the arrays.   
example:
```
arr1 := [1, 2, "apple", Bool.true]
arr2 := [3, 4, "banana", Bool.false]
arr3 := [5, 6, "cherry", Bool.true]
arr4 := [7, 8, "date", Bool.false]

IO.print(arr1 + arr2, "\n") // [1, 2, apple, true, 3, 4, banana, false]
IO.print(arr3 + arr4, "\n") // [5, 6, cherry, true, 7, 8, date, false]
IO.print(arr1 + arr3, "\n") // [1, 2, apple, true, 5, 6, cherry, true]
```
### Array index-assignment
Array index-assignment is the operation of changing a value at a specified index of an array.  
Array indices cannot be constant-assigned.   
example:
```
arr    = [1, 2]
temp   = arr[0]
arr[0] = arr[1]
arr[1] = temp
```
### Array locking
applying the lock operator `&` to an array creates a locked version of it.  
a locked array cannot be index assigned or used with any modifying standard library functions.
locking an array does not copy it, but simply creates a locked reference to the same array
locking the array does not prevent elements within the array to be modified, but only the array itself: 
```
arr = ["Hello", 1, 2]
arr[0][1] = "J" 
IO.print(arr[0]) // "Jello"

arr[0] = "Lorem" // error
```
this is called shallow-locking, if you want the behavior of locking elements within the array, there's something called deep-locking
### Array deep-locking
applying deep-locking operator `&&` to an array creates a deep-locked version of it, a deep-locked array recursively applies locking behavior on the array and elements within, deep-locking DOES copy the array
example:
```
arr = ["Hello", 1, 2]
arr[0][1] = "J" // error
arr[0] = "Lorem" // error
```
### Array copying
Since array is a reference type, assigning with an array does not copy it, but a reference to the same array, which makes all modification applied to the new array also modifying for the original one, if this behavior is not desired, use [Value.copy](#Value.copy)
### Array standard library
the standard library for Array utilities
#### Array.len
`Array.len(arr)` is the length of array `arr`.  
a runtime error is raised if:
- `arr` is not of type array.   
example:
```
IO.print(Array.len([1, 2, 3]), "\n") // 3
IO.print(Array.len([[1, 2, 3], 4]), "\n") // 2
IO.print(Array.len([]), "\n") // 0
```
#### Array.append
`Array.append(arr, elements...)` appends variable argument `elements...` to `arr`.   
a runtime error is raised if:
- `arr` is not of type array.
- `arr` is a locked array.  
example:
```
arr := [1, 2, 3]
Array.append(arr, 4, 5, 6)
IO.print(arr) // [1, 2, 4, 5, 6]
```
#### Array.insert
`Array.insert(arr, element, index)` insert `element` in `arr` at `index`.   
a runtime error is raised if:
- `arr` is not of type array.
- `index` is not of type float.
- `index` is not a valid index.
- `index` is greater than the length of `arr`.   
example:
```
arr := [1, 2, 3]
Array.insert(arr, 0, 0)
Array.insert(arr, 4, Array.len(arr))
IO.print(arr) // [0, 1, 2, 3, 4]
```
#### Array.merge
`Array.merge(arrays...)` concatenates variable argument `arrays...` into a new array.   
`Array.merge(arr1, arr2, arr3)` takes the same effect as `arr1 + arr2 + arr3`.   
a runtime error is raised if:
- one of `arrays...` is not of type array.   
example:
```
arr1 := [1, 2, "apple", Bool.true]
arr2 := [3, 4, "banana", Bool.false]
arr3 := [5, 6, "cherry", Bool.true]
arr4 := [7, 8, "date", Bool.false]

IO.print(Array.merge(arr1, arr2), "\n") 
// [1, 2, apple, true, 3, 4, banana, false]

IO.print(Array.merge(arr3, arr4), "\n") 
// [5, 6, cherry, true, 7, 8, date, false]

IO.print(Array.merge(arr1, arr3), "\n") 
// [1, 2, apple, true, 5, 6, cherry, true]
```
#### Array.index
`Array.index(arr, element)` is the index at which `element` occurs first in `arr`.   
if `element` does not exist in `arr`, the result is `-1`.   
a runtime error is raised if:
- `arr` is not of type array.   
example:
```
arr := [1, 2, 3, 1]
IO.print(Array.index(arr, 1), "\n") // 0
IO.print(Array.index(arr, 3), "\n") // 2
IO.print(Array.index(arr, 4), "\n") // -1
```
#### Array.pop
`Array.pop(arr, indices...)` removes and shifts elements at each of variable argument `indices...` from `arr`.   
note that `indices...` are not accumulated, rather each index is removed independently and the next indices treat the array as a full one: `Array.pop([1, 2, 3], 0, 1) // [2] not [3]`.   
a runtime error is raised if:
- `arr` is not of type array.
- one of the `indices...` is not a valid index.
- one of `indices...` is out of bounds.
- `arr` is a locked array.   
example:
```
arr := [0, 5, 1, 2, 6, 3, 4]
Array.pop(arr, 1, 3)
IO.print(arr, "\n") // [0, 1, 2, 3, 4]

Array.pop(arr, 0)
IO.print(arr, "\n")  // [1, 2, 3, 4]
```
#### Array.remove 
`Array.remove(arr, elements...)` removes the first occurrence of each value in variable argument `elements` from arr.   
if an element of `elements...` is not occurring in `arr`, it gets skipped.   
a runtime error is raised if:
- `arr` is not of type array.
- `arr` is a locked array.   
```
arr := ["Hello", "World", 1, 1.01, 2, Bool.false]
Array.remove(arr, "Hello", 2)
IO.print(arr)
```
#### Array.clear
`Array.clear(arr)` clears `arr` and sets it's size to 0 without deallocating it's capacity, this is useful if `arr` will be later used.   
a runtime error is raised if:
- `arr` is not of type array.   
example:
```
arr := [1, 2, 3, "apple"]
Array.clear(arr)
IO.print(arr) // []
```
#### Array.count
`Array.count(arr, element)` is the how many times `element` occurs in `arr`.   
a runtime error is raised if:
- `arr` is not of type array.   
example:
```
arr := [1, 2, 3, 1]
IO.print(Array.count(arr, 1), "\n") // 2
IO.print(Array.count(arr, 2), "\n") // 1
IO.print(Array.count(arr, 5), "\n") // 0
```
## Nil
Nil is a standalone type and value that represents the absence of a value, akin to C#'s and JS's `null`.  
it is the return value of non-returning functions and natives.   
it's also often used to indicate the failure of a returning function, this is likely to change with the addition of `err` type in later versions, See [Ideas for future releases](#Ideas%20for%20future%20releases).   
it is represented in the language with the `_` (Underscore) symbol.   
example:
```
return_of_print := IO.print(_, "\n") // "nil"
IO.print(return_of_print, "\n") // IO.print returns nil
```
## Block statement
Block statement (also called compound statement) is a sequence of zero or more statements enclosed within curly braces.   
it can show wherever a statement is allowed.   
primarily used with if and looping statements.   
example:
```
i = 0
>> i < 10 {
	IO.print(i, "\n")
	i = i + 1
}
```
## If...else statement
If...else statements is a control flow construct to execute code branches based on a condition.   
in Aerospec, if statements (represented with `??`) requires condition expression and a statement, both parenthesis around the condition expression and block statements are optional.   
the condition expression is evaluated to it's truth value and branches are executed based on it.   
else statement (represented with `::`) is optional, and is always bound to the closest if statement.   
in Aerospec, if statements does not introduce a new scope.   
example:
```
i = 8
?? i % 2 == 0
	IO.print("'i' is even\n")
::
	IO.print("'i' is odd\n")

age = 20
?? (age >= 18) {
   IO.print("Adult\n")
   
   ?? (age >= 21) {
      IO.print("Legal drinking age (don't drink though)\n")
   } :: {
      IO.print("Not of legal drinking age\n")
   }
   
} :: {
   IO.print("Minor\n")
}
```
## Ternary expression
Ternary expression is an expression that evaluates to one of two values based on a condition. 
in Aerospec, it's syntax and semantics is identical to C.   
example:
```
fizzbuzz_30 :=
30 % 3 == 0 && 30 % 5 == 0 
? "fizzbuzz"
: 30 % 3 == 0 
? "fizz"
: 30 % 3 == 1 
? "buzz"
: "30"

IO.print(fizzbuzz_30)
```
## Logical && and ||
like in most dynamically typed languages, and with taking advantage of short-circuiting; `&&` and `||` are both operators and control flow.   
`expr1 && expr2` takes the same effect as: `expr1 ? expr2 : expr1`.   
`expr1 || expr2` takes the same effect as: `expr1 ? expr1 : expr2`.
example:
```
// IO.print returns nil; right hand never evaluates
nil := IO.print("Hello, ") && IO.print("World!")

one := 0 || 1
```
## Range expression
a range is an expression which is only valid in specific contexts, it defines a constant identifier and increments/decrements it based on specified lower and upper bounds non-decimal floats.   
the syntax for ranges is akin to math's Interval notation: `lbound < x < ubound`.
all relational comparison operators are allowed in a range expression, but `< | <=` cannot be used in the same expression along `> | >=`:
```
0 < i < 10
i  = name of the iterator, the identifier 'i' is optional
0  = the lower bound
10 = the higher bound

this expression reads as:
"define 'i' iterator starting with a number greater than 0: (1), increment until 'i' is equal to a number lesser than 10: (9)"

0 <= i <= 10
"define 'i' iterator starting with a number equal to 0: (0), increment until 'i' is equal to a number equal to 10: (10)"

0 < i <= 10, 0 <= i < 10 are also allowed
```
a range expression which uses (`<` | `<=`) is an incrementing range expression.   
an incrementing range expression must have it's lower bound lesser than it's upper bound, otherwise it's a NO-OP
```
10 > i > 1
"define 'i' iterator starting with a number lesser than 10: (9), decrement until 'i' is equal to a number greater than 1: (2)"

10 >= i >= 1
"define 'i' iterator starting with a number equal to 10: (10), decrement until 'i'
is equal to a number equal to 1: (1)"

10 > i >= 0, 10 >= i > 0 are also allowed
```
a range expression which uses (`>` | `>=`) is a decrementing range expression.   
a decrementing range expression must have it's lower bound greater than it's higher bound,
otherwise it's a NO-OP.   
## Loop
In Aerospec, a loop is an iterative construct that keeps executing code as long as a specific rule holds.   
unlike traditional behavior, loops do not introduce a new scope.   
### Regular loop
Regular loop is one of the two iterative constructs in Aerospec, it executes a statement until a condition expression truth value is false.   
it requires an expression as a condition and a statement.   
it does not require parenthesis around the condition expression nor does it require a block statement.   
example:
```
i = 0 
>> i < 10 {
	eval = i % 2 == 0 ? "even" : "odd" 
	IO.print("i = ", i, ": ", eval, "\n")
	i = i + 1
}

// i = 0: even
// ...
// i = 9: odd
```
### Range loop
Range loop is an iterative construct which defines an iterator for a specified [range](#Range%20expression) and keeps iterating until the range is finished.   
the iterator is removed from [scope](#Scope) upon exiting the loop.   
example:
```
arr := [1, 2, 3, 4, 5]
>> 0 <= i < Array.len(arr)
	IO.print("arr[", i, "] = ", arr[i], "\n")

// "arr[0] = 1"
// ...
// "arr[4] = 5"
```
### Continue
Continue statement (represented with `<<`) skips the remaining execution path of the current iteration and starts a new one.   
A Continue statement must occur only in a loop statement.   
for regular loop statements, it skips the rest of the iteration.   
for range loops statements, it advances the iterator then skips the rest of the iteration.   
example:
```
>> 0 <= i <= 10 {
    ?? i % 2 == 1
        <<
    IO.print(i, "\n")
}

// 0 // 2 // ... // 8 // 10
```
### Break
Break statement (represented with `**`) skips the remaining execution path of the current iteration and exits the loop.   
example:
```
i = 0
>> Bool.true {
	?? i == 100 
		**
	
	IO.print(i, "\t")
	?? i != 0 && i % 10 == 0
		IO.print("\n")
	i = i + 1 
}
// 1 ... 10
// ...
// 90 ... 99
```
## Builders
Builder is a declarative construct for array creation, it is akin to python's list comprehension.   
syntax: `[range; condition; expression]`, `range` is a range expression, fully adhering to the specification of [ranges](#range-expression), `condition` is a condition which determines whether the current iteration of the range will be added to the array, `condition` can be omitted and will default to `Bool.true`.  `expression` is the expression that evaluates to the current value of the iteration (if `condition` evaluates to true).   
builders are actually quite powerful,   
here's how you can do the three transformation functions of `map`, `filter`,`reduce` using builders:
```
// creates an array from 0 to 10, inclusive
arr := [0 <= i <= 10;; i]

// filtering
only_odds := [0 <= i < Array.len(arr); arr[i] % 2 == 1; arr[i]]

// mapping
doubled := [0 <= i < Array.len(arr);; arr[i] * 2]

// reduction, this is optimized to avoid array creation
sum_all = 0 
;[0 <= i < Array.len(arr);; sum_all = sum_all + arr[i]] 
```
## Scope
a scope is a region of code in which specific identifiers evaluate to specific values.   
in Aerospec, loops and if statements do not introduce a new scope, however, objects and functions do introduce a new scope, in which can variables and constants be re-assigned without affecting the outer identically named identifiers.
## Functions
functions are re-usable modules of code which can process data (parameters), and return data (return values).   
in Aerospec, functions are just variables or constants with lambda values, emphasizing the first-class nature of functions in the language.   
when printing a function, it prints the parameter names enclosed within two parenthesis, providing an easy way to better understand the task of the function.   
functions always return a value, if a function does not explicitly return, the default return value is nil.    
functions always introduce a new scope, which allows for re-assigning identically named identifiers without affecting the outer ones, which all gets discarded upon function exiting.   
it is highly recommended to always assign functions to constants instead of variables.   
example:
```
reverse_string := (str) {
    i = 0
    j = String.len(str) - 1
    >> j > i {
        temp   = str[i]
        str[i] = str[j]
        str[j] = temp
        i = i + 1
        j = j - 1
    }
}

str := "Hello, World!"
reverse_string(str)
IO.print(str, "\n") // !dlroW ,olleH

IO.print(reverse_string, "\n") // <function ( str )>
```
the body of the function is not executed until the function is called; a function with erroneous body will not raise an error until it's called:
```
f := (){
	// Unbinded identifier 'a' 
	IO.print(a)
}
// nothing happens...

f() // error
```
### Parameters
parameters is one way functions communicate with the function call, used as a variable to refer to one input provided to the function at the function call.   
In Aerospec, parameters are identifiers enclosed within parenthesis and separated by commas followed by a block contained code.   
functions can have at most 255 parameters, and no two parameters can be named identically.   
as of v0.1.0, Aerospec does not have default or variable arguments.   
example:
```
greet_name := (name) {
	IO.print("Hello: ", name, "!\n")
}

greet_name("John Doe") // Hello: John Doe!
```
### Function calls
function calls invokes the execution of the function being called, assigning parameters positionally with arguments being passed.   
if the function has parameters, it must be called with the same amount of arguments, this may change in future versions upon introducing currying, See [Ideas for future releases](#ideas-for-future-releases).   
example:
```
print_range := (min, max) {
	>> min <= i <= max
		IO.print(i, " ")
}

print_range(0, 100) // 1 2 ... 99 100 
```
### Return
Return statement (represented with `->`) ends the execution of the function and evaluates the function call to the expression followed.   
In Aerospec, functions must return a value, a function that doesn't explicitly return, evaluates to nil. 
the return expression after the return statement cannot be omitted, if the function shouldn't return anything, simply return a nil: `-> _`.   
return can only occur within a function.   
example:
```
max := (x, y) {
	?? (x > y) -> x
	:: -> y 
} 

IO.print(max(123, 123.1)) // 123.1
```
### First-class
In Aerospec, functions are first-class citizens, which means they're treated as any other data-type;
they can be stored in arrays, returned or passed to other functions.   
example:
```
map := (arr, f) {
	ret := []
	>> 0 <= i < Array.len(arr) 
		Array.append(ret, f(arr[i]))
	-> ret
}

arr := [1, 2, 3, 4, 5]
double  := map(arr, (x){ -> x * 2 })
increm  := map(arr, (x){ -> x + 1 })
square  := map(arr, (x){ -> x * x })

IO.print(arr, "\n")
IO.print(double, "\n")
IO.print(increm, "\n")
IO.print(square, "\n")
```
### Native functions
Native functions are functions that are not defined in Aerospec, but in the Aerospec's runtime.   
all standard library functions are native functions.   
as of v0.1.0, native functions has features that normal functions do not have, like variable arguments.   
example:
```
// IO.print is a native function
IO.print(IO.print) // <native ( params... )>
```
### Closures (nested functions)
Aerospec allows nested functions (also known as closures), which are functions defined within other functions, closures have access to the outer function scope (nonlocal scope), which can be modified with the [global access operator](#global-access), most often you won't need to do so however.     
outer functions can call inner functions and vice versa, which allows nested mutual recursion.  
functions can return closures, which will keep the nonlocal scope accessible through the closure after the function exits.   
example:
```
multiply := (x, y) {
	-> x * y
}

create_multiplier := (x) {
	-> (y) {
		-> multiply(x, y)
	}
}

multiply_by_5  := create_multiplier(5)
multiply_by_10 := create_multiplier(10)

IO.print(multiply_by_5(5), "\n") // 25
IO.print(multiply_by_5(10), "\n") // 50
IO.print(multiply_by_10(12), "\n") // 120
IO.print(multiply_by_10(4), "\n") // 40
```
### Recursion
Recursion is the operation of calling a function in itself.   
in Aerospec, function have access to themselves by default, and also have access to the functions defined after them, allowing mutual recursion.   
example:
```
quick_sort := (arr) {
	len := Array.len(arr)
	?? len < 2 
		-> arr

	pivot := arr[0]
	less  := [0 <= i < len; arr[i] < pivot; arr[i]]
	equal := [0 <= i < len; arr[i] == pivot; arr[i]]
	great := [0 <= i < len; arr[i] > pivot; arr[i]]

	-> quick_sort(less) + equal + quick_sort(great) 
}

arr    := [1, 9, 2, 8, 3, 7, 4, 6, 5]
sorted := quick_sort(arr)
IO.print(sorted) // [1, 2, 3, 4, 5, 6, 7, 8, 9]
```
## Global access operator
Global access operator (represented as `$`) is an operator used to re-assign to a variable outside of the current scope and access an identically named identifiers inside and out of the current scope.  
it leaves the current scope and searches downward the stack of scopes, and chooses the closest identifier to the current scope.   
global access operator is not necessary if no identically named identifier exists in the current scope.    
a runtime error is raised when the global access operator is used in the global scope.
### Global access
accessing an identifier within and outside of the current scope.   
example:
```
a := "global"
f := () {
	a = "non-local"
	
	f := () {
		a = "inner"
		IO.print(a, "\n")
		IO.print($a, "\n")
	}
	f()
	IO.print($a, "\n")
}
f()
// inner // non-local // global
```
### Global assignment
Global access operator can also be used to modify a variable outside of the current scope.   
Global identifiers cannot be constant assigned.   
example:
```
a = "Hello"
f := () {
	$a = "modified by f"
}
IO.print(a, "\n")

f()
IO.print(a, "\n")
```
## NO-OP statement
no operation statement (represented with `;`) is a statement that does not affect the execution of the program and is usually ignored by the parser.   
it's primarily used to disambiguate expressions and as the statement part of if and loop statements that do nothing.   
example:
```
// infinite loop
>> Bool.true
	;

arr  := [1, 2, 3, 4]
arr2 := arr
; [1]
// an array that contains one elements, discarded
// without the ';', the above expression would've parsed as (arr2 := arr[1]) = 2 
```
## Objects
In Aerospec, objects are collections of data and methods which have access to this data.   
Objects are the building blocks of OOP in the language.   
think of objects as inner programs which have access to the outer one, quite actually that's how they're implemented.   
as of v0.1.0, some of the prototype-OOP features are missing from the language, like extending objects with others.   
### Object initialization
Objects are initialized as a group of statements enclosed within two curly braces.   
statements within the objects modify the state of the object.   
assignment and constant-assignment expressions introduce fields to the objects which are exposed outside of the object as attributes.   
example:
```
john := {
	first_name = "John"
	last_name  = "Doe"
	age        = 33
}
```
### Object copying
Objects are reference values; they're not copied when assigned to other identifiers, which means any modification to the newly assigned object will affect the original one.   
to copy an object, use the object in a function call, this deep-copies the object and is equivalent to `Value.copy(obj)`:
```
jane := john()
jane.first_name = "Jane"

IO.print(john.first_name, "\n") // John
IO.print(jane.first_name, "\n") // Jane
```
### Methods
Methods are functions defined within an object, they have access to the data within the object and can apply modifications to it.   
Methods can call functions and other methods.   
like regular functions, Methods modify and access identifiers using the global access operator.   
as of v0.1.0, methods cannot refer to the object of which they're called from.   
methods will always work as if they were called within the object, that means it works correctly even if it's assigned to an identifier.   
example:
```
Point := {
	x = 15
	y = 40

	repr := () {
		-> "Point{" + String.repr(x) + ", " + String.repr(y) + "}"
	}
}

IO.print(Point.repr(), "\n") // Point{15, 40}

repr_of_point = Point.repr
IO.print(repr_of_point(), "\n") // Point{15, 40}
```
### Field access
Field access is the operation of obtaining a value of a field.   
it's performed using the dot `.` operator, with the object as a left hand and the field identifier as the right hand.   
accessing a non-existent field raises a runtime error.   
example:
```
object := {
	field_1 := 123
	field_2 := "field"
}

IO.print(object.field_1, "\n") // 123
IO.print(object.field_2, "\n") // field
```
### Field assignment
Field assignment is the operation of assigning a field outside of the object it is defined in.   
constant fields cannot be re-assigned outside or within the object.   
assigning to a non-existent fields pops it into existence.   
assigning a new field with a function turns it into a method and can be treated as such.   
example:
```
person := { first_name = "John" }

IO.print(person.first_name, "\n") // John

// there are no fields named last_name or age
// this method will raise a runtime error if called now
person.print := () {
	IO.print(
	"first name: ", first_name, "\n",
	"last name: ", last_name, "\n",
	"age: ", age, "\n"
	)
}

person.last_name = "Doe"
person.age       = 33

person.print()
// first name: John
// last name: Doe
// age: 33
```
### Object locking
applying the locking operator (`&`) on an object creates a locked object.   
a locked object prevents any field assignments to be performed on it.   
the body of the object is unaffected by this operator.   
locking an object does not copy the object, but just creates locked reference to the same object.   
example:
```
obj := {field = 123}
locked_obj = &obj

obj.field = 0        // fine
locked_obj.field = 0 // error
```
### Object deep-locking
applying the deep-locking operator (`&&`) on an object creates a deep-locked object.
a deep-locked object prevents any field assignment to be performed on it.   
it deep-locks all the fields within itself and converts all variables to constants; any function that attempts to modify or re-assign a field will raise a runtime error.   
deep-locking an object does copy the object.   
example:
```
obj := {
	field = 123
	modify_field := (n) {
		$field = n
	}
}

locked_obj      = &obj
deep_locked_obj = &&obj

obj.field = 0       // fine
obj.modify_field(0) // fine

locked_obj.field = 0       // error
locked_obj.modify_field(0) // fine

deep_locked_obj.field = 0       // error
deep_locked_obj.modify_field(0) // error
```
### Object standard library
the standard library for Object utilities, it's planned for this library to be expanded in the next release, See [Ideas for future releases](#Ideas-for-future-releases).
#### Object.fields
`Object.fields(obj)` is an array of arrays which contains the name, value and whether a field is a variable (in contrast to a constant) for every field `obj` currently contains, this includes fields defined within and outside of `obj`.   
a runtime error is raised if `obj` is not of type object.   
example:
```
date := {
	day   = 1
	month = 1
	year  := 1970
}

date_fields := Object.fields(date)
IO.print(date_fields)
// [[month, 1, true], [day, 1, true], [year, 1970, false]]
```
## Importing
Importing is the operation which allows one file to use bound values defined in another file.   
the import operator `#` applies to a string, which is a relative or absolute path to another Aerospec code file, it runs the code within the file then it evaluates to an object which stores all the assigned identifiers as object fields.   
it's recommended to always lock an imported object and assign it to an identifier starting with upper letter.   
in Aerospec, Importing is a runtime operation.   
importing a file caches it in memory; using the import operator on the same path does not copy the imported object.   
a runtime error is raised if:
- the import operator `#` is applied to a value which is not of type string.
- if the string is a valid relative or absolute path.
- if there's cyclical import.
- if a file imports itself.   
example:
```
file1.aero:

map := (f, arr) {
	-> [0 <= i < Array.len(arr);; f(arr[i])]
}

--------------------------
fil2.aero:

Map := &(#"file1.aero")

arr        := [1, 2, 3, 4, 5]
square_arr := Map.map((x){ -> x * x}, arr)
IO.print(square_arr) // [1, 4, 9, 16, 25]
```
## Miscellaneous standard libraries
utility standard libraries for general use.   
### IO standard library
the standard library for IO utilities.
#### IO.print
`IO.print(params...)` prints the string representation of each value of variable argument `params...` to the standard output.   
it does not print a new-line character at the end by default.  
example:
```
IO.print("Hello, World!\n")
```
#### IO.input
`IO.input()` Flushes standard output, then read characters from standard input until a newline character is encountered.   
Return the string of all characters read, without the newline character at the end.   
example:
```
line := IO.input()
IO.print(line, "\n")
```
### Time standard library
the standard library for Time utilities
#### Time.clock
`Time.clock()` is the processor time in seconds, used by the program since the beginning of execution.   
example:
```
begin := Time.clock()
>> 0 <= i <= 1000000;
end := Time.clock()

IO.print("from 0 to 1000000 took: ", end - begin, "\n")
```
### Value standard library
the standard library for Value utilities, functions defined here can be applied to a value of any type. 
#### Value.copy
`Value.copy(v)` is a deep-copy of `v`.   
if `v` is not of a reference type, it returns `v` unchanged.   
example:
```
arr  := [1, 2, 3]
copy := Value.copy(arr)
copy[0] = 0

IO.print(arr, "\n")  // [1, 2, 3]
IO.print(copy, "\n") // [0, 2, 3]
```
## Ideas for future releases
1. implementing the interpreter as a stack machine.
2. adding hexadecimal escape characters.
3. adding hexadecimal literals.
4. adding command argument support.
5. adding type-hinting.
6. modify string index-assignment to longer strings.
8. adding a C API.
9. adding Hashmaps.
10. adding integers.
11. adding static-analysis. 
12. adding tuples.
13. adding modes, like locked mode and static mode.
14. adding operator overloading mechanism for objects.
15. adding meta-info to function environments.
16. adding the ability to extend objects.
17. adding currying.
18. adding pipeline operator.
19. adding optional parameters.
20. adding parameter unfolding.
21. adding variable arguments to normal functions.
22. adding tail optimization.
23. expanding the standard library.
## Implementation
Aerospec is fully made in OCaml and is highly influenced by it.   
the parser is a recursive-descent.   
the interpreter is a tree walker and is planned to be reworked.   
scopes and objects are implemented as OCaml hashtables.   
builder expression statements is optimized as a range loop syntax sugar.   
as of v0.1.0, it does not do any static-analyses whatsoever and most errors are delegated to runtime.   
as of v0.1.0, the structure of the implementation is as follows:
- `lib/lexer.ml`: the lexer.
- `lib/parser.ml`: the parser.
- `lib/interpreter.ml`: the interpreter.
- `lib/natives.ml`: all standard library functions are defined here.
- `lib/resizable.ml`: the underlying type of strings and arrays.