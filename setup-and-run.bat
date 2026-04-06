@echo off
REM ASCB Database System - Universal Setup and Run Script
REM This script works on any Windows machine by automatically installing Java 21 and Maven if needed

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
    
    if !errorlevel! equ 0 (
        exit /b 0
    ) else (
        exit /b 1
    )
) else (
    echo ERROR: PowerShell is not available on this system.
    echo.
    echo Please install PowerShell or run setup-and-run.ps1 manually:
    echo   Right-click setup-and-run.ps1 and select "Run with PowerShell"
    echo.
    pause
    exit /b 1
)
