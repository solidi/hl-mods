#Requires -Version 7.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Packaging Cold Ice GoldSrc"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$Config = @{ }
[int]$botCount = 0
[int]$hdModels = 1
[string]$map = "stalkyard"
[int]$teamplay = 0
[string]$spawnweaponList = ""
[int]$runes = 1
[int]$timelimit = 0

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
    } else {
        $cmd = $_.Split(' ')[0]
        if ($cmd) {
            echo "${cmd} is not supported..."
            exit
        }
    }
}

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$iceFolder = "ice"
$hldir = $Config['hlDir'] ?? "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$hlexe = $Config['hlExe'] ?? "hl.exe"
$gameParameters = $Config['gameParameters'] ?? "-console -dev -condebug -gl -windowed -width 640 -height 480"
$iceDir = "${hldir}\${iceFolder}"
$icehddir = "${hldir}\${iceFolder}_hd"

copyDistributionFiles $rootDir $redistDir $redisthddir $iceDir $icehddir

New-Item $iceDir\game.cfg

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
    "addbot 5" | Add-Content $iceDir\grave_bot.cfg
    "pause 3" | Add-Content $iceDir\grave_bot.cfg
}

Set-Location -Path $hldir
Launch-HL $botCount $hdModels $map $hldir $hlexe $gameParameters $iceFolder
Set-Location -Path ${PSScriptRoot}
