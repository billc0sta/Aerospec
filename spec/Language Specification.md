## Structures
- Literals 
- Types
- Operators
- Functions
- Lambdas
- Variables

### Literals
- **Integer Literal**: `13138`
- **Float Literal**: `1292.043`

### Functions and Lambdas
- Treated as first-class citizens.
- Support for capturing.
- Must have at least one parameter.
- Function calls: `f(x, y)`.
- Function definition: `f := (x, y) {x + y}`.
- Lambda definition: `(p1, p2) {p1 op p2}`
- a functions is just a constant variable to lambda, there's absolutely no difference 
- Recursive

### Types
- **Floats**
- **Arrays (n-dimensional)**

### Floats
- All numeric values are represented as double-precision floats at runtime.

### Arrays
- **Syntax**: `arr = [0, 1, 2, 3]`.
- 0-based indexing.
- **Indexing**: Denoted by `.`; **Ranging**: Denoted by `:`; **Selections**: Denoted by `,`.
- **Getting Size**: `#arr`.
- **Builders**:
  - Syntax: `arr = [range; condition; generator]` or `arr = [0 < i < 10; i % 2 == 0; i]`.
  - Identifier `i` is optional.
  - Conditional expressions can be omitted: `[5 < i < 10;; i]`.
  - Range expressions can be omitted if an identifier is used for indexing: `[;; arr.i + 10]` evaluates to `[0 < i < #arr; 1; arr.i + 10]`.
  - The lower bound (`0 <`) can be omitted, defaulting to `0 <= ...`; the upper bound is mandatory.
  - Valid operators in generation expressions: `<` and `<=`, `<=` is inclusive, `<` isn't.
  - For reverse ranging: `maxvalue > i > minvalue`.
  - This is the single most important construct in the language.

- **Examples**:
  - **Mapping**
    - `[;; f(arr.i)]` — Apply function `f` to each element of `arr`.
    - `[;; arr.i * 2]` — Double each element in the array.
    - `[;; arr.i + 1]` — Increment each element in the array by 1.

  - **Filtering**
    - `[; f(arr.i); arr.i]` — Keep elements that satisfy function `f`.
    - `[; arr.i % 2 == 0; arr.i]` — Keep only even elements.
    - `[; arr.i > 1; arr.i]` — Keep elements greater than 1.

  - **Reduction**
    - `acc = 0 [;; acc = acc + arr.i]` — Sum all elements of `arr`.
    - `acc = 1 [;; acc = acc * arr.i]` — Multiply all elements of `arr`.
    - `acc = 0 [;; acc = acc op arr.i]` — Use a custom operator `op` to combine elements (optimized to avoid array creation).

  - **Indexing**:
    - `arr.x:y`
    - `arr.x:`
    - `arr.:y`
    - `arr.x.y.:z`
    - `arr.:,z`
    - `arr.x:y,z`
    - `arr.x:y,z:f`
    - `arr.0` — Access the first element.
    - `arr.1:3` — Access elements from index 1 to index 3 (exclusive).
    - `arr.:2` — Access all elements up to index 2.
    - `arr.1.y:3` — Access a sub-array of the array at index 1.
  
  - **Ranging**:
    - `arr.0:4` — Access elements from index 0 to index 4 (exclusive).
    - `arr.:3` — Access all elements up to index 3.
    - `arr.3:5` — Access elements from index 3 to index 5 (exclusive).
    - `arr.5:8` — Access elements from index 5 to 8 (exclusive).
  
  - **Selection**:
    - `arr.0, 2` — Select elements at index 0 and 2.
    - `arr.x:y,z` — Select a range and specific elements, e.g., `arr.1:3, 0` selects elements from index 1 to 3 and the element at index 0.
    - `arr.:,2` — Select all elements and include index 2.
    - `arr.x:3,y` — Select elements from index x to index 3 and include index y.

### Variables
- Strongly and Statically-typed.
- Implicitly declared: `a := [i<3;;i]` initializes `a` constant and sets it's value to `[0, 1, 2]`
- There are two init operators, `=` defines a mutable variable, while `:=` defines a constant
- Initializations can be chained: this is valid initialization `x = y = z = 10`

### Operators
- Input: `$`
- Printing: `@`.
- Size-of: `#`.
- If: `?`
- Else: `:` 
- Parenthesis: `()`
- Equals: `==`.
- Not-equals: `!=`.
- Greater-than: `>`.
- Lesser-than: `<`.
- Greater-equal: `>=`.
- Lesser-equal: `<=`.
- Plus: `+`.
- Minus: `-`.
- Multiply: `*`.
- Division: `/`.
- Modulo: `%`.
- Square Brackets: `[]`
- Curly Brackets: `{}`.
- Logical and: `&&`.
- Logical or: `||`.
- Logical not: `!`.
- Init-const: `:=`.
- Init-mutable: `=`.
- Loop: `>>`

- Plus operator concatenates two arrays.
- `arr op float` is the same as `[;; arr.i op float]`.