$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Packaging Cold Ice GoldSrc"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "Rebuild") {
        $rebuild = "/rebuild"
        echo "rebuilding all code sources..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Rollback") {
        $rollback = "yes"
        echo "unpacking previous game version..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Preserve") {
        $preserve = "yes"
        echo "preserving previous game version..."
    }
}

$hldir = "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$redistdir = "Z:\redist"
$bindir = "Z:\bin"
$modelsdir = "Z:\models"
$spritesdir = "z:\sprites"
$mapsdir = "Z:\maps"
$wadsdir = "Z:\wads"
$icedir = "${hldir}\iceg"
$zipfile = "Z:\last-build.zip"

function Launch-HL {
    $hlexe = "${hldir}\hl.exe"
    
    # https://developer.valvesoftware.com/wiki/Command_Line_Options
    & $hlexe -dev -console -game iceg -condebug -windowed -gl -w 640 -h 480 +log on +sv_lan 1 +map stalkyard +deathmatch 1 | Out-Null

    if ($lastexitcode -ne 0) {
        echo "Something went wrong with Half-Life. Exit code: ${lastexitcode}"
        exit
    }
}

if (Test-Path variable:rollback) {
    if (Test-Path $zipfile) {
        Set-Location -Path $hldir
        Remove-Item $icedir\\* -Recurse -Force -ErrorAction Ignore
        Expand-Archive -LiteralPath $zipfile -DestinationPath $icedir
        Launch-HL
        exit
    } else {
        echo "zip not found?"
        exit
    }
}

if (!(Test-Path variable:preserve)) {
    Remove-Item $zipfile -Recurse -Force -ErrorAction Ignore
    Compress-Archive -Path ${icedir}\\* -DestinationPath $zipfile
}

function Compile-DLL {
    param (
        $dll,
        $target,
        $path,
        $rebuildAll
    )

    $srcdir = "Z:\src"
    $msdev = "C:\Program Files (x86)\Microsoft Visual Studio\Common\MSDev98\Bin\msdev3"

    # Delete current libraries so that we do not use old copies
    Remove-Item ${redistdir}\$path\$dll.dll -ErrorAction Ignore

    # https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-6.0/aa699274(v=vs.60)
    $out = & $msdev $srcdir\$path\$target.dsp /make "$target - Win32 Release" ${rebuildAll} | Out-String

    echo $out

    if ($lastexitcode -ne 0) {
        echo "Could not compile $dll.dll. Exit code: ${lastexitcode}"
        exit
    }

    if ($out.ToLower().Contains("Error")) {
        echo "Could not compile $dll.dll."
        exit
    }
}

Compile-DLL "hl" "hl" "dlls" $rebuild
Compile-DLL "client" "cl_dll" "cl_dll" $rebuild

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
    Move-Item $modelsdir\$target\$target.mdl $redistdir\models\$target.mdl -force
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

function Compile-Wad {
    param (
        $target
    )

    Set-Location -Path $bindir
    & .\makels $wadsdir\$target $wadsdir\$target $wadsdir\$target.ls | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not makels ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\qlumpy $wadsdir\$target.ls
    if ($lastexitcode -ne 0) {
        echo "Could not qlumpy ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Remove-Item $wadsdir\$target.ls -Recurse -Force -ErrorAction Ignore
    Move-Item $wadsdir\$target.wad $redistdir -force
}

# Compile source models
Compile-Model "v_9mmAR"
Compile-Model "p_9mmar"
Compile-Model "v_shotgun"

# Compile sprites
Compile-Sprite "muzzleflash1"

# Compile wads
# Compile-Wad "coldice"

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

Launch-HL
