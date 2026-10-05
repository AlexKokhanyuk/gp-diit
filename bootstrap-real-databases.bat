@echo off
cd /d "%~dp0"
call scripts\set-java.bat
if errorlevel 1 exit /b 1
set "MAVEN_OPTS=-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC"
echo This will create/update isolated lab schemas on real test servers.
choice /M "Continue"
if errorlevel 2 exit /b 1
call mvn -q -DskipTests compile
if errorlevel 1 exit /b 1
call mvn -q -DskipTests exec:java "-Dexec.mainClass=edu.diploma.deadlocklab.bootstrap.RealDatabaseBootstrap" "-Dexec.args=all"
if errorlevel 1 exit /b 1
call mvn -Prun-postgresql-real spring-boot:run "-Dspring-boot.run.arguments=--spring.main.web-application-type=none"
if errorlevel 1 exit /b 1
call mvn -Prun-mssql-real spring-boot:run "-Dspring-boot.run.arguments=--spring.main.web-application-type=none"
if errorlevel 1 exit /b 1
call mvn -Prun-oracle-real spring-boot:run "-Dspring-boot.run.arguments=--spring.main.web-application-type=none"

