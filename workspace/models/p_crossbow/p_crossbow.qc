/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_crossbow.mdl

Original internal name:
"valve/models/p_crossbow.mdl"

==============================================================================
*/

$modelname "p_crossbow.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "crossbow"

$texturegroup ice
{
  {
    "bowCHROME.bmp"
    "clip_side.bmp"
    "mechanismside.bmp"
    "receiverside.BMP"
    "sightcyl.BMP"
    "stock.BMP"
    "world_grip.BMP"
    "world_shoulder.BMP"
    "world_slide.BMP"
  }
  {
    "invert_bowCHROME.bmp"
    "invert_clip_side.bmp"
    "invert_mechanismside.bmp"
    "invert_receiverside.BMP"
    "invert_sightcyl.BMP"
    "invert_stock.BMP"
    "invert_world_grip.BMP"
    "invert_world_shoulder.BMP"
    "invert_world_slide.BMP"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
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
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 Neck" -2.869898 0.000000 -4.140396 0.000000 1.399663 0.000000
$hbox 0 "crossbow" -11.980000 -6.720000 -8.780000 16.010000 4.130000 8.830000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
