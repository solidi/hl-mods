/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_crossbow.mdl

Original internal name:
"c:/sierra/half-life/valve/models/v_crossbow.mdl"

==============================================================================
*/

$modelname "v_crossbow.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "crossbow"

$body "body" "v_gordon_hands_Reference"

$texturegroup ice
{
  {
    "bowCHROME.bmp"
    "lensCHROME.bmp"
    "v_crossbow_Reference.bmp"
    "..\gordon_glove.bmp"
    "..\gordon_sleeve.bmp"
  }
  {
    "invert_bowCHROME.bmp"
    "invert_lensCHROME.bmp"
    "invert_v_crossbow_Reference.bmp"
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
    "bowCHROME.bmp"
    "lensCHROME.bmp"
    "v_crossbow_Reference.bmp"
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
$attachment 0 "Bip01 R Hand" 0.0 0.0 0.0
// aim
$attachment 1 "Bip01 R Hand" 2.0 5.0 8.0
// angles
$attachment 2 "Bip01 R Hand" 0.0 -7.0 0.0

// hit box(es)
$hbox 0 "Bip01 R Hand" 0.000000 -0.990000 -1.710000 3.920000 1.946522 4.704309
$hbox 0 "crossbow parent" -3.940000 -20.639999 -5.310000 3.960000 6.860000 3.590000
$hbox 0 "grip" -4.000000 -10.388143 -2.752418 4.000000 5.101495 0.485730
$hbox 0 "Slide" -1.650000 -3.389288 -3.590000 4.050000 1.690000 0.450000
$hbox 0 "Bip01 L Hand" 0.000000 -0.960000 -1.820000 3.910000 0.900000 1.710000
$hbox 0 "Bip01 L Finger0" 0.000000 -0.950000 -0.570000 2.450000 0.380000 0.970000
$hbox 0 "L_Arm_bone" -1.920000 -2.640000 -2.300000 2.760000 2.490000 7.980000
$hbox 0 "Bip01 R Finger0" 0.000000 -0.940000 -1.000000 2.450000 0.390000 0.540000
$hbox 0 "R_Arm_bone" -2.620000 -2.640000 -2.290000 2.060000 2.490000 7.990000

// animation sequence(s)
$sequence "idle1" "idle1" fps 30 loop 
$sequence "idle2" "idle2" fps 30 loop 
$sequence "fidget1" "fidget1" fps 30 
$sequence "fidget2" "fidget2" fps 30 
$sequence "fire1" "fire1" fps 60 
$sequence "fire2" "fire2" fps 30 
$sequence "fire3" "fire3" fps 30 
$sequence "reload" "reload" fps 30 
$sequence "draw_lowkey" "draw1" fps 64 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw1" fps 64 { event 5004 0 "default_draw.wav" } { event 5005 0 "boltgun_selected.wav" }
$sequence "draw2" "draw2" fps 64 { event 5004 0 "default_draw.wav" } { event 5005 0 "boltgun_selected.wav" }
$sequence "holster1" "holster1" fps 48 
$sequence "holster2" "holster2" fps 48 

// End of QC script.
