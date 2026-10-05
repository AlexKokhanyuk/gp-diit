@echo off
set "JAVA_CANDIDATE=C:\Java\jdk-17.0.0.1"
if exist "%JAVA_CANDIDATE%\bin\java.exe" goto useJava
set "JAVA_CANDIDATE=C:\Program Files\Java\jdk-25.0.2"
if exist "%JAVA_CANDIDATE%\bin\java.exe" goto useJava
set "JAVA_CANDIDATE=C:\Program Files\Java\latest"
if exist "%JAVA_CANDIDATE%\bin\java.exe" goto useJava
echo Java was not found in known locations.
echo Install Java 17+ or update scripts\set-java.bat.
exit /b 1
:useJava
set "JAVA_HOME=%JAVA_CANDIDATE%"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo JAVA_HOME=%JAVA_HOME%
exit /b 0
