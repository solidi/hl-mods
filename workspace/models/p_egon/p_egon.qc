/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_egon.mdl

Original internal name:
"valve/models/p_egon.mdl"

==============================================================================
*/

$modelname "p_egon.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "egon"

$texturegroup ice
{
  {
    "egonchrome2.bmp"
    "world_egon_combined.bmp"
  }
  {
    "invert_egonchrome2.bmp"
    "invert_world_egon_combined.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 Spine1" -9.250000 -14.990000 -8.980000 16.959999 0.000000 8.510000
$hbox 0 "Bip01 Neck" -12.030000 -4.880000 -12.220000 0.000000 1.399663 0.000000
$hbox 0 "Bip01 R Arm1" 0.000000 -1.020000 -8.340000 11.850000 5.890000 0.000000
$hbox 0 "Bip01 R Arm2" 0.000000 -11.560000 -8.140000 29.070000 0.000000 10.080000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
