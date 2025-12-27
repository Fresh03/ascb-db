ASC BDB — Java 21 upgrade notes
===============================

This repository contains two Maven modules:
- `backend` — Spring Boot backend (Spring Boot 3.5.3)
- `frontend` — JavaFX frontend (OpenJFX via javafx-maven-plugin)

Summary: Java runtime upgrade
----------------------------
- The project has been updated to target Java 21 (LTS).
- Changes made:
  - `backend/pom.xml` — `<java.version>` set to `21`, `maven-compiler-plugin` configured to use `<release>${java.version}</release>` and a `lombok.version` property added and applied so annotation processing resolves.
  - `frontend/pom.xml` — `<java.version>` set to `21` and compiler plugin configured to use `<release>${java.version}</release>`.
  - `frontend` FXML files updated to use the JavaFX 21 namespace (to match runtime).

Why this README
----------------
When switching a project to a new Java major release you must ensure the build/runtime use a matching JDK. Typical symptom when the shell/IDE still uses an older JDK is:

  "Fatal error compiling: error: release version 21 not supported"

This README documents how to run the project correctly under Java 21 and how to reproduce or troubleshoot issues.

Quick run instructions (PowerShell)
----------------------------------
Below are exact PowerShell commands you can copy/paste to run the project locally on Windows. There are two helper options:

- Recommended: run the included helper script (it finds a JDK 21 on your machine and sets `JAVA_HOME` in the current shell).
- Manual: set `JAVA_HOME` yourself in the shell if you prefer.

