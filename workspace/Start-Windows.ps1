#Requires -Version 7.2
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$Config = @{ }
[int]$botCount = 20
[int]$hdModels = 1
[string]$map = "snowyard"
[int]$teamplay = 0
[string]$spawnweaponList = ""
[int]$runes = 1
[int]$timelimit = 0
[bool]$copyDistro = 1
[bool]$detailedTextures = $false
[string]$singlePlayer = ""

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Bots") {
        $botCount = $_.Split(' ')[1]
        echo "adding ${botCount} bots..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Map") {
        $map = $_.Split(' ')[1]
        echo "level is ${map} map..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Teamplay") {
        $teamplay = 1
        echo "with teamplay..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SpawnWeaponList") {
        $spawnweaponList = $_.Split(' ')[1]
        echo "spawn weapon list is ${spawnweaponList}..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "LowRes") {
        $hdModels = 0
        echo "switching to low res models..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipRunes") {
        $runes = 0
        echo "skipping runes..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "TimeLimit") {
        $timelimit = $_.Split(' ')[1]
        echo "timelimit is ${timelimit}..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipDistro") {
        $copyDistro = 0
        echo "skipping copying distro..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Detail") {
        $detailedTextures = $true
        Write-Output "with detailed textures..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SinglePlayer") {
        $singlePlayer = "_sp"
        Write-Output "single player..."
    } else {
        $cmd = $_.Split(' ')[0]
        if ($cmd) {
            echo "${cmd} is not supported..."
            exit
        }
    }
}

$host.UI.RawUI.WindowTitle = "Starting Windows $($Config['projectName'])"

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$redistSpDir = "${rootDir}\redist_sp"
$gameFolder = $Config['gameFolder'] ?? "ice_beta4"
$hldir = $Config['hlDir'] ?? "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$hlexe = $Config['hlExe'] ?? "hl.exe"
$gameParameters = $Config['gameParameters'] ?? "-console -dev -condebug -gl -windowed -width 640 -height 480"
$iceDir = "${hldir}\${gameFolder}"
$icehddir = "${hldir}\${gameFolder}_hd"
$iceSPDir = "${hldir}\${gameFolder}_sp"

if ($copyDistro) {
    copyDistributionFiles $rootDir $redistDir $redisthddir $redistSpDir $iceDir $icehddir $iceSPDir $detailedTextures
}

New-Item $iceDir\game.cfg -Force

if ($teamplay) {
    "mp_teamplay 1" | Add-Content $iceDir\game.cfg
}

if (!$runes) {
    "mp_allowrunes 0" | Add-Content $iceDir\game.cfg
}

if ($spawnweaponlist) {
    "mp_spawnweaponlist `"$spawnweaponlist`"" | Add-Content $iceDir\game.cfg
}

if ($timelimit) {
    "mp_timelimit `"$timelimt`"" | Add-Content $iceDir\game.cfg
}

for ($bot = 0; $bot -lt $botCount; $bot++) {
    "addbot 3" | Add-Content $iceDir\grave_bot.cfg
    "pause 3" | Add-Content $iceDir\grave_bot.cfg
}

Set-Location -Path $hldir
Launch-HL $botCount $hdModels $map $hldir $hlexe $gameParameters "$($gameFolder)$($singlePlayer)"
Set-Location -Path ${PSScriptRoot}
