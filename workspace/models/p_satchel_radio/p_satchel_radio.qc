/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_satchel_radio.mdl

Original internal name:
"valve/models/p_satchel_radio.mdl"

==============================================================================
*/

$modelname "p_satchel_radio.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "detonator"

$texturegroup ice
{
  {
    "satchel.bmp"
  }
  {
    "invert_satchel.bmp"
  }
  {
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
  }
}


// hit box(es)
$hbox 0 "Bip01 Neck" -2.869898 0.000000 -4.140396 0.000000 1.399663 0.000000
$hbox 0 "detonator" -0.490000 -6.960000 -1.300000 1.320000 2.430000 0.720000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
