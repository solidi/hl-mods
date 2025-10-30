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
[bool]$clean = $false

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Clean") {
        $clean = $true
        echo "rebuilding all sounds..."
    }
}

$Host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Sound"

Import-Module $PSScriptRoot\powershell\Compile-Sound.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

$soundDir = "${RootDir}\sound"

if ($clean -eq $true) {
    Remove-Item $redistDir\sound\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redisthddir\sound\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redistDir\media\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redistDir\sound -Force -ErrorAction Ignore
    Remove-Item $redisthddir\sound -Force -ErrorAction Ignore
    Remove-Item $redistDir\media -Force -ErrorAction Ignore
    [void](New-Item -ItemType directory -Path $redistDir\sound)
    [void](New-Item -ItemType directory -Path $redisthddir\sound)
    [void](New-Item -ItemType directory -Path $redistdir\sound\weapons)
    [void](New-Item -ItemType directory -Path $redistdir\sound\player)
    [void](New-Item -ItemType directory -Path $redistdir\sound\hev)
    [void](New-Item -ItemType directory -Path $redistDir\media)
    [void](New-Item -ItemType directory -Path $redistDir\sound\ui)
    [void](New-Item -ItemType directory -Path $redistDir\sound\comet)
    [void](New-Item -ItemType directory -Path $redistDir\sound\panthereye)
}

