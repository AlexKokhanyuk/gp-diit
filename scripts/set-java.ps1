$preferredJdks = @(
    "C:\Java\jdk-17.0.0.1",
    "C:\Program Files\Java\jdk-25.0.2",
    "C:\Program Files\Java\latest"
)

foreach ($jdk in $preferredJdks) {
    $java = Join-Path $jdk "bin\java.exe"
    if (Test-Path -LiteralPath $java) {
        $env:JAVA_HOME = $jdk
        $env:Path = "$env:JAVA_HOME\bin;$env:Path"
        Write-Host "JAVA_HOME=$env:JAVA_HOME"
        return
    }
}

Write-Host "Modern JDK was not found in known locations; using current JAVA_HOME=$env:JAVA_HOME"
