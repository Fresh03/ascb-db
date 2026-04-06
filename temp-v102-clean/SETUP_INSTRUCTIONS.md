# ASCB Database System - Installation and Runtime Guide

## For Users with a Fresh Computer

If you receive the ASCB application as a ZIP archive on a computer with **nothing installed**, follow these steps:

### Option 1: Automatic Setup & Run (Recommended)

#### On Windows:

1. **Extract the archive** to any folder (e.g., `C:\ASCB` or `D:\ASCB`)

2. **Run ONE of these:**
   - **Double-click** `setup-and-run.bat` (works in Command Prompt)
   - **OR Right-click** `setup-and-run.ps1` → **Run with PowerShell**

3. **The script will automatically:**
   - ✅ Detect if Java 21 is installed
   - ✅ If NOT installed → Download and install Java 21 (200MB)
   - ✅ Detect if Maven is installed  
   - ✅ If NOT installed → Download and install Maven (10MB)
   - ✅ Start the backend server
   - ✅ Start the frontend GUI
   - ✅ Close all terminal windows when GUI appears

4. **Done!** The application runs. To stop, close the frontend window.

---

### Option 2: Manual Installation (if auto-setup fails)

#### Install Java 21:
1. Download from: https://adoptium.net/temurin/releases/
2. Select **JDK 21** for Windows x64
3. Run the installer, follow the steps
4. In Command Prompt, verify: `java -version`

#### Install Maven:
1. Download from: https://maven.apache.org/download.cgi
2. Extract to `C:\apache-maven`
3. Add to PATH (System Environment Variables → PATH → Add `C:\apache-maven\bin`)
4. In Command Prompt, verify: `mvn -version`

#### Run the application:
```cmd
cd path\to\ascb-db
.\start-ascb.bat
```

---

## For Developers

### Using the setup script with custom options:

```powershell
# Skip Java check (if you already have it)
.\setup-and-run.ps1 -SkipJavaSetup

# Skip Maven check (if you already have it)
.\setup-and-run.ps1 -SkipMavenSetup

# Skip both (if you have everything)
.\setup-and-run.ps1 -SkipJavaSetup -SkipMavenSetup
```

### Manual build and run (if you prefer):

```bash
# Navigate to backend directory
cd ascb-db/backend
mvn clean compile install spring-boot:run

# In another terminal, navigate to frontend directory
cd ascb-db/frontend
mvn clean compile install javafx:run
```

---

## Requirements

**Automatically handled by the setup script:**
- ✅ Java 21 JDK
- ✅ Maven 3.9.6

**Database:**
- Configured to use TiDB Cloud (credentials in `application.properties`)
- Internet connection required to connect to database

---

## Troubleshooting

### "PowerShell script cannot be run on this system"
**Solution:** 
1. Right-click `setup-and-run.ps1`
2. Click **Properties**
3. Check **"Unblock"** at the bottom
4. Click **OK**
5. Right-click and **Run with PowerShell**

### "Java installation failed"
**Solution:**
1. Download Java 21 manually from https://adoptium.net/
2. Run the installer with Administrator rights
3. Set environment variables manually:
   - Create `JAVA_HOME` = `C:\Program Files\Eclipse Adoptium\jdk-21.x.x`
   - Add to `PATH`: `%JAVA_HOME%\bin`

### "Maven installation failed"
**Solution:**
1. Download Maven from https://maven.apache.org/
2. Extract to `C:\apache-maven`
3. Add to PATH: `C:\apache-maven\bin`

### "Connection refused" to database
**Check:** Is your TiDB Cloud instance running? Update credentials in `ascb-db/backend/src/main/resources/application.properties`

### GUI doesn't appear in 60 seconds
**Check:** 
1. Open Task Manager → Verify both `java.exe` processes are running
2. Check network connection (database sync)
3. View console output in the minimized windows

---

## System Architecture

```
┌─────────────────────────────────────────┐
│   setup-and-run.bat / .ps1              │
│   (Auto-setup Java & Maven)             │
└────────────┬────────────────────────────┘
             │
    ┌────────┴──────────┐
    │                   │
    v                   v
┌─────────────┐   ┌─────────────┐
│   Backend   │   │  Frontend   │
│   (Java)    │   │  (JavaFX)   │
│  Port 8080  │   │   GUI       │
└──────┬──────┘   └──────┬──────┘
       │                 │
       └────────┬────────┘
                │
                v
        ┌──────────────┐
        │  TiDB Cloud  │
        │   Database   │
        └──────────────┘
```

---

## First Run Steps

1. **Launcher closes** → Everything is ready!
2. **Login screen appears** → Use admin credentials from database
3. **Main dashboard** → Manage volunteers and database
4. **Close window** → Cleanly shuts down backend and frontend

**Enjoy!** 🎉
