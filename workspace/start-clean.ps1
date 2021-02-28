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

[int]$launch = 1
[int]$hdmodels = 1
[int]$verifyfiles = 1
[int]$dedicatedserver = 0
[string]$rebuild = "Build"
[string]$grapplinghook = "GRAPPLING_HOOK"
[string]$weaponvest = "VEST"
[string]$weaponhandgun = "SILENCER"
[string]$weaponclustergrenades = "CLUSTER_GRENADES"
[string]$weaponcrowbar = "CROWBAR"
[string]$weaponknife = "KNIFE"
[string]$weaponrpg = "RPG"
[string]$weapontripmine = "TRIPMINE"
[int]$bots = 0
[string]$map = "stalkyard"
[int]$teamplay = 0

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "Rebuild") {
        $rebuild = "Rebuild"
        echo "rebuilding all code sources..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "NoLaunch") {
        $launch = 0
        echo "packaging only..."
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
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipHook") {
        $grapplinghook = ""
        echo "skipping grappling hook..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipVest") {
        $weaponvest = ""
        echo "skipping vest device..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipHandgun") {
        $weaponhandgun = ""
        echo "skipping handgun..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipClusterGrenades") {
        $weaponclustergrenades = ""
        echo "skipping cluster grenades..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Bots") {
        $bots = $_.Split(' ')[1]
        echo "adding ${bots} bots..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Map") {
        $map = $_.Split(' ')[1]
        echo "level is ${map} map..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipCrowbar") {
        $weaponcrowbar = ""
        echo "skipping crowbar..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipKnife") {
        $weaponknife = ""
        echo "skipping knife..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipRpg") {
        $weaponrpg = ""
        echo "skipping rpg..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipTripmine") {
        $weapontripmine = ""
        echo "skipping tripmine..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "DedicatedServer") {
        $dedicatedserver = 1
        echo "running dedicated server..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Teamplay") {
        $teamplay = 1
        echo "with teamplay..."
    } else {
        $cmd = $_.Split(' ')[0]
        if ($cmd) {
            echo "${cmd} is not supported..."
            exit
        }
    }
}

$driveletter = "Y:"
$hldir = "C:\Program Files (x86)\Steam\steamapps\common\half-life"
$hldsdir = "C:\steamcmd\steamapps\common\Half-Life"
$redistdir = "$driveletter\redist"
$redisthddir = "$driveletter\redist_hd"
$bindir = "$driveletter\bin"
$mapsdir = "$driveletter\maps"
$wadsdir = "$driveletter\wads"
$sounddir = "$driveletter\sound"
$icefolder = "iceg"
$icedir = "${hldir}\${icefolder}"
$icehddir = "${hldir}\${icefolder}_hd"
$icedsdir = "${hldsdir}\${icefolder}"
$icedshddir = "${hldsdir}\${icefolder}_hd"
$zipfile = "$driveletter\last-build.zip"

