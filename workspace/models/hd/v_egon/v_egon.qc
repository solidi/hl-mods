/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_egon.mdl

Original internal name:
"c:/sierra/half-life/valve/models/v_egon.mdl"

==============================================================================
*/

$modelname "v_egon.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "egon"

$body "body" "v_gordon_hands_reference"

$texturegroup ice
{
  {
    "v_egon_reference.BMP"
    "..\gordon_glove.bmp"
    "..\gordon_sleeve.bmp"
  }
  {
    "invert_v_egon_reference.BMP"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "v_egon_reference.BMP"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\silverCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\goldCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
}


// attachment(s)
$attachment 0 "egon" 0.000000 0.000000 17.000000

// hit box(es)
$hbox 0 "Bip01 R Hand" 0.000000 -0.990000 -1.710000 3.920000 1.150015 5.622992
$hbox 0 "egon" -6.210000 -2.410000 0.000000 9.750000 3.400000 16.980000
$hbox 0 "Bip01 L Hand" 0.000000 -0.960000 -1.820000 3.910000 0.900000 1.710000
$hbox 0 "Bip01 L Finger0" 0.000000 -0.950000 -0.570000 2.450000 0.380000 0.970000
$hbox 0 "L_Arm_bone" -1.920000 -2.640000 -2.300000 2.760000 2.490000 7.980000
$hbox 0 "Bip01 R Finger0" 0.000000 -0.940000 -1.000000 2.450000 0.390000 0.540000
$hbox 0 "R_Arm_bone" -2.620000 -2.640000 -2.290000 2.060000 2.490000 7.990000

// animation sequence(s)
$sequence "idle1" "idle1" fps 30 loop 
$sequence "fidget1" "fidget1" fps 30  { event 5005 0 "egon_switch.wav" } { event 5004 24 "weapons/dryfire1.wav" } { event 5004 40 "weapons/dryfire1.wav" } 
$sequence "altfireon" "altfireon" fps 30 loop 
$sequence "altfirecycle" "altfirecycle" fps 30 loop 
$sequence "altfireoff" "altfireoff" fps 30 loop 
$sequence "fire1" "fire1" fps 30 loop 
$sequence "fire2" "fire2" fps 30 loop 
$sequence "fire3" "fire3" fps 30 loop 
$sequence "fire4" "fire4" fps 30 loop 
$sequence "draw_lowkey" "draw" fps 60 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw" fps 60 { event 5004 0 "default_draw.wav" } { event 5005 0 "egon_selected.wav" }
$sequence "holster" "holster" fps 45 

// End of QC script.
