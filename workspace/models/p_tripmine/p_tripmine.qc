/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_tripmine.mdl

Original internal name:
"valve/models/p_tripmine.mdl"

==============================================================================
*/

$modelname "p_tripmine.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "tripmine"

$texturegroup ice
{
  {
    "box.bmp"
    "face.bmp"
    "lensCHROME.BMP"
    "light.bmp"
    "side.bmp"
  }
  {
    "invert_box.bmp"
    "invert_face.bmp"
    "invert_lensCHROME.BMP"
    "invert_light.bmp"
    "invert_side.bmp"
  }
  {
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
  }
}

// hit box(es)
$hbox 0 "Bip01 Neck" -2.869898 0.000000 -4.140396 0.000000 1.399663 0.000000
$hbox 0 "Bip01 R Hand" 0.000000 0.000000 0.000000 4.278921 3.312595 1.946941
$hbox 0 "tripmine" -4.080000 -1.350000 -2.720000 4.100000 2.660000 0.700000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
