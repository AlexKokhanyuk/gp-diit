@echo off
cd /d "%~dp0"
docker compose up -d postgres
if errorlevel 1 goto error
call scripts\set-java.bat
if errorlevel 1 goto error
set "MAVEN_OPTS=-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC -Duser.timezone=UTC"
set "JAVA_TOOL_OPTIONS=-Duser.timezone=UTC"
call mvn -q -DskipTests compile
if errorlevel 1 goto error
call mvn -q -DskipTests exec:java "-Dexec.mainClass=edu.diploma.deadlocklab.bootstrap.DockerDatabaseBootstrap" "-Ddocker.target=postgresql"
if errorlevel 1 goto error
call mvn -Prun-postgresql spring-boot:run
if errorlevel 1 goto error
exit /b 0

:error
echo.
echo run-postgresql-docker.bat failed with exit code %errorlevel%
pause
exit /b %errorlevel%

