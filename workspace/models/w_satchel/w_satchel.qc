/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_satchel.mdl

Original internal name:
"valve/models/w_satchel.mdl"

==============================================================================
*/

$modelname "w_satchel.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures

$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "satchel"

$texturegroup ice
{
  {
    "black.bmp"
    "radioside.bmp"
    "tag.bmp"
    "wrldsatchel.bmp"
  }
  {
    "invert_black.bmp"
    "invert_radioside.bmp"
    "invert_tag.bmp"
    "invert_wrldsatchel.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
}


// hit box(es)
$hbox 0 "satchel" -7.710000 -7.550000 -7.110000 5.480000 16.639999 6.290000

// animation sequence(s)
$sequence "idle" "idle" fps 30 
$sequence "spin" "spin" loop fps 21 
$sequence "onback" "onback" fps 30 

// End of QC script.
