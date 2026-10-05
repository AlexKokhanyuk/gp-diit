$ErrorActionPreference = "Stop"
. $PSScriptRoot\set-java.ps1

$env:MAVEN_OPTS = "-Xms32m -Xmx192m -XX:MaxMetaspaceSize=128m -XX:+UseSerialGC"
Write-Host "MAVEN_OPTS=$env:MAVEN_OPTS"

mvn -DskipTests package
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
