/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_rpgammo.mdl

Original internal name:
"c:/sierra/half-life/valve/models/w_rpgammo.mdl"

==============================================================================
*/

$modelname "w_rpgammo.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "rpgammo"

$texturegroup ice
{
  {
    "rpg_ammo.BMP"
  }
  {
    "invert_rpg_ammo.BMP"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "rpgammo" -4.160000 -12.040000 0.000000 7.490000 3.600000 29.610001

// animation sequence(s)
$sequence "idle" "idle" fps 30 
$sequence "spin" "spin" fps 21 loop 
$sequence "capped" "capped" fps 30 

// End of QC script.
