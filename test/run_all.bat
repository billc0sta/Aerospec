@echo off
setlocal enabledelayedexpansion

set passed=0
set failed=0
set nosnaps=0

set results_path=.\results
set snapshots_path=.\snapshots

for %%i in (./tests/*) do (
    set "filename=%%~ni"

    call dune exec ..\_build\default\bin\main.exe ".\tests\%%i" > "!results_path!\!filename!.txt" 2> nul

    if exist "!results_path!\!filename!.txt" (
        set "snapshot_file=!snapshots_path!\!filename!.txt"

        if exist "!snapshot_file!" (            
            fc "!results_path!\!filename!.txt" "!snapshot_file!" > nul
            if !errorlevel! == 0 (
                echo PASSED TEST: !filename!
                set /a passed+=1
            ) else (
                echo FAILED TEST: !filename!
                set /a failed+=1
            )
        ) else (
            echo NOSNAP TEST: !filename!
            set /a nosnaps+=1
        )
    ) else (
        echo Result file does NOT exist: "!results_path!\!filename!.txt"
    )
)

echo.
echo SUMMARY:
echo PASSED: !passed!
echo FAILED: !failed!
echo NOSNAP: !nosnaps!

endlocal