try {
Compile-Sound $binDir $redistDir $soundDir "hhg.mp3" 2.0 "sound\holy_handgrenade.wav" "wav" 0 2.8
Compile-Sound $binDir $redistDir $soundDir "leroy.swf.mp3" 1.0 "sound\vest_attack.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "alive.wav" 2.0 "sound\vest_alive.wav" "wav" 1 5
Compile-Sound $binDir $redistDir $soundDir "buddha.wav" 1.0 "sound\knife_thecore.wav" "wav" 0 3
# Compile-Sound $binDir $redistDir $soundDir "limp.wav" 1.0 "media\gamestartup.mp3" "mp3"
Compile-Sound $binDir $redistDir $soundDir "zeke.mp3" 1.0 "sound\crowbar_zeke.wav" "wav" 2 6
Compile-Sound $binDir $redistDir $soundDir "rocket1.wav" 1.0 "sound\rocket1.wav" "wav" 0 1.6
Compile-Sound $binDir $redistDir $soundDir "rocket_1.mp3" 2.0 "sound\rpg_igotone.wav" "wav" 0 3.75
Compile-Sound $binDir $redistDir $soundDir "yakety-sax-music.mp3" 1.5 "sound\chumtoad_release.wav" "wav" 0 6
Compile-Sound $binDir $redistDir $soundDir "target-to-destroy.mp3" 1.0 "sound\rifle_destroy.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "139-item-catch.mp3" 1.0 "sound\boltgun_gotitem.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "excellent.mp3" 1.0 "sound\railgun_selected.wav" "wav"
Compile-Sound $binDir $redistdir $soundDir "m2burnbaby.mp3" 1.0 "sound\cannon_burn.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "i-am-turok.mp3" 1.5 "sound\mag60_turok.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "hell-yeah_dBN35mW.mp3" 1.5 "sound\chaingun_hellyeah.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "team-fortress-2-heavy-oh-this-is-bad.mp3" 1.0 "sound\glauncher_bad.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "this-is-hans-gruber.wav" 1.25 "sound\smg_selected.wav" "wav" 1.5 3.2
Compile-Sound $binDir $redistDir $soundDir "8e8118_counter_strike_go_go_go_sound_effect.mp3" 1.25 "sound\usas_gogogo.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "manos.m4a" 5.5 "sound\fists_selected.wav" "wav" 1 5
Compile-Sound $binDir $redistDir $soundDir "punch_hit_sfx.mp3" 1.0 "sound\fists_hit.wav" "wav" 0.25 1.5
Compile-Sound $binDir $redistDir $soundDir "punch_swoosh_sfx.mp3" 2.0 "sound\fists_miss.wav" "wav" 0.2 0.55
Compile-Sound $binDir $redistDir $soundDir "pull_back.mp3" 1.75 "sound\pull_back.wav" "wav" 1.25 3
Compile-Sound $binDir $redistDir $soundDir "chainsaw_E069GVr.mp3" 1.75 "sound\chainsaw_selected.wav" "wav" 0 3
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson.wav" "wav" 9.5 11.5
Compile-Sound $binDir $redistDir $soundDir "clint-eastwood.mp3" 2.0 "sound\357_selected.wav" "wav" 0 4.5
Compile-Sound $binDir $redistDir $soundDir "family-feud-good-answer.mp3" 2.0 "sound\point.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "ghostbusters_eNjs1Aq.mp3" 1.0 "sound\egon_selected.wav" "wav" 0 5
Compile-Sound $binDir $redistDir $soundDir "ghostbusters-bad.mp3" 2.0 "sound\egon_switch.wav" "wav" 3.5 6
Compile-Sound $binDir $redistDir $soundDir "boomstick.mp3" 1.0 "sound\shotgun_boomstick.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "modern-warfare-2-tactical-nuke-sound.mp3" 1.0 "sound\nuke_selected.wav" "wav" 0 2.5
Compile-Sound $binDir $redistDir $soundDir "nuke_explosion.mp3" 2.0 "sound\nuke_explosion.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "laser-lips1.mp3" 1.0 "sound\gauss_selected.wav" "wav" 1 4
Compile-Sound $binDir $redistDir $soundDir "the-five-notes.mp3" 1.0 "sound\hgun_selected.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "expedientes-secretos-x-musica22.mp3" 1.0 "sound\squeak_selected.wav" "wav" 0 8
Compile-Sound $binDir $redistDir $soundDir "ryu_shoryuken.mp3" 5.5 "sound\fists_shoryuken.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson_shutup.wav" "wav" 4.0 7.0
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson_moneyout.wav" "wav" 7.0 8.5
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson_moneyall.wav" "wav" 12.0 14.5
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson_comeon.wav" "wav" 18 19
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson_buddy.wav" "wav" 28 29.5
Compile-Sound $binDir $redistDir $soundDir "cta-samuel.mp3" 6.5 "sound\12gauge_jackson_dontstallme.wav" "wav" 38 42.0
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_nolossoflife.wav" "wav" 17 22
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_nicesuit.wav" "wav" 71 72
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_doitmyself.wav" "wav" 77 79
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_shes.wav" "wav" 84 85.5
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_nolossoflife.wav" "wav" 17 22.5
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 20dB "sound\smg_gruber_shootglass.wav" "wav" 93 95
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_timemagazine.wav" "wav" 118 120
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 30dB "sound\smg_gruber_hohoho.wav" "wav" 125 128
Compile-Sound $binDir $redistDir $soundDir "the-best-of-hans-gruber.mp3" 25dB "sound\smg_gruber_troublesome.wav" "wav" 142.5 144.5
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_music.wav" "wav" 0 3.5
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_suckaheads.wav" "wav" 19 24
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_arrangement.wav" "wav" 35.5 37
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_usethem.wav" "wav" 37.75 40.5
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_frost.wav" "wav" 53.5 55
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_nature.wav" "wav" 75 77
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_capable.wav" "wav" 77.5 79.5
Compile-Sound $binDir $redistDir $soundDir "blade-10-best-quotes.mp3" 1.5 "sound\mag60_blade_uphill.wav" "wav" 89 91.5
Compile-Sound $binDir $redistDir $soundDir "blade-another-10-best-quotes.mp3" 1.5 "sound\mag60_blade_topping.wav" "wav" 9.5 12
Compile-Sound $binDir $redistDir $soundDir "blade-another-10-best-quotes.mp3" 1.5 "sound\mag60_blade_trigger.wav" "wav" 16 20
Compile-Sound $binDir $redistDir $soundDir "blade-another-10-best-quotes.mp3" 1.5 "sound\mag60_blade_pass.wav" "wav" 37 38.5
Compile-Sound $binDir $redistDir $soundDir "blade-another-10-best-quotes.mp3" 1.5 "sound\mag60_blade_dead.wav" "wav" 48.5 54
Compile-Sound $binDir $redistDir $soundDir "dodge_bullets.wav" 1.0 "sound\deagle_selected.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "freezing-sound-effect.mp3" 2.0 "sound\freezing.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "phasers.mp3" 1.5 "sound\freezegun_deploy.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "slide_on_gravel.mp3" 2.0 "sound\slide_on_gravel.wav" "wav" 12.25 13.5
Compile-Sound $binDir $redistDir $soundDir "fire1.wav" 1.0 "sound\fire1.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "ut-ludicrous-kill-sound.mp3" 2.0 "sound\ludicrouskill.wav" "wav" 0.2 4.4
Compile-Sound $binDir $redistDir $soundDir "ut-holy-shit-sound-effect.mp3" 1.0 "sound\holyshitkill.wav" "wav" 1.0 4.8
Compile-Sound $binDir $redistDir $soundDir "what-the-f.mp3" 2.0 "sound\wtfkill.wav" "wav" 0.3 2.3
Compile-Sound $binDir $redistDir $soundDir "shart-sound-effect.mp3" 2.0 "sound\shart.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "delicious.mp3" 1.0 "sound\delicious.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "hohoho.mp3" 1.0 "sound\hohoho.wav" "wav" 9 12
Compile-Sound $binDir $redistDir $soundDir "sleighbell.mp3" 1.0 "sound\sleighbell.wav" "wav" 0 3
Compile-Sound $binDir $redistDir $soundDir "merrychristmas.mp3" 1.0 "sound\merrychristmas.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "StarCraft-2-Firebat-Quotes.mp3" 1.0 "sound\dual_flamethrower_selected.wav" "wav" 44.5 47.5
Compile-Sound $binDir $redistDir $soundDir "do_you_like_to_play_with_fire.mp3" 1.0 "sound\flamethrower_selected.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "helloo-imbecile.mp3" 1.0 "sound\portalgun_selected.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "votegame.mp3" 2.5 "sound\votegame.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "votemap.mp3" 2.5 "sound\votemap.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "greatjob.mp3" 2.5 "sound\greatjob.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "votestarted.mp3" 2.5 "sound\votestarted.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "votemutator.mp3" 2.5 "sound\votemutator.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "ryu_hurricane_kick.mp3" 3.5 "sound\fists_hurricane.wav" "wav" 0 1.25
Compile-Sound $binDir $redistDir $soundDir "I_am_proud_to_serve_and_proud_to_die_male.mp3" 1.0 "sound\taunt01.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "Nothing_can_stop_me_male.mp3" 1.0 "sound\taunt02.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "You_died_a_horrible_death_male.mp3" 1.0 "sound\taunt03.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "Another_body_for_the_pile_male.mp3" 1.0 "sound\taunt04.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "Nice_try_now_die_male.mp3" 1.0 "sound\taunt05.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-android-notifications-pixie-dust.mp3" 1.0 "sound\notify1.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-discord-message.mp3" 1.0 "sound\notify2.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-facebook-chat.mp3" 1.0 "sound\notify3.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-facebook-message.mp3" 1.0 "sound\notify4.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-google-meet-ask-to-join-sound.mp3" 1.0 "sound\notify5.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-icq-old-sound.mp3" 1.0 "sound\notify6.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-iphone-message-swoosh.mp3" 1.0 "sound\notify7.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-messenger-ringtone.mp3" 1.0 "sound\notify8.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-old-aol-instant-messenger-aim.mp3" 1.0 "sound\notify9.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-snapchat_notification.mp3" 1.0 "sound\notify10.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-steam-message-old.mp3" 1.0 "sound\notify11.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-steam-message.mp3" 1.0 "sound\notify12.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-windows-xp-error.mp3" 1.0 "sound\notify13.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-windows-2000-error.mp3" 1.0 "sound\notify14.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-windows-7-error.mp3" 1.0 "sound\notify15.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-windows-10-error.mp3" 1.0 "sound\notify16.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-iphone.mp3" 1.0 "sound\notify17.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-samsung.mp3" 1.0 "sound\notify18.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-windows-10.mp3" 1.0 "sound\notify19.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-ding-vibrate.mp3" 1.0 "sound\notify20.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-zoom.mp3" 1.0 "sound\notify21.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-skype.mp3" 1.0 "sound\notify22.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "notify-video-call.mp3" 1.0 "sound\notify23.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "ding-sound-effect_2.mp3" 1.0 "sound\ding.wav" "wav" 0 2
Compile-Sound $binDir $redistDir $soundDir "perfect-fart.mp3" 1.0 "sound\fart.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "064-laser-thum_hYpSdXS.mp3" 1.0 "sound\zapgun.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "heavenly-choir-crowd-react-w.mp3" 1.0 "sound\heaven.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "ode-to-joy.mp3" 1.0 "sound\odetojoy.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "nap-kehn-storie.mp3" 2.0 "sound\napkin_story.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "engineer_gunslinger.mp3" 1.0 "sound\dual_sawedoff_selected.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "Smoking_Sound_Effect.mp3" 1.0 "sound\smoking.wav" "wav" 5 9
Compile-Sound $binDir $redistDir $soundDir "Drinking_Sound_Effect.mp3" 1.0 "sound\drinking.wav" "wav" 1 4
Compile-Sound $binDir $redistDir $soundDir "round_over.mp3" 1.0 "sound\round_over.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "horse-neigh-390297.mp3" 1.0 "sound\horse_neigh.wav" "wav"
Compile-Sound $binDir $redistDir $soundDir "chicken_1.mp3" 1.0 "sound\chicken.wav" "wav"
}
catch
{
    Set-Location -Path ${PSScriptRoot}
    Write-Error "$($_.Exception.Message)"
}

