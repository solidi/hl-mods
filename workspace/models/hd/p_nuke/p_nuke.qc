/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_nuke.mdl

Original internal name:
"p_BFG.mdl"

==============================================================================
*/

$modelname "p_nuke.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "nuke"

$texturegroup ice
{
  {
    "1.bmp"
    "2.bmp"
    "SRRAILM4.bmp"
    "w_clip_bfg.bmp"
  }
  {
    "invert_1.bmp"
    "invert_2.bmp"
    "invert_SRRAILM4.bmp"
    "invert_w_clip_bfg.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 R Hand" 0.000000 -1.499062 -1.778342 26.516474 0.000000 0.000000
$hbox 0 "nuke" -8.240000 -12.720000 -45.029999 15.150000 22.230000 7.280000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
