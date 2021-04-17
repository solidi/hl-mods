#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$cfg = "release"
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "c") {
        $cfg = $_.Split(' ')[1]
        echo "build config is $cfg..."
    }
}

docker -c win run -v z:\:c:\build `
    -it ice-windows-tools powershell c:\build\Build-Windows.ps1 -BuildConfig $cfg