#Requires -Version 7.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

$host.UI.RawUI.WindowTitle = "Build Cold Ice GoldSrc Models"
function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
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
        echo "rebuilding all models..."
    }
}

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
    [void](New-Item -ItemType directory -Path $redisthddir\models)
}

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
Invert-Skin $binDir "w_mag60" $modelsdir\hd
Invert-Skin $binDir "v_mag60" $modelsdir\hd
Invert-Skin $binDir "p_mag60" $modelsdir
Invert-Skin $binDir "w_mag60" $modelsdir
Invert-Skin $binDir "v_mag60" $modelsdir
Invert-Skin $binDir "p_chaingun" $modelsdir\hd
Invert-Skin $binDir "w_chaingun" $modelsdir\hd
Invert-Skin $binDir "v_chaingun" $modelsdir\hd
Invert-Skin $binDir "p_chaingun" $modelsdir
Invert-Skin $binDir "w_chaingun" $modelsdir
Invert-Skin $binDir "v_chaingun" $modelsdir
Invert-Skin $binDir "p_glauncher" $modelsdir\hd
Invert-Skin $binDir "w_glauncher" $modelsdir\hd
Invert-Skin $binDir "v_glauncher" $modelsdir\hd
Invert-Skin $binDir "p_glauncher" $modelsdir
Invert-Skin $binDir "w_glauncher" $modelsdir
Invert-Skin $binDir "v_glauncher" $modelsdir
Invert-Skin $binDir "w_contact_grenade" $modelsdir
Invert-Skin $binDir "w_contact_grenade" $modelsdir\hd
Invert-Skin $binDir "p_smg" $modelsdir\hd
Invert-Skin $binDir "w_smg" $modelsdir\hd
Invert-Skin $binDir "v_smg" $modelsdir\hd
Invert-Skin $binDir "p_smg" $modelsdir
Invert-Skin $binDir "w_smg" $modelsdir
Invert-Skin $binDir "v_smg" $modelsdir
Invert-Skin $binDir "v_usas" $modelsdir\hd
Invert-Skin $binDir "w_usas" $modelsdir\hd
Invert-Skin $binDir "p_usas" $modelsdir\hd
Invert-Skin $binDir "v_usas" $modelsdir
Invert-Skin $binDir "w_usas" $modelsdir
Invert-Skin $binDir "p_usas" $modelsdir
Invert-Skin $binDir "w_shotgunshell" $modelsdir
Invert-Skin $binDir "w_shotgunshell" $modelsdir\hd
Invert-Skin $binDir "v_fists" $modelsdir\hd
Invert-Skin $binDir "v_wrench" $modelsdir
Invert-Skin $binDir "p_wrench" $modelsdir
Invert-Skin $binDir "w_wrench" $modelsdir
Invert-Skin $binDir "v_wrench" $modelsdir\hd
Invert-Skin $binDir "w_wrench" $modelsdir\hd
Invert-Skin $binDir "p_wrench" $modelsdir\hd
Invert-Skin $binDir "v_snowball" $modelsdir\hd
Invert-Skin $binDir "v_snowball" $modelsdir
Invert-Skin $binDir "p_snowball" $modelsdir
Invert-Skin $binDir "w_snowball" $modelsdir
Invert-Skin $binDir "w_hgibs" $modelsdir
Invert-Skin $binDir "v_9mmAR" $modelsdir
Invert-Skin $binDir "v_9mmAR" $modelsdir\hd

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
Compile-Model $binDir "v_satchel_radio" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_hassassin" $modelsdir $redistDir\models
Compile-Model $binDir "v_satchel" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_satchel" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_satchel" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_satchel_radio" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_satchel" $modelsdir $redistDir\models
Compile-Model $binDir "p_satchel_radio" $modelsdir $redistDir\models
Compile-Model $binDir "v_satchel" $modelsdir $redistDir\models
Compile-Model $binDir "v_satchel_radio" $modelsdir $redistDir\models
Compile-Model $binDir "w_satchel" $modelsdir $redistDir\models
Compile-Model $binDir "w_shell" $modelsdir $redistDir\models
Compile-Model $binDir "w_shell" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_mag60" $modelsdir $redistDir\models
Compile-Model $binDir "v_mag60" $modelsdir $redistDir\models
Compile-Model $binDir "p_mag60" $modelsdir $redistDir\models
Compile-Model $binDir "w_mag60" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_mag60" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_mag60" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_chaingun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_chaingun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_chaingun" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_chaingun" $modelsdir $redistDir\models
Compile-Model $binDir "v_chaingun" $modelsdir $redistDir\models
Compile-Model $binDir "p_chaingun" $modelsdir $redistDir\models
Compile-Model $binDir "w_glauncher" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_glauncher" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_glauncher" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_glauncher" $modelsdir $redistdir\models
Compile-Model $binDir "p_glauncher" $modelsdir $redistdir\models
Compile-Model $binDir "v_glauncher" $modelsdir $redistdir\models
Compile-Model $binDir "w_contact_grenade" $modelsdir $redistdir\models
Compile-Model $binDir "w_contact_grenade" $modelsdir $redisthddir\models
Compile-Model $binDir "w_smg" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_smg" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_smg" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_smg" $modelsdir $redistdir\models
Compile-Model $binDir "p_smg" $modelsdir $redistdir\models
Compile-Model $binDir "v_smg" $modelsdir $redistdir\models
Compile-Model $binDir "v_usas" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "p_usas" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_usas" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_usas" $modelsdir $redistdir\models
Compile-Model $binDir "w_usas" $modelsdir $redistdir\models
Compile-Model $binDir "p_usas" $modelsdir $redistdir\models
Compile-Model $binDir "w_shotgunshell" $modelsdir $redistdir\models
Compile-Model $binDir "w_shotgunshell" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_fists" $modelsdir $redistdir\models
Compile-Model $binDir "v_fists" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_wrench" $modelsdir $redistdir\models
Compile-Model $binDir "p_wrench" $modelsdir $redistdir\models
Compile-Model $binDir "w_wrench" $modelsdir $redistdir\models
Compile-Model $binDir "p_wrench" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "w_wrench" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_wrench" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_snowball" $modelsdir\hd $redisthddir\models
Compile-Model $binDir "v_snowball" $modelsdir $redistdir\models
Compile-Model $binDir "p_snowball" $modelsdir $redistdir\models
Compile-Model $binDir "w_snowball" $modelsdir $redistdir\models
Compile-Model $binDir "w_hgibs" $modelsdir $redistdir\models

Set-Location -Path ${PSScriptRoot}
