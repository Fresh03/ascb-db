# ASCB Database System - Distribution Checklist

When distributing ASCB to others, include these files in the ZIP archive:

## Required Files:
- ✅ ascb-db/backend/          (Backend Spring Boot application)
- ✅ ascb-db/frontend/         (Frontend JavaFX application)
- ✅ setup-and-run.bat         (Universal launcher - works on any system)
- ✅ setup-and-run.ps1         (PowerShell setup script)
- ✅ start-ascb.bat            (Alternative launcher - for users with Java & Maven)
- ✅ SETUP_INSTRUCTIONS.md     (User guide)
- ✅ DISTRIBUTION_CHECKLIST.md (This file)

## What Gets Installed Automatically:

When a user runs setup-and-run.bat on a fresh Windows system, the script will:

1. **Check for Java 21**
   - If found → Use existing installation
   - If not found → Download (≈200 MB) and install Eclipse Temurin 21

2. **Check for Maven 3.9.6**
   - If found → Use existing installation
   - If not found → Download (≈10 MB) and extract to C:\apache-maven

3. **Start the application**
   - Backend on port 8080
   - Frontend in separate window
   - Launcher closes when GUI appears

## Network Requirements:

Users must have **internet connection** for:
- First time setup (downloading Java & Maven)
- Database connectivity (TiDB Cloud)

## System Requirements:

- Windows 10 or later (64-bit)
- At least 500 MB free disk space for Java & Maven
- 2 GB RAM (minimum), 4 GB recommended
- Administrator rights (for first-time Java/Maven installation)

## File Sizes:

```
Original ZIP (with source code):     ~50 MB
After first run:
  + Java 21 installation:           ~350 MB
  + Maven installation:              ~40 MB
  + Project build artifacts:         ~500 MB
  ─────────────────────────────────────────
  Total disk usage:                  ~1.4 GB
```

## Testing Before Distribution:

1. **Test on a clean VM or fresh Windows installation**
   ```
   - Open setup-and-run.bat
   - Verify Java downloads and installs
   - Verify Maven downloads and extracts
   - Verify application starts
   - Close application and verify cleanup
   ```

2. **Test connectivity**
   ```
   - Verify TiDB Cloud connection works
   - Test login functionality
   - Test database queries
   ```

3. **Test application shutdown**
   ```
   - Close frontend window
   - Verify backend shuts down cleanly
   ```

## Deployment Instructions for Users:

### For End Users:
1. Extract archive to desired location
2. Double-click `setup-and-run.bat`
3. Wait for Java & Maven to download/install (if needed)
4. Application starts automatically
5. Close frontend window to stop everything

### For Developers:
1. Extract archive
2. Configure TiDB credentials in `ascb-db/backend/src/main/resources/application.properties`
3. Run: `.\setup-and-run.ps1`
4. Application starts with full setup

## If Automatic Setup Fails:

Users can manually follow SETUP_INSTRUCTIONS.md:
1. Install Java 21 from adoptium.net
2. Install Maven from maven.apache.org
3. Run start-ascb.bat

## Folder Structure for Distribution:

```
ASCB-App-v1.0.zip
├── ascb-db/
│   ├── backend/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── ...
│   ├── frontend/
│   │   ├── src/
│   │   ├── pom.xml
│   │   └── ...
│   └── README.md
├── setup-and-run.bat          ← START HERE
├── setup-and-run.ps1
├── start-ascb.bat             (alternative)
├── SETUP_INSTRUCTIONS.md
└── DISTRIBUTION_CHECKLIST.md
```

## Post-Installation Cleanup (Optional):

Users can free up disk space by running:

```batch
REM Remove Maven cache (safe to delete)
rmdir /s /q %USERPROFILE%\.m2\repository

REM Remove build artifacts (will be rebuilt on next run)
cd ascb-db\backend
mvn clean

cd ..\frontend
mvn clean
```

---

**Distribution Ready! ✅**

The ASCB application is now ready to be shared with anyone who has a Windows PC.
No prior installation of Java or Maven is required!
