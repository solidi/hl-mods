/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_freezegun.mdl

Original internal name:
"p_plasmagun.mdl"

==============================================================================
*/

$modelname "p_freezegun.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "freezegun"

$texturegroup ice
{
  {
    "#128128plasma_p_alpha.BMP"
    "#256256plasma_p.bmp"
  }
  {
    "invert_#128128plasma_p_alpha.BMP"
    "invert_#256256plasma_p.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
  }
}

$texrendermode "#128128plasma_p_alpha.BMP" "additive" 

// attachment(s)
$attachment 0 "freezegun" -9.000000 1.500000 0.500000

// hit box(es)
$hbox 0 "Bip01 Neck" -2.869898 0.000000 -4.140396 0.000000 1.399663 0.000000
$hbox 0 "freezegun" -8.280000 -4.820000 -1.020000 17.500000 5.250000 2.090000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
