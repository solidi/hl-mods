/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_egon.mdl

Original internal name:
"c:/sierra/half-life/valve/models/p_egon.mdl"

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
    "w_egon_reference.BMP"
  }
  {
    "invert_w_egon_reference.BMP"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}


// hit box(es)
$hbox 0 "Bip01 Spine1" -10.280000 -16.540001 -11.060000 17.950001 0.000000 9.700000
$hbox 0 "Bip01 R UpperArm" 0.000000 -1.020000 -8.340000 11.860000 5.900000 0.000000
$hbox 0 "Bip01 R Forearm" 0.000000 -10.810000 -8.150000 29.219999 0.000000 7.800000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
