#Requires -Version 7.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Build Cold Ice GoldSrc Sound"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
}
Set-ConsoleColor 'DarkCyan' 'White'

$Config = @{ }

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    }
}

Import-Module $PSScriptRoot\powershell\Compile-Sound.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

$soundDir = "${RootDir}\sound"

Remove-Item $redistDir\sound\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sound\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\media\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\sound -Force -ErrorAction Ignore
Remove-Item $redisthddir\sound -Force -ErrorAction Ignore
Remove-Item $redistDir\media -Force -ErrorAction Ignore
[void](New-Item -ItemType directory -Path $redistDir\sound)
[void](New-Item -ItemType directory -Path $redisthddir\sound)
[void](New-Item -ItemType directory -Path $redistDir\media)

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
Compile-Sound $binDir $redistDir $soundDir "i-am-turok.mp3" 1.5 "sound\mag60_turok.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "hell-yeah_dBN35mW.mp3" 1.5 "sound\chaingun_hellyeah.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "team-fortress-2-heavy-oh-this-is-bad.mp3" 1.0 "sound\glauncher_bad.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "this-is-hans-gruber.wav" 1.25 "sound\smg_selected.wav" "wav" 1.5 3
Compile-Sound $binDir $redistDir $soundDir "8e8118_counter_strike_go_go_go_sound_effect.mp3" 1.25 "sound\usas_gogogo.wav" "wav"
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
Copy-Item $soundDir\decoy_selected.wav $redistdir\sound
Copy-Item $soundDir\decoy_pushthatbutton.wav $redistdir\sound
Copy-Item $soundDir\mag60_fire.wav $redistdir\sound
Copy-Item $soundDir\mag60_selected.wav $redistdir\sound
Copy-Item $soundDir\chaingun_fire.wav $redistdir\sound
Copy-Item $soundDir\chaingun_spinup.wav $redistdir\sound
Copy-Item $soundDir\chaingun_spindown.wav $redistdir\sound
Copy-Item $soundDir\chaingun_selected.wav $redistdir\sound
Copy-Item $soundDir\chaingun_reload.wav $redistdir\sound
Copy-Item $soundDir\glauncher_selected.wav $redistdir\sound
Copy-Item $soundDir\glauncher_reload.wav $redistdir\sound
Copy-Item $soundDir\smg_fire.wav $redistdir\sound
Copy-Item $soundDir\smg_select.wav $redistdir\sound
Copy-Item $soundDir\usas_selected.wav $redistdir\sound
Copy-Item $soundDir\usas_fire.wav $redistdir\sound
Copy-Item $soundDir\usas_cock.wav $redistdir\sound
Copy-Item $soundDir\usas_release.wav $redistdir\sound
Copy-Item $soundDir\usas_insert.wav $redistdir\sound

Set-Location -Path ${PSScriptRoot}