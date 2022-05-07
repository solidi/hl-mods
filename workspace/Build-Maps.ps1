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
[bool]$clean = $false
[string]$mapName = ""
[bool]$finalCompile = $true

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Clean") {
        $clean = $true
        echo "rebuilding all maps..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Map") {
        $mapName = $_.Split(' ')[1]
        echo "building map $mapName..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Fast") {
        $finalCompile = $false
        echo "building map as draft..."
    }
}

$host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Maps"

Import-Module $PSScriptRoot\powershell\Compile-Map.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

$wadsDir = "${RootDir}\wads"
$mapsDir = "${RootDir}\maps"

$currentBranchName = $(Git-Current-Branch-Name)
$headBranchName = $(Git-Head-Branch-Name)

echo "checking branches [currentBranchName=$currentBranchName, headBranchName=$headBranchName]"
if ($currentBranchName -eq $headBranchName) {
    echo "current branch is head branch, setting full compilation of maps..."
    $finalCompile = $true
}

if ($clean -eq $true) {
    Remove-Item $redistDir\maps\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redistDir\maps -Force -ErrorAction Ignore
    [void](New-Item -ItemType directory -Path $redistDir\maps)
}

if ([string]::IsNullOrEmpty($mapName)) {
    Compile-Map $binDir "fences" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "training" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "stalkyard2" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "coldice" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "training2" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "focus" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "furrow" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "snowyard" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "canyon" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "bounce2" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "catacombs" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "depot" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "snowcross" $mapsDir $redistDir $wadsDir $finalCompile
    Compile-Map $binDir "frostfire" $mapsDir $redistDir $wadsDir $finalCompile
} else {
    Compile-Map $binDir $mapName $mapsDir $redistDir $wadsDir $finalCompile
}

Set-Location -Path ${PSScriptRoot}