Write-Output "Copying sound files..."
Copy-Item $soundDir\clustergrenades_selected.wav $redistdir\sound
Copy-Item $soundDir\grapple_deploy.wav $redistdir\sound
Copy-Item $soundDir\grapple_hit.wav $redistdir\sound
Copy-Item $soundDir\handgun_bond.wav $redistdir\sound
Copy-Item $soundDir\handgun_selected.wav $redistdir\sound
Copy-Item $soundDir\handgun_silenced.wav $redistdir\sound
Copy-Item $soundDir\handgun.wav $redistdir\sound
Copy-Item $soundDir\vest_equip.wav $redistdir\sound
Copy-Item $soundDir\vest_selected.wav $redistdir\sound
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
Copy-Item $soundDir\cannon_pump.wav $redistdir\sound
Copy-Item $soundDir\cannon_loadammo.wav $redistdir\sound
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
Copy-Item $soundDir\fists_hitbod.wav $redistdir\sound
Copy-Item $soundDir\wrench_selected.wav $redistdir\sound
Copy-Item $soundDir\wrench_hit1.wav $redistdir\sound
Copy-Item $soundDir\wrench_hit2.wav $redistdir\sound
Copy-Item $soundDir\wrench_hitbod1.wav $redistdir\sound
Copy-Item $soundDir\wrench_hitbod2.wav $redistdir\sound
Copy-Item $soundDir\wrench_hitbod3.wav $redistdir\sound
Copy-Item $soundDir\wrench_miss1.wav $redistdir\sound
Copy-Item $soundDir\wrench_getsome.wav $redistdir\sound
Copy-Item $soundDir\wrench_draw.wav $redistdir\sound
Copy-Item $soundDir\snowball_throw.wav $redistdir\sound
Copy-Item $soundDir\snowball_miss.wav $redistdir\sound
Copy-Item $soundDir\snowball_hitbod.wav $redistdir\sound
Copy-Item $soundDir\snowball_selected.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_attack1_start.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_attack1_loop.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_attack1_end.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_draw.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_hit.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_slash.wav $redistdir\sound
Copy-Item $soundDir\chainsaw_idle.wav $redistdir\sound
Copy-Item $soundDir\12gauge_selected.wav $redistdir\sound
Copy-Item $soundDir\12gauge_fire.wav $redistdir\sound
Copy-Item $soundDir\12gauge_cock.wav $redistdir\sound
Copy-Item $soundDir\ironsight_on.wav $redistdir\sound
Copy-Item $soundDir\ironsight_off.wav $redistdir\sound
Copy-Item $soundDir\revolver_fire.wav $redistdir\sound
Copy-Item $soundDir\revolver_draw.wav $redistdir\sound
Copy-Item $soundDir\default_draw.wav $redistdir\sound
Copy-Item $soundDir\m16_boltpull.wav $redistdir\sound
Copy-Item $soundDir\m16_close.wav $redistdir\sound
Copy-Item $soundDir\m16_draw_heavy.wav $redistdir\sound
Copy-Item $soundDir\m16_glauncher.wav $redistdir\sound
Copy-Item $soundDir\m16_glauncher2.wav $redistdir\sound
Copy-Item $soundDir\m16_hks1.wav $redistdir\sound
Copy-Item $soundDir\m16_hks2.wav $redistdir\sound
Copy-Item $soundDir\m16_hks3.wav $redistdir\sound
Copy-Item $soundDir\m16_hold.wav $redistdir\sound
Copy-Item $soundDir\m16_insert.wav $redistdir\sound
Copy-Item $soundDir\m16_magin.wav $redistdir\sound
Copy-Item $soundDir\m16_magout.wav $redistdir\sound
Copy-Item $soundDir\m16_magplace.wav $redistdir\sound
Copy-Item $soundDir\m16_open.wav $redistdir\sound
Copy-Item $soundDir\m16_selected.wav $redistdir\sound
Copy-Item $soundDir\shotgun_deploy.wav $redistdir\sound
Copy-Item $soundDir\shotgun_selected.wav $redistdir\sound
Copy-Item $soundDir\pinpull.wav $redistdir\sound
Copy-Item $soundDir\grenade_throw.wav $redistdir\sound
Copy-Item $soundDir\nuke_draw.wav $redistdir\sound
Copy-Item $soundDir\kick.wav $redistdir\sound
Copy-Item $soundDir\deagle_deploy.wav $redistdir\sound
Copy-Item $soundDir\deagle_reload1.wav $redistdir\sound
Copy-Item $soundDir\deagle_reload2.wav $redistdir\sound
Copy-Item $soundDir\deagle_reload3.wav $redistdir\sound
Copy-Item $soundDir\deagle_fire.wav $redistdir\sound
Copy-Item $soundDir\plasma_hitwall.wav $redistdir\sound
Copy-Item $soundDir\freezegun_fire.wav $redistdir\sound
Copy-Item $soundDir\freezegun_reload.wav $redistdir\sound
Copy-Item $soundDir\freezegun_spin.wav $redistdir\sound
Copy-Item $soundDir\freezegun_draw.wav $redistdir\sound
Copy-Item $soundDir\freezegun_idle.wav $redistdir\sound
Copy-Item $soundDir\freezegun_clipin1.wav $redistdir\sound
Copy-Item $soundDir\freezegun_clipin2.wav $redistdir\sound
Copy-Item $soundDir\freezegun_clipout.wav $redistdir\sound
Copy-Item $soundDir\pl_snow1.wav $redistdir\sound\player\
Copy-Item $soundDir\pl_snow2.wav $redistdir\sound\player\
Copy-Item $soundDir\pl_snow3.wav $redistdir\sound\player\
Copy-Item $soundDir\pl_snow4.wav $redistdir\sound\player\
Copy-Item $soundDir\doublekill.wav $redistdir\sound
Copy-Item $soundDir\multikill.wav $redistdir\sound
Copy-Item $soundDir\ultrakill.wav $redistdir\sound
Copy-Item $soundDir\monsterkill.wav $redistdir\sound
Copy-Item $soundDir\wallclimb.wav $redistdir\sound
Copy-Item $soundDir\prepareforbattle.wav $redistdir\sound
Copy-Item $soundDir\outstanding.wav $redistdir\sound
Copy-Item $soundDir\humiliatingdefeat.wav $redistdir\sound
Copy-Item $soundDir\massacre.wav $redistdir\sound
Copy-Item $soundDir\killingmachine.wav $redistdir\sound
Copy-Item $soundDir\pickupyourweaponsandfight.wav $redistdir\sound
Copy-Item $soundDir\youarethelastmanstanding.wav $redistdir\sound
Copy-Item $soundDir\preparetofight.wav $redistdir\sound
Copy-Item $soundDir\flame_hitwall.wav $redistdir\sound
Copy-Item $soundDir\flamethrower_reload.wav $redistdir\sound
Copy-Item $soundDir\flamethrower.wav $redistdir\sound
Copy-Item $soundDir\flamethrowerend.wav $redistdir\sound
Copy-Item $soundDir\flamerun.wav $redistdir\sound
Copy-Item $soundDir\flameburst.wav $redistdir\sound
Copy-Item $soundDir\fire_loop.wav $redistdir\sound
Copy-Item $soundDir\pullbolt.wav $redistdir\sound
Copy-Item $soundDir\portalgun_shoot_blue.wav $redistdir\sound
Copy-Item $soundDir\portalgun_shoot_red.wav $redistdir\sound
Copy-Item $soundDir\portal_enter1.wav $redistdir\sound
Copy-Item $soundDir\portal_enter2.wav $redistdir\sound
Copy-Item $soundDir\takenlead.wav $redistdir\sound
Copy-Item $soundDir\tiedlead.wav $redistdir\sound
Copy-Item $soundDir\lostlead.wav $redistdir\sound
Copy-Item $soundDir\whickedsick.wav $redistdir\sound
Copy-Item $soundDir\unstoppable2.wav $redistdir\sound
Copy-Item $soundDir\maniac.wav $redistdir\sound
Copy-Item $soundDir\impressive.wav $redistdir\sound
Copy-Item $soundDir\excellent.wav $redistdir\sound
Copy-Item $soundDir\bullseye.wav $redistdir\sound
Copy-Item $soundDir\headshot.wav $redistdir\sound
Copy-Item $soundDir\firstblood.wav $redistdir\sound
Copy-Item $soundDir\sawedoff_click.wav $redistdir\sound
Copy-Item $soundDir\sawedoff.wav $redistdir\sound
Copy-Item $soundDir\goldeneye_respawn.wav $redistdir\sound
Copy-Item $soundDir\taunt_blah.wav $redistdir\sound
Copy-Item $soundDir\ctf_flag_taken.wav $redistdir\sound
Copy-Item $soundDir\ctf_flag_capture.wav $redistdir\sound
Copy-Item $soundDir\wavebegins.wav $redistdir\sound
Copy-Item $soundDir\waveended.wav $redistdir\sound
Copy-Item $soundDir\sprayer.wav $redistdir\sound
Copy-Item $soundDir\grunch.wav $redistdir\sound
Copy-Item $soundDir\snowfall2.wav $redistdir\sound

Copy-Item $soundDir\valve_sound.wav $redistdir\sound\ui\

Copy-Item $soundDir\sentences.txt $redistdir\sound
Copy-Item $soundDir\materials.txt $redistdir\sound

# Sound packs
Write-Output "Copying voice-overs..."
Copy-Item -Recurse -Force -Path $soundDir\hev\* -Destination $redistdir\sound\hev
Write-Output "Copying media..."
Copy-Item -Recurse -Force -Path $soundDir\media\* -Destination $redistdir\media
Write-Output "Copying monster sounds..."
Copy-Item -Recurse -Force -Path $soundDir\panthereye\* -Destination $redistdir\sound\panthereye
Write-Output "Copying map sounds..."
Copy-Item -Recurse -Force -Path $soundDir\comet\* -Destination $redistdir\sound\comet

Set-Location -Path ${PSScriptRoot}
