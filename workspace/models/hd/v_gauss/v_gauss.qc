/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_gauss.mdl

Original internal name:
"c:/sierra/half-life/valve/models/v_gauss.mdl"

==============================================================================
*/

$modelname "v_gauss.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "gun" "gauss"

$texturegroup ice
{
  {
    "gaussCHROME.BMP"
    "glow.BMP"
    "V_GAUSS_REFERENCE.BMP"
  }
  {
    "invert_gaussCHROME.BMP"
    "invert_glow.BMP"
    "invert_V_GAUSS_REFERENCE.BMP"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
  }
  {
    "gaussCHROME.BMP"
    "glow.BMP"
    "V_GAUSS_REFERENCE.BMP"
  }
  {
    "..\..\silverCHROME.bmp"
    "..\..\silverCHROME.bmp"
    "..\..\silverCHROME.bmp"
  }
  {
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
    "..\..\goldCHROME.bmp"
  }
}

// attachment(s)
$attachment 0 "GaussMesh" -1.500000 -17.000000 0.000000

// hit box(es)
$hbox 0 "Bip01 R Hand" 0.000000 0.000000 0.000000 1.135289 1.147308 4.113231
$hbox 0 "GaussMesh" -4.080000 -15.460000 -3.800000 4.080000 4.090000 6.180000
$hbox 0 "Object02" -2.480000 -1.130000 -1.710000 2.480000 1.140000 2.600000

// animation sequence(s)
$sequence "idle" "idle" fps 15 loop 
$sequence "idle2" "idle2" fps 15 loop 
$sequence "fidget" "fidget" fps 30 
$sequence "spinup" "spinup" fps 30 loop 
$sequence "spin" "spin" fps 30 loop 
$sequence "fire" "fire" fps 30 
$sequence "fire2" "fire2" fps 30 
$sequence "holster" "holster" fps 90 
$sequence "draw_lowkey" "draw" fps 140 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw" fps 140 { event 5004 0 "default_draw.wav" } { event 5005 0 "gauss_selected.wav" } 

// End of QC script.
