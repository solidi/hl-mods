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

$host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Tools"

Import-Module $PSScriptRoot\powershell\Compile-DLL.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$msBuild = $Config['msBuild'] ?? "msbuild"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"
$mapsOnly = $Config['mapsOnly'] ?? $false

if ($mapsOnly -eq $false)
{
Compile-Exe $msBuild "${RootDir}\bsp-tools\BSP_tool\BSP_tool.sln" "BSP_tool" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\makefont\makefont.sln" "makefont" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\sprgen\sprgen.sln" "sprgen" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\makels\makels.sln" "makels" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\qlumpy\qlumpy.sln" "qlumpy" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\qpakman\qpakman.sln" "qpakman" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\src\utils\studiomdl\studiomdl.sln" "studiomdl" $buildConfiguration $rebuild
}
Compile-Exe $msBuild "${RootDir}\vhlt\zhlt.sln" "hlcsg" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\vhlt\zhlt.sln" "hlbsp" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\vhlt\zhlt.sln" "hlrad" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\vhlt\zhlt.sln" "hlvis" $buildConfiguration $rebuild
Compile-Exe $msBuild "${RootDir}\resgen\RESGen.sln" "RESGen" $buildConfiguration $rebuild

Set-Location -Path ${PSScriptRoot}
