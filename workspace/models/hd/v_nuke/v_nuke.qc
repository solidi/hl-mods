/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_nuke.mdl

Original internal name:
"v_BFG.mdl"

==============================================================================
*/

$modelname "v_nuke.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "nuke"

$texturegroup ice
{
  {
    "1.bmp"
    "2.bmp"
    "flashlig.bmp"
    "SRRAILM4.bmp"
    "w_clip_bfg.bmp"
    "..\gordon_glove.bmp"
    "..\gordon_sleeve.bmp"
  }
  {
    "invert_1.bmp"
    "invert_2.bmp"
    "invert_flashlig.bmp"
    "invert_SRRAILM4.bmp"
    "invert_w_clip_bfg.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
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
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "1.bmp"
    "2.bmp"
    "flashlig.bmp"
    "SRRAILM4.bmp"
    "w_clip_bfg.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
  {
    "..\..\silverCHROME.bmp"
    "..\..\silverCHROME.bmp"
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
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\iceGlove.bmp"
    "..\iceSleeve.bmp"
  }
}


// attachment(s)
$attachment 0 "Rlauncher" 5.000000 -38.000000 5.000000

// hit box(es)
$hbox 0 "Rlauncher" -4.280000 -16.423262 -8.050000 2.550000 9.460000 5.940000

// animation sequence(s)
$sequence "idle1" "idle1" fps 15 
$sequence "idle2" "idle2" fps 15 
$sequence "reload" "reload" fps 14
$sequence "fire" "fire" fps 30 
$sequence "fire_solid" "fire_solid" fps 30 
$sequence "holster" "holster" fps 45 
$sequence "draw_lowkey" "draw" fps 60 { event 5004 0 "nuke_draw.wav" } 
$sequence "draw" "draw" fps 60 { event 5004 0 "nuke_draw.wav" } { event 5005 0 "nuke_selected.wav" } 
$sequence "spinup" "spinup" fps 30

// End of QC script.
