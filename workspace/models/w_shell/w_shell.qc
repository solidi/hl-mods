/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_shell.mdl

Original internal name:
"valve/models/shell.mdl"

==============================================================================
*/

$modelname "w_shell.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "shellcase"

$texturegroup ice
{
  {
    "back.bmp"
    "bulletCHROME.bmp"
    "front.bmp"
  }
  {
    "invert_back.bmp"
    "invert_bulletCHROME.bmp"
    "invert_front.bmp"
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


// 1 hit box(es)
$hbox 0 "MDLDEC_Bone1" -0.630000 -0.740000 0.000000 0.770000 0.740000 3.000000

// 1 animation sequence(s)
$sequence "shell" "shell" fps 30 

// End of QC script.
