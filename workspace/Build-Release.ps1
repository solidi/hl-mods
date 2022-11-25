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
[int]$verifyFiles = 1

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipVerify") {
        $verifyFiles = 0
        echo "skipping file verification..."
    }
}

$host.UI.RawUI.WindowTitle = "Packaging $($Config['projectName'])"

Import-Module $PSScriptRoot\powershell\Compile-Font.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Test-Manifest.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\PAK-File.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Package-Release.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"
$gameFolder = $Config['gameFolder'] ?? "ice_beta3"

Remove-Item $redistDir\debug.log -Force -ErrorAction Ignore
Remove-Item $redistDir\qconsole.log -Force -ErrorAction Ignore
Remove-Item $redistDir\steam_appid.txt -Force -ErrorAction Ignore
Remove-Item $redistDir\htmlcache -Recurse -Force -ErrorAction Ignore

Remove-Item $redistDir\dlls\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\cl_dlls\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\dlls -Force -ErrorAction Ignore
Remove-Item $redistDir\cl_dlls -Force -ErrorAction Ignore
[void](New-Item -ItemType directory -Path $redistDir\dlls)
[void](New-Item -ItemType directory -Path $redistDir\cl_dlls)

Copy-Item ${RootDir}\libs\dlls\ice.dll $redistDir\dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\dlls\grave_bot.dll $redistDir\dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\cl_dlls\client.dll $redistDir\cl_dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\dlls\ice.dylib $redistDir\dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\dlls\ice.so $redistDir\dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\cl_dlls\client.dylib $redistDir\cl_dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\cl_dlls\client.so $redistDir\cl_dlls -ErrorAction Ignore
Copy-Item ${RootDir}\libs\dlls\gravebot.so $redistDir\dlls -ErrorAction Ignore

Compile-Font $binDir $redistDir "Arial"

Remove-Item $redistDir\pak0.pak -Force -ErrorAction Ignore

if ($verifyfiles) {
    Test-Manifest "${RootDir}\manifest" $redistDir
    Test-Manifest "${RootDir}\manifest_hd" $redisthddir
}

try {
    # Shift player models out of pak
    Move-Item $redistDir\models\player $redistDir -Force
    PAK-File $binDir $redistDir @("models", "sound", "sprites")
} catch {
    if ($verifyfiles) {
        Throw
    }
}

Package-Release $rootDir $redistDir $redistHdDir $gameFolder

Set-Location -Path ${PSScriptRoot}
