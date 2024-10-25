# Aerospec

a fully-fledged dynamic imperative programming language with functional traits.  
documents will be available very soon.

## Examples
See [examples](examples/).

## Usage
to run programs use: 
```
./_build/default/bin/main.exe program.aero
```

## Testing
to test fixtures:
```
./test/run_all.bat
```

for new test cases:
```
./test/run_nosnaps.bat
```
the results will be stored in [results](test/results).   
results of test cases with no snapshots should be compared to the expected output.  
if succeeded, then it should be stored in (snapshots)[test/snapshots]