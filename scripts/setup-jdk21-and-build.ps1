<#
setup-jdk21-and-build.ps1

Usage examples:
# 1) If you already installed JDK21 and know its install path:
#    .\setup-jdk21-and-build.ps1 -JdkPath 'C:\Program Files\Eclipse Adoptium\jdk-21.0.2'
# 2) If JDK21 is already on PATH, just run the script and it will use it:
#    .\setup-jdk21-and-build.ps1
#
# The script will:
# - show current java version (if any)
# - attempt to locate a JDK21 under common Program Files locations when JdkPath not provided
# - set JAVA_HOME and PATH for the current session
# - run `mvn -v` and then `mvn -DskipTests package` from the repository root
#
# NOTE: This script modifies environment variables only for the current PowerShell session.
# It won't change system environment variables permanently.
 #>
param(
    [string]$JdkPath
)

function Get-JavaVersion {
    if (Get-Command java -ErrorAction SilentlyContinue) {
        $out = & java -version 2>&1
        return ($out -join "`n")
    }
    return $null
}

Write-Host "--- JDK21 helper & build script ---" -ForegroundColor Cyan

$javaInfo = Get-JavaVersion
if ($javaInfo) {
    Write-Host "Current 'java -version' output:`n$javaInfo`n" -ForegroundColor Yellow
} else {
    Write-Host "No 'java' found on PATH." -ForegroundColor Yellow
}

function Get-MajorJavaVersionFromOutput([string]$verOutput) {
    if (-not $verOutput) { return $null }
    if ($verOutput -match '"(\d+)(?:\.(\d+))?(?:\.\d+)?') {
        return [int]$Matches[1]
    }
    return $null
}

$major = Get-MajorJavaVersionFromOutput -verOutput $javaInfo

if ($JdkPath) {
    if (-not (Test-Path $JdkPath)) {
        Write-Host "Provided JdkPath '$JdkPath' does not exist." -ForegroundColor Red
        exit 1
    }
    $resolved = (Resolve-Path $JdkPath).Path
    Write-Host "Using provided JDK path: $resolved" -ForegroundColor Green
    $env:JAVA_HOME = $resolved
    $env:PATH = "$env:JAVA_HOME\bin;${env:PATH}"
} elseif ($major -ge 21) {
    Write-Host "Detected java major version $major on PATH; attempting to infer JAVA_HOME from java executable." -ForegroundColor Green
    try {
        $javaCmdEntry = Get-Command java -ErrorAction Stop
        $javaCmd = $javaCmdEntry.Source
        if ($javaCmd) {
            $javaExe = (Resolve-Path $javaCmd).Path
            $jdkRoot = Split-Path -Parent $javaExe
            # If the resolved path points to a 'bin' folder, step up one level to the JDK root
            if ([IO.Path]::GetFileName($jdkRoot) -ieq 'bin') { $jdkRoot = Split-Path -Parent $jdkRoot }
            if (Test-Path (Join-Path $jdkRoot 'bin\java.exe')) {
                $env:JAVA_HOME = $jdkRoot
                $env:PATH = "$env:JAVA_HOME\bin;${env:PATH}"
                Write-Host "Inferred JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Green
            } else {
                Write-Host "Could not verify JDK layout under inferred path: $jdkRoot. Leaving PATH unchanged." -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "Could not infer JAVA_HOME from PATH java; leaving PATH unchanged." -ForegroundColor Yellow
    }
} else {
    Write-Host "No suitable Java 21 detected. Searching common Program Files locations for JDK 21..." -ForegroundColor Yellow
    $candidates = @(
        'C:\Program Files\Eclipse Adoptium',
        'C:\Program Files\Adoptium',
        'C:\Program Files\Temurin',
        'C:\Program Files\Amazon Corretto',
        'C:\Program Files\Zulu',
        'C:\Program Files\Microsoft',
        'C:\Program Files\Java'
    )

    $found = $null
    foreach ($base in $candidates) {
        if (-not (Test-Path $base)) { continue }
        Get-ChildItem -Path $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Name -match '21') {
                $candidate = $_.FullName
                # check bin\java exists
                if (Test-Path (Join-Path $candidate 'bin\java.exe')) {
                    $found = $candidate
                }
            }
        }
        if ($found) { break }
    }

    if ($found) {
        Write-Host "Found JDK21 at: $found" -ForegroundColor Green
        $env:JAVA_HOME = $found
        $env:PATH = "$env:JAVA_HOME\bin;${env:PATH}"
    } else {
        Write-Host "No JDK21 automatically found. Please install JDK 21 first. Suggestions:" -ForegroundColor Red
        Write-Host "- Using Chocolatey (run as Administrator): choco install temurin21jdk -y" -ForegroundColor Yellow
        Write-Host "- Or download Temurin 21: https://adoptium.net/temurin/releases/?version=21" -ForegroundColor Yellow
        Write-Host "- Or use your preferred JDK vendor and then re-run this script with -JdkPath '<install_path>'" -ForegroundColor Yellow
        exit 2
    }
}

# Verify we now have Java 21
$javaInfo2 = Get-JavaVersion
Write-Host "After session setup, 'java -version' ->`n$javaInfo2`n" -ForegroundColor Cyan
$major2 = Get-MajorJavaVersionFromOutput -verOutput $javaInfo2
if (-not $major2 -or $major2 -lt 21) {
    Write-Host "WARNING: Java major version is not 21. Detected: $major2" -ForegroundColor Red
    Write-Host "If you intended to use JDK21, set -JdkPath to the JDK21 installation folder and re-run." -ForegroundColor Yellow
    exit 3
}

# Run mvn -v then build
Write-Host "Running 'mvn -v' to show Maven using Java..." -ForegroundColor Cyan
mvn -v

Write-Host "Running 'mvn -DskipTests package' from repository root..." -ForegroundColor Cyan
Push-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) | Out-Null
# assume script lives in scripts/ under repo root
$repoRoot = Resolve-Path ".." | Select-Object -ExpandProperty Path
Pop-Location | Out-Null
Write-Host "Repository root: $repoRoot" -ForegroundColor Green
Set-Location -Path $repoRoot

$mvnCmd = 'mvn -DskipTests package'
Write-Host "Executing: $mvnCmd" -ForegroundColor Cyan
Invoke-Expression $mvnCmd

Write-Host "Completed build step. If compilation failed, paste the output here and I will help triage." -ForegroundColor Green
