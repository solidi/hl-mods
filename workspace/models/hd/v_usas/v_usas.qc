/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_9mmAR.mdl

Original internal name:
"c:\sierra\half-life\valve\models\v_9mmAR.mdl"

==============================================================================
*/

$modelname "v_usas.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "usas_scaled"

$body "studio" "v_gordon_hands_reference"

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
$attachment 0 "carbine" 0.500000 -27.000000 2.000000
// aim
$attachment 1 "carbine" 3.0 3.0 5.5

// hit box(es)
$hbox 0 "carbine" -0.390000 -26.900000 -4.740000 1.880000 5.480000 6.030000
$hbox 0 "tube" -1.340000 -7.290000 -3.780000 1.340000 7.190000 0.120000
$hbox 0 "Bip01 L Hand" 0.000000 -0.960000 -1.820000 3.910000 0.900000 1.710000
$hbox 0 "Bip01 L Finger0" 0.000000 -0.950000 -0.570000 2.450000 0.380000 0.970000
$hbox 0 "L_Arm_bone" -1.920000 -2.640000 -2.300000 2.760000 2.490000 7.980000
$hbox 0 "Bip01 R Hand" 0.000000 -0.990000 -1.710000 3.920000 0.870000 1.820000
$hbox 0 "Bip01 R Finger0" 0.000000 -0.940000 -1.000000 2.450000 0.390000 0.540000
$hbox 0 "R_Arm_bone" -2.620000 -2.640000 -2.290000 2.060000 2.490000 7.990000

// animation sequence(s)
$sequence "aim" "aim" fps 35
$sequence "longidle" "longidle" fps 8  
$sequence "idle1" "idle1" fps 35
$sequence "idle2" "idle1" fps 35
$sequence "reload" "reload_2" fps 30 { event 5005 5 "usas_gogogo.wav" } { event 5004 5 "usas_release.wav" } { event 5004 24 "usas_insert.wav" } { event 5004 27 "usas_cock.wav" } 
$sequence "draw_lowkey" "deploy" fps 44 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "deploy" fps 44 { event 5004 0 "default_draw.wav" } { event 5005 0 "usas_selected.wav" } 
$sequence "shoot_1" "shoot_1" fps 10 { event 5001 0 "4" } 
$sequence "shoot_2" "shoot_1" fps 10 { event 5001 0 "4" } 
$sequence "shoot_3" "shoot_1" fps 10 { event 5001 0 "4" } 
$sequence "holster" "holster" fps 33 

// End of QC script.
