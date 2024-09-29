## Symbolic

Symbolic is a dynamic imperative programming language with functional traits.  
Its goal is to provide concise, readable code, focusing on solving algorithmic problems.  
Built-in golfing and declarative utilities make Symbolic suitable for functional, imperative, and prototype-based OOP styles.  
While OOP might feel unconventional, it's still useful.  
Symbolic has no keywords and offers a small standard library for various tasks.

---

## Literals

- **Integer**: `12345`  
- **Float**: `123.45`  
- **String**: `"Hello, World!"`

---

## Types

Symbolic is dynamically and strongly typed, prohibiting implicit type conversions.

---

## Numerics

All numeric values, including integer literals, are treated as double-precision floats.  
Trap values like signed `NaN` and `Inf` are included.  
Most numeric operators (`-`, `*`, `/`, etc.) are exclusive to numeric types, except for the `+` operator, which concatenates sequence types (strings, arrays).

---

## Strings

- Indexable, mutable, and resizable.
- Can contain newlines and support escaped characters (e.g., `\n`, `\34`).
- The `+` operator concatenates two strings.
- Equality and comparison operators work lexicographically.

---

## Lambdas

Functions are variables or constants holding lambda values, with no distinction between a function and a lambda.  
Example definition: `ident := (x, y) { -> x + y }`.  
Function call: `ident(x, y)`.  
Functions are first-class citizens and support closures.  
Methods access object fields via the dot operator (`.`), e.g., `.field = value`.

---

## Objects

Objects resemble JavaScript objects and support OOP in Symbolic.  
Fields are defined like this: `{field1="", field2=1234, ...}`.  
Fields can hold any type, including functions.  
Functions access object fields through the `.` operator, e.g., `.field = new_value`.  
New fields can be added after creation: `obj.new_field = value`.  
Uninitialized fields come into existence upon assignment.  
Use `:=` to define constant fields, and `=` to define mutable fields.

---

## Arrays

Symbolic arrays are n-dimensional, indexable, homogeneous, and resizable.  
They support complex ranging and selection, with a builder (list comprehension) constructor.  
Example: `[1, 2, 3, 4, 5]`.  
The `#` operator returns the size: `#arr`.  
Indexes are zero-based and bounds-checked.  
Arrays resemble C-style indexing without segmentation faults: `arr[1]`.  
Ranges allow for selecting multiple elements, similar to Python: `arr[1:10]`.

### Indexing and Ranging

- `arr[x:y]` — select elements from `x` to `y` (non-inclusive).
- `arr[x:]` — select elements from `x` to the end.
- `arr[:y]` — select elements from the start to `y`.
- `arr[x:y, z]` — from each element in range `x` to `y`, select index `z`.
- `arr[x:y, z:f]` — from each element in range `x` to `y`, select range `z` to `f`.

---

## Booleans

Booleans result from equality or comparison operations.  
All types can evaluate as either true or false.

### Truth Evaluation

- Equality and comparison operators produce booleans.
- All types can be compared using equality operators.
- Comparing two different types raises a type error.
- Strings are compared lexicographically.
- Truthiness follows Python-like rules: empty values (`"", [], {}, 0, nil`) are false; everything else is true.
- Objects are `true` only if all fields match.
- Functions compare as `true` only against themselves.

---

## Builders

Builders are declarative array constructors, akin to Python list comprehensions.  
Syntax: `[range; condition; expression]`.  
Ranges define array elements: `min < identifier < max`.  
The condition determines element inclusion, defaulting to `1` (always true) if omitted.  
Example: `[;; arr[i] + 10]` desugars into `[0 <= i < #arr; 1; arr[i] + 10]`.

### Transformations: Mapping, Filtering, Reduction

- **Mapping**: `[;; f(arr[i])]`.
- **Filtering**: `[; f(arr[i]); arr[i]]`.
- **Reduction**: `acc = 0 [;; acc = f(arr[i], acc)]`.  
  This avoids unnecessary array creation for efficiency.
