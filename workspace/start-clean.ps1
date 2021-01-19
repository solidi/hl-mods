#Requires -Version 5.1
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Packaging Cold Ice GoldSrc"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

[int]$hdmodels = 1
[int]$verifyfiles = 1
[string]$rebuild = "Build"

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "Rebuild") {
        $rebuild = "Clean,Build"
        echo "rebuilding all code sources..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Rollback") {
        $rollback = "yes"
        echo "unpacking previous game version..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Preserve") {
        $preserve = "yes"
        echo "preserving previous game version..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "LowRes") {
        $hdmodels = 0
        echo "switching to low res models..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipVerify") {
        $verifyfiles = 0
        echo "skipping file verification..."
    }
}

$hldir = "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$redistdir = "Z:\redist"
$redisthddir = "Z:\redist_hd"
$bindir = "Z:\bin"
$spritesdir = "z:\sprites"
$mapsdir = "Z:\maps"
$wadsdir = "Z:\wads"
$icedir = "${hldir}\iceg"
$icehddir = "${hldir}\iceg_hd"
$zipfile = "Z:\last-build.zip"

function Launch-HL {
    $hlexe = "${hldir}\hl.exe"

    # Set hdmodels
    Get-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings
    Set-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings -Name hdmodels -Value $hdmodels

    # https://developer.valvesoftware.com/wiki/Command_Line_Options
    $out = & $hlexe -dev `
            -console `
            -game iceg `
            -condebug `
            -windowed -gl -w 640 -h 480 `
            +log on +sv_lan 1 +map stalkyard +deathmatch 1 +maxplayers 2 | Out-String

    echo $out

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
        $slnpath,
        $dllname,
        $rebuildall
    )

    $msdev = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild"

    # https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-6.0/aa699274(v=vs.60)
    $out = & $msdev $slnpath /t:$rebuildall /p:Configuration=Release | Out-String

    if ($lastexitcode -ne 0) {
        echo $out
        echo "Could not compile $dllname.dll. Exit code: ${lastexitcode}"
        exit
    }

    echo $out

    if ($out -match '^[1-9]\d* Error') {
        echo "Could not compile $dllname.dll."
        exit
    }
}

function Compile-Model {
    param (
        $target,
        $modelsdir,
        $outdir
    )

    Copy-Item $bindir\studiomdl.exe $modelsdir\$target
    Remove-Item $modelsdir\$target.mdl -ErrorAction Ignore
    Set-Location -Path $modelsdir\$target
    & .\studiomdl $modelsdir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $modelsdir\$target\$target.mdl $outdir\$target.mdl -force
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
    Move-Item $spritesdir\$target\$target.spr $redistdir\sprites\$target.spr -force
    Remove-Item $spritesdir\$target\sprgen.exe
}

function Compile-Map {
    param (
        $target
    )

    Set-Location -Path $bindir
    & .\hlcsg $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not qcsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\hlbsp $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not qbsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\hlvis $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not vis ${target}. Exit code: ${lastexitcode}"
        exit
    }
    & .\hlrad $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "Could not qrad ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Copy-Item $mapsdir\$target\$target.bsp $redistdir\maps\$target.bsp
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
    Copy-Item $wadsdir\$target.wad $redistdir -force
}

# Compile all DLLs
Remove-Item $redistdir\dlls\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistdir\cl_dlls\\* -Recurse -Force -ErrorAction Ignore
Compile-DLL "Z:\grave-bot-src\dlls\grave_bot.sln" "grave_bot" $rebuild
Compile-DLL "Z:\src\projects\vs2019\hldll.sln" "hl" $rebuild
Compile-DLL "Z:\src\projects\vs2019\hl_cdll.sln" "client" $rebuild

# Compile source models
Remove-Item $redistdir\models\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\models\\* -Recurse -Force -ErrorAction Ignore
$modelsdir = "Z:\models"
Compile-Model "v_9mmAR" $modelsdir $redistdir\models
Compile-Model "v_9mmAR" $modelsdir\hd $redisthddir\models
Compile-Model "p_9mmar" $modelsdir\hd $redisthddir\models
Compile-Model "v_shotgun" $modelsdir\hd $redisthddir\models
Compile-Model "p_vest" $modelsdir $redistdir\models
Compile-Model "v_vest_radio" $modelsdir $redistdir\models
Compile-Model "v_vest_radio" $modelsdir\hd $redisthddir\models
Compile-Model "w_vest" $modelsdir $redistdir\models

# Compile sprites
Remove-Item $redistdir\sprites\\* -Recurse -Force -ErrorAction Ignore
Compile-Sprite "muzzleflash1"
Copy-Item $spritesdir\weapon_vest.txt $redistdir\sprites
Copy-Item $spritesdir\hud.txt $redistdir\sprites

# Compile wads
# Remove-Item $redistdir\wads\\* -Recurse -Force -ErrorAction Ignore
# Compile-Wad "coldice"

# Compile fonts
Set-Location -Path $bindir
& .\makefont.exe -font "Arial" $redistdir\fonts.wad

# Compile maps
Remove-Item $redistdir\maps\\* -Recurse -Force -ErrorAction Ignore
Compile-Map "yard"
# Compile-Map "cir_stalkyard"

# Prepare distribution folders
Remove-Item $icedir\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $icehddir\\* -Recurse -Force -ErrorAction Ignore

if (!(Test-Path $icedir)) {
    New-Item -ItemType directory -Path $icedir
}

if (!(Test-Path $icehddir)) {
    New-Item -ItemType directory -Path $icehddir
}

Copy-Item $redistdir\\* $icedir -Recurse -Force
Copy-Item $redisthddir\\* $icehddir -Recurse -Force

function Test-Manifest {
    param (
        $manifest,
        $target
    )

    # Read $mainfest files to directory
    $files = Get-Content -Path $manifest
    Set-Location -Path $target
    foreach ($file in $files) {
        echo "locating $file in directory..."
        if (!(Test-Path "${file}")) {
            echo "Could not find $file in $target"
            exit
        }
    }

    # Read directory files to $manifest
    $rawfiles = Get-ChildItem -Path $target -Recurse
    foreach ($file in $rawfiles) {
        $fileName = $file.FullName.Replace("$target\","")
        echo "locating $file in $manifest..."
        if (!$files.Contains($fileName)) {
            echo "Could not find $fileName in $manifest"
            exit
        }
    }
}

if ($verifyfiles) {
    Test-Manifest "Z:\manifest" $redistdir
    Test-Manifest "Z:\manifest_hd" $redisthddir
}

function PAK-File {
    param (
        $targets
    )

    Copy-Item Z:\bin\qpakman.exe $icedir -Force
    Set-Location -Path $icedir
    $folders = [String]::Join(" ", $targets)
    $in = ".\qpakman.exe ${folders} -o pak0.pak"
    $out = iex $in | Out-String
    echo $out

    # qpakman does not exit with failure.
    if ($out -match '[1-9] failures' -or $out.Contains("FAILURE")) {
        echo "Could not create pak file."
        exit
    }

    foreach ($folder in $targets) {
        Remove-Item "${icedir}\${folder}" -Recurse -Force
    }
    Remove-Item "${icedir}\qpakman.exe"
}

PAK-File @("models", "maps", "sound", "sprites")

Launch-HL
