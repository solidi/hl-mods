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

Import-Module $PSScriptRoot\powershell\Compile-Model.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$modelsdir = "${rootDir}\models"
$binDir = "${rootDir}\bin"

[void](New-Item -ItemType directory -Path $redistDir\models)
Compile-Model $binDir "w_satchel" $modelsdir $redistDir\models
