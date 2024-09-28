# Language Overhaul

1. implicit variable declaration is not good for statically-typed language
and neither is static-typing good for conciseness nor interpreted languages
so I will keep the syntax and turn the language into a dynamic one

2. the builder construct is great, but it needs to be massively nerfed, there's no need for the language to revolve around it, 
and it shouldn't replace looping constructs

3. I think dealing with functions as just lambda constants is nice and emphasizes the functional influence, remove the syntactic sugar of function declaration

4. add while and for loops, while repeats until the condition is false, for uses ranging

5. add strings

6. allow printing functions, prints the signature

7. add some kind of structuring type

8. remove unnecessary or replaceable operators, to clear space for new constructs

9. swap between assignment and constant-assignment operators

10. ranges are a separate type, they can be assigned to variables.

11. ranges truthiness depends on whether the iterator has reached it's end