function Launch-HL {
    param (
        $launch,
        $botcount
    )

    if (!$launch) {
        return;
    }

    $players = $botcount + 2
    $hlexe = "${hldir}\hl.exe"

    # Set hdmodels
    Get-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings
    Set-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings -Name hdmodels -Value $hdmodels

    # https://developer.valvesoftware.com/wiki/Command_Line_Options
    $out = & $hlexe `
            -console -dev -condebug `
            -game $icefolder `
            -windowed -gl -w 640 -h 480 `
            +developer 2 +log on `
            +sv_lan 1 +map $map +deathmatch 1 +maxplayers $players | Out-String

    echo $out

    if ($lastexitcode -ne 0) {
        echo "Something went wrong with Half-Life. Exit code: ${lastexitcode}"
        exit
    }
}

function Launch-HLDS {
    param (
        $launch,
        $botcount
    )

    if (!$launch) {
        return;
    }

    $players = $botcount + 2
    $hldsexe = "${hldsdir}\hlds.exe"

    $out = & $hldsexe -game $icefolder +maxplayers $players +map stalkyard -ip localhost +port 27015 | Out-String

    echo $out

    if ($lastexitcode -ne 0) {
        echo "Something went wrong with Half-Life Dedicated Server. Exit code: ${lastexitcode}"
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

    echo "Compiling dll $slnpath > $dllname.dll..."
    # https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019
    $out = & $msdev $slnpath /t:"$rebuildall" `
                    /p:Configuration=Release `
                    /p:GrapplingHook=$grapplinghook `
                    /p:Vest=$weaponvest `
                    /p:Silencer=$weaponhandgun `
                    /p:ClusterGrenades=$weaponclustergrenades `
                    /p:Knife=$weaponknife `
                    /p:Crowbar=$weaponcrowbar `
                    /p:Rpg=$weaponrpg `
                    /p:Tripmine=$weapontripmine `
                    | Out-String

    if ($lastexitcode -ne 0) {
        echo "$out> Could not compile $dllname.dll. Exit code: ${lastexitcode}"
        exit
    }

    if ($out -match '^[1-9]\d* Error') {
        echo "$out> Could not compile $dllname.dll."
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
    echo "Compiling model $modelsdir\$target\$target.qc..."
    $out = & .\studiomdl $modelsdir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $modelsdir\$target\$target.mdl $outdir\$target.mdl -force
    Remove-Item $modelsdir\$target\studiomdl.exe
}

function Compile-Sprite {
    param (
        $target,
        $spritesdir,
        $outdir
    )

    Copy-Item $bindir\sprgen.exe $spritesdir\$target
    Remove-Item $spritesdir\$target.spr -ErrorAction Ignore
    Set-Location -Path $spritesdir\$target
    echo "Compiling sprite $spritesdir\$target.spr..."
    $out = & .\sprgen $spritesdir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $spritesdir\$target\$target.spr $outdir\$target.spr -force
    Remove-Item $spritesdir\$target\sprgen.exe
}

function Compile-Map {
    param (
        $target
    )

    Set-Location -Path $bindir
    echo "Compiling map $target..."
    $out = & .\hlcsg $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qcsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\hlbsp $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qbsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\hlvis $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not vis ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\hlrad $mapsdir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qrad ${target}. Exit code: ${lastexitcode}"
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
    echo "Compiling wad $wadsdir\$target.wad..."
    $out = & .\makels $wadsdir\$target $wadsdir\$target $wadsdir\$target.ls | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not makels ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\qlumpy $wadsdir\$target.ls | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qlumpy ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Remove-Item $wadsdir\$target.ls -Recurse -Force -ErrorAction Ignore
    Copy-Item $wadsdir\$target.wad $redistdir -force
}

function Compile-Sound {
    param (
        $target,
        [float]$volume,
        $outsound,
        $type="wav",
        [int]$trimfrom=0,
        [int]$trimto=0
    )

    $trimcmd = ""
    if ($trimto -gt 0) {
        $trimcmd = "-ss $trimfrom -to $trimto"
    }

    if ($type -eq "mp3") {
       $typecmd = "-acodec libmp3lame"
    } else {
        $typecmd = "-ar 22050 -ac 1 -acodec pcm_u8 "
    }

    Set-Location -Path $bindir
    echo "Converting sound $outsound..."
    $in = ".\ffmpeg -y -i $sounddir\$target " `
          + "$typecmd " `
          + "-filter:a volume=$volume " `
          + "$trimcmd " `
          + "-hide_banner -loglevel error " `
          + "$redistdir\$outsound"

    $out = iex $in | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not convert sound ${target}. Exit code: ${lastexitcode}"
        exit
    }
}

