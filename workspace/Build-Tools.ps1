#Requires -Version 7.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Building Cold Ice Tools"
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
$msBuild = $Config['msBuild']
$binDir = $Config['binDir']

Remove-Item $binDir\makefont.exe -Force -ErrorAction Ignore
Remove-Item $binDir\sprgen.exe -Force -ErrorAction Ignore
Remove-Item $binDir\makels.exe -Force -ErrorAction Ignore
Remove-Item $binDir\qlumpy.exe -Force -ErrorAction Ignore
Remove-Item $binDir\qpakman.exe -Force -ErrorAction Ignore

Compile-Exe $msBuild "${RootDir}\src\utils\makefont\makefont.sln" "makefont" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\sprgen\sprgen.sln" "sprgen" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\makels\makels.sln" "makels" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\qlumpy\qlumpy.sln" "qlumpy" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\qpakman\qpakman.sln" "qpakman" $buildConfiguration $rebuild