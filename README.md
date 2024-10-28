# Aerospec

a fully-fledged dynamic imperative programming language with functional traits.  

## Docs
See [docs](docs/).

## Examples
See [examples](examples/).

## Installation
Go to [Releases](https://github.com/billc0sta/Aerospec/releases/) page and download the latest version.   
for now, Aerospec is only compiled for Windows.  
it needs to be re-built if you're using another OS.

## Usage
to run programs use: 
```
Aerospec program.aero
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