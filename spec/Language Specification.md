# Aerospec

**Aerospec** is a full-fledged dynamic imperative programming language with functional traits.  
It's designed specifically to solve algorithm problems, so it contains a lot of built-in golfing and declarative utilities.  
It supports functional, imperative, and prototype-based OOP styles, though the OOP might be a little quirky (but not useless).  
The language contains no keywords and has a small standard library for essential tasks.

---

## Literals

- **Integer**: `12345`  
- **Float**: `123.45`  
- **String**: `"Hello, World!"`

---

## Types

The language is dynamically and strongly typed; it doesn't allow weird implicit conversions.

---

## Numerics

Although integer literals exist, all numeric values in the language are computed as double-precision floats.  
The language includes the traditional trap values of signed `NaN` and `Inf`.  
Most operators in the language are specific to numeric values, e.g., (`-`, `*`, `/`). Notice that the plus operator is not included because it performs concatenation on other sequence types.

---

## Strings

Strings are indexable, mutable, and resizable. They can contain newlines and support escaped characters and values (e.g., `\n`, `\34`).  
The plus operator `+` concatenates two strings into a new one. Equality and comparison operators (`==`, `>`...) are permitted on strings and are based on lexicographical order.

---

## Lambdas

Functions in Aerospec are just variables or constants with lambda values; there is no distinction.  
An example of a definition: `ident := (x, y) { -> x + y }`, which is called traditionally as `ident(x, y)`.  
Functions are treated as first-class citizens, meaning they can be passed to other functions, stored in arrays or variables, and support closures.  
Functions in objects (methods) have access to object fields through the dot pointer, e.g., `.field = value`. Objects will be explained further later.

---

## Objects

Note: Not yet implemented

Objects are the fundamental building blocks of OOP in the language, similar to JavaScript objects.  
Fields are defined as follows: `{field1="" field2=1234 ...}`. Fields can contain any value with any type, including functions.  
Functions have access to the object fields through the dot `.` operator, e.g., `... fn:=(new_value){ .field = new_value }`.  
Objects can add new fields (or attributes) after creation: `obj.new_field = value`.  
If `new_field` was not initially defined, it comes into existence upon assignment. New functions can be added and operate on new fields.  
The operator `:=` defines a constant field that cannot be changed by the object user, while `=` defines a regular variable field. More on assignment operators later.

---

## Arrays

Arrays are n-dimensional, homogeneous, and resizable.  
Arrays are central to the language, with much built-in syntax specifically for their usage.  
They support complex ranging as well as a constructor called a builder (a slightly more powerful list comprehension).  
Array expression syntax: `[1, 2, 3, 4, 5]`. obtaining the size of a sequence (string or array) can be done using len(): `len(arr)` is the size of array `arr`.  
Indexes are zero-based and bounds-checked; there is no relative (negative) indexing.  
Arrays work similarly to C indexing.
Example: `arr[1]` selects the element at index 1.  
Ranges allow selecting multiple elements without using loops. They work similarly to Python ranges.  
Example: `arr[1:10]` selects elements from index `1` through index `9`. is non-inclusive
both start and end can be omitted: `arr[:]` returns the whole array

### More examples on indexing, ranging, and selection:

- `arr[x:y]` — select elements from `x` to `y` (non-inclusive)
- `arr[x:]` — select elements from `x` to `#arr` (end omitted)
- `arr[:y]` — select elements from `0` to `#arr` (beginning omitted)
- `arr[x, y, :z]` — select index `x`, then index `y` from `[x]`, and from `[x][y]`, select the range from `0` to `z`
- `arr[:, z]` — from each element of `arr`, select index `z`
- `arr[x:y, z]` — from each element in range `x` to `y`, select index `z`
- `arr[x:y, z:f]` — from each element in range `x` to `y`, select the range from `z` to `f`

---

## Booleans

Booleans are the result of any equality or comparison operation. All types can evaluate to either true or false.  
Since the language contains no keywords, the idiomatic way to obtain boolean values is `1 == 1`, `1 == 0`.  
To obtain the truthiness of a value, use `!!value`.  

### Evaluation rules:

1. Equality and comparison operators result in a boolean.
2. Any type can be compared using the equality operators.
3. Comparing two different types raises a type error (not silently true nor false).
4. Strings are compared lexicographically.
5. Truthiness of a single value follows Python's rules: empty strings, arrays, objects, `0`, and `nil` evaluate to `false`; everything else evaluates to `true`.
6. Objects are hashmaps and compared field by field, producing `true` only if all fields match exactly.
7. Functions (or lambdas) are only true when compared with themselves, false when compared with any other function.

---

## Builders

Note: Not yet implemented

Builders are a declarative way to construct arrays, very similar to Python's list comprehensions.  
The syntax is `[range; condition; expression]`.  
A basic range syntax is `minimum < identifier < maximum`.  
The `condition` determines whether the current iteration will produce a new element or not.  
The `expression` evaluates to a value, which is appended to the array with each successful iteration (when the condition is true).  
The conditional expression can be omitted, defaulting to `...; 1; ...`.  
The range can also be omitted if an unknown identifier is used to index an array.  
For example: `[;; arr[i] + 10]` desugars into `[0 <= i < #arr; 1; arr[i] + 10]`.  
This builder syntax is extremely powerful and greatly reduces the need for loops.  

Here’s how you can perform the three transformation bundles: mapping, filtering, and reduction.

- Mapping: `[;; f(arr[i])]`
- Filtering: `[; f(arr[i]); arr[i]]`
- Reduction: `acc = 0 [;; acc = f(arr[i], acc)]`  
  Assignments are expressions, so they can be used here. This is optimized to avoid array creation.