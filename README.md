# Aerospec

a full-fledged dynamic imperative programming language with functional traits.  
documents will be available soon, for now, there's only minimal specification [here](spec/Language Specification.md).  
here's how you can implement Mandelbrot set in Aerospec  
```Aerospec
mandelbrot := (cx, cy, max_iter) {
    zx = zy = iter = 0
    >> (zx * zx + zy * zy <= 4 && iter < max_iter) {
        xtemp = zx * zx - zy * zy + cx
        zy = 2 * zx * zy + cy
        zx = xtemp
        iter = iter + 1
    }
    -> iter
}

generate_mandelbrot := (width, height, max_iter, x_min, x_max, y_min, y_max) {
    x_range := (x_max - x_min) / width
    y_range := (y_max - y_min) / height
    i = 0
    >> (i < height) {
        j = 0
        >> (j < width) {
            cx = x_min + j * x_range
            cy = y_min + i * y_range
            iter = mandelbrot(cx, cy, max_iter)
            
            ?? (iter == max_iter) print("*")
            :: print(" ")

            j = j + 1
        }
        print("\n")
        i = i + 1
    }
}

width := 80
height := 40
max_iter := 100
x_min := -2.5
x_max := 1
y_min := -1
y_max := 1

generate_mandelbrot(width, height, max_iter, x_min, x_max, y_min, y_max)
```

to run programs use: 
```
./_build/default/bin/main.exe program.aero
```
