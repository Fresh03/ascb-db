# ASCB Database Management System

A complete Java 17+ application for managing ASCB volunteers through a web-connected database.

## Quick Start (3 Options)

### 1️⃣ **Automatic Setup (Recommended for Fresh Windows)**

If you're on a computer with **nothing installed**:

```bash
# Run ONE of these:
setup-and-run.bat          # Batch version (easiest)

# OR right-click and "Run with PowerShell":
setup-and-run.ps1          # PowerShell version (auto-downloads Java & Maven)
```

**What happens:**
- ✅ Detects Java 17+ (downloads if missing)
- ✅ Detects Maven (downloads if missing)
- ✅ Builds and starts backend on port 8080
- ✅ **Auto-fallback to dev mode** if production database unavailable
- ✅ Starts frontend GUI in separate window
- ✅ Closes launcher when GUI appears

### 2️⃣ **Quick Guide (Already have Java & Maven)**

```bash
quick-setup.bat            # Just checks for Java/Maven and runs app
```

### 3️⃣ **Manual (If prefer direct control)**

```bash
# Terminal 1 - Backend
cd ascb-db/backend
mvn clean compile install spring-boot:run

# Terminal 2 - Frontend
cd ascb-db/frontend  
mvn clean compile install javafx:run
```

---

## System Architecture

```
┌──────────────────────────────────────────┐
│  Frontend (JavaFX)                       │
│  - Login screen                          │
│  - Volunteer management UI               │
│  - Real-time data display                │
└──────────────────┬───────────────────────┘
                   │ HTTP Client
                   ↓
┌──────────────────────────────────────────┐
│  Backend (Spring Boot 3.5.3)             │
│  - REST API on :8080                     │
│  - Authentication (JWT)                  │
│  - Database operations                   │
└──────────────────┬───────────────────────┘
                   │ JDBC
                   ↓
┌──────────────────────────────────────────┐
│  TiDB Cloud Database (MySQL-compatible)  │
│  - Volunteers table                      │
│  - Admin credentials                     │
│  - Secure connection (SSL)               │
└──────────────────────────────────────────┘
```

---

## Features

### ✅ Volunteer Management
- Add/Edit/Delete volunteers
- Track volunteer status and information
- Search and filter capabilities
- Data validation and error handling

### ✅ Authentication
- Admin login system
- JWT token-based security
- Secure password storage
- Session management

### ✅ Database
- Cloud-hosted TiDB database
- Automatic schema management
- Connection pooling
- Transaction support

### ✅ GUI
- Modern JavaFX interface
- Responsive layout
- Real-time updates
- Graceful shutdown

---

## Requirements

**Automatically installed by setup script:**
- ✅ Java 17 JDK (Eclipse Temurin)
- ✅ Maven 3.9.6

**Manually required:**
- ✅ Windows 10+ (64-bit) or Linux/Mac (using bash)
- ✅ Internet connection (database & first-time setup)
- ✅ 500 MB disk space (for Java + Maven)
- ✅ 2 GB RAM (minimum)

---

## Configuration

### Database Connection
Edit `ascb-db/backend/src/main/resources/application.properties`:

```properties
spring.datasource.url=jdbc:mysql://YOUR_HOST:4000/ascb_db?useSSL=true&serverTimezone=UTC
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD
```

### Backend Port
Default: `8080`
Change in `application.properties`:
```properties
server.port=8080
```

---

## Stopping the Application

**Option 1:** Close the frontend GUI window (cleanest)
- Frontend sends shutdown signal to backend
- Both applications terminate gracefully

**Option 2:** Close backend terminal(s)
- Manually terminate backend (if needed)

**Option 3:** Kill Java processes (emergency)
```bash
taskkill /F /IM java.exe     # Windows
pkill java                    # Linux/Mac
```

---

## Troubleshooting

### "Java not found"
```bash
# Download from: https://adoptium.net/temurin/releases/
# Install Java 17 for your OS
# Restart setup script
```

### "Maven not found"
```bash
# Download from: https://maven.apache.org/download.cgi
# Extract to C:\apache-maven (Windows)
# Add to PATH and restart
```

### "Connection refused" on localhost:8080
```bash
# Check if backend is running:
netstat -an | findstr :8080    # Windows
lsof -i :8080                  # Linux/Mac

# If not running, check logs in:
ascb-db/backend/target/
```

