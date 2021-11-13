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

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -Force -DisableNameChecking

$Config = @{ }

([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    }
}

$host.UI.RawUI.WindowTitle = "Copy Distribution $($Config['projectName'])"

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$hldir = $Config['hlDir'] ?? "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$gameFolder = $Config['gameFolder'] ?? "ice"
$iceDir = "${hldir}\${gameFolder}"
$icehddir = "${hldir}\${gameFolder}_hd"

copyDistributionFiles $rootDir $redistDir $redisthddir $iceDir $icehddir
