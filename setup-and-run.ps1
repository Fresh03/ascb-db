# ASCB Database System - Setup and Run Script
# This script uses Java 17+ (and can install Java 21 if needed) plus Maven Wrapper, then starts the application
# 
# Usage:
#   .\setup-and-run.ps1                           (Full setup and run)
#   .\setup-and-run.ps1 -SkipJavaSetup            (Skip Java check, use existing)
#   .\setup-and-run.ps1 -SkipMavenSetup           (Skip Maven check, use existing)
#   .\setup-and-run.ps1 -PreferCloudDb            (Try TiDB Cloud first; otherwise local H2 is used)
#   .\setup-and-run.ps1 -SkipJavaSetup -SkipMavenSetup  (Use existing tools, just run app)

param(
    [switch]$SkipJavaSetup = $false,
    [switch]$SkipMavenSetup = $false,
    [switch]$PreferCloudDb = $false
)

$RequiredJavaVersion = 17
$PreferredJavaVersion = 21

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")
    $colors = @{
        "INFO" = "Cyan"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
    }
    Write-Host "[$Status] $Message" -ForegroundColor $colors[$Status]
}

function Get-JavaMajorVersion {
    param([object]$JavaVersionOutput)

    if ($null -eq $JavaVersionOutput) {
        return $null
    }

    $versionText = if ($JavaVersionOutput -is [System.Array]) {
        $JavaVersionOutput -join "`n"
    } else {
        [string]$JavaVersionOutput
    }

    if ($versionText -match 'version\s+"(?<major>\d+)(?:\.(?<minor>\d+))?') {
        $major = [int]$Matches['major']
        if ($major -eq 1 -and $Matches['minor']) {
            return [int]$Matches['minor']
        }
        return $major
    }

    return $null
}

function Use-JavaHome {
    param([string]$JavaHome)

    if ([string]::IsNullOrWhiteSpace($JavaHome)) {
        return $false
    }

    $resolvedHome = $JavaHome.TrimEnd('\\')
    $javaExe = Join-Path $resolvedHome "bin\java.exe"
    if (-not (Test-Path $javaExe)) {
        return $false
    }

    $env:JAVA_HOME = $resolvedHome
    if (-not ($env:PATH -split ';' | Where-Object { $_ -eq "$resolvedHome\bin" })) {
        $env:PATH = "$resolvedHome\bin;$env:PATH"
    }
    return $true
}

function Find-SupportedJavaHome {
    $candidates = New-Object System.Collections.Generic.List[string]

    if ($env:JAVA_HOME) {
        $candidates.Add($env:JAVA_HOME)
    }

    $javaLocations = @(
        "C:\Program Files\Eclipse Adoptium",
        "C:\Program Files\Adoptium",
        "C:\Program Files\Java",
        "C:\Program Files\Microsoft",
        "C:\Program Files\Amazon Corretto",
        "$env:USERPROFILE\AppData\Local\Programs\Eclipse Adoptium"
    )

    foreach ($location in $javaLocations) {
        if (-not (Test-Path $location)) {
            continue
        }

        Get-ChildItem -Path $location -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            ForEach-Object {
                $candidates.Add($_.FullName)
            }
    }

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (-not (Use-JavaHome $candidate)) {
            continue
        }

        try {
            $javaVersion = & java -version 2>&1
            $majorVersion = Get-JavaMajorVersion $javaVersion
            if ($LASTEXITCODE -eq 0 -and $majorVersion -ge $RequiredJavaVersion) {
                Write-Status "Using Java $majorVersion from: $candidate" "SUCCESS"
                return $true
            }
        } catch {
            # Keep searching
        }
    }

    return $false
}

function Check-Java {
    try {
        $javaVersion = & java -version 2>&1
        $majorVersion = Get-JavaMajorVersion $javaVersion
        if ($LASTEXITCODE -eq 0 -and $majorVersion -ge $RequiredJavaVersion) {
            Write-Status "Java $majorVersion found: $($javaVersion[0])" "SUCCESS"
            return $true
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Status "Detected Java $majorVersion, but Java $RequiredJavaVersion or newer is required." "WARNING"
        }
    } catch {
        Write-Status "Java not found in PATH" "WARNING"
    }

    if (Find-SupportedJavaHome) {
        return $true
    }

    return $false
}

