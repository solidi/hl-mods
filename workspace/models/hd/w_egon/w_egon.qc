/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_egon.mdl

Original internal name:
"c:/sierra/half-life/valve/models/w_egon.mdl"

==============================================================================
*/

$modelname "w_egon.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "egon"

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
$hbox 0 "egon" -28.680000 -35.730000 -33.130001 12.300000 3.930000 1.790000

// animation sequence(s)
$sequence "idle" "idle" fps 1 
$sequence "spin" "spin" fps 21 loop 

// End of QC script.
