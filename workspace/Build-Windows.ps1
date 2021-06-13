#Requires -Version 7.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Building Cold Ice GoldSrc"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$Config = @{ }
[string]$buildConfiguration = "Release"
[string]$rebuild = "Build"

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "BuildConfig") {
        $buildConfiguration = $_.Split(' ')[1]
        echo "build config is $buildConfiguration..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Clean") {
        $rebuild = "Rebuild"
        echo "rebuilding all code sources..."
    }
}

Import-Module $PSScriptRoot\powershell\Compile-DLL.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$libsDir = "${rootDir}\libs"
$msBuild = $Config['msBuild'] ?? "msbuild"
$definitions = $Config['defintions'] ?? ""

Compile-DLL $msBuild "${RootDir}\grave-bot-src\dlls\grave_bot.sln" "grave_bot" $buildConfiguration $definitions $rebuild
Compile-DLL $msBuild "${RootDir}\src\projects\vs2019\hldll.sln" "hl" $buildConfiguration $definitions $rebuild
Compile-DLL $msBuild "${RootDir}\src\projects\vs2019\hl_cdll.sln" "client" $buildConfiguration $definitions $rebuild

Set-Location -Path ${PSScriptRoot}
