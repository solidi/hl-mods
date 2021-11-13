#Requires -Version 7.1
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
[bool]$clean = $false
[string]$mapName = ""

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Clean") {
        $clean = $true
        echo "rebuilding all wads and maps..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Map") {
        $mapName = $_.Split(' ')[1]
        echo "building map $mapName..."
    }
}

$host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Maps"

Import-Module $PSScriptRoot\powershell\Compile-Map.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Wad.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

$wadsDir = "${RootDir}\wads"

if ($clean -eq $true) {
    Remove-Item $redistDir\* -Recurse -Include *.wad -Force -ErrorAction Ignore
}

Compile-Wad $binDir "coldice" $wadsDir $redistDir
Compile-Wad $binDir "decals" $wadsDir $redistDir

$mapsDir = "${RootDir}\maps"

if ($clean -eq $true) {
    Remove-Item $redistDir\maps\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redistDir\maps -Force -ErrorAction Ignore
    [void](New-Item -ItemType directory -Path $redistDir\maps)
}

if ([string]::IsNullOrEmpty($mapName)) {
    Compile-Map $binDir "fences" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "training" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "stalkyard2" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "coldice" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "training2" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "focus" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "furrow" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "snowyard" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "canyon" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "bounce2" $mapsDir $redistDir $wadsDir
    Compile-Map $binDir "catacombs" $mapsDir $redistDir $wadsDir
} else {
    Compile-Map $binDir $mapName $mapsDir $redistDir $wadsDir
}

Copy-Item $mapsDir\stalkyard.wpt $redistDir\maps
Copy-Item $mapsDir\boot_camp.wpt $redistDir\maps

Set-Location -Path ${PSScriptRoot}
