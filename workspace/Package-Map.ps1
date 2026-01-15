#Requires -Version 7.2
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    # Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$Config = @{ }
[string]$mapName = ""

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Map") {
        $mapName = $_.Split(' ')[1]
        echo "packaging map $mapName..."
    }
}

if ([string]::IsNullOrWhiteSpace($mapName)) {
    Write-Error "Map name is required. Use -Map parameter."
    exit 1
}

$host.UI.RawUI.WindowTitle = "Packaging $($Config['projectName']) Map: $mapName"

Import-Module $PSScriptRoot\powershell\Git-Utils.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Package-Map.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$detailedTexturesDir = "${rootDir}\detailed-textures"

try {
    Package-Map -mapName $mapName -rootDir $rootDir -redistDir $redistDir -detailedTexturesDir $detailedTexturesDir
} catch {
    Write-Error "Failed to package map: $($_.Exception.Message)"
    exit 1
}
