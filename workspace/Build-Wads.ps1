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

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Clean") {
        $clean = $true
        echo "rebuilding all wads..."
    }
}

$host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Wads"

Import-Module $PSScriptRoot\powershell\Compile-Wad.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

$wadsDir = "${RootDir}\wads"

if ($clean -eq $true) {
    Remove-Item $redistDir\* -Recurse -Include *.wad -Force -ErrorAction Ignore
}

Compile-Wad $binDir "coldice" $wadsDir $redistDir
Compile-Wad $binDir "spacepirate" $wadsDir $redistDir
Compile-Wad $binDir "decals" $wadsDir $redistDir
Compile-Wad $binDir "icerink" $wadsDir $redistDir
Compile-Wad $binDir "datafloe" $wadsDir $redistDir
Compile-Wad $binDir "thetemple" $wadsDir $redistDir
Compile-Wad $binDir "glacialcore" $wadsDir $redistDir
Compile-Wad $binDir "latenightxmas" $wadsDir $redistDir
Compile-Wad $binDir "storm" $wadsDir $redistDir
Compile-Wad $binDir "quadfrost" $wadsDir $redistDir

Set-Location -Path ${PSScriptRoot}
