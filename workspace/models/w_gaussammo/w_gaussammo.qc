/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_gaussammo.mdl

Original internal name:
"valve\models\w_gaussammo.mdl"

==============================================================================
*/

$modelname "w_gaussammo.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures

$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "gaussammo"

$texturegroup ice
{
  {
    "boxside.bmp"
    "boxtop.bmp"
    "hinge.bmp"
  }
  {
    "invert_boxside.bmp"
    "invert_boxtop.bmp"
    "invert_hinge.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "gaussammo" -9.830000 -13.310000 0.000000 9.800000 0.850000 10.110000

// animation sequence(s)
$sequence "idle" "idle" fps 30 
$sequence "spin" "spin" fps 21 loop 

// End of QC script.
