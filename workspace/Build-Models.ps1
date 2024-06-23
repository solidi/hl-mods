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
[string]$playerModel = ""
[string]$singleModel = ""
[string]$singleHdModel = ""

# https://stackoverflow.com/questions/27794898/powershell-pass-named-parameters-to-argumentlist
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "ConfigFile") {
        $configFile = $_.Split(' ')[1]
        . ("$PSScriptRoot\$configFile.ps1")
        echo "configuration file is $configFile..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Clean") {
        $clean = $true
        echo "rebuilding all models..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Player") {
        $playerModel = $_.Split(' ')[1]
        echo "building player $playerModel..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "Model") {
        $singleModel = $_.Split(' ')[1]
        echo "building model $singleModel..."
    } elseif ($_.Split(' ')[0].ToUpper() -eq "HdModel") {
        $singleHdModel = $_.Split(' ')[1]
        echo "building HD model $singleHdModel..."
    }
}

$host.UI.RawUI.WindowTitle = "Building $($Config['projectName']) Models"

Import-Module $PSScriptRoot\powershell\Compile-Model.psm1 -Force -DisableNameChecking
Import-Module $PSScriptRoot\powershell\Invert-Skin.psm1 -Force -DisableNameChecking

$rootDir = ${PSScriptRoot}.Trimend('\')
$redistDir = "${rootDir}\redist"
$redisthddir = "${rootDir}\redist_hd"
$binDir = $Config['binDir'] ?? "${rootDir}\bin"

if ($clean -eq $true) {
    Remove-Item $redistDir\models\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redisthddir\models\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $redistDir\models -Force -ErrorAction Ignore
    Remove-Item $redisthddir\models -Force -ErrorAction Ignore
    [void](New-Item -ItemType directory -Path $redistDir\models)
    [void](New-Item -ItemType directory -Path $redistDir\models\player)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\alpina)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\army)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\assassin)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\baer)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\barney)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\commando)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\frost)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\grunt)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\hhev)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\holo)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\hotfire)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\iceman)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\jesus)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\navy)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\recon)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\santa)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\scientist)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\skeleton)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\snowman)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\stormtrooper)
    [void](New-Item -ItemType directory -Path $redistDir\models\player\swat)
    [void](New-Item -ItemType directory -Path $redisthddir\models)
}

$modelsdir = "${rootDir}\models"

