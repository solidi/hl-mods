/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_knife.mdl

Original internal name:
"p_crowbar.mdl"

==============================================================================
*/

$modelname "p_knife.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "knife"

$texturegroup ice
{
  {
    "body.bmp"
  }
  {
    "invert_body.bmp"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 Neck" -2.869917 0.000000 -4.140396 0.000000 1.399630 0.000000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
