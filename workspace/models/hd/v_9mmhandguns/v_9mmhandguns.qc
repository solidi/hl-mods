/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_9mmhandguns.mdl

Original internal name:
"v_9mmhandgun.mdl"

==============================================================================
*/

$modelname "v_9mmhandguns.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "hands" "v_gordon_hands_ref"

$body "beretta" "beretta"

$body "clip" "clip_reference"

$body "clip" "silencer"

$texturegroup ice
{
  {
    "bulletCHROME.BMP"
    "chrome_black.BMP"
    "chrome.bmp"
    "gclip.bmp"
    "gclipinside.bmp"
    "v_beretta_bottom.BMP"
    "v_beretta_main.BMP"
    "..\gordon_sleeve.bmp"
    "..\gordon_glove.bmp"
  }
  {
    "invert_bulletCHROME.BMP"
    "invert_chrome_black.BMP"
    "invert_chrome.bmp"
    "invert_gclip.bmp"
    "invert_gclipinside.bmp"
    "invert_v_beretta_bottom.BMP"
    "invert_v_beretta_main.BMP"
    "..\iceSleeve.bmp"
    "..\iceGlove.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\iceSleeve.bmp"
    "..\iceGlove.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceSleeve.bmp"
    "..\iceGlove.bmp"
  }
  {
    "bulletCHROME.BMP"
    "chrome_black.BMP"
    "chrome.bmp"
    "gclip.bmp"
    "gclipinside.bmp"
    "v_beretta_bottom.BMP"
    "v_beretta_main.BMP"
    "..\iceSleeve.bmp"
    "..\iceGlove.bmp"
  }
  {
    "..\..\silverChrome.bmp"
    "..\..\silverChrome.bmp"
    "..\..\silverChrome.bmp"
    "..\..\silverChrome.bmp"
    "..\..\silverChrome.bmp"
    "..\..\silverChrome.bmp"
    "..\..\silverChrome.bmp"
    "..\iceSleeve.bmp"
    "..\iceGlove.bmp"
  }
  {
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\iceSleeve.bmp"
    "..\iceGlove.bmp"
  }
}

// attachment(s)
$attachment 0 "Bip01 R Hand" 12.000000 2.250000 4.250000
// aim
$attachment 1 "Bip01 R Hand" 2.0 5.0 8.0

// hit box(es)
$hbox 0 "Bip01 L Hand" 0.000000 -1.240000 -1.820000 3.930000 0.870000 1.700000
$hbox 0 "Bip01 L Finger01" -0.100000 -0.730000 -0.620000 1.071903 0.370000 0.450000
$hbox 0 "L_Arm_bone" -2.340000 -2.920000 -2.040000 2.340000 2.250000 8.240000
$hbox 0 "Bip01 R Hand" 0.000000 -1.240000 -1.700000 3.930000 0.949478 3.273725
$hbox 0 "Bip01 R Finger01" -0.100000 -0.730000 -0.450000 1.071902 0.370000 0.620000
$hbox 0 "R_Arm_bone" -2.170000 -2.920000 -2.020000 2.510000 2.250000 8.270000
$hbox 0 "Hands mesh" -0.870000 -6.840000 -6.780000 1.240000 3.200000 2.760000
$hbox 0 "Hands mesh 2" -0.950000 -2.340000 -4.570000 0.800000 1.580000 4.150000

// animation sequence(s)
$sequence "aim" "aim" fps 16 loop 
$sequence "idle1" "idle1" fps 16 loop 
$sequence "idle2" "idle2" fps 16 loop 
$sequence "idle3" "idle3" fps 14 loop 
$sequence "shoot" "shoot" fps 28 
$sequence "shoot_empty" "shoot_empty" fps 28 
$sequence "reload" "reload" fps 25 { event 5004 4 "items/9mmclip2.wav" } { event 5004 23 "items/9mmclip1.wav" } 
$sequence "reload_noshot" "reload_noshot" fps 25 { event 5004 4 "items/9mmclip2.wav" } { event 5004 23 "items/9mmclip1.wav" } 
$sequence "draw_lowkey" "draw" fps 45 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw" fps 45 { event 5004 0 "default_draw.wav" } 
$sequence "holster" "holster" fps 60 

// End of QC script.