### "Backend takes too long to start"
The application automatically tries two modes:
1. **Production mode** (TiDB Cloud) - requires internet
2. **Dev mode** (H2 local database) - works offline

If you see "waiting for backend" for more than 30 seconds, it will automatically switch to dev mode. No manual intervention needed!

### "Database connection failed"
1. Check internet connection
2. Verify TiDB credentials in application.properties
3. Ensure TiDB Cloud instance is running
4. Check firewall rules
5. **Note:** App will automatically use local H2 database if cloud DB fails

### "GUI doesn't appear"
1. Check if Java process is running: `tasklist | findstr java`
2. Check temp folder logs
3. Try running with `-Dlog4j.configuration=file:log4j.properties`

---

## Project Structure

```
ascb-db/
├── backend/
│   ├── src/main/java/ro/ascb/ascb_db_backend/
│   │   ├── AscbDbBackendApplication.java
│   │   ├── config/
│   │   │   ├── JwtFilter.java
│   │   │   └── SecurityConfig.java
│   │   ├── controller/
│   │   │   ├── ApiController.java
│   │   │   ├── AuthController.java
│   │   │   └── DebugController.java
│   │   ├── model/
│   │   ├── repository/
│   │   └── service/
│   ├── src/main/resources/
│   │   └── application.properties
│   └── pom.xml
│
├── frontend/
│   ├── src/main/java/ro/ascb/frontend/
│   │   ├── MainApp.java
│   │   ├── controller/
│   │   │   ├── LoginController.java
│   │   │   └── MainController.java
│   │   └── model/
│   ├── src/main/resources/
│   │   ├── fxml/
│   │   │   ├── Login.fxml
│   │   │   └── Main.fxml
│   │   ├── images/
│   │   └── styles/
│   │       └── main.css
│   └── pom.xml
│
├── start-ascb.bat           (Simple launcher)
├── setup-and-run.bat        (Auto-setup launcher)
├── setup-and-run.ps1        (PowerShell auto-setup)
├── quick-setup.bat          (Lightweight check + run)
└── pom.xml
```

---

## Build and Deploy

### Development Build
```bash
cd ascb-db
mvn clean install
```

### Production Build
```bash
mvn clean package -P production
```

### Create Distribution
```bash
# Package everything for sharing:
REM Include in ZIP:
REM - ascb-db/ folder
REM - setup-and-run.bat
REM - setup-and-run.ps1
REM - quick-setup.bat
REM - SETUP_INSTRUCTIONS.md
```

---

## Development Setup

### IDE Setup (IntelliJ IDEA or VS Code)

1. **Open project** → Select ascb-db folder
2. **Configure JDK** → Set to Java 17 or newer
3. **Run configurations:**
   - Backend: `Main class: ro.ascb.ascb_db_backend.AscbDbBackendApplication`
   - Frontend: `Main class: ro.ascb.frontend.MainApp`

### CLI Build & Run

```bash
# Backend
cd ascb-db/backend
mvn clean compile
mvn spring-boot:run

# Frontend (separate terminal)
cd ascb-db/frontend
mvn clean compile
mvn javafx:run
```

---

## Keyboard Shortcuts

- `Alt+F4` or `Ctrl+Q` - Quit application (graceful shutdown)
- `Tab` - Focus next field
- `Enter` - Submit form

---

## Security Notes

⚠️ **For Production Use:**
1. Change default admin credentials in database
2. Use HTTPS instead of HTTP
3. Enable firewall rules
4. Implement API rate limiting
5. Add request validation
6. Use environment variables for sensitive config
7. Enable database backups
8. Implement audit logging

---

## Support & Issues

If you encounter issues:

1. **Check logs** in `ascb-db/backend/target/` for error details
2. **Verify requirements** in Terminal:
   ```bash
   java -version         # Should show Java 17 or newer
   mvn -version          # Should show Maven 3.9.x
   ```

3. **Test connectivity:**
   ```bash
   # Windows:
   netstat -an | findstr :8080
   # Linux/Mac:
   lsof -i :8080
   ```

4. **Clear cache and rebuild:**
   ```bash
   mvn clean
   rm -rf ~/.m2/repository/
   mvn clean install
   ```

---

## License & Credits

ASCB Database Management System  
Built with Java 17, Spring Boot, and JavaFX

---

**Ready to use! Follow the Quick Start section above to get started.** 🚀
