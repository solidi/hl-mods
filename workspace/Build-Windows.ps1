#Requires -Version 5.1
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

[string]$configFile = "Config.Docker"
[string]$buildConfiguration = "Release"
[string]$rebuild = "Build"

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
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
. ("$PSScriptRoot\$configFile.ps1")

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$msBuild = $Config['msBuild']

Remove-Item $redistDir\dlls\grave_bot.dll -Force -ErrorAction Ignore
Remove-Item $redistDir\dlls\ice.dll -Force -ErrorAction Ignore
Remove-Item $redistDir\cl_dlls\client.dll -Force -ErrorAction Ignore

Compile-DLL $msBuild "${RootDir}\grave-bot-src\dlls\grave_bot.sln" "grave_bot" $buildConfiguration $rebuild
Compile-DLL $msBuild "${RootDir}\src\projects\vs2019\hldll.sln" "hl" $buildConfiguration $rebuild
Compile-DLL $msBuild "${RootDir}\src\projects\vs2019\hl_cdll.sln" "client" $buildConfiguration $rebuild

Compile-Exe $msBuild "${RootDir}\src\utils\makefont\makefont.sln" "makefont" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\sprgen\sprgen.sln" "sprgen" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\makels\makels.sln" "makels" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\qlumpy\qlumpy.sln" "qlumpy" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\qpakman\qpakman.sln" "qpakman" $buildConfiguration $rebuild
