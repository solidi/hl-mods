/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_glauncher.mdl

Original internal name:
"D:\stuff\_coldIce\models\agl40\wpmdls\p\p_agl35.mdl"

==============================================================================
*/

$modelname "p_glauncher.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "glauncher"

$texturegroup ice
{
  {
    "wmodel.bmp"
  }
  {
    "invert_wmodel.bmp"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}


// hit box(es)
$hbox 0 "Bip01 Neck" -2.869898 0.000000 -4.140396 0.000000 1.399663 0.000000
$hbox 0 "Bip01 R Hand" 0.000000 0.000000 0.000000 12.295609 1.386845 1.667124
$hbox 0 "glauncher" -12.260000 -4.010000 -1.570000 12.260000 4.010000 1.570000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
