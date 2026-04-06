@echo off
REM ASCB Database System - Quick Setup Launcher
REM This batch file calls the PowerShell setup script

echo Starting ASCB Database System Setup...
echo.

REM Run PowerShell script with bypass execution policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0setup-and-run.ps1'"

echo.
echo Press any key to exit...
pause >nul
if exist "%TEMP%\ascb_gui_ready.txt" (
    echo.
    echo ========================================
    echo GUI is ready! Application started.
    echo ========================================
    del "%TEMP%\ascb_gui_ready.txt" >nul 2>&1
    exit /b 0
)

set /a counter+=1
if !counter! geq 60 (
    echo.
    echo Timeout - if app doesn't start, check:
    echo 1. Backend is running on port 8080
    echo 2. Frontend window (minimized) is open
    echo 3. Check temp folder for errors
    exit /b 0
)

timeout /t 1 /nobreak >nul
goto wait_loop