try {

    if (![string]::IsNullOrEmpty($playerModel)) {
        Compile-Player $playerModel $binDir $modelsdir $redistDir
    } elseif (![string]::IsNullOrEmpty($singleModel)) {
        Invert-Skin $binDir $singleModel $modelsdir
        Compile-Model $binDir $singleModel $modelsdir $redistDir\models
    } elseif (![string]::IsNullOrEmpty($singleHdModel)) {
        Invert-Skin $binDir $singleHdModel $modelsdir\hd
        Compile-Model $binDir $singleHdModel $modelsdir\hd $redistHdDir\models
    } else {
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
    Invert-Skin $binDir "v_tripmine" $modelsdir\hd
    Invert-Skin $binDir "v_sniperrifle" $modelsdir\hd
    Invert-Skin $binDir "v_vest_radio" $modelsdir\hd
    Invert-Skin $binDir "w_bolt" $modelsdir\hd
    Invert-Skin $binDir "w_grenade" $modelsdir\hd
    Invert-Skin $binDir "v_sniperrifle" $modelsdir\hd
    Invert-Skin $binDir "p_sniperrifle" $modelsdir\hd
    Invert-Skin $binDir "w_sniperrifle" $modelsdir\hd
    Invert-Skin $binDir "p_9mmhandgun" $modelsdir
    Invert-Skin $binDir "p_9mmhandguns" $modelsdir
    Invert-Skin $binDir "p_chumtoad" $modelsdir
    Invert-Skin $binDir "p_crossbow" $modelsdir
    Invert-Skin $binDir "p_crowbar" $modelsdir
    Invert-Skin $binDir "p_crowbar" $modelsdir\hd
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
    Invert-Skin $binDir "v_sniperrifle" $modelsdir
    Invert-Skin $binDir "v_tripmine" $modelsdir
    Invert-Skin $binDir "v_vest_radio" $modelsdir
    Invert-Skin $binDir "w_762shell" $modelsdir
    Invert-Skin $binDir "w_bolt" $modelsdir
    Invert-Skin $binDir "w_chumtoad" $modelsdir
    Invert-Skin $binDir "w_grenade" $modelsdir
    Invert-Skin $binDir "w_sniperrifle" $modelsdir
    Invert-Skin $binDir "w_weaponbox" $modelsdir
    Invert-Skin $binDir "v_cannon" $modelsdir
    Invert-Skin $binDir "p_cannon" $modelsdir
    Invert-Skin $binDir "p_cannon" $modelsdir\hd
    Invert-Skin $binDir "v_cannon" $modelsdir\hd
    Invert-Skin $binDir "w_hassassin" $modelsdir
    Invert-Skin $binDir "w_satchel" $modelsdir\hd
    Invert-Skin $binDir "v_satchel" $modelsdir\hd
    Invert-Skin $binDir "v_satchel_radio" $modelsdir\hd
    Invert-Skin $binDir "p_satchel" $modelsdir\hd
    Invert-Skin $binDir "p_satchel_radio" $modelsdir\hd
    Invert-Skin $binDir "p_satchel" $modelsdir
    Invert-Skin $binDir "p_satchel_radio" $modelsdir
    Invert-Skin $binDir "v_satchel" $modelsdir
    Invert-Skin $binDir "v_satchel_radio" $modelsdir
    Invert-Skin $binDir "w_satchel" $modelsdir
    Invert-Skin $binDir "w_shell" $modelsdir
    Invert-Skin $binDir "w_shell" $modelsdir\hd
    Invert-Skin $binDir "p_mag60" $modelsdir\hd
    Invert-Skin $binDir "v_mag60" $modelsdir\hd
    Invert-Skin $binDir "p_mag60" $modelsdir
    Invert-Skin $binDir "v_mag60" $modelsdir
    Invert-Skin $binDir "p_chaingun" $modelsdir\hd
    Invert-Skin $binDir "p_chaingun" $modelsdir
    Invert-Skin $binDir "p_glauncher" $modelsdir\hd
    Invert-Skin $binDir "v_glauncher" $modelsdir\hd
    Invert-Skin $binDir "p_glauncher" $modelsdir
    Invert-Skin $binDir "v_glauncher" $modelsdir
    Invert-Skin $binDir "w_contact_grenade" $modelsdir
    Invert-Skin $binDir "w_contact_grenade" $modelsdir\hd
    Invert-Skin $binDir "p_smg" $modelsdir\hd
    Invert-Skin $binDir "v_smg" $modelsdir\hd
    Invert-Skin $binDir "p_smg" $modelsdir
    Invert-Skin $binDir "v_smg" $modelsdir
    Invert-Skin $binDir "v_usas" $modelsdir\hd
    Invert-Skin $binDir "p_usas" $modelsdir\hd
    Invert-Skin $binDir "v_usas" $modelsdir
    Invert-Skin $binDir "p_usas" $modelsdir
    Invert-Skin $binDir "w_shotgunshell" $modelsdir
    Invert-Skin $binDir "w_shotgunshell" $modelsdir\hd
    Invert-Skin $binDir "v_fists" $modelsdir\hd
    Invert-Skin $binDir "v_wrench" $modelsdir
    Invert-Skin $binDir "p_wrench" $modelsdir
    Invert-Skin $binDir "v_wrench" $modelsdir\hd
    Invert-Skin $binDir "p_wrench" $modelsdir\hd
    Invert-Skin $binDir "v_snowball" $modelsdir\hd
    Invert-Skin $binDir "v_snowball" $modelsdir
    Invert-Skin $binDir "p_snowball" $modelsdir
    Invert-Skin $binDir "w_hgibs" $modelsdir
    Invert-Skin $binDir "v_9mmAR" $modelsdir
    Invert-Skin $binDir "p_9mmAR" $modelsdir
    Invert-Skin $binDir "v_9mmAR" $modelsdir\hd
    Invert-Skin $binDir "p_9mmAR" $modelsdir\hd
    Invert-Skin $binDir "v_shotgun" $modelsdir
    Invert-Skin $binDir "p_shotgun" $modelsdir
    Invert-Skin $binDir "v_shotgun" $modelsdir\hd
    Invert-Skin $binDir "p_shotgun" $modelsdir\hd
    Invert-Skin $binDir "v_chainsaw" $modelsdir\hd
    Invert-Skin $binDir "p_chainsaw" $modelsdir\hd
    Invert-Skin $binDir "v_chainsaw" $modelsdir
    Invert-Skin $binDir "p_chainsaw" $modelsdir
    Invert-Skin $binDir "v_12gauge" $modelsdir
    Invert-Skin $binDir "p_12gauge" $modelsdir
    Invert-Skin $binDir "p_12gauge" $modelsdir\hd
    Invert-Skin $binDir "v_12gauge" $modelsdir\hd
    Invert-Skin $binDir "w_battery" $modelsdir
    Invert-Skin $binDir "w_longjump" $modelsdir
    Invert-Skin $binDir "w_medkit" $modelsdir
    Invert-Skin $binDir "w_gaussammo" $modelsdir
    Invert-Skin $binDir "w_gaussammo" $modelsdir\hd
    Invert-Skin $binDir "v_357" $modelsdir
    Invert-Skin $binDir "p_357" $modelsdir
    Invert-Skin $binDir "p_357" $modelsdir\hd
    Invert-Skin $binDir "v_357" $modelsdir\hd
    Invert-Skin $binDir "v_egon" $modelsdir
    Invert-Skin $binDir "p_egon" $modelsdir
    Invert-Skin $binDir "p_egon" $modelsdir\hd
    Invert-Skin $binDir "v_egon" $modelsdir\hd
    Invert-Skin $binDir "v_nuke" $modelsdir
    Invert-Skin $binDir "p_nuke" $modelsdir
    Invert-Skin $binDir "p_nuke" $modelsdir\hd
    Invert-Skin $binDir "v_nuke" $modelsdir\hd
    Invert-Skin $binDir "v_gauss" $modelsdir
    Invert-Skin $binDir "p_gauss" $modelsdir
    Invert-Skin $binDir "p_gauss" $modelsdir\hd
    Invert-Skin $binDir "v_gauss" $modelsdir\hd
    Invert-Skin $binDir "p_hgun" $modelsdir
    Invert-Skin $binDir "p_hgun" $modelsdir\hd
    Invert-Skin $binDir "w_hornet" $modelsdir
    Invert-Skin $binDir "v_squeak" $modelsdir
    Invert-Skin $binDir "p_squeak" $modelsdir
    Invert-Skin $binDir "w_sqknest" $modelsdir
    Invert-Skin $binDir "w_squeak" $modelsdir
    Invert-Skin $binDir "p_squeak" $modelsdir\hd
    Invert-Skin $binDir "w_sqknest" $modelsdir\hd
    Invert-Skin $binDir "v_squeak" $modelsdir\hd
    Invert-Skin $binDir "w_squeak" $modelsdir\hd
    Invert-Skin $binDir "v_deagle" $modelsdir\hd
    Invert-Skin $binDir "p_deagle" $modelsdir
    Invert-Skin $binDir "p_deagle" $modelsdir\hd
    Invert-Skin $binDir "v_dual_deagle" $modelsdir
    Invert-Skin $binDir "p_dual_deagle" $modelsdir
    Invert-Skin $binDir "v_dual_deagle" $modelsdir\hd
    Invert-Skin $binDir "p_dual_deagle" $modelsdir\hd
    Invert-Skin $binDir "p_dual_sawedoff" $modelsdir
    Invert-Skin $binDir "v_dual_rpg" $modelsdir\hd
    Invert-Skin $binDir "p_dual_rpg" $modelsdir\hd
    Invert-Skin $binDir "p_dual_rpg" $modelsdir
    Invert-Skin $binDir "v_dual_rpg" $modelsdir
    Invert-Skin $binDir "v_dual_smg" $modelsdir\hd
    Invert-Skin $binDir "p_dual_smg" $modelsdir\hd
    Invert-Skin $binDir "v_dual_wrench" $modelsdir\hd
    Invert-Skin $binDir "p_dual_wrench" $modelsdir\hd
    Invert-Skin $binDir "p_dual_smg" $modelsdir
    Invert-Skin $binDir "v_dual_smg" $modelsdir
    Invert-Skin $binDir "p_dual_wrench" $modelsdir
    Invert-Skin $binDir "v_dual_wrench" $modelsdir
    Invert-Skin $binDir "v_dual_usas" $modelsdir\hd
    Invert-Skin $binDir "p_dual_usas" $modelsdir\hd
    Invert-Skin $binDir "v_dual_usas" $modelsdir
    Invert-Skin $binDir "p_dual_usas" $modelsdir
    Invert-Skin $binDir "v_freezegun" $modelsdir\hd
    Invert-Skin $binDir "p_freezegun" $modelsdir\hd
    Invert-Skin $binDir "v_freezegun" $modelsdir
    Invert-Skin $binDir "p_freezegun" $modelsdir
    Invert-Skin $binDir "w_concretegibs" $modelsdir
    Invert-Skin $binDir "v_dual_mag60" $modelsdir\hd
    Invert-Skin $binDir "p_dual_mag60" $modelsdir\hd
    Invert-Skin $binDir "v_dual_mag60" $modelsdir
    Invert-Skin $binDir "p_dual_mag60" $modelsdir
    Invert-Skin $binDir "v_rocketcrowbar" $modelsdir\hd
    Invert-Skin $binDir "p_rocketcrowbar" $modelsdir\hd
    Invert-Skin $binDir "v_rocketcrowbar" $modelsdir
    Invert-Skin $binDir "p_rocketcrowbar" $modelsdir
    Invert-Skin $binDir "v_dual_railgun" $modelsdir
    Invert-Skin $binDir "p_dual_railgun" $modelsdir
    Invert-Skin $binDir "v_gravitygun" $modelsdir
    Invert-Skin $binDir "p_gravitygun" $modelsdir
    Invert-Skin $binDir "w_barrel" $modelsdir
    Invert-Skin $binDir "w_cabinet" $modelsdir
    Invert-Skin $binDir "w_cabinet" $modelsdir\hd
    Invert-Skin $binDir "w_sentry" $modelsdir
    Invert-Skin $binDir "v_flamethrower" $modelsdir
    Invert-Skin $binDir "p_flamethrower" $modelsdir
    Invert-Skin $binDir "v_dual_flamethrower" $modelsdir
    Invert-Skin $binDir "p_dual_flamethrower" $modelsdir
    Invert-Skin $binDir "v_portalgun" $modelsdir
    Invert-Skin $binDir "p_portalgun" $modelsdir
    Invert-Skin $binDir "w_portalgun" $modelsdir
    Invert-Skin $binDir "w_portal" $modelsdir
    Invert-Skin $binDir "p_sawedoff" $modelsdir
    Invert-Skin $binDir "v_sawedoff" $modelsdir\hd
    Invert-Skin $binDir "v_sawedoff" $modelsdir
    Invert-Skin $binDir "p_sawedoff" $modelsdir
    Invert-Skin $binDir "v_dual_chaingun" $modelsdir
    Invert-Skin $binDir "p_dual_chaingun" $modelsdir
    Invert-Skin $binDir "w_dual_chaingun" $modelsdir
    Invert-Skin $binDir "v_dual_chaingun" $modelsdir\hd
    Invert-Skin $binDir "p_dual_chaingun" $modelsdir\hd
    Invert-Skin $binDir "w_dual_chaingun" $modelsdir\hd
    Invert-Skin $binDir "v_zapgun" $modelsdir
    Invert-Skin $binDir "v_zapgun" $modelsdir\hd
    Invert-Skin $binDir "p_zapgun" $modelsdir
    Invert-Skin $binDir "w_zapgun" $modelsdir
    Invert-Skin $binDir "w_tombstone" $modelsdir

    Compile-Player "alpina" $binDir $modelsdir $redistDir
    Compile-Player "army" $binDir $modelsdir $redistDir
    Compile-Player "assassin" $binDir $modelsdir $redistDir
    Compile-Player "baer" $binDir $modelsdir $redistDir
    Compile-Player "barney" $binDir $modelsdir $redistDir
    Compile-Player "commando" $binDir $modelsdir $redistDir
    Compile-Player "frost" $binDir $modelsdir $redistDir
    Compile-Player "grunt" $binDir $modelsdir $redistDir
    Compile-Player "hhev" $binDir $modelsdir $redistDir
    Compile-Player "holo" $binDir $modelsdir $redistDir
    Compile-Player "hotfire" $binDir $modelsdir $redistDir
    Compile-Player "iceman" $binDir $modelsdir $redistDir
    Compile-Player "jesus" $binDir $modelsdir $redistDir
    Compile-Player "navy" $binDir $modelsdir $redistDir
    Compile-Player "recon" $binDir $modelsdir $redistDir
    Compile-Player "santa" $binDir $modelsdir $redistDir
    Compile-Player "scientist" $binDir $modelsdir $redistDir
    Compile-Player "skeleton" $binDir $modelsdir $redistDir
    Compile-Player "snowman" $binDir $modelsdir $redistDir
    Compile-Player "stormtrooper" $binDir $modelsdir $redistDir
    Compile-Player "swat" $binDir $modelsdir $redistDir

    Compile-Model $binDir "v_9mmAR" $modelsdir $redistDir\models
    Compile-Model $binDir "v_9mmAR" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_shotgun" $modelsdir $redistDir\models
    Compile-Model $binDir "v_shotgun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_vest_radio" $modelsdir $redistDir\models
    Compile-Model $binDir "v_vest_radio" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_9mmhandgun" $modelsdir $redistDir\models
    Compile-Model $binDir "v_9mmhandgun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_9mmhandguns" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_9mmhandguns" $modelsdir $redistDir\models
    Compile-Model $binDir "v_grenade" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_grenade" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_grenade" $modelsdir $redistDir\models
    Compile-Model $binDir "w_grenade" $modelsdir $redistDir\models
    Compile-Model $binDir "v_knife" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_knife" $modelsdir $redistDir\models
    Compile-Model $binDir "v_crowbar" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_crowbar" $modelsdir $redistDir\models
    Compile-Model $binDir "rpgrocket" $modelsdir $redistDir\models
    Compile-Model $binDir "rpgrocket" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_tripmine" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_tripmine" $modelsdir $redistDir\models
    Compile-Model $binDir "v_chumtoad" $modelsdir $redistDir\models
    Compile-Model $binDir "w_chumtoad" $modelsdir $redistDir\models
    Compile-Model $binDir "v_chumtoad" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_sniperrifle" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_sniperrifle" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_sniperrifle" $modelsdir $redistDir\models
    Compile-Model $binDir "w_sniperrifle" $modelsdir $redistDir\models
    Compile-Model $binDir "w_762shell" $modelsdir $redistDir\models
    Compile-Model $binDir "v_crossbow" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_crossbow" $modelsdir $redistDir\models
    Compile-Model $binDir "w_bolt" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_bolt" $modelsdir $redistDir\models
    Compile-Model $binDir "v_railgun" $modelsdir $redistDir\models
    Compile-Model $binDir "w_weaponbox" $modelsdir $redistDir\models
    Compile-Model $binDir "w_runes" $modelsdir $redistDir\models
    Compile-Model $binDir "v_cannon" $modelsdir $redistDir\models
    Compile-Model $binDir "v_cannon" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_satchel_radio" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_hassassin" $modelsdir $redistDir\models
    Compile-Model $binDir "v_satchel" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_satchel" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "p_satchel_radio" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "p_satchel_radio" $modelsdir $redistDir\models
    Compile-Model $binDir "v_satchel" $modelsdir $redistDir\models
    Compile-Model $binDir "v_satchel_radio" $modelsdir $redistDir\models
    Compile-Model $binDir "w_satchel" $modelsdir $redistDir\models
    Compile-Model $binDir "w_shell" $modelsdir $redistDir\models
    Compile-Model $binDir "w_shell" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_mag60" $modelsdir $redistDir\models
    Compile-Model $binDir "v_mag60" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_glauncher" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_glauncher" $modelsdir $redistdir\models
    Compile-Model $binDir "w_contact_grenade" $modelsdir $redistdir\models
    Compile-Model $binDir "w_contact_grenade" $modelsdir $redisthddir\models
    Compile-Model $binDir "v_smg" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_smg" $modelsdir $redistdir\models
    Compile-Model $binDir "v_usas" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_usas" $modelsdir $redistdir\models
    Compile-Model $binDir "w_shotgunshell" $modelsdir $redistdir\models
    Compile-Model $binDir "w_shotgunshell" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_fists" $modelsdir $redistdir\models
    Compile-Model $binDir "v_fists" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_wrench" $modelsdir $redistdir\models
    Compile-Model $binDir "v_wrench" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_snowball" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_snowball" $modelsdir $redistdir\models
    Compile-Model $binDir "w_hgibs" $modelsdir $redistdir\models
    Compile-Model $binDir "v_chainsaw" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_chainsaw" $modelsdir $redistdir\models
    Compile-Model $binDir "v_12gauge" $modelsdir $redistdir\models
    Compile-Model $binDir "v_12gauge" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_battery" $modelsdir $redistdir\models
    Compile-Model $binDir "w_medkit" $modelsdir $redistdir\models
    Compile-Model $binDir "w_longjump" $modelsdir $redistdir\models
    Compile-Model $binDir "w_gaussammo" $modelsdir $redistdir\models
    Compile-Model $binDir "w_gaussammo" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_gaussammo_light" $modelsdir $redistdir\models
    Compile-Model $binDir "v_357" $modelsdir $redistdir\models
    Compile-Model $binDir "v_357" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_egon" $modelsdir $redistdir\models
    Compile-Model $binDir "v_egon" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_nuke" $modelsdir $redistdir\models
    Compile-Model $binDir "v_nuke" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_gauss" $modelsdir $redistdir\models
    Compile-Model $binDir "v_gauss" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_hornet" $modelsdir $redistdir\models
    Compile-Model $binDir "v_squeak" $modelsdir $redistdir\models
    Compile-Model $binDir "w_sqknest" $modelsdir $redistdir\models
    Compile-Model $binDir "w_squeak" $modelsdir $redistdir\models
    Compile-Model $binDir "v_squeak" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_sqknest" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_squeak" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_leg" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_leg" $modelsdir $redistdir\models
    Compile-Model $binDir "v_deagle" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_deagle" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_deagle" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_deagle" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_rpg" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_rpg" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_smg" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_wrench" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_smg" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_wrench" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_usas" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_usas" $modelsdir $redistdir\models
    Compile-Model $binDir "v_freezegun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_freezegun" $modelsdir $redistdir\models
    Compile-Model $binDir "plasma" $modelsdir $redistdir\models
    Compile-Model $binDir "w_battery_light" $modelsdir $redistdir\models
    Compile-Model $binDir "w_medkit_light" $modelsdir $redistdir\models
    Compile-Model $binDir "w_concretegibs" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_mag60" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_mag60" $modelsdir $redistdir\models
    Compile-Model $binDir "v_rocketcrowbar" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_rocketcrowbar" $modelsdir $redistdir\models
    Compile-Model $binDir "v_railgun_light" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_railgun" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_railgun_light" $modelsdir $redistdir\models
    Compile-Model $binDir "v_gravitygun" $modelsdir $redistdir\models
    Compile-Model $binDir "w_barrel" $modelsdir $redistdir\models
    Compile-Model $binDir "w_cabinet" $modelsdir $redistdir\models
    Compile-Model $binDir "w_cabinet" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_sentry" $modelsdir $redistdir\models
    Compile-Model $binDir "v_flamethrower" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_flamethrower" $modelsdir $redistdir\models
    Compile-Model $binDir "v_portalgun" $modelsdir $redistdir\models
    Compile-Model $binDir "p_portalgun" $modelsdir $redistdir\models
    Compile-Model $binDir "w_portalgun" $modelsdir $redistdir\models
    Compile-Model $binDir "w_portal" $modelsdir $redistdir\models
    #Compile-Model $binDir "v_bluetakis" $modelsdir $redistdir\models
    Compile-Model $binDir "w_weapons" $modelsdir $redistdir\models
    Compile-Model $binDir "w_weapons" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "p_weapons" $modelsdir $redistdir\models
    Compile-Model $binDir "p_weapons" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_taunt" $modelsdir $redistdir\models
    Compile-Model $binDir "v_taunt" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_sawedoff" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_sawedoff" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_sawedoff" $modelsdir $redistdir\models
    Compile-Model $binDir "w_tracer" $modelsdir $redistdir\models
    Compile-Model $binDir "box" $modelsdir $redistdir\models
    Compile-Model $binDir "hats" $modelsdir $redistdir\models
    Compile-Model $binDir "w_ammo" $modelsdir $redistdir\models
    Compile-Model $binDir "w_ammo" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_chaingun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_chaingun" $modelsdir $redistdir\models
    Compile-Model $binDir "v_dual_hgun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_dual_hgun" $modelsdir $redistdir\models
    Compile-Model $binDir "v_fingergun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "v_fingergun" $modelsdir $redistdir\models
    Compile-Model $binDir "flag" $modelsdir $redistdir\models
    Compile-Model $binDir "flagbase" $modelsdir $redistdir\models
    Compile-Model $binDir "v_zapgun" $modelsdir $redistdir\models
    Compile-Model $binDir "v_zapgun" $modelsdir\hd $redisthddir\models
    Compile-Model $binDir "w_tombstone" $modelsdir $redistdir\models
    }
}
catch
{
    Set-Location -Path ${PSScriptRoot}
    Write-Error "$($_.Exception.Message)"
}

Set-Location -Path ${PSScriptRoot}
