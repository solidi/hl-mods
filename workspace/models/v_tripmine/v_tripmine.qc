/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_tripmine.mdl

Original internal name:
"valve/models/v_tripmine.mdl"

==============================================================================
*/

$modelname "v_tripmine.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$bodygroup "hands"
{
studio "tripmine_hands"
blank
}

$bodygroup "mine"
{
studio "tripmine_mine"
studio "tripmine_boned_world"
}

$texturegroup ice
{
  {
    "..\gordon_GLOVE_handpak.bmp.bmp"
    "..\gordon_GLOVED_knuckle.bmp"
    "..\gordon_GLOVED_sleeve.bmp"
    "box.bmp"
    "face.bmp"
    "lensCHROME.bmp"
    "light.bmp"
    "side.bmp"
  }
  {
    "..\GLOVE_handpak.bmp.bmp"
    "..\GLOVED_knuckle.bmp"
    "..\GLOVED_sleeve.bmp"
    "invert_box.bmp"
    "invert_face.bmp"
    "invert_lensCHROME.bmp"
    "invert_light.bmp"
    "invert_side.bmp"
  }
  {
    "..\GLOVE_handpak.bmp.bmp"
    "..\GLOVED_knuckle.bmp"
    "..\GLOVED_sleeve.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
  {
    "..\GLOVE_handpak.bmp.bmp"
    "..\GLOVED_knuckle.bmp"
    "..\GLOVED_sleeve.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
  {
    "..\GLOVE_handpak.bmp.bmp"
    "..\GLOVED_knuckle.bmp"
    "..\GLOVED_sleeve.bmp"
    "box.bmp"
    "face.bmp"
    "lensCHROME.bmp"
    "light.bmp"
    "side.bmp"
  }
  {
    "..\GLOVE_handpak.bmp.bmp"
    "..\GLOVED_knuckle.bmp"
    "..\GLOVED_sleeve.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
  }
  {
    "..\GLOVE_handpak.bmp.bmp"
    "..\GLOVED_knuckle.bmp"
    "..\GLOVED_sleeve.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "Bip01 L Arm2" 0.000000 -1.770000 -1.570000 11.680000 1.030000 2.620000
$hbox 0 "Bip01 L Hand" -0.070000 -0.870000 -1.950000 3.890000 1.030000 1.700000
$hbox 0 "Bip01 R Arm2" 0.000000 -1.770000 -2.590000 11.368423 1.000000 1.570000
$hbox 0 "Bip01 R Hand" -0.070000 -0.870000 -1.790000 3.890000 1.030000 1.950000
$hbox 0 "Dummy22" -11.440000 -3.910000 -4.220000 11.460000 7.320000 5.430000

// animation sequence(s)
$sequence "idle1" "idle1" fps 30 loop 
$sequence "spin" "spin" fps 21 loop 
$sequence "idle2" "idle2" fps 30 loop 
$sequence "arm1" "arm1" fps 60 
$sequence "place" "place" fps 30 { event 5005 0 "hgrunt/c2a3_hg_laugh.wav" }
$sequence "fidget" "fidget" fps 30 loop 
$sequence "holster" "holster" fps 45 
$sequence "draw_lowkey" "draw" fps 60 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw" fps 60 { event 5004 0 "default_draw.wav" } { event 5005 0 "tripmine_selected.wav" }
$sequence "world" "world" fps 30 loop 
$sequence "ground" "ground" fps 30 loop 

// End of QC script.
