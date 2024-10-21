@Echo Off
SetLocal EnableExtensions DisableDelayedExpansion

Set /A passed=failed=nosnaps=0

For %%G In ("tests\*") Do (
    
    dune.exe exec ..\_build\default\bin\main.exe "%%G" 1>"results\%%~nG.txt" 2>NUL
    
    If Exist "snapshots\%%~nG.txt" (
        %SystemRoot%\System32\fc.exe "snapshots\%%~nG.txt" "results\%%~nG.txt" 1>NUL && (
            Echo PASSED: %%~nG
            Set /A passed += 1
        ) || (
            Echo FAILED: %%~nG
            Set /A failed += 1
        )
    ) Else (
        Echo NOSNAP: %%~nG
        Set /A nosnaps += 1
    )
)

Echo.
Echo SUMMARY:
Echo PASSED: %passed%
Echo FAILED: %failed%
Echo NOSNAP: %nosnaps%

EndLocal
