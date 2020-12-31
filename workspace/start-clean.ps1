$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Packaging Cold Ice GoldSrc"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$rebuild = $args[0]
$msdev = "C:\Program Files (x86)\Microsoft Visual Studio\Common\MSDev98\Bin\msdev3"
$hldir = "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$redistdir = "Z:\redist"
$bindir = "Z:\bin"
$modelsdir = "Z:\models"
$spritesdir = "z:\sprites"
$mapsdir = "Z:\maps"
$icedir = "${hldir}\iceg"
$hlexe = "${hldir}\hl.exe"

# Delete current libraries so that we do not use old copies
Remove-Item ${redistdir}\dlls\hl.dll -ErrorAction Ignore
Remove-Item ${redistdir}\cl_dlls\client.dll -ErrorAction Ignore

# https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-6.0/aa699274(v=vs.60)
& $msdev z:\src\dlls\hl.dsp /make "hl - Win32 Release" ${rebuild} | Out-String

if ($lastexitcode -ne 0) {
    echo "Could not compile hl.dll. Exit code: ${lastexitcode}"
    exit
}

& $msdev z:\src\cl_dll\cl_dll.dsp /make "cl_dll - Win32 Release" ${rebuild} | Out-String

if ($lastexitcode -ne 0) {
    echo "Could not compile hl.dll. Exit code: ${lastexitcode}"
    exit
}

function Compile-Model {
    param (
        $target
    )

    Copy-Item $bindir\studiomdl.exe $modelsdir\$target
    Remove-Item $modelsdir\$target.mdl -ErrorAction Ignore
    Set-Location -Path $modelsdir\$target
    & .\studiomdl $modelsdir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $modelsdir\$target\$target.mdl $redistdir\models -force
    Remove-Item $modelsdir\$target\studiomdl.exe
}

function Compile-Sprite {
    param (
        $target
    )

    Copy-Item $bindir\sprgen.exe $spritesdir\$target
    Remove-Item $spritesdir\$target.spr -ErrorAction Ignore
    Set-Location -Path $spritesdir\$target
    & .\sprgen $spritesdir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $spritesdir\$target\$target.spr $redistdir\sprites -force
    Remove-Item $spritesdir\$target\sprgen.exe
}

function Compile-Map {
    param (
        $target
    )

    Set-Location -Path $bindir
    & .\qcsg $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not qcsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\qbsp2 $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not qbsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\vis $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not vis ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\qrad $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not qrad ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Copy-Item $mapsdir\$target\$target.bsp $redistdir\maps
    Get-ChildItem $mapsdir\$target -Exclude *.map | Remove-Item -Force -ErrorAction Ignore
}

# Compile source models
Compile-Model "v_9mmAR"

# Compile sprites
Compile-Sprite "muzzleflash1"

# Compile maps
Compile-Map "yard"
# Compile-Map "training"

Remove-Item $icedir\\* -Recurse -Force -ErrorAction Ignore

if (!(Test-Path $icedir)) {
    New-Item -ItemType directory -Path $icedir
}

Copy-Item $redistdir\\* $icedir -Recurse -Force

if (!(Test-Path "${icedir}\dlls\hl.dll")) {
    echo "Could not find hl.dll."
    exit
}

if (!(Test-Path "${icedir}\cl_dlls\client.dll")) {
    echo "Could not find client.dll."
    exit
}

# Making PAK file
Copy-Item Z:\bin\qpakman.exe $icedir -Force
Set-Location -Path $icedir
$out = & "${icedir}\qpakman.exe" models -o pak0.pak | Out-String

# qpakman does not exit with failure.
if ($out -like "FAILURE") {
    echo "Could not create pak file."
    exit
}

Remove-Item "${icedir}\models" -Recurse -Force
Remove-Item "${icedir}\qpakman.exe"

# https://developer.valvesoftware.com/wiki/Command_Line_Options
& $hlexe -dev -console -game iceg -condebug -windowed -gl -w 640 -h 480 +log on +sv_lan 1 +map stalkyard | Out-Null

if ($lastexitcode -ne 0) {
    echo "Something went wrong with Half-Life. Exit code: ${lastexitcode}"
    exit
}
