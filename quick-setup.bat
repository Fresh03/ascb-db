@echo off
REM ASCB Database System - Quick Setup Launcher
REM Still checks Java 17+, but skips Maven installation because the project uses Maven Wrapper.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-and-run.ps1" -SkipMavenSetup
set "exitCode=%errorlevel%"
echo.
if %exitCode% equ 0 (
    echo The application launcher finished.
    echo If the ASCB window is open, you can close this console safely.
) else (
    echo Startup failed. Review the message above and the logs folder, then press any key.
)
pause
exit /b %exitCode%

