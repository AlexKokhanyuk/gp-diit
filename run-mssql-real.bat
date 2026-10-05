@echo off
cd /d "%~dp0"
call scripts\set-java.bat
if errorlevel 1 exit /b 1
set "MAVEN_OPTS=-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC"
call mvn -Prun-mssql-real spring-boot:run

