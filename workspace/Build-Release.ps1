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

[string]$configFile = "Config.Docker"
[int]$verifyFiles = 1

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "SkipVerify") {
        $verifyFiles = 0
        echo "skipping file verification..."
    }
}

Import-Module $PSScriptRoot\powershell\Compile-Model.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Invert-Skin.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Sprite.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Wad.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Font.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Map.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Compile-Sound.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Test-Manifest.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\PAK-File.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Zip-Release.psm1 -Force -DisableNameChecking
. ("$PSScriptRoot\$configFile.ps1")

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir']

Remove-Item $redistDir\debug.log -Force -ErrorAction Ignore
Remove-Item $redistDir\qconsole.log -Force -ErrorAction Ignore
Remove-Item $redistDir\steam_appid.txt -Force -ErrorAction Ignore
Remove-Item $redistDir\htmlcache -Recurse -Force -ErrorAction Ignore

Remove-Item $redistDir\dlls\ice.dylib -Force -ErrorAction Ignore
Remove-Item $redistDir\dlls\ice.so -Force -ErrorAction Ignore
Remove-Item $redistDir\cl_dlls\client.dylib -Force -ErrorAction Ignore
Remove-Item $redistDir\cl_dlls\client.so -Force -ErrorAction Ignore
Remove-Item $redistDir\dlls\gravebot.so -Force -ErrorAction Ignore

# Copy Windows DLLs?
Copy-Item ${RootDir}\libs\dlls\ice.dylib $redistDir\dlls
Copy-Item ${RootDir}\libs\dlls\ice.so $redistDir\dlls
Copy-Item ${RootDir}\libs\cl_dlls\client.dylib $redistDir\cl_dlls
Copy-Item ${RootDir}\libs\cl_dlls\client.so $redistDir\cl_dlls
Copy-Item ${RootDir}\libs\dlls\gravebot.so $redistDir\dlls

Remove-Item $redistDir\models\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\models\\* -Recurse -Force -ErrorAction Ignore

$modelsdir = "${rootDir}\models"

Invert-Skin $binDir "p_9mmhandgun" $modelsdir\hd
Invert-Skin $binDir "p_9mmhandguns" $modelsdir\hd
Invert-Skin $binDir "p_crossbow" $modelsdir\hd
Invert-Skin $binDir "p_grenade" $modelsdir\hd
Invert-Skin $binDir "p_knife" $modelsdir\hd
Invert-Skin $binDir "p_rpg" $modelsdir\hd
Invert-Skin $binDir "p_tripmine" $modelsdir\hd
Invert-Skin $binDir "rpgrocket" $modelsdir\hd
Invert-Skin $binDir "v_9mmhandgun" $modelsdir\hd
Invert-Skin $binDir "v_9mmhandguns" $modelsdir\hd
Invert-Skin $binDir "v_chumtoad" $modelsdir\hd
Invert-Skin $binDir "v_crossbow" $modelsdir\hd
Invert-Skin $binDir "v_crowbar" $modelsdir\hd
Invert-Skin $binDir "v_grenade" $modelsdir\hd
Invert-Skin $binDir "v_knife" $modelsdir\hd
Invert-Skin $binDir "v_rpg" $modelsdir\hd
Invert-Skin $binDir "v_tripmine" $modelsdir\hd
Invert-Skin $binDir "v_sniperrifle" $modelsdir\hd
Invert-Skin $binDir "v_vest_radio" $modelsdir\hd
Invert-Skin $binDir "w_9mmhandgun" $modelsdir\hd
Invert-Skin $binDir "w_9mmhandguns" $modelsdir\hd
Invert-Skin $binDir "w_bolt" $modelsdir\hd
Invert-Skin $binDir "w_crossbow" $modelsdir\hd
Invert-Skin $binDir "w_crowbar" $modelsdir\hd
Invert-Skin $binDir "w_grenade" $modelsdir\hd
Invert-Skin $binDir "w_knife" $modelsdir\hd
Invert-Skin $binDir "w_rpg" $modelsdir\hd
Invert-Skin $binDir "v_sniperrifle" $modelsdir\hd
Invert-Skin $binDir "p_sniperrifle" $modelsdir\hd
Invert-Skin $binDir "w_sniperrifle" $modelsdir\hd
Invert-Skin $binDir "p_9mmhandgun" $modelsdir
Invert-Skin $binDir "p_9mmhandguns" $modelsdir
Invert-Skin $binDir "p_chumtoad" $modelsdir
Invert-Skin $binDir "p_crossbow" $modelsdir
Invert-Skin $binDir "p_crowbar" $modelsdir
Invert-Skin $binDir "p_grenade" $modelsdir
Invert-Skin $binDir "p_knife" $modelsdir
Invert-Skin $binDir "p_railgun" $modelsdir
Invert-Skin $binDir "p_rpg" $modelsdir
Invert-Skin $binDir "p_sniperrifle" $modelsdir
Invert-Skin $binDir "p_tripmine" $modelsdir
Invert-Skin $binDir "p_vest" $modelsdir
Invert-Skin $binDir "rpgrocket" $modelsdir
Invert-Skin $binDir "v_9mmhandgun" $modelsdir
Invert-Skin $binDir "v_9mmhandguns" $modelsdir
Invert-Skin $binDir "v_chumtoad" $modelsdir
Invert-Skin $binDir "v_crossbow" $modelsdir
Invert-Skin $binDir "v_crowbar" $modelsdir
Invert-Skin $binDir "v_grenade" $modelsdir
Invert-Skin $binDir "v_knife" $modelsdir
Invert-Skin $binDir "v_railgun" $modelsdir
Invert-Skin $binDir "v_rpg" $modelsdir
Invert-Skin $binDir "v_sniperrifle" $modelsdir
Invert-Skin $binDir "v_tripmine" $modelsdir
Invert-Skin $binDir "v_vest_radio" $modelsdir
Invert-Skin $binDir "w_9mmhandgun" $modelsdir
Invert-Skin $binDir "w_9mmhandguns" $modelsdir
Invert-Skin $binDir "w_762shell" $modelsdir
Invert-Skin $binDir "w_bolt" $modelsdir
Invert-Skin $binDir "w_chumtoad" $modelsdir
Invert-Skin $binDir "w_chumtoad_nest" $modelsdir
Invert-Skin $binDir "w_crossbow" $modelsdir
Invert-Skin $binDir "w_crowbar" $modelsdir
Invert-Skin $binDir "w_grenade" $modelsdir
Invert-Skin $binDir "w_knife" $modelsdir
Invert-Skin $binDir "w_railgun" $modelsdir
Invert-Skin $binDir "w_rpg" $modelsdir
Invert-Skin $binDir "w_sniperrifle" $modelsdir
Invert-Skin $binDir "w_vest" $modelsdir
Invert-Skin $binDir "w_weaponbox" $modelsdir
Invert-Skin $binDir "v_cannon" $modelsdir
Invert-Skin $binDir "w_cannon" $modelsdir
Invert-Skin $binDir "p_cannon" $modelsdir

