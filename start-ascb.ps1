# ASCB Database Management System Launcher

Write-Host "Launching ASCB Database System (non-Docker mode)..." -ForegroundColor Cyan
$scriptPath = Join-Path $PSScriptRoot "setup-and-run.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "setup-and-run.ps1 nu a fost găsit." -ForegroundColor Red
    exit 1
}

& $scriptPath
exit $LASTEXITCODE
