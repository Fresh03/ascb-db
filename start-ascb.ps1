# ASCB Database Management System Launcher
# PowerShell Script for Windows

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    ASCB Database Management System" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host

Write-Host "Checking Java installation..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String -Pattern "version"
    if ($javaVersion -match "21") {
        Write-Host "✓ Java 21 found" -ForegroundColor Green
    } else {
        Write-Host "⚠ Java found but not version 21. This may cause issues." -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ ERROR: Java is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Java 21 and add it to your PATH." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Checking Maven installation..." -ForegroundColor Yellow
try {
    $mvnVersion = mvn -version 2>&1 | Select-String -Pattern "Apache Maven"
    if ($mvnVersion) {
        Write-Host "✓ Maven found" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ ERROR: Maven is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Maven and add it to your PATH." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host
Write-Host "Starting ASCB Database System..." -ForegroundColor Green
Write-Host

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Join-Path $scriptDir "ascb-db"

Write-Host "[1/2] Starting Backend Server..." -ForegroundColor Yellow
Write-Host "Backend will run on: http://localhost:8080" -ForegroundColor White

# Start backend in background
$backendDir = Join-Path $projectDir "backend"
$backendProcess = Start-Process -FilePath "cmd" -ArgumentList "/k cd /d $backendDir && mvn spring-boot:run -q" -NoNewWindow -PassThru

Write-Host "Waiting for backend to initialize..." -ForegroundColor Yellow

# Health check: wait for backend to be ready
$maxAttempts = 30
$attempt = 0
$backendReady = $false

while ($attempt -lt $maxAttempts -and -not $backendReady) {
    $attempt++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host "✓ Backend is ready (took $attempt seconds)" -ForegroundColor Green
        }
    } catch {
        Write-Host -NoNewline "."
        Start-Sleep -Seconds 1
    }
}

if (-not $backendReady) {
    Write-Host "⚠ Production backend failed to start, trying dev mode (H2 database)..." -ForegroundColor Yellow
    
    # Kill the failed backend process
    Stop-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue
    
    # Start backend in dev mode
        $backendProcess = Start-Process -FilePath "cmd" -ArgumentList "/k", "cd", "/d", $backendDir, "&&", "mvn", "spring-boot:run", "-Dspring.profiles.active=dev", "-q" -NoNewWindow -PassThru
    # Wait for dev backend to start
    $attempt = 0
    while ($attempt -lt 20 -and -not $backendReady) {
        $attempt++
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $backendReady = $true
                Write-Host "✓ Dev backend is ready (took $attempt seconds)" -ForegroundColor Green
            }
        } catch {
            Write-Host -NoNewline "."
            Start-Sleep -Seconds 1
        }
    }
}

if (-not $backendReady) {
    Write-Host "❌ Backend failed to start in both modes. Check logs and network connection." -ForegroundColor Red
    exit 1
}

Write-Host
Write-Host "[2/2] Starting Frontend Application..." -ForegroundColor Yellow
Write-Host "Frontend GUI will open in a new window." -ForegroundColor White

# Start frontend
$frontendDir = Join-Path $projectDir "frontend"
$frontendProcess = Start-Process -FilePath "cmd" -ArgumentList "/k cd /d $frontendDir && mvn -DskipTests javafx:run" -NoNewWindow -PassThru

Write-Host
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    System Started Successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host
Write-Host "- Backend API: http://localhost:8080" -ForegroundColor White
Write-Host "- Frontend GUI: Should open automatically" -ForegroundColor White
Write-Host
Write-Host "Press Ctrl+C to stop all services..." -ForegroundColor Yellow

# Wait for user interrupt
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "Stopping services..." -ForegroundColor Yellow
    Stop-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue
    Stop-Process -Id $frontendProcess.Id -ErrorAction SilentlyContinue
}