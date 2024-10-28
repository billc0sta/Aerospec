@Echo Off
SetLocal EnableExtensions DisableDelayedExpansion

Set /A nosnaps=0

For %%G In ("tests\*") Do (

    If Not Exist "snapshots\%%~nG.txt" (
       dune.exe exec ..\_build\default\bin\main.exe "%%G" 1>"results\%%~nG.txt" 2>NUL
       Echo NOSNAP: %%~nG
       Set /A nosnaps += 1
       Copy "results\%%~nG.txt" "nosnaps\%%~nG.txt" >NUL
    )
)

Echo.
Echo SUMMARY: 
Echo NOSNAP: %nosnaps%
