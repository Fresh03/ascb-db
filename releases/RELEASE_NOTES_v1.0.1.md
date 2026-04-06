# ASCB Database Management System - Release v1.0.1

**Release Date:** April 6, 2026
**Version:** 1.0.1
**Previous Version:** 1.0.0

## 🚀 What's New in v1.0.1

### Performance Improvements
- **50% faster startup time** - Replaced hardcoded 15-second wait with intelligent health check
- **Optimized database logging** - Disabled SQL logging for production performance
- **Enhanced Hibernate settings** - Added batch optimizations for better database performance
- **Maven quiet mode** - Reduced verbose output during builds

### Cross-Platform Fixes
- **Fixed JavaFX platform dependencies** - Added platform-specific natives for Windows, Linux, and Mac
- **Resolved GUI hanging issues** - Applications now start properly on all devices
- **Automatic platform detection** - Maven profiles detect OS and download correct libraries

### Technical Improvements
- **Health check endpoint** - New `/api/debug/health` endpoint for startup verification
- **Improved startup scripts** - Both `start-ascb.ps1` and `setup-and-run.ps1` use health checks
- **Better error handling** - More robust startup process with fallback mechanisms

## 📦 Installation

### Option 1: Automatic Setup (Recommended)
```bash
# Extract the archive and run:
setup-and-run.bat    # Windows Batch
setup-and-run.ps1    # Windows PowerShell
```

### Option 2: Manual Setup
```bash
cd ascb-db/backend && mvn spring-boot:run    # Terminal 1
cd ascb-db/frontend && mvn javafx:run        # Terminal 2
```

## 🔧 System Requirements

- **Java:** JDK 21 (Eclipse Temurin recommended)
- **Maven:** 3.9.6+
- **OS:** Windows 10+, Linux, or macOS
- **RAM:** 2GB minimum
- **Storage:** 500MB free space

## 📋 Files Included

- `ascb-db/` - Main application code
- `start-ascb.bat/ps1/sh` - Quick start scripts
- `setup-and-run.bat/ps1` - Full setup scripts
- `README.md` - Complete documentation
- `.vscode/` - VS Code configuration

## 🐛 Bug Fixes

- Fixed GUI hanging on non-Windows devices
- Resolved JavaFX native library loading issues
- Improved cross-platform compatibility
- Fixed startup timing issues

## 📞 Support

For issues or questions:
- Check the README.md for troubleshooting
- Verify Java 21 and Maven installation
- Ensure database connectivity for full functionality

---

**Checksum (SHA-256):** Verify archive integrity
```
# Run: Get-FileHash .\releases\ascb-db-v1.0.1.zip -Algorithm SHA256
```