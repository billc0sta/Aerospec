# Aerospec

a fully-fledged dynamic imperative programming language with functional traits.  

## Docs
See [docs](docs/).
still under construction

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
failed tests will be stored in the [failure](test/failure) directory.   
if a test succeeded and had a previous test result stored in 'failure', it will be deleted.   
for new test cases, add a test to the [tests](test/tests) directory then run:
```
./test/run_nosnaps.bat
```
the results will be stored in the [nosnaps](test/nosnaps) directory.   
results of test cases with no snapshots should be compared to the expected output.  
if succeeded, then it should be stored in the [snapshots](test/snapshots) directory.  
the last results will be stored in the [results](test/results) directory.