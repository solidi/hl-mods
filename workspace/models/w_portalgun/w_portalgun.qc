/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_portalgun.mdl

Original internal name:
"w_aug.mdl"

==============================================================================
*/

$modelname "w_portalgun.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "portalgun_front"

$body "studio" "portalgun_back"

$texturegroup ice
{
  {
    "..\w_portalgun\w_portalgun.bmp"
  }
  {
    "invert_w_portalgun.bmp"
  }
  {
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "portalgun" -13.480000 -9.130000 -3.610000 8.650000 8.440000 7.050000

// animation sequence(s)
$sequence "idle" "idle" fps 30 
$sequence "spin" "spin" fps 21 loop 

// End of QC script.
