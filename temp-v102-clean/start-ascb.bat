@echo off
echo ========================================
echo    ASCB Database Management System
echo ========================================
echo.
echo Press any key to continue...
pause >nul
echo.

echo Checking Java installation...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed or not in PATH.
    echo Trying to find Java in common locations...
    
    for /d %%i in ("C:\Program Files\Java\*") do (
        if exist "%%i\bin\java.exe" (
            echo Found Java at: %%i
            set "JAVA_HOME=%%i"
            set "PATH=%%i\bin;%PATH%"
            goto java_found
        )
    )
    
    for /d %%i in ("C:\Program Files\Eclipse Adoptium\*") do (
        if exist "%%i\bin\java.exe" (
            echo Found Java at: %%i
            set "JAVA_HOME=%%i"
            set "PATH=%%i\bin;%PATH%"
            goto java_found
        )
    )
    
    echo Java not found. Please install Java 21.
    pause
    exit /b 1
)
:java_found
echo Java found successfully.

echo Checking Maven installation...
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo Maven not found in PATH. Trying common locations...
    
    if exist "C:\Tools\bin\mvn.cmd" (
        echo Found Maven in C:\Tools
        set "PATH=C:\Tools\bin;%PATH%"
        goto maven_found
    )
    
    if exist "%USERPROFILE%\scoop\apps\maven\current\bin\mvn.cmd" (
        echo Found Maven via Scoop
        set "PATH=%USERPROFILE%\scoop\apps\maven\current\bin;%PATH%"
        goto maven_found
    )
    
    echo Maven not found. Please install Maven.
    pause
    exit /b 1
)
:maven_found
echo Maven found successfully.

echo.
echo Starting ASCB Database System...

cd /d "%~dp0ascb-db"

if not exist "%~dp0ascb-db" (
    echo ERROR: Directory 'ascb-db' not found.
    pause
    exit /b 1
)

echo [1/2] Starting Backend Server...
echo Backend will run on: http://localhost:8080
start /B cmd /c "cd /d %~dp0ascb-db\backend && mvn spring-boot:run"

echo Waiting 15 seconds for backend to initialize...
timeout /t 15 /nobreak >nul

echo.
echo [2/2] Starting Frontend Application...
echo Frontend GUI will open in a new window.
start /MIN "ASCB Frontend" cmd /c "cd /d %~dp0ascb-db\frontend && mvn -DskipTests javafx:run"

echo.
echo Waiting for GUI to appear...

REM Wait up to 30 seconds for the GUI to be ready (marked by presence of ascb_gui_ready.txt)
set "counter=0"
:wait_for_gui
if exist "%TEMP%\ascb_gui_ready.txt" (
    echo GUI is ready! Closing launcher...
    del "%TEMP%\ascb_gui_ready.txt" >nul 2>&1
    timeout /t 1 /nobreak >nul
    exit /b 0
)

set /a counter+=1
if %counter% geq 60 (
    echo Timeout waiting for GUI. Proceeding anyway...
    exit /b 0
)

timeout /t 1 /nobreak >nul
goto wait_for_gui