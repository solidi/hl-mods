/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_dual_smg.mdl

Original internal name:
"v_9mmar.mdl"

==============================================================================
*/

$modelname "v_dual_usas.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "usas_right"

$origin 0 0 -1

$bodygroup "arms"
{
studio "gordon_arms"
}

$bodygroup "leftgun"
{
studio "usas_left"
}

$texturegroup ice
{
  {
    "USAS-1.bmp"
    "USAS-2.bmp"
    "USAS-3.bmp"
    "..\gordon_glove.bmp"
    "..\gordon_sleeve.bmp"
  }
  {
    "invert_USAS-1.bmp"
    "invert_USAS-2.bmp"
    "invert_USAS-3.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "USAS-1.bmp"
    "USAS-2.bmp"
    "USAS-3.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\silverCHROME.bmp"
    "..\..\silverCHROME.bmp"
    "..\..\silverCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
}

// attachment(s)
$attachment 0 "Bone09" -13.500000 0.200000 -0.300000
$attachment 1 "Bone22" -13.000000 7.500000 -8.500000

// hit box(es)
$hbox 0 "Bone01" -4.930077 -8.806835 0.000000 0.000000 0.000000 4.555555
$hbox 0 "Bone02" -13.236908 -3.969946 -1.142586 0.000000 0.000000 9.111436
$hbox 0 "Bone03" -11.880000 -3.310000 -7.850000 0.550000 3.180000 0.190000
$hbox 0 "Bone04" -5.650000 -1.410000 -2.220000 1.360000 2.840000 2.370000
$hbox 0 "Bone05" -15.050000 -4.200000 -1.800000 2.470000 6.680000 0.870000
//$hbox 0 "Bone12" -2.330000 -7.350000 -1.270000 0.650000 0.850000 0.000000
$hbox 0 "Bone19" -15.890000 0.000000 -8.360000 0.000000 6.340000 1.880000
$hbox 0 "Bone20" -13.544948 0.000000 -6.601963 0.000000 3.169006 0.000000
$hbox 0 "Bone22" -5.090000 -1.730000 -5.460000 2.020000 3.620000 4.260785
$hbox 0 "Bone23" -1.550000 -1.030000 -0.860000 0.790000 1.750000 2.110000
$hbox 0 "Bone24" -1.540000 0.000000 -0.860000 0.000000 1.240000 0.310000
$hbox 0 "Bone06" -0.410000 -1.410000 -1.310000 2.480000 0.180000 0.810000
$hbox 0 "Bone33" -1.890000 -1.010000 -0.070000 0.000000 0.000000 1.120000
//$hbox 0 "joint30" -4.410000 -2.910000 -2.400000 5.540000 5.750000 15.220000
//$hbox 0 "joint31" -3.170000 -2.580000 0.000000 3.940000 3.290000 17.293789
//$hbox 0 "joint32" -8.990000 -4.890000 -0.520000 2.540000 2.220000 4.450000
$hbox 0 "leftgun" -0.520000 -6.140000 -2.210000 3.790000 6.720000 15.120000
//$hbox 0 "leftgun_mag" -0.960000 -4.690000 -1.450000 0.460000 3.060000 1.600000

// animation sequence(s)
$sequence "USAS_IDLE" "USAS_IDLE" fps 8 
$sequence "USAS_FIRE_BOTH1" "USAS_FIRE_BOTH1" fps 20 { event 5011 0 "4" } { event 5001 1 "4" }  
//$sequence "SMG_FIRE_BOTH2" "SMG_FIRE_BOTH2" fps 20 { event 6001 0 "11" } { event 5001 0 "11" } 
$sequence "USAS_RELOAD" "USAS_RELOAD_KEYS" fps 44 {
  { event 5004 14 "items/cliprelease1.wav" } 
  { event 5015 14 "0" } 
  { event 5004 48 "items/clipinsert1.wav" } 
  { event 5016 48 "0" } 
  { event 5004 70 "items/cliprelease1.wav" } 
  { event 5015 70 "0" } 
  { event 5004 97 "items/clipinsert1.wav" } 
  { event 5016 97 "0" } 
 }
$sequence "USAS_DEPLOY_LOWKEY" "USAS_DEPLOY" fps 76 { event 5004 0 "default_draw.wav" } { event 5004 5 "default_draw.wav" }  
$sequence "USAS_DEPLOY" "USAS_DEPLOY" fps 76 { event 5004 0 "default_draw.wav" } { event 5005 2 "dual_usas_selected.wav" } { event 5004 5 "default_draw.wav" }  
$sequence "USAS_HOLSTER" "USAS_HOLSTER" fps 57 
$sequence "USAS_FIRE_LEFT" "USAS_FIRE_LEFT" fps 20 { event 5011 1 "4" }  
$sequence "USAS_FIRE_RIGHT" "USAS_FIRE_RIGHT" fps 20 { event 5001 1 "4" } 

// End of QC script.
