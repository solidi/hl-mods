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

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    }
}

$host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Sprites"

Import-Module $PSScriptRoot\powershell\Compile-Sprite.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"
$spritesDir = "${rootDir}\sprites"

# Colorize-Folder $binDir $spritesDir fire "0,113,230" 100
# exit

Remove-Item $redistDir\sprites\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sprites\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\sprites -Force -ErrorAction Ignore
Remove-Item $redisthddir\sprites -Force -ErrorAction Ignore
[void](New-Item -ItemType directory -Path $redistDir\sprites)
[void](New-Item -ItemType directory -Path $redisthddir\sprites)

try {
    Compile-Sprite $binDir "ice_muzzleflash1" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "ice_muzzleflash2" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "ice_muzzleflash3" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "ice_zerogxplode" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "animglow01" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "ice_xspark4" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "crosshairs" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "320hud2" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hud1" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hud1" $spritesDir\hd $redisthddir\sprites
    Compile-Sprite $binDir "640hud4" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hud4" $spritesDir\hd $redisthddir\sprites
    Compile-Sprite $binDir "640hud7" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof01" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof02" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof03" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof04" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof05" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof06" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof07" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof08" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof09" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof10" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof11" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof12" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof13" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "640hudof14" $spritesDir $redistDir\sprites
    Compile-Sprite $binDir "snowballhit" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "gunsmoke" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "smokeball2" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_nuke2" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "nuke2" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_hotglow" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_muzzleflashplasma" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "muzzleflashplasma" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_particles" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "particles" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_plasma5" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "plasma5" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_plasmatrail" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "plasmatrail" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "tsplasma" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "fire" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_fire" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "nuke_crosshair" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "sparks" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ice_sparks" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "lifebar" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "killspree" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "snowflake" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "rain" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "ripple" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "sanic" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "wallclimb" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "gameicons" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "voiceicon" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamesteam" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "null" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flameline" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "blacksmoke" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "black_smoke1" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamepart1" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamepart3" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamepart9" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamepart11" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamepart12" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "flamepart13" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "nuke_flicker" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "640hudrunes" $spritesDir $redistdir\sprites
    Compile-Sprite $binDir "gameicons2" $spritesDir $redistdir\sprites
    Copy-Item $spritesDir\weapon_vest.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_knife.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_9mmhandgun.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_rpg.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_chumtoad.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_sniperrifle.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_railgun.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_cannon.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_mag60.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_chaingun.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_glauncher.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_smg.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_usas.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_fists.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_wrench.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_snowball.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_chainsaw.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_12gauge.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_nuke.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_deagle.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_deagle.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_rpg.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_mag60.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_smg.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_wrench.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_usas.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_crowbar.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_freezegun.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_rocketcrowbar.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_railgun.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_gravitygun.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_flamethrower.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_flamethrower.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_ashpod.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_sawedoff.txt $redistDir\sprites
    Copy-Item $spritesDir\weapon_dual_sawedoff.txt $redistDir\sprites
    Copy-Item $spritesDir\hud.txt $redistDir\sprites
} catch {
    Write-Error "$($_.Exception.Message)"
} finally {
    Set-Location -Path ${PSScriptRoot}
}
