/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

p_grenade.mdl

Original internal name:
"c:\sierra\half-life\valve\models\p_grenade.mdl"

==============================================================================
*/

$modelname "p_grenade.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "grenade"

$texturegroup ice
{
  {
    "grenade 128.bmp"
  }
  {
    "invert_grenade 128.bmp"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 Neck" -2.869902 0.000000 -4.140396 0.000000 1.399666 0.000000
$hbox 0 "Bip01 R Hand" 0.000000 0.000000 0.000000 3.076825 1.896887 1.272390
$hbox 0 "grenade" -2.760000 -2.390000 -2.050000 0.740000 3.600000 0.940000

// animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
