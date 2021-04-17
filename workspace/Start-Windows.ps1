#Requires -Version 5.1
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

[int]$botCount = 0
[int]$hdModels = 1
[string]$map = "stalkyard"
[int]$teamplay = 0
[string]$spawnweaponList = ""

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "Bots") {
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
    } else {
        $cmd = $_.Split(' ')[0]
        if ($cmd) {
            echo "${cmd} is not supported..."
            exit
        }
    }
}

Import-Module $PSScriptRoot\powershell\Launch-HL.psm1 -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$iceFolder = "ice"
$hldir = "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$iceDir = "${hldir}\${iceFolder}"
$icehddir = "${hldir}\${iceFolder}_hd"

# Prepare distribution folders
Remove-Item $iceDir\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $iceDir\\* -Recurse -Force -ErrorAction Ignore
if (!(Test-Path $iceDir)) {
    New-Item -ItemType directory -Path $iceDir
}
if (!(Test-Path $icehddir)) {
    New-Item -ItemType directory -Path $icehddir
}
Copy-Item $redistdir\\* $iceDir -Recurse -Force
Copy-Item $redisthddir\\* $icehddir -Recurse -Force

if ($teamplay) {
    "mp_teamplay 1" | Add-Content $iceDir\game.cfg
}

if ($spawnweaponlist) {
    "mp_spawnweaponlist $spawnweaponlist" | Add-Content $iceDir\game.cfg
}

for ($bot = 0; $bot -lt $botCount; $bot++) {
    "addbot 5" | Add-Content $iceDir\grave_bot.cfg
    "pause 3" | Add-Content $iceDir\grave_bot.cfg
    echo $bot
}

Launch-HL $botCount $hdModels $map $hldir $iceFolder