function Install-Java {
    Write-Status "Installing Java 21 (Eclipse Temurin)..." "INFO"
    
    $javaUrl = "https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1%2B12/OpenJDK21U-jdk_x64_windows_hotspot_21.0.1_12.msi"
    $javaInstaller = "$env:TEMP\java-installer.msi"
    
    Write-Status "Downloading Java 21..." "INFO"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $javaUrl -OutFile $javaInstaller -UseBasicParsing
        Write-Status "Download completed" "SUCCESS"
    } catch {
        Write-Status "Failed to download Java: $_" "ERROR"
        Write-Status "Please download Java 21 manually from: https://adoptium.net/temurin/releases/" "WARNING"
        return $false
    }
    
    Write-Status "Installing Java 21..." "INFO"
    try {
        $installProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$javaInstaller`" /quiet /qn" -Wait -PassThru
        if ($installProcess.ExitCode -ne 0) {
            Write-Status "Java installer exited with code $($installProcess.ExitCode)" "ERROR"
            return $false
        }

        if (-not (Find-SupportedJavaHome)) {
            Write-Status "Java installer finished, but a supported Java version could not be activated automatically." "ERROR"
            return $false
        }

        Write-Status "Java 21 installed successfully" "SUCCESS"
        
        # Cleanup installer
        Remove-Item -Path $javaInstaller -Force -ErrorAction SilentlyContinue
        return $true
    } catch {
        Write-Status "Installation failed: $_" "ERROR"
        return $false
    }
}

function Check-Maven {
    try {
        $mvnVersion = & mvn -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Maven found: $($mvnVersion[0])" "SUCCESS"
            return $true
        }
    } catch {
        Write-Status "Maven not found in PATH" "WARNING"
    }
    
    # Check common installation locations
    $mavenLocations = @(
        "C:\Program Files\Apache\Maven",
        "C:\apache-maven",
        "$env:USERPROFILE\AppData\Local\apache-maven"
    )
    
    foreach ($location in $mavenLocations) {
        if (Test-Path "$location\bin\mvn.cmd") {
            Write-Status "Found Maven at: $location" "SUCCESS"
            $env:PATH = "$location\bin;$env:PATH"
            return $true
        }
    }
    
    return $false
}

function Install-Maven {
    Write-Status "Installing Maven 3.9.6..." "INFO"
    
    $mavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
    $mavenZip = "$env:TEMP\maven.zip"
    $mavenExtract = "$env:TEMP\maven-extract"
    $mavenFinal = "C:\apache-maven"
    
    Write-Status "Downloading Maven 3.9.6..." "INFO"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $mavenUrl -OutFile $mavenZip -UseBasicParsing
        Write-Status "Download completed" "SUCCESS"
    } catch {
        Write-Status "Failed to download Maven: $_" "ERROR"
        Write-Status "Please download Maven manually from: https://maven.apache.org/download.cgi" "WARNING"
        return $false
    }
    
    Write-Status "Extracting Maven..." "INFO"
    try {
        if (Test-Path $mavenExtract) {
            Remove-Item -Path $mavenExtract -Recurse -Force
        }
        
        Expand-Archive -Path $mavenZip -DestinationPath $mavenExtract
        
        if (Test-Path $mavenFinal) {
            Remove-Item -Path $mavenFinal -Recurse -Force
        }
        
        Move-Item -Path "$mavenExtract\apache-maven-3.9.6" -Destination $mavenFinal
        
        Write-Status "Maven installed successfully at: $mavenFinal" "SUCCESS"
        
        # Add Maven to PATH
        $env:PATH = "$mavenFinal\bin;$env:PATH"
        
        # Cleanup
        Remove-Item -Path $mavenZip -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $mavenExtract -Recurse -Force -ErrorAction SilentlyContinue
        return $true
    } catch {
        Write-Status "Installation failed: $_" "ERROR"
        return $false
    }
}

function Show-RecentLog {
    param(
        [string]$Label,
        [string]$LogPath,
        [int]$Lines = 30
    )

    if (Test-Path $LogPath) {
        Write-Host ""
        Write-Status "$Label (last $Lines lines):" "WARNING"
        Get-Content -Path $LogPath -Tail $Lines -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  $_"
        }
    }
}

function Start-Application {
    Write-Status "Starting ASCB Database System..." "INFO"
    
    $scriptDir = Split-Path -Parent $PSCommandPath
    $backendDir = Join-Path $scriptDir "ascb-db\backend"
    $frontendDir = Join-Path $scriptDir "ascb-db\frontend"
    $projectPom = Join-Path $scriptDir "ascb-db\pom.xml"
    $logsDir = Join-Path $scriptDir "logs"
    $guiMarker = Join-Path $env:TEMP "ascb_gui_ready.txt"
    $mavenCmd = Join-Path $backendDir "mvnw.cmd"
    if (-not (Test-Path $mavenCmd)) {
        $mavenCmd = "mvn"
    }

    New-Item -ItemType Directory -Force -Path $logsDir | Out-Null
    Remove-Item $guiMarker -Force -ErrorAction SilentlyContinue
    Write-Status "Logs will be saved to: $logsDir" "INFO"
    
    if (-not (Test-Path $backendDir)) {
        Write-Status "Backend directory not found at: $backendDir" "ERROR"
        return $false
    }
    
    if (-not (Test-Path $frontendDir)) {
        Write-Status "Frontend directory not found at: $frontendDir" "ERROR"
        return $false
    }
    
    $backendReady = $false
    $attempt = 0
    $maxAttempts = 60

    $backendStdOut = Join-Path $logsDir "backend.log"
    $backendStdErr = Join-Path $logsDir "backend-error.log"
    $frontendStdOut = Join-Path $logsDir "frontend.log"
    $frontendStdErr = Join-Path $logsDir "frontend-error.log"

    Remove-Item $backendStdOut, $backendStdErr, $frontendStdOut, $frontendStdErr -Force -ErrorAction SilentlyContinue

    if ($PreferCloudDb) {
        Write-Status "Starting Backend Server on port 8080 using TiDB Cloud..." "INFO"
        $backendProcess = Start-Process -FilePath $mavenCmd `
            -ArgumentList @("-q", "-f", $projectPom, "-pl", "backend", "-am", "spring-boot:run") `
            -WorkingDirectory $backendDir `
            -WindowStyle Hidden `
            -RedirectStandardOutput $backendStdOut `
            -RedirectStandardError $backendStdErr `
            -PassThru

        Write-Status "Waiting for cloud backend to initialize (first run on a new laptop can take longer)..." "INFO"
        $maxAttempts = 120

        while ($attempt -lt $maxAttempts -and -not $backendReady) {
            if ($backendProcess.HasExited) {
                break
            }

            $attempt++
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $backendReady = $true
                    Write-Status "Backend is ready (took $attempt seconds)" "SUCCESS"
                }
            } catch {
                Write-Host -NoNewline "."
                Start-Sleep -Seconds 1
            }
        }

        if (-not $backendReady) {
            Write-Status "Cloud backend not ready in time; switching to local dev mode (H2 database)..." "WARNING"
            if (-not $backendProcess.HasExited) {
                Stop-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue
            }
            $attempt = 0
        }
    }

    if (-not $backendReady) {
        Write-Status "Starting Backend Server on port 8080 using local H2 mode..." "INFO"
        $backendProcess = Start-Process -FilePath $mavenCmd `
            -ArgumentList @("-q", "-f", $projectPom, "-pl", "backend", "-am", "-Dspring-boot.run.profiles=dev", "spring-boot:run") `
            -WorkingDirectory $backendDir `
            -WindowStyle Hidden `
            -RedirectStandardOutput $backendStdOut `
            -RedirectStandardError $backendStdErr `
            -PassThru

        Write-Status "Waiting for local backend to initialize..." "INFO"
        while ($attempt -lt $maxAttempts -and -not $backendReady) {
            if ($backendProcess.HasExited) {
                break
            }

            $attempt++
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $backendReady = $true
                    Write-Status "Local backend is ready (took $attempt seconds)" "SUCCESS"
                }
            } catch {
                Write-Host -NoNewline "."
                Start-Sleep -Seconds 1
            }
        }
    }
    
    if (-not $backendReady) {
        Write-Status "Backend failed to start in both modes. Check the log files in: $logsDir" "ERROR"
        Show-RecentLog -Label "Backend standard output" -LogPath $backendStdOut
        Show-RecentLog -Label "Backend errors" -LogPath $backendStdErr
        return $false
    }
    
    Write-Status "Starting Frontend Application..." "INFO"
    $env:BACKEND_URL = 'http://localhost:8080'
    $frontendPom = Join-Path $frontendDir "pom.xml"
    $frontendProcess = Start-Process -FilePath $mavenCmd `
        -ArgumentList @("-q", "-f", $frontendPom, "-DskipTests", "org.openjfx:javafx-maven-plugin:0.0.8:run") `
        -WorkingDirectory $frontendDir `
        -WindowStyle Minimized `
        -RedirectStandardOutput $frontendStdOut `
        -RedirectStandardError $frontendStdErr `
        -PassThru
    
    Write-Status "Waiting for GUI to appear..." "INFO"
    $counter = 0
    $maxWait = 60
    
    while ($counter -lt $maxWait) {
        if (Test-Path $guiMarker) {
            Write-Status "GUI is ready! Application started successfully!" "SUCCESS"
            Remove-Item $guiMarker -Force -ErrorAction SilentlyContinue
            return $true
        }

        if ($frontendProcess.HasExited) {
            Write-Status "Frontend process closed before the GUI appeared. Check the log files in: $logsDir" "ERROR"
            Show-RecentLog -Label "Frontend standard output" -LogPath $frontendStdOut
            Show-RecentLog -Label "Frontend errors" -LogPath $frontendStdErr
            return $false
        }

        Start-Sleep -Seconds 1
        $counter++
    }
    
    Write-Status "GUI is still initializing. The app may already be opening; logs are in: $logsDir" "WARNING"
    return $true
}

# Main execution
Write-Host ""
Write-Status "========================================" "INFO"
Write-Status "ASCB Database System - Auto Setup" "INFO"
Write-Status "========================================" "INFO"
Write-Host ""

# Check and install Java
if (-not $SkipJavaSetup) {
    Write-Status "Checking Java installation..." "INFO"
    if (-not (Check-Java)) {
        Write-Status "Java not found. Installing Java 21..." "WARNING"
        if (-not (Install-Java)) {
            Write-Status "Java installation failed. Please install Java 21 manually." "ERROR"
            exit 1
        }
    }
}

# Check and install Maven only if the bundled Maven Wrapper is unavailable
$mavenWrapper = Join-Path $PSScriptRoot "ascb-db\backend\mvnw.cmd"
if (Test-Path $mavenWrapper) {
    Write-Status "Using bundled Maven Wrapper - no Maven installation required." "SUCCESS"
} elseif (-not $SkipMavenSetup) {
    Write-Status "Checking Maven installation..." "INFO"
    if (-not (Check-Maven)) {
        Write-Status "Maven not found. Installing Maven 3.9.6..." "WARNING"
        if (-not (Install-Maven)) {
            Write-Status "Maven installation failed. Please install Maven manually." "ERROR"
            exit 1
        }
    }
}

# Verify installations
Write-Host ""
Write-Status "Verifying installations..." "INFO"
try {
    $javaVer = & java -version 2>&1
    $javaMajor = Get-JavaMajorVersion $javaVer
    if (-not $javaMajor -or $javaMajor -lt $RequiredJavaVersion) {
        Write-Status "Java $RequiredJavaVersion or newer is required. Detected: $($javaVer[0])" "ERROR"
        exit 1
    }
    Write-Status "Java ${javaMajor}: $($javaVer[0])" "SUCCESS"
    if ($env:JAVA_HOME) {
        Write-Status "JAVA_HOME: $env:JAVA_HOME" "INFO"
    }
} catch {
    Write-Status "Java verification failed" "ERROR"
    exit 1
}

try {
    if (Test-Path $mavenWrapper) {
        $mvnVer = & $mavenWrapper -version 2>&1
        Write-Status "Maven Wrapper: $($mvnVer[0])" "SUCCESS"
    } else {
        $mvnVer = & mvn -version 2>&1
        Write-Status "Maven: $($mvnVer[0])" "SUCCESS"
    }
} catch {
    Write-Status "Maven verification failed" "ERROR"
    exit 1
}

# Start application
Write-Host ""
if (Start-Application) {
    Write-Status "========================================" "SUCCESS"
    Write-Status "System is running!" "SUCCESS"
    Write-Status "========================================" "SUCCESS"
    Write-Host ""
    Write-Status "Backend: http://localhost:8080" "INFO"
    Write-Status "Frontend: Check the minimized window" "INFO"
    Write-Status "To stop: Close the Frontend window" "INFO"
} else {
    Write-Status "Failed to start application" "ERROR"
    exit 1
}
