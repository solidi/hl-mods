/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_9mmhandgun.mdl

Original internal name:
"valve/models/p_9mmhandgun.mdl"

==============================================================================
*/

$modelname "p_mag60.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "mag60"

$texturegroup ice
{
  {
    "glockback.bmp"
    "glockfront.bmp"
    "glockside.bmp"
    "glocktop1.bmp"
  }
  {
    "invert_glockback.bmp"
    "invert_glockfront.bmp"
    "invert_glockside.bmp"
    "invert_glocktop1.bmp"
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
$hbox 0 "Bip01 Neck" -2.869898 0.000000 -4.140396 0.000000 1.399663 0.000000
$hbox 0 "mag60" -4.120000 -0.790000 -2.650000 4.120000 0.790000 2.650000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
