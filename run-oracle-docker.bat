@echo off
cd /d "%~dp0"
docker compose up -d oracle
if errorlevel 1 goto error
call scripts\set-java.bat
if errorlevel 1 goto error
set "MAVEN_OPTS=-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC"
call mvn -q -DskipTests compile
if errorlevel 1 goto error
call mvn -q -DskipTests exec:java "-Dexec.mainClass=edu.diploma.deadlocklab.bootstrap.DockerDatabaseBootstrap" "-Ddocker.target=oracle"
if errorlevel 1 goto error
call mvn -Prun-oracle spring-boot:run
if errorlevel 1 goto error
exit /b 0

:error
echo.
echo run-oracle-docker.bat failed with exit code %errorlevel%
pause
exit /b %errorlevel%