# Compile all DLLs
Remove-Item $redistdir\dlls\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistdir\cl_dlls\\* -Recurse -Force -ErrorAction Ignore
Compile-DLL "$driveletter\grave-bot-src\dlls\grave_bot.sln" "grave_bot" $rebuild
Compile-DLL "$driveletter\src\projects\vs2019\hldll.sln" "hl" $rebuild
Compile-DLL "$driveletter\src\projects\vs2019\hl_cdll.sln" "client" $rebuild
Copy-Item $driveletter\libs\dlls\hl.dylib $redistdir\dlls
Copy-Item $driveletter\libs\dlls\hl.so $redistdir\dlls
Copy-Item $driveletter\libs\cl_dlls\client.dylib $redistdir\cl_dlls
Copy-Item $driveletter\libs\cl_dlls\client.so $redistdir\cl_dlls
Copy-Item $driveletter\libs\dlls\gravebot.so $redistdir\dlls

# Compile source models
Remove-Item $redistdir\models\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\models\\* -Recurse -Force -ErrorAction Ignore
$modelsdir = "$driveletter\models"
Compile-Model "v_9mmAR" $modelsdir $redistdir\models
Compile-Model "v_9mmAR" $modelsdir\hd $redisthddir\models
Compile-Model "p_9mmar" $modelsdir\hd $redisthddir\models
Compile-Model "v_shotgun" $modelsdir\hd $redisthddir\models
Compile-Model "p_vest" $modelsdir $redistdir\models
Compile-Model "v_vest_radio" $modelsdir $redistdir\models
Compile-Model "v_vest_radio" $modelsdir\hd $redisthddir\models
Compile-Model "w_vest" $modelsdir $redistdir\models
Compile-Model "v_9mmhandgun" $modelsdir $redistdir\models
Compile-Model "v_9mmhandgun" $modelsdir\hd $redisthddir\models
Compile-Model "v_9mmhandguns" $modelsdir\hd $redisthddir\models
Compile-Model "v_9mmhandguns" $modelsdir $redistdir\models
Compile-Model "p_9mmhandguns" $modelsdir $redistdir\models
Compile-Model "p_9mmhandgun" $modelsdir $redistdir\models
Compile-Model "p_9mmhandgun" $modelsdir\hd $redisthddir\models
Compile-Model "p_9mmhandguns" $modelsdir\hd $redisthddir\models
Compile-Model "w_9mmhandgun" $modelsdir $redistdir\models
Compile-Model "w_9mmhandguns" $modelsdir $redistdir\models
Compile-Model "w_9mmhandgun" $modelsdir\hd $redisthddir\models
Compile-Model "w_9mmhandguns" $modelsdir\hd $redisthddir\models
Compile-Model "v_grenade" $modelsdir\hd $redisthddir\models
Compile-Model "w_grenade" $modelsdir\hd $redisthddir\models
Compile-Model "p_grenade" $modelsdir\hd $redisthddir\models
Compile-Model "p_grenade" $modelsdir $redistdir\models
Compile-Model "v_grenade" $modelsdir $redistdir\models
Compile-Model "w_grenade" $modelsdir $redistdir\models
Compile-Model "p_knife" $modelsdir\hd $redisthddir\models
Compile-Model "v_knife" $modelsdir\hd $redisthddir\models
Compile-Model "w_knife" $modelsdir\hd $redisthddir\models
Compile-Model "p_knife" $modelsdir $redistdir\models
Compile-Model "v_knife" $modelsdir $redistdir\models
Compile-Model "w_knife" $modelsdir $redistdir\models
Compile-Model "v_crowbar" $modelsdir\hd $redisthddir\models
Compile-Model "w_crowbar" $modelsdir\hd $redisthddir\models
Compile-Model "p_crowbar" $modelsdir\hd $redisthddir\models
Compile-Model "p_crowbar" $modelsdir $redistdir\models
Compile-Model "v_crowbar" $modelsdir $redistdir\models
Compile-Model "w_crowbar" $modelsdir $redistdir\models
Compile-Model "v_rpg" $modelsdir\hd $redisthddir\models
Compile-Model "p_rpg" $modelsdir\hd $redisthddir\models
Compile-Model "w_rpg" $modelsdir\hd $redisthddir\models
Compile-Model "v_rpg" $modelsdir $redistdir\models
Compile-Model "p_rpg" $modelsdir $redistdir\models
Compile-Model "w_rpg" $modelsdir $redistdir\models
Compile-Model "rpgrocket" $modelsdir $redistdir\models
Compile-Model "rpgrocket" $modelsdir\hd $redisthddir\models
Compile-Model "v_tripmine" $modelsdir\hd $redisthddir\models
Compile-Model "p_tripmine" $modelsdir\hd $redisthddir\models
Compile-Model "v_tripmine" $modelsdir $redistdir\models
Compile-Model "p_tripmine" $modelsdir $redistdir\models

