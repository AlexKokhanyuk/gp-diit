param(
    [int]$Port = 8080,
    [string]$Profile = "h2"
)

$ErrorActionPreference = "Stop"
. $PSScriptRoot\set-java.ps1

$env:MAVEN_OPTS = "-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC"
Write-Host "MAVEN_OPTS=$env:MAVEN_OPTS"

mvn spring-boot:run "-Dspring-boot.run.profiles=$Profile" "-Dspring-boot.run.arguments=--server.port=$Port"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
