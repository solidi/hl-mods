/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_chaingun.mdl

Original internal name:
"D:\stuff\_coldIce\models\vulcan\compile2\v_vulcan.mdl"

==============================================================================
*/

$modelname "v_dual_chaingun.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$bodygroup "body"
{
studio "chaingun_right"
studio "dual_chaingun_r_hands"
}

// Slightly pull foward, and rotate right.
$origin 0 2 0 2


$texturegroup ice
{
  {
    "..\gordon_glove.bmp"
    "..\gordon_sleeve.bmp"
    "chrome1.bmp"
  }
  {
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
    "invert_chrome1.bmp"
  }
  {
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
    "..\iceCHROME.bmp"
  }
  {
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
    "chrome1.bmp"
  }
  {
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
    "..\..\silverCHROME.bmp"
  }
  {
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
    "..\..\goldCHROME.bmp"
  }
}

// attachment(s)
$attachment 0 "Bip01 R Arm2" 0.000000 1.920000 25.049999
$attachment 1 "Bip01 L Arm2" 0.000000 1.920000 25.049999
// aim
$attachment 2 "Bip01 R Arm2" 8.0 2.0 6.0

// hit box(es)
$hbox 0 "Bip01 L Arm2" 0.000000 -2.800000 -1.730000 11.680000 3.020000 4.000000
$hbox 0 "Bip01 L Hand" 0.000000 -0.870000 -1.940000 3.890000 1.030000 1.790000

// animation sequence(s)
$sequence "idle1" "idle1" fps 30 
$sequence "idle1" "idle1" fps 30 
$sequence "spinup" "spinup_shift3" loop fps 20 
$sequence "spindown" "spindown" fps 21 { event 5005 15 "chaingun_hellyeah.wav" }
$sequence "shoot" "shoot" fps 45 loop { event 5001 0 "4" } 
$sequence "shoot_both" "shoot" fps 45 loop { event 5001 0 "4" } { event 5011 3 "4" } 
$sequence "draw_lowkey" "draw_shift2" fps 16 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw_shift2" fps 16 { event 5004 0 "default_draw.wav" } { event 5005 0 "dual_chaingun_selected.wav" }
$sequence "holster" "holster_shift2" fps 21 
$sequence "reload" "reload_shift3" fps 4

// End of QC script.
