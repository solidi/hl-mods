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

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -Force -DisableNameChecking

$Config = @{ }
[bool]$unzip = $false
[bool]$detailedTextures = $false

([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Unzip") {
        $unzip = $true
        Write-Output "unzipping current archive..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Detail") {
        $detailedTextures = $true
        Write-Output "with detailed textures..."
    }
}

$host.UI.RawUI.WindowTitle = "Copy Distribution $($Config['projectName'])"

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$hldir = $Config['hlDir'] ?? "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$redistSpDir = "${rootDir}\redist_sp"
$gameFolder = $Config['gameFolder'] ?? "ice_beta5"
$iceDir = "${hldir}\${gameFolder}"
$icehddir = "${hldir}\${gameFolder}_hd"
$iceSpDir = "${hldir}\${gameFolder}_sp"

if ($unzip -eq $true) {
    unzipDistributionFiles $rootDir $hldir $iceDir $icehddir
} else {
    copyDistributionFiles $rootDir $redistDir $redisthddir $redistSpDir $iceDir $icehddir $iceSpDir $detailedTextures
}
