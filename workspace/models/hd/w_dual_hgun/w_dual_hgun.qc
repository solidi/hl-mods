/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_hgun.mdl

Original internal name:
"c:\sierra\half-life\valve\models\w_Hgun.mdl"

==============================================================================
*/

$modelname "w_dual_hgun.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "dual_hgun"

$texturegroup ice
{
  {
    "w_hivehand.bmp"
  }
  {
    "invert_w_hivehand.bmp"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}


// hit box(es)
$hbox 0 "dual_hgun" -10.140000 -9.360000 -23.620001 11.280000 11.370000 46.910000

// animation sequence(s)
$sequence "idle" "idle" fps 1 
$sequence "spin" "spin" fps 21 loop  

// End of QC script.
