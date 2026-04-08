@echo off
REM ASCB Database System - Universal Setup and Run Script
REM This script works on any Windows machine by automatically installing Java 17 and Maven if needed

setlocal enabledelayedexpansion

echo.
echo ========================================
echo    ASCB Database System - Auto Setup
echo ========================================
echo.

REM Check if PowerShell is available and run the setup script
where powershell >nul 2>&1
if %errorlevel% equ 0 (
    echo Launching auto-setup PowerShell script...
    echo.
    
    REM Get the directory where this script is located
    set "scriptDir=%~dp0"
    
    REM Run PowerShell with unrestricted execution policy for this script only
    powershell -NoProfile -ExecutionPolicy Bypass -File "!scriptDir!setup-and-run.ps1"
    set "exitCode=!errorlevel!"

    echo.
    if !exitCode! equ 0 (
        echo The application launcher finished.
        echo If the ASCB window is open, you can close this console safely.
    ) else (
        echo Startup failed. Review the message above and the logs folder, then press any key.
    )
    pause
    exit /b !exitCode!
) else (
    echo ERROR: PowerShell is not available on this system.
    echo.
    echo Please install PowerShell or run setup-and-run.ps1 manually:
    echo   Right-click setup-and-run.ps1 and select "Run with PowerShell"
    echo.
    pause
    exit /b 1
)