Compile-Model $binDir "v_9mmAR" $modelsdir $redistDir\models
Compile-Model $binDir "v_9mmAR" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_9mmar" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_shotgun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_vest" $modelsdir $redistDir\models
Compile-Model $binDir "v_vest_radio" $modelsdir $redistDir\models
Compile-Model $binDir "v_vest_radio" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_vest" $modelsdir $redistDir\models
Compile-Model $binDir "v_9mmhandgun" $modelsdir $redistDir\models
Compile-Model $binDir "v_9mmhandgun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_9mmhandguns" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_9mmhandguns" $modelsdir $redistDir\models
Compile-Model $binDir "p_9mmhandguns" $modelsdir $redistDir\models
Compile-Model $binDir "p_9mmhandgun" $modelsdir $redistDir\models
Compile-Model $binDir "p_9mmhandgun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_9mmhandguns" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_9mmhandgun" $modelsdir $redistDir\models
Compile-Model $binDir "w_9mmhandguns" $modelsdir $redistDir\models
Compile-Model $binDir "w_9mmhandgun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_9mmhandguns" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_grenade" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_grenade" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_grenade" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_grenade" $modelsdir $redistDir\models
Compile-Model $binDir "v_grenade" $modelsdir $redistDir\models
Compile-Model $binDir "w_grenade" $modelsdir $redistDir\models
Compile-Model $binDir "p_knife" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_knife" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_knife" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_knife" $modelsdir $redistDir\models
Compile-Model $binDir "v_knife" $modelsdir $redistDir\models
Compile-Model $binDir "w_knife" $modelsdir $redistDir\models
Compile-Model $binDir "v_crowbar" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_crowbar" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_crowbar" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_crowbar" $modelsdir $redistDir\models
Compile-Model $binDir "v_crowbar" $modelsdir $redistDir\models
Compile-Model $binDir "w_crowbar" $modelsdir $redistDir\models
Compile-Model $binDir "v_rpg" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_rpg" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_rpg" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_rpg" $modelsdir $redistDir\models
Compile-Model $binDir "p_rpg" $modelsdir $redistDir\models
Compile-Model $binDir "w_rpg" $modelsdir $redistDir\models
Compile-Model $binDir "rpgrocket" $modelsdir $redistDir\models
Compile-Model $binDir "rpgrocket" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_tripmine" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_tripmine" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_tripmine" $modelsdir $redistDir\models
Compile-Model $binDir "p_tripmine" $modelsdir $redistDir\models
Compile-Model $binDir "v_chumtoad" $modelsdir $redistDir\models
Compile-Model $binDir "w_chumtoad_nest" $modelsdir $redistDir\models
Compile-Model $binDir "p_chumtoad" $modelsdir $redistDir\models
Compile-Model $binDir "w_chumtoad" $modelsdir $redistDir\models
Compile-Model $binDir "v_chumtoad" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_sniperrifle" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_sniperrifle" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_sniperrifle" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_sniperrifle" $modelsdir $redistDir\models
Compile-Model $binDir "p_sniperrifle" $modelsdir $redistDir\models
Compile-Model $binDir "w_sniperrifle" $modelsdir $redistDir\models
Compile-Model $binDir "w_762shell" $modelsdir $redistDir\models
Compile-Model $binDir "v_crossbow" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_crossbow" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_crossbow" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_crossbow" $modelsdir $redistDir\models
Compile-Model $binDir "p_crossbow" $modelsdir $redistDir\models
Compile-Model $binDir "w_crossbow" $modelsdir $redistDir\models
Compile-Model $binDir "w_bolt" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_bolt" $modelsdir $redistDir\models
Compile-Model $binDir "w_railgun" $modelsdir $redistDir\models
Compile-Model $binDir "v_railgun" $modelsdir $redistDir\models
Compile-Model $binDir "p_railgun" $modelsdir $redistDir\models
Compile-Model $binDir "w_weaponbox" $modelsdir $redistDir\models
Compile-Model $binDir "w_runes" $modelsdir $redistDir\models
Compile-Model $binDir "v_cannon" $modelsdir $redistDir\models
Compile-Model $binDir "w_cannon" $modelsdir $redistDir\models
Compile-Model $binDir "p_cannon" $modelsdir $redistDir\models

