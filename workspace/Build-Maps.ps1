#Requires -Version 7.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Build Cold Ice GoldSrc Maps"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$Config = @{ }

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    }
}

Import-Module $PSScriptRoot\powershell\Compile-Map.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Wad.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

$wadsDir = "${RootDir}\wads"

Remove-Item $redistDir\wads\\* -Recurse -Force -ErrorAction Ignore

Compile-Wad $binDir "coldice" $wadsDir $redistDir

$mapsDir = "${RootDir}\maps"

Remove-Item $redistDir\maps\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\maps -Force -ErrorAction Ignore
[void](New-Item -ItemType directory -Path $redistDir\maps)

Compile-Map $binDir "yard" $mapsDir $redistDir $wadsDir
Copy-Item $mapsDir\stalkyard.wpt $redistDir\maps
Copy-Item $mapsDir\boot_camp.wpt $redistDir\maps

Set-Location -Path ${PSScriptRoot}