# New-Item -ItemType directory -Path $redistdir\models\player\gordon
# Compile-Model "gordon" $modelsdir $redistdir\models\player\gordon

# Compile sprites
Remove-Item $redistdir\sprites\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sprites\\* -Recurse -Force -ErrorAction Ignore
$spritesdir = "$driveletter\sprites"
Compile-Sprite "muzzleflash1" $spritesdir $redistdir\sprites
Compile-Sprite "muzzleflash2" $spritesdir $redistdir\sprites
Compile-Sprite "zerogxplode" $spritesdir $redistdir\sprites
Compile-Sprite "animglow01" $spritesdir $redistdir\sprites
Compile-Sprite "crosshairs" $spritesdir $redistdir\sprites
Compile-Sprite "640hud1" $spritesdir $redistdir\sprites
Compile-Sprite "640hud1" $spritesdir\hd $redisthddir\sprites
Compile-Sprite "640hud4" $spritesdir $redistdir\sprites
Compile-Sprite "640hud4" $spritesdir\hd $redisthddir\sprites
Copy-Item $spritesdir\weapon_vest.txt $redistdir\sprites
Copy-Item $spritesdir\weapon_knife.txt $redistdir\sprites
Copy-Item $spritesdir\weapon_9mmhandgun.txt $redistdir\sprites
Copy-Item $spritesdir\weapon_rpg.txt $redistdir\sprites
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
Copy-Item $mapsdir\stalkyard.wpt $redistdir\maps
Copy-Item $mapsdir\boot_camp.wpt $redistdir\maps
# Compile-Map "cir_stalkyard"

# Compile sounds
Remove-Item $redistdir\sound\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sound\\* -Recurse -Force -ErrorAction Ignore
Compile-Sound "hhg.mp3" 2.0 "sound\holy_handgrenade.wav"
Compile-Sound "alive.wav" 1.5 "sound\vest_alive.wav"
Copy-Item $sounddir\clustergrenades_selected.wav $redistdir\sound
Copy-Item $sounddir\grapple_deploy.wav $redistdir\sound
Copy-Item $sounddir\grapple_hit.wav $redistdir\sound
Copy-Item $sounddir\handgun_bond.wav $redistdir\sound
Copy-Item $sounddir\handgun_selected.wav $redistdir\sound
Copy-Item $sounddir\handgun_silenced.wav $redistdir\sound
Copy-Item $sounddir\handgun.wav $redistdir\sound
Copy-Item $sounddir\vest_attack.wav $redistdir\sound
Copy-Item $sounddir\vest_equip.wav $redistdir\sound
Copy-Item $sounddir\vest_selected.wav $redistdir\sound
New-Item -ItemType directory -Path $redistdir\sound\weapons
Copy-Item $sounddir\explode3.wav $redistdir\sound\weapons
Copy-Item $sounddir\explode4.wav $redistdir\sound\weapons
Copy-Item $sounddir\explode5.wav $redistdir\sound\weapons
Copy-Item $sounddir\knife_selected.wav $redistdir\sound
Compile-Sound "buddha.wav" 1.0 "sound\knife_thecore.wav" "wav" 0 3
Copy-Item $sounddir\knife_miss2.wav $redistdir\sound
Copy-Item $sounddir\hd\knife_miss2.wav $redisthddir\sound
Copy-Item $sounddir\knife_hit_flesh1.wav $redistdir\sound
Copy-Item $sounddir\knife_hit_flesh2.wav $redistdir\sound
Copy-Item $sounddir\knife_hit_wall1.wav $redistdir\sound
Copy-Item $sounddir\knife_hit_wall2.wav $redistdir\sound
Compile-Sound "limp.wav" 1.0 "media\gamestartup.mp3" "mp3"
Compile-Sound "zeke.mp3" 1.0 "sound\crowbar_zeke.wav" "wav" 2 6
Copy-Item $sounddir\crowbar_selected.wav $redistdir\sound
Copy-Item $sounddir\cbar_hit1.wav $redistdir\sound
Copy-Item $sounddir\cbar_hitbod1.wav $redistdir\sound
Copy-Item $sounddir\cbar_hitbod2.wav $redistdir\sound
Copy-Item $sounddir\cbar_hitbod3.wav $redistdir\sound
Copy-Item $sounddir\talk.wav $redistdir\sound
Copy-Item $sounddir\wpn_hudoff.wav $redistdir\sound
Copy-Item $sounddir\wpn_hudon.wav $redistdir\sound
Copy-Item $sounddir\wpn_moveselect.wav $redistdir\sound
Copy-Item $sounddir\wpn_select.wav $redistdir\sound
Compile-Sound "rocket1.wav" 1.0 "sound\rocket1.wav" "wav" 0 2
Copy-Item $sounddir\rpg_selected.wav $redistdir\sound
Compile-Sound "rocket_1.mp3" 2.0 "sound\rpg_igotone.wav" "wav" 0 4
Copy-Item $sounddir\tripmine_selected.wav $redistdir\sound
Copy-Item $sounddir\mine_activate.wav $redistdir\sound

