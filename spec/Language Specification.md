# **Symbolic**
**Symbolic** is a full-fledged dynamic imperative programming language with functional traits.
the language goal is for it's code to be concise and short, without losing it's readability.
it's designed specifically to solve algorithm problems so it contains a lot of built-in golfing and declarative utilites.
supports functional, imperative, prototype-based OOP styles, although the OOP might be a little quirky (but not useless).
the language contains no keyword, and has a small standard library for various tasks.

## Literals
**Integer**: `12345`
**Float**: `123.45`
**String**: `"Hello, World!"`

## Types
the language is dynamically and strongly typed, it doesn't allow weird implicit conversions 

## **Numerics**
although there exists integer literals, all numeric values in the language are computed as double-precision floats.
and has the traditional trap values of signed `NaN` and `Inf`
most operators in language is specific to numeric values, e.g (`-`, `*`, `/`), notice that the plus operator is not there,
because it performs concatentation on other sequence types

## **Strings**
strings are indexable, mutable and resizable, and can contain newlines. it also supports escaped characters and values, e.g (`\n`, `\34`)
the plus operator `+` concatenats two strings into a new one, the equality and comparison operators (`==`, `>`...) are permitted on strings,
and performs based on the lexicographical order.

## **Lambdas**
functions here are really just variables or constants with lambda values, there's no difference whatsoever.
an example of definition is: `ident := (x, y) { -> x + y }`, and is called in the traditional way of `ident(x, y)`.
functions are treated as first-class citizens, they can be passed to other functions, stored in arrays or variables, and support closures. 
functions in objects (methods) have access to the object fields through the dot pointer, e.g `.field = value`.
objects will be explained further later.

## **Objects**
objects are the fundamental building blocks of the OOP in language, they're much like javascript objects.
fields are defined as such `{field1="" field2=1234 ...}`, fields can contain any value with any type, including functions.
functions have access to the object fields through the dot `.` operator, e.g `... fn:=(new_value){ .field = new_value }`
objects can add new fields (or attributes, if you will) after creation, here: `obj.new_field = value`, if `new_field` is not an initial field
of the object, it pops into existence after assignment, also a new function can be added and can operate on new fields
the operator `:=` defines a constant field that can't be changed by the user of the object, while `=` defines a regular variable field.
more on assignment operators later

## **Arrays**
arrays are n-diminsional, indexable, homogeneous and resizable.
arrays are very important in the language, thus there's a lot of builtin syntax specific to them.
they support complex ranging and selection, and constructor called a builder (a slightly more powerful list comprehension).
array expression syntax: `[1, 2, 3, 4, 5]`. a specific operator for obtaining the size of array is `#` (pronounced as `size of`), `#arr` is the size of array `arr`.
indexes are zero based and bound checked, there's no relative (negative) indexing, 
works identically to C indexing (without the segfaults), 
example: `arr[1]` — obvious.
ranges is for selecting multiple elements with the omittion of loops, they work identically to python ranges.
example: `arr[1:10]` — elements from the index `1` through index `9`.
selections works only on multi-diminsional arrays, it selects a specified index or range from each subarray in a range
example: `arr[1:10, 0:5]` — from each subarry of range `1` through `9`, select elements from range `0` through `4`,
this also works for indexing one element
example `arr[0, 1, 2]` — from index `0`, select index `1`, from index `[0][1]`, select index `2`

more examples on indexing, ranging, and selection:
- `arr[x:y]` — select elements from `x` to `y` (non-inclusive)
- `arr[x:]` — select elements from `x` to `#arr` (end omitted)
- `arr[:y]` — select elements from `0` to `#arr` (beginning omitted)
- `arr[x, y, :z]` — select index of `x`, select index of `[x][y]`, from `[x][y]`, select range from `0` to `z` 
- `arr[:, z]` — from each element of `arr`, select index `z`
- `arr[x:y, z]` — from each element in range `x` to `y`, select index `z`  
- `arr[x:y, z:f]` — from each element in range `x` to `y`, select range from `z` to `f`

## **Booleans**
booleans are the result of any equality or comparison operation, all types can evaluate to either true or false.
since the language doesn't contain keywords, the idiomatic way to obtain boolean values is `1==1`, `1==0`,
to obtain the truthiness of a value, you can do `!!value`.
the evaluation rules are simple.  
1. all equality and comparison operators result in a boolean.
2. any type can be compared with the equality operators.
3. comparing two different types is not silently false or true, it raises a type error
4. strings are compared based on the lexicographical order
5. truthiness of a single value follows python steps, empty strings, empty arrays, empty objects, zero `0`, and `nil` evaluate to `false`
anything else evaluates to `true`
6. objects are hashmaps and can be compared as such, fields are compared pair by pair and will only produce `true` when each one exactly matches
7. a function (or lambda) only produces true when compared with itself, produces false when compared with any other function

## **Builders**
builders are a declarative way to construct arrays, very similar to python's list comprehensions.
the syntax of a builder is `[range; condition; expression]`. 
`range` is an actual builtin type in the language (not to be confused with array ranges)
a basic range syntax is `minimum < identifier < maximum`, more on ranges later.
the `condition` determines whether the current iteration will produce a new element or not.
the `expression` evaluates to a value which will be appended to the array with each successful iteration (condition results in `true`).
the conditional expression can be omitted, it defaults to `...; 1 ;...`.
also the range can be omitted in case an unknown identifier was used to index an array,
for example: `[;; arr[i] + 10]` desugars into `[0 <= i < #arr; 1; arr[i] + 10]`.
this builder syntax is actually extremely powerful, and will massively reduce your need for looping
here's how you can perform the three transformations bundle: mapping, filtering and reduction
- mapping: `[;; f(arr[i])]`
- filtering: `[; f(arr[i]); arr[i]]`
- reduction: `acc = 0 [;; acc = f(arr[i], acc)]`, assignments are expressions; thus can be used here, this is optimized to avoid array creation.