$spritesDir = "${rootDir}\sprites"

Remove-Item $redistDir\sprites\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sprites\\* -Recurse -Force -ErrorAction Ignore

Compile-Sprite $binDir "muzzleflash1" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "muzzleflash2" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "zerogxplode" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "animglow01" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "xspark4" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "crosshairs" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "640hud1" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "640hud1" $spritesDir\hd $redisthddir\sprites
Compile-Sprite $binDir "640hud4" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "640hud4" $spritesDir\hd $redisthddir\sprites
Copy-Item $spritesDir\weapon_vest.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_knife.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_9mmhandgun.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_rpg.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_chumtoad.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_sniperrifle.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_railgun.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_cannon.txt $redistDir\sprites
Copy-Item $spritesDir\hud.txt $redistDir\sprites

$wadsDir = "${RootDir}\wads"

Remove-Item $redistDir\wads\\* -Recurse -Force -ErrorAction Ignore

Compile-Wad $binDir "coldice" $wadsDir $redistDir

Compile-Font $binDir $redistDir "Arial"

$mapsDir = "${RootDir}\maps"

Remove-Item $redistDir\maps\\* -Recurse -Force -ErrorAction Ignore

Compile-Map $binDir "yard" $mapsDir $redistDir $wadsDir
Copy-Item $mapsDir\stalkyard.wpt $redistDir\maps
Copy-Item $mapsDir\boot_camp.wpt $redistDir\maps

$soundDir = "${RootDir}\sound"

Remove-Item $redistDir\sound\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sound\\* -Recurse -Force -ErrorAction Ignore