# Prepare distribution folders
Remove-Item $icedir\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $icedsdir\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $icehddir\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $icedshddir\\* -Recurse -Force -ErrorAction Ignore

if (!(Test-Path $icedir)) {
    New-Item -ItemType directory -Path $icedir
}
if (!(Test-Path $icedsdir)) {
    New-Item -ItemType directory -Path $icedsdir
}

if (!(Test-Path $icehddir)) {
    New-Item -ItemType directory -Path $icehddir
}
if (!(Test-Path $icedshddir)) {
    New-Item -ItemType directory -Path $icedshddir
}

Copy-Item $redistdir\\* $icedir -Recurse -Force
Copy-Item $redistdir\\* $icedsdir -Recurse -Force
Copy-Item $redisthddir\\* $icehddir -Recurse -Force
Copy-Item $redisthddir\\* $icedshddir -Recurse -Force

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

if ($teamplay) {
    "mp_teamplay 1" | Add-Content $icedir\listenserver.cfg
}

for ($bot = 0; $bot -lt $bots; $bot++) {
    "addbot 5" | Add-Content $icedir\grave_bot.cfg
    "pause 3" | Add-Content $icedir\grave_bot.cfg
}

if ($verifyfiles) {
    Test-Manifest "$driveletter\manifest" $redistdir
    Test-Manifest "$driveletter\manifest_hd" $redisthddir
}

function PAK-File {
    param (
        $targets
    )

    Copy-Item $driveletter\bin\qpakman.exe $icedir -Force
    Set-Location -Path $icedir
    $folders = [String]::Join(" ", $targets)
    $in = ".\qpakman.exe ${folders} -o pak0.pak"
    echo "Creating pak0 file..."
    $out = iex $in | Out-String

    # qpakman does not exit with failure.
    if ($out -match '[1-9] failures' -or $out.Contains("FAILURE")) {
        echo "$out> Could not create pak file."
        exit
    }

    foreach ($folder in $targets) {
        Remove-Item "${icedir}\${folder}" -Recurse -Force
    }
    Remove-Item "${icedir}\qpakman.exe"
}

PAK-File @("models", "sound", "sprites")

if (!$dedicatedserver) {
    Launch-HL $launch $bots
} else {
    Launch-HLDS $launch $bots
}