Important notes before running:
- The `frontend` module does not include a Maven wrapper (`mvnw.cmd`) so use your system `mvn` (ensure it's on PATH).
- The helper script is `scripts\setup-jdk21-and-build.ps1` and must be run from the repository root.

Option A — recommended (use the helper script)

Open two PowerShell windows (Terminal A = backend, Terminal B = frontend).

# Terminal A — backend (MySQL / production mode)
```powershell
Set-Location 'D:\Facultate\ASCB\ASCBDB'
.\scripts\setup-jdk21-and-build.ps1
Set-Location 'D:\Facultate\ASCB\ASCBDB\backend'
# Run using the MySQL configuration defined in backend/src/main/resources/application.properties
mvn spring-boot:run
```

If you want the backend to run using the in-memory H2 dev profile instead (no MySQL needed):
```powershell
Set-Location 'D:\Facultate\ASCB\ASCBDB\backend'
mvn -Dspring-boot.run.profiles=dev spring-boot:run
```

# Terminal B — frontend (GUI)
```powershell
Set-Location 'D:\Facultate\ASCB\ASCBDB'
.\scripts\setup-jdk21-and-build.ps1
Set-Location 'D:\Facultate\ASCB\ASCBDB\frontend'
# frontend uses system 'mvn' (no mvnw in frontend module)
mvn -DskipTests javafx:run
```

Option B — manual JAVA_HOME (if you don't want to use the helper script)

Set `JAVA_HOME` and PATH in each PowerShell window before running Maven (replace path if your JDK differs):
```powershell
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot'
$env:PATH = "$env:JAVA_HOME\bin;${env:PATH}"

# verify
java -version
mvn -v

# then run backend and frontend as shown in Option A (use the 'backend' and 'frontend' folders)
```

If you need to run the frontend against a custom backend URL (different host/port):
```powershell
Set-Location 'D:\Facultate\ASCB\ASCBDB\frontend'
mvn -DskipTests javafx:run -Dbackend.url=http://127.0.0.1:8080
```

If you see "Fatal error compiling: error: release version 21 not supported" when running `mvn`, make sure the same shell has `java -version` and `mvn -v` showing Java 21. Re-run the helper script or set `JAVA_HOME` as shown above.

Notes:
- The `dev` profile uses an embedded H2 database and enables the H2 console at `/h2-console`.
- A default admin user is created at startup by `DataLoader` when the `dev` profile runs:
  - email: `admin@ascb.ro`
  - password: `parola123`

5) Build and run frontend (session must use JDK21, see the helper above):

```powershell
Set-Location 'D:\Facultate\ASCB\ASCBDB\frontend'
mvn -DskipTests javafx:run
```

Exact commands I used (PowerShell)
---------------------------------
Below are the exact commands I ran in two separate PowerShell windows during testing. You can copy-paste these directly.

Option A — use the helper script (recommended):

```powershell
# in Terminal A (backend)
.\scripts\setup-jdk21-and-build.ps1
Set-Location 'D:\Facultate\ASCB\ASCBDB\backend'
mvn "-Dspring-boot.run.profiles=dev" spring-boot:run

# in Terminal B (frontend)
.\scripts\setup-jdk21-and-build.ps1
Set-Location 'D:\Facultate\ASCB\ASCBDB\frontend'
mvn -DskipTests javafx:run
```

Option B — set JAVA_HOME explicitly in each shell (if you prefer):

```powershell
# in Terminal A (backend)
$env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot'
$env:PATH = "$env:JAVA_HOME\bin;${env:PATH}"
Set-Location 'D:\Facultate\ASCB\ASCBDB\backend'
mvn "-Dspring-boot.run.profiles=dev" spring-boot:run

# in Terminal B (frontend)
$env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot'
$env:PATH = "$env:JAVA_HOME\bin;${env:PATH}"
Set-Location 'D:\Facultate\ASCB\ASCBDB\frontend'
mvn -DskipTests javafx:run
```

Run frontend against a custom backend address (example):

```powershell
# from frontend folder
mvn -DskipTests javafx:run -Dbackend.url=http://127.0.0.1:8080
```

Quick smoke test (HTTP):

```powershell
# Post login using curl (PowerShell):
curl -X POST -d "email=admin@ascb.ro&password=parola123" http://localhost:8080/auth/login
# expected response: "Login reușit!"
```

Run notes and troubleshooting
----------------------------
- If you see "release version 21 not supported" when running `mvn`, that means the `javac` that Maven is using is older than Java 21. Re-check `java -version` and `mvn -v` in the same shell and set `JAVA_HOME` for that shell.
- For a permanent change, set `JAVA_HOME` as a system environment variable (Windows: run `setx JAVA_HOME "C:\Path\To\JDK21" /M` in an elevated PowerShell and restart shells/IDE).
- If your IDE starts Maven with a different JDK, change the IDE's configured JDK / run configuration to point to JDK 21.

Frontend-specific notes
-----------------------
- The FXML files were standardized to the JavaFX 21 namespace. If you want to use JavaFX 24, you'd need to upgrade the `javafx.version` in `frontend/pom.xml` and ensure the JDK & platform versions are compatible (note: JavaFX 24 uses bytecode compiled for a later spec and may require a matching JDK runtime).
- The `javafx-maven-plugin` may show a warning about unknown `modules` parameter — this is harmless for running, but you can consider upgrading the plugin if you change plugin configuration.
- At runtime the frontend attempts to contact the backend (login). Ensure the backend is started and reachable (default: http://localhost:8080 unless otherwise configured).

Backend-specific notes
----------------------
- `backend/pom.xml` now includes a `lombok.version` property and uses that for the Lombok dependency and annotationProcessorPaths so annotation processing resolves during compilation.
- You may see warnings about MySQL Connector relocation (artifact coordinates moved from `mysql:mysql-connector-java` to `com.mysql:mysql-connector-j`). Consider updating POM dependencies to use `com.mysql:mysql-connector-j` and a newer 8.1.x/8.0.x patch release.

Testing & verification
----------------------
- Run all tests (ensures runtime + integration tests pass):

```powershell
cd /d D:\Facultate\ASCB\ASCBDB
mvn test
```

Committing changes
------------------
If you want to commit the POM and FXML changes I made locally, a suggested flow (create a branch, commit, push):

```powershell
cd /d D:\Facultate\ASCB\ASCBDB
git checkout -b upgrade/java-21
git add backend/pom.xml frontend/pom.xml frontend/src/main/resources/fxml/*.fxml
git commit -m "Upgrade runtime to Java 21; fix FXML & Lombok resolution"
# then push (if remote exists):
# git push -u origin upgrade/java-21
```

Follow-ups I can do for you
--------------------------
- Create and push the branch with the changes.
- Update `mysql` dependency coordinates to `com.mysql:mysql-connector-j` and bump a safe version.
- Add a short `CONTRIBUTING.md` or `RUNNING.md` with the same steps separated.

If you'd like me to commit the README and POM/FXML changes to a branch, tell me the branch name and I'll create the branch and commit the files for you.
