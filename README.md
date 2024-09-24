## Traits
- Guaranteed tail optimizations.
- Minimal functional programming language that allows side effects.
- Statically typed with type inference.
- Turing complete.
- Highly influenced by mathematical notation.
## Structures
- Literals 
- Types
- Operators
- Functions
- lambdas
- Pattern matching
- Variables (constants)
### Literals
- **Integer Literal**: `13138`
- **Float Literal**: `1292.043`
### Functions and Lambdas
- Treated as first-class citizens.
- Support for capturing.
- Must have at least one parameter.
- Function calls: `f(x, y)`.
- Function definition: `f(p1, p2) -> p1 op p2`.
- Lambda definition: `(p1, p2) -> p1 op p2`
- Function definition `f(x) -> x+1`is just a syntax sugar for `f = (x) -> x+1`
- Recursion is allowed.
### Types
- **Floats**
- **Arrays (n-dimensional)**
### Floats
- All numeric values are represented as double-precision floats at runtime.
### Arrays
- **Syntax**: `arr = (0, 1, 2, 3)`.
- 0-based indexing.
- **Indexing**: Denoted by `.`; **Ranging**: Denoted by `:`; **Selections**: Denoted by `,`.
- **Getting Size**: `#arr`.
- **Builders**:
  - Syntax: `arr = (range; condition; generator)` or `arr = (0 < i < 10; i % 2 == 0; i)`.
  - Identifier `i` is optional.
  - Conditional expressions can be omitted: `(5 < i < 10;; i)`.
  - Range expressions can be omitted if an identifier is used for indexing: `(;; arr.i + 10)` evaluates to `(0 < i < #arr; 1; arr.i + 10)`.
  - The lower bound (`0 <`) can be omitted, defaulting to `0 <= ...`; the upper bound is mandatory.
  - Valid operators in generation expressions: `<` and `<=`, `<=` is inclusive, `<` isn't
- **Examples**:
  - Indexing: `arr.x:y`, `arr.x:`, `arr.:y`, `arr.x.y.:z`, `arr.:,z`, `arr.x:y,z`, `arr.x:y,z:f`.
  - Mapping: `(;; f(arr.i))`.
  - Filtering: `(; f(arr.i); arr.i)`.
  - Reduction: `acc = 0 (;; acc = acc op arr.i)` (optimized to avoid array creation).
### Pattern Matching
- **Syntax**: `| condition ? expression | c2 ? e2`.
- Catch-all condition: Use `| expression`, (the condition is omitted)
- Optimized into a jump table when possible.
### Operators
- Printing: `@`.
- Size-of: `#`.
- If: `?`
- Else: `:`
- Parenthesis: `()`
- Assignment: `=`.
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
- Curly Brackets: `{}`
- Logical and: `&`.
- Logical or: `|`.
- Logical not: `!`.

- Plus operator concatenates two arrays.
- `arr op float` is the same as `[;; arr.i op float]`.