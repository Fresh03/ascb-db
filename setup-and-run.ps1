# ASCB Database System - Setup and Run Script
# This script automatically installs Java 21 and Maven if not present, then starts the application
# 
# Usage:
#   .\setup-and-run.ps1                           (Full setup and run)
#   .\setup-and-run.ps1 -SkipJavaSetup            (Skip Java check, use existing)
#   .\setup-and-run.ps1 -SkipMavenSetup           (Skip Maven check, use existing)
#   .\setup-and-run.ps1 -SkipJavaSetup -SkipMavenSetup  (Use existing tools, just run app)

param(
    [switch]$SkipJavaSetup = $false,
    [switch]$SkipMavenSetup = $false
)

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

function Check-Java {
    try {
        $javaVersion = & java -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Java found: $($javaVersion[0])" "SUCCESS"
            return $true
        }
    } catch {
        Write-Status "Java not found in PATH" "WARNING"
    }
    
    # Check common installation locations
    $javaLocations = @(
        "C:\Program Files\Eclipse Adoptium",
        "C:\Program Files\Java",
        "$env:USERPROFILE\AppData\Local\Programs\Eclipse Adoptium"
    )
    
    foreach ($location in $javaLocations) {
        if (Test-Path "$location") {
            $javaExe = Get-ChildItem -Path "$location" -Filter "java.exe" -Recurse | Select-Object -First 1
            if ($javaExe) {
                Write-Status "Found Java at: $($javaExe.Directory)" "SUCCESS"
                $env:PATH = "$($javaExe.Directory);$env:PATH"
                return $true
            }
        }
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
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$javaInstaller`" /quiet /qn" -Wait
        Write-Status "Java 21 installed successfully" "SUCCESS"
        
        # Add Java to PATH
        $javaHome = "C:\Program Files\Eclipse Adoptium\jdk-21.0.1+12"
        if (Test-Path $javaHome) {
            $env:JAVA_HOME = $javaHome
            $env:PATH = "$javaHome\bin;$env:PATH"
        }
        
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

function Start-Application {
    Write-Status "Starting ASCB Database System..." "INFO"
    
    $scriptDir = Split-Path -Parent $PSCommandPath
    $backendDir = Join-Path $scriptDir "ascb-db\backend"
    $frontendDir = Join-Path $scriptDir "ascb-db\frontend"
    
    if (-not (Test-Path $backendDir)) {
        Write-Status "Backend directory not found at: $backendDir" "ERROR"
        return $false
    }
    
    if (-not (Test-Path $frontendDir)) {
        Write-Status "Frontend directory not found at: $frontendDir" "ERROR"
        return $false
    }
    
    Write-Status "Starting Backend Server on port 8080..." "INFO"
    $backendProcess = Start-Process -FilePath cmd.exe -ArgumentList "/c", "cd /d `"$backendDir`" && mvn spring-boot:run -q" -WindowStyle Hidden -PassThru
    
    Write-Status "Waiting for backend to initialize..." "INFO"
    
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
                Write-Status "Backend is ready (took $attempt seconds)" "SUCCESS"
            }
        } catch {
            Write-Host -NoNewline "."
            Start-Sleep -Seconds 1
        }
    }
    
    if (-not $backendReady) {
        Write-Status "Production backend failed, trying dev mode (H2 database)..." "WARNING"
        
        # Kill the failed backend process
        Stop-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue
        
        # Start backend in dev mode
        $backendProcess = Start-Process -FilePath cmd.exe -ArgumentList "/c", "cd /d `"$backendDir`" && mvn -DskipTests -Dspring-boot.run.profiles=dev spring-boot:run -q" -WindowStyle Hidden -PassThru
        
        # Wait for dev backend to start
        $attempt = 0
        while ($attempt -lt 20 -and -not $backendReady) {
            $attempt++
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8080/api/debug/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
                if ($response.StatusCode -eq 200) {
                    $backendReady = $true
                    Write-Status "Dev backend is ready (took $attempt seconds)" "SUCCESS"
                }
            } catch {
                Write-Host -NoNewline "."
                Start-Sleep -Seconds 1
            }
        }
    }
    
    if (-not $backendReady) {
        Write-Status "Backend failed to start in both modes. Check network and logs." "ERROR"
        return $false
    }
    
    Write-Status "Starting Frontend Application..." "INFO"
    Start-Process -FilePath cmd.exe -ArgumentList "/c", "cd /d `"$frontendDir`" && mvn -DskipTests javafx:run" -WindowStyle Minimized
    
    Write-Status "Waiting for GUI to appear..." "INFO"
    $counter = 0
    $maxWait = 60
    
    while ($counter -lt $maxWait) {
        if (Test-Path "$env:TEMP\ascb_gui_ready.txt") {
            Write-Status "GUI is ready! Application started successfully!" "SUCCESS"
            Remove-Item "$env:TEMP\ascb_gui_ready.txt" -Force -ErrorAction SilentlyContinue
            return $true
        }
        Start-Sleep -Seconds 1
        $counter++
    }
    
    Write-Status "Application started (GUI ready timeout)" "WARNING"
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

# Check and install Maven
if (-not $SkipMavenSetup) {
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
    Write-Status "Java: $($javaVer[0])" "SUCCESS"
} catch {
    Write-Status "Java verification failed" "ERROR"
    exit 1
}

try {
    $mvnVer = & mvn -version 2>&1
    Write-Status "Maven: $($mvnVer[0])" "SUCCESS"
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
