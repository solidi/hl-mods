/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_12gauge.mdl

Original internal name:
"tfc/models/v_tfc_12gauge.mdl"

==============================================================================
*/

$modelname "v_12gauge.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "12gauge"

$body "studio" "shell"

$texturegroup ice
{
  {
    "12gauge_chrome.bmp"
    "12gauge_pump.bmp"
    "12gauge_receiver.bmp"
    "12gauge_stock.bmp"
    "shell.bmp"
    "..\gordon_GLOVED_sleeve.bmp"
  }
  {
    "invert_12gauge_chrome.bmp"
    "invert_12gauge_pump.bmp"
    "invert_12gauge_receiver.bmp"
    "invert_12gauge_stock.bmp"
    "invert_shell.bmp"
    "..\GLOVED_sleeve.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\GLOVED_sleeve.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\GLOVED_sleeve.bmp"
  }
  {
    "12gauge_chrome.bmp"
    "12gauge_pump.bmp"
    "12gauge_receiver.bmp"
    "12gauge_stock.bmp"
    "shell.bmp"
    "..\GLOVED_sleeve.bmp"
  }
  {
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\GLOVED_sleeve.bmp"
  }
  {
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\GLOVED_sleeve.bmp"
  }
}

// attachment(s)
$attachment 0 "Bip01 R Hand" 30.000000 1.000000 6.000000
// aim
$attachment 1 "Bip01 R Hand" 3.0 2.5 5.5
// angles
$attachment 2 "Bip01 R Hand" 10.0 0.0 0.0

// hit box(es)
$hbox 0 "Bip01 L Arm2" 0.000000 -2.030000 -2.940000 12.710000 1.840000 2.200000
$hbox 0 "Bip01 L Hand" 0.000000 -0.790000 -1.770000 4.120000 1.250000 1.890000
$hbox 0 "Bip01 L Finger0" -0.120000 -1.220000 -0.320000 1.450000 0.660000 0.840000
$hbox 0 "Bip01 R Hand" -5.190000 -0.570000 -0.590000 24.370001 1.460000 5.790000
$hbox 0 "Bone01" -0.540000 -1.840000 -1.900000 6.900000 1.030000 1.790000

// animation sequence(s)
$sequence "sm_idle" "sm_idle" fps 9 loop 
$sequence "idle4" "idle4" fps 9 loop 
$sequence "draw_lowkey" "draw" fps 52 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw" fps 52 { event 5004 0 "default_draw.wav" } { event 5005 0 "12gauge_selected.wav" }
$sequence "shoot" "shoot" fps 20 { event 5001 0 "31" } 
$sequence "start_reload" "start_reload" fps 12 
$sequence "reload" "reload" fps 16 
$sequence "pump" "pump" fps 13 
$sequence "reholster" "reholster" fps 33 
$sequence "shoot_big" "shoot_big" fps 13 { event 5001 0 "41" } 
$sequence "deepidle" "deepidle" fps 12 loop 

// End of QC script.
