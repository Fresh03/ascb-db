@echo off
REM ASCB Database System Launcher (Windows Batch)
REM This batch file calls the PowerShell script with proper execution policy

echo Starting ASCB Database System...
echo.

REM Run PowerShell script with bypass execution policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0start-ascb.ps1'"

echo.
echo Press any key to exit...
pause >nul

set /a counter+=1
if %counter% geq 60 (
    echo Timeout waiting for GUI. Proceeding anyway...
    exit /b 0
)

timeout /t 1 /nobreak >nul
goto wait_for_gui