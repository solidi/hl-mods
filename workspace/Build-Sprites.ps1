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

# Colorize-Folder $binDir $spritesDir plasmablue5 "16,50,90" 100

Remove-Item $redistDir\sprites\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redisthddir\sprites\\* -Recurse -Force -ErrorAction Ignore
Remove-Item $redistDir\sprites -Force -ErrorAction Ignore
Remove-Item $redisthddir\sprites -Force -ErrorAction Ignore
[void](New-Item -ItemType directory -Path $redistDir\sprites)
[void](New-Item -ItemType directory -Path $redisthddir\sprites)

Compile-Sprite $binDir "muzzleflash1" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "muzzleflash2" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "muzzleflash3" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "zerogxplode" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "animglow01" $spritesDir $redistDir\sprites
Compile-Sprite $binDir "xspark4" $spritesDir $redistDir\sprites
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
Compile-Sprite $binDir "snowballhit" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "gunsmoke" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "smokeball2" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "nuke2" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "hotglow" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "muzzleflashplasma" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "particles_blue" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "plasmablue5" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "plasmatrail" $spritesDir $redistdir\sprites
Compile-Sprite $binDir "tsplasma" $spritesDir $redistdir\sprites
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
Copy-Item $spritesDir\weapon_dual_smg.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_dual_wrench.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_dual_usas.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_crowbar.txt $redistDir\sprites
Copy-Item $spritesDir\weapon_freezegun.txt $redistDir\sprites
Copy-Item $spritesDir\hud.txt $redistDir\sprites

Set-Location -Path ${PSScriptRoot}
