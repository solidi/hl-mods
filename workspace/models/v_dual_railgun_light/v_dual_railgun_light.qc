/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_railgun.mdl

Original internal name:
"C:\Games\Half-Life\models\guass\v_gauss.mdl"

==============================================================================
*/

$modelname "v_dual_railgun_light.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "railgun"

$texrendermode "Skin.bmp" "additive"

$texturegroup ice
{
  {
    "Skin_Red.bmp"
  }
  {
    "Skin.bmp"
  }
  {
    "Skin.bmp"
  }
  {
    "Skin.bmp"
  }
  {
    "Skin_Red.bmp"
  }
  {
    "Skin.bmp"
  }
  {
    "Skin.bmp"
  }
}

// attachment(s)
$attachment 0 "Gauss Master" 17.000000 -1.000000 0.000000

// hit box(es)
$hbox 0 "Gauss Master" -7.870000 -5.000000 -5.450000 16.980000 3.700000 2.680000

// animation sequence(s)
$sequence "idle" "idle" fps 15 loop 

// End of QC script.
