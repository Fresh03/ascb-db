@echo off
REM ASCB Database System - Lightweight Setup
REM This version only checks for Java & Maven and provides download links if missing

setlocal enabledelayedexpansion

cls
echo.
echo ========================================
echo    ASCB Database System - Setup
echo ========================================
echo.

REM Check Java
echo Checking Java 21 installation...
java -version >nul 2>&1
if !errorlevel! equ 0 (
    echo [OK] Java found
    for /f "tokens=*" %%i in ('java -version 2^>^&1') do (
        echo      %%i
        goto java_ok
    )
)

:java_missing
echo [MISSING] Java 21 is not installed or not in PATH.
echo.
echo Download and install from: https://adoptium.net/temurin/releases/
echo   1. Select "Latest LTS Release" - JDK 21
echo   2. Select "Windows x64" 
echo   3. Run the installer
echo   4. Add Java to PATH (or restart after installation)
echo.
echo After installing Java, run this script again.
pause
exit /b 1

:java_ok
echo.

REM Check Maven
echo Checking Maven installation...
where mvn >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=*" %%i in ('mvn -version 2^>^&1') do (
        echo [OK] Maven found
        echo      %%i
        goto maven_ok
    )
)

:maven_missing
echo [MISSING] Maven is not installed or not in PATH.
echo.
echo Download and install from: https://maven.apache.org/download.cgi
echo   1. Download "Binary zip archive" (apache-maven-3.9.6-bin.zip)
echo   2. Extract to: C:\apache-maven
echo   3. Add to PATH:
echo      - Open System Properties (Win+R: sysdm.cpl)
echo      - Click "Environment Variables"
echo      - Edit "Path" and add: C:\apache-maven\bin
echo   4. Restart command prompt
echo.
echo After installing Maven, run this script again.
pause
exit /b 1

:maven_ok
echo.
echo ========================================
echo All requirements found! Starting app...
echo ========================================
echo.

REM Get script directory
set "scriptDir=%~dp0"
cd /d "!scriptDir!ascb-db"

if not exist "backend" (
    echo ERROR: backend directory not found
    pause
    exit /b 1
)

echo Starting Backend Server...
start /B cmd /c "cd /d !scriptDir!ascb-db\backend && mvn spring-boot:run"

echo Waiting 15 seconds for backend initialization...
timeout /t 15 /nobreak

echo.
echo Starting Frontend Application...
start /MIN "ASCB Frontend" cmd /c "cd /d !scriptDir!ascb-db\frontend && mvn -DskipTests javafx:run"

echo.
echo Waiting for GUI to appear...

REM Wait for GUI ready signal
set "counter=0"
:wait_loop
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
