/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_rpg.mdl

Original internal name:
"c:\sierra\half-life\valve\models\P_rpg.mdl"

==============================================================================
*/

$modelname "p_rpg.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "rpg"

$texturegroup ice
{
  {
    "w_rpg_reference.BMP"
  }
  {
    "invert_w_rpg_reference.BMP"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 Neck" -2.869899 0.000000 -4.140396 0.000000 1.399664 0.000000
$hbox 0 "Bip01 R Hand" 0.000000 0.000000 0.000000 2.164582 1.638621 3.936291
$hbox 0 "rpg" -4.190000 -21.110001 -7.690000 4.190000 21.129999 7.700000

// animation sequence(s)
$sequence "idle" "idle" fps 30 loop 

// End of QC script.
