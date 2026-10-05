@echo off
cd /d "%~dp0"
docker compose up -d mssql
if errorlevel 1 exit /b 1
call scripts\set-java.bat
if errorlevel 1 exit /b 1
set "MAVEN_OPTS=-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC"
call mvn -q -DskipTests compile
if errorlevel 1 exit /b 1
call mvn -q -DskipTests exec:java "-Dexec.mainClass=edu.diploma.deadlocklab.bootstrap.DockerDatabaseBootstrap"
if errorlevel 1 exit /b 1
call mvn -Prun-mssql spring-boot:run

