@Echo Off
SetLocal EnableExtensions DisableDelayedExpansion

Set /A passed=failed=nosnaps=0

For %%G In ("tests\*") Do (
    
    dune.exe exec ..\_build\default\bin\main.exe "%%G" 1>"results\%%~nG.txt" 2>NUL
    
    If Exist "snapshots\%%~nG.txt" (
        If Exist "nosnaps\%%~nG.txt" Del "nosnaps\%%~nG.txt"
        
        %SystemRoot%\System32\fc.exe "snapshots\%%~nG.txt" "results\%%~nG.txt" 1>NUL && (
            Echo PASSED: %%~nG
            Set /A passed += 1
            If Exist "failure\%%~nG.txt" Del "failure\%%~nG.txt"
        ) || (
            Echo FAILED: %%~nG
            Set /A failed += 1
            Copy "results\%%~nG.txt" "failure\%%~nG.txt" >NUL
        )
    ) Else (
        Copy "results\%%~nG.txt" "nosnaps\%%~nG.txt" >NUL
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
