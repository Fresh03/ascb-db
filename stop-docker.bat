@echo off
REM Root launcher for Docker-based ASCB shutdown
call "%~dp0ascb-db\stop-docker.bat"
