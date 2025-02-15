@echo off
setlocal enabledelayedexpansion

if "%~3"=="" (
    echo Usage: %0 ^<filename^> ^<query_number^> ^<team_number^>
    exit /b 1
)

set "filename=%~1"
set "query_num=%~2"
set "team_num=%~3"

REM Calculate the new value
set /a new_value=20+%team_num%

REM Run PowerShell to replace the value the number with the new value
powershell -Command "(Get-Content '%filename%') -replace '\b%query_num%\b', '%new_value%' | Set-Content '%filename%'"

echo Successfully replaced all occurrences of '%query_num%' with '%new_value%'
