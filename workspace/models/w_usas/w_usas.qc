/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_usas.mdl

Original internal name:
"models/w_9mmar.mdl"

==============================================================================
*/

$modelname "w_usas.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures

$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "usas"

$texturegroup ice
{
  {
    "ringchrome.bmp"
    "ringchrome2.bmp"
  }
  {
    "invert_ringchrome.bmp"
    "invert_ringchrome2.bmp"
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
$hbox 0 "usas" -47.169998 -16.750000 0.000000 29.910000 12.190000 13.760000

// animation sequence(s)
$sequence "idle" "idle" fps 30 
$sequence "spin" "spin" fps 21 loop 

// End of QC script.