Compile-Sound $binDir $redistDir $soundDir "hhg.mp3" 2.0 "sound\holy_handgrenade.wav"
Compile-Sound $binDir $redistDir $soundDir "alive.wav" 1.5 "sound\vest_alive.wav"
Compile-Sound $binDir $redistDir $soundDir "buddha.wav" 1.0 "sound\knife_thecore.wav" "wav" 0 3
Compile-Sound $binDir $redistDir $soundDir "limp.wav" 1.0 "media\gamestartup.mp3" "mp3"
Compile-Sound $binDir $redistDir $soundDir "zeke.mp3" 1.0 "sound\crowbar_zeke.wav" "wav" 2 6
Compile-Sound $binDir $redistDir $soundDir "rocket1.wav" 1.0 "sound\rocket1.wav" "wav" 0 2
Compile-Sound $binDir $redistDir $soundDir "rocket_1.mp3" 2.0 "sound\rpg_igotone.wav" "wav" 0 4
Compile-Sound $binDir $redistDir $soundDir "yakety-sax-music.mp3" 1.5 "sound\chumtoad_release.wav" "wav" 0 4
Compile-Sound $binDir $redistDir $soundDir "target-to-destroy.mp3" 1.0 "sound\rifle_destroy.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "139-item-catch.mp3" 1.0 "sound\boltgun_gotitem.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "excellent.mp3" 1.0 "sound\railgun_selected.wav" "wav"
Compile-Sound $binDir $redistdir $soundDir "m2burnbaby.mp3" 1.0 "sound\cannon_burn.wav" "wav"
Copy-Item $soundDir\clustergrenades_selected.wav $redistdir\sound
Copy-Item $soundDir\grapple_deploy.wav $redistdir\sound
Copy-Item $soundDir\grapple_hit.wav $redistdir\sound
Copy-Item $soundDir\handgun_bond.wav $redistdir\sound
Copy-Item $soundDir\handgun_selected.wav $redistdir\sound
Copy-Item $soundDir\handgun_silenced.wav $redistdir\sound
Copy-Item $soundDir\handgun.wav $redistdir\sound
Copy-Item $soundDir\vest_attack.wav $redistdir\sound
Copy-Item $soundDir\vest_equip.wav $redistdir\sound
Copy-Item $soundDir\vest_selected.wav $redistdir\sound
[void](New-Item -ItemType directory -Path $redistdir\sound\weapons)
Copy-Item $soundDir\explode3.wav $redistdir\sound\weapons
Copy-Item $soundDir\explode4.wav $redistdir\sound\weapons
Copy-Item $soundDir\explode5.wav $redistdir\sound\weapons
Copy-Item $soundDir\knife_selected.wav $redistdir\sound
Copy-Item $soundDir\knife_miss2.wav $redistdir\sound
Copy-Item $soundDir\hd\knife_miss2.wav $redisthddir\sound
Copy-Item $soundDir\knife_hit_flesh1.wav $redistdir\sound
Copy-Item $soundDir\knife_hit_flesh2.wav $redistdir\sound
Copy-Item $soundDir\knife_hit_wall1.wav $redistdir\sound
Copy-Item $soundDir\knife_hit_wall2.wav $redistdir\sound
Copy-Item $soundDir\crowbar_selected.wav $redistdir\sound
Copy-Item $soundDir\cbar_hit1.wav $redistdir\sound
Copy-Item $soundDir\cbar_hitbod1.wav $redistdir\sound
Copy-Item $soundDir\cbar_hitbod2.wav $redistdir\sound
Copy-Item $soundDir\cbar_hitbod3.wav $redistdir\sound
Copy-Item $soundDir\talk.wav $redistdir\sound
Copy-Item $soundDir\wpn_hudoff.wav $redistdir\sound
Copy-Item $soundDir\wpn_hudon.wav $redistdir\sound
Copy-Item $soundDir\wpn_moveselect.wav $redistdir\sound
Copy-Item $soundDir\wpn_select.wav $redistdir\sound
Copy-Item $soundDir\rpg_selected.wav $redistdir\sound
Copy-Item $soundDir\tripmine_selected.wav $redistdir\sound
Copy-Item $soundDir\mine_activate.wav $redistdir\sound
Copy-Item $soundDir\chumtoad_selected.wav $redistdir\sound
Copy-Item $soundDir\chumtoad_hunt1.wav $redistdir\sound
Copy-Item $soundDir\chumtoad_hunt2.wav $redistdir\sound
Copy-Item $soundDir\chumtoad_hunt3.wav $redistdir\sound
Copy-Item $soundDir\chumtoad_blast1.wav $redistdir\sound
Copy-Item $soundDir\chumtoad_bite.wav $redistdir\sound
Copy-Item $soundDir\rifle1.wav $redistdir\sound
Copy-Item $soundDir\rifle_selected.wav $redistdir\sound
Copy-Item $soundDir\rifle_reload_1.wav $redistdir\sound
Copy-Item $soundDir\rifle_reload_2.wav $redistdir\sound
Copy-Item $soundDir\rifle_zoomout.wav $redistdir\sound
Copy-Item $soundDir\boltgun_fire.wav $redistdir\sound
Copy-Item $soundDir\boltgun_selected.wav $redistdir\sound
Copy-Item $soundDir\railgun_fire.wav $redistdir\sound
Copy-Item $soundDir\rune_pickup.wav $redistdir\sound
Copy-Item $soundDir\cannon_selected.wav $redistdir\sound
Copy-Item $soundDir\cannon_fire.wav $redistdir\sound

if ($verifyfiles) {
    Test-Manifest "${RootDir}\manifest" $redistDir
    Test-Manifest "${RootDir}\manifest_hd" $redisthddir
}

PAK-File $binDir $redistDir @("models", "sound", "sprites")

Zip-Release $rootDir $redistDir $redistHdDir
