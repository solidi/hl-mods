/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_argrenade.mdl

Original internal name:
"c:\sierra\half-life\valve\models\w_ARgrenade.mdl"

==============================================================================
*/

$modelname "w_argrenade.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "argrenades"

$texturegroup ice
{
  {
    "m4_grenade_ammo.bmp"
  }
  {
    "invert_m4_grenade_ammo.bmp"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "argrenade" -2.110000 -6.250000 0.000000 7.660000 2.260000 8.860000

// animation sequence(s)
$sequence "idle" "idle" fps 30 
$sequence "spin" "spin" fps 21 loop

// End of QC script.
