# ASCB Database Management System Launcher

Write-Host "Checking requirements..." -ForegroundColor Cyan
java -version 2>&1 | out-null
mvn -version 2>&1 | out-null

Write-Host "Starting backend..." -ForegroundColor Yellow
$backendDir = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "ascb-db\backend"
Start-Process powershell.exe -ArgumentList "-NoProfile", "-Command", "cd '$backendDir'; mvn spring-boot:run -q" -NoNewWindow

Write-Host "Waiting for backend to start..." -ForegroundColor Yellow
$ready = 0
for ($i = 0; $i -lt 30; $i++) {
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 1 -ErrorAction SilentlyContinue
        if ($r.StatusCode -eq 200) {
            $ready = 1
            Write-Host "Backend ready" -ForegroundColor Green
            break
        }
    } catch {}
    Write-Host -NoNewline "."
    Start-Sleep 1
}

if ($ready -eq 0) {
    Write-Host "Backend failed, trying dev mode..." -ForegroundColor Yellow
    for ($i = 0; $i -lt 20; $i++) {
        try {
            $r = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 1 -ErrorAction SilentlyContinue
            if ($r.StatusCode -eq 200) {
                $ready = 1
                Write-Host "Dev backend ready" -ForegroundColor Green
                break
            }
        } catch {}
        Write-Host -NoNewline "."
        Start-Sleep 1
    }
}

if ($ready -eq 1) {
    Write-Host ""
    Write-Host "Starting frontend..." -ForegroundColor Yellow
    $frontendDir = Join-Path (Split-Path $MyInvocation.MyCommand.Path) "ascb-db\frontend"
    Start-Process powershell.exe -ArgumentList "-NoProfile", "-Command", "cd '$frontendDir'; mvn -DskipTests javafx:run" -NoNewWindow
    
    Write-Host "System started successfully!" -ForegroundColor Green
} else {
    Write-Host "Backend failed to start" -ForegroundColor Red
    exit 1
}
