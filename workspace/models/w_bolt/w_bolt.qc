/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_bolt.mdl

Original internal name:
"valve/models/crossbow_bolt.mdl"

==============================================================================
*/

$modelname "w_bolt.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "crossbow_bolt"

$texturegroup ice
{
  {
    "boltCHROME.bmp"
    "finCHOME.bmp"
  }
  {
    "invert_boltCHROME.bmp"
    "invert_finCHOME.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
}

// 1 hit box(es)
$hbox 0 "Crossbow03" -1.900000 -0.140000 -1.910000 1.900000 25.000000 1.910000

// 1 animation sequence(s)
$sequence "idle" "idle" fps 30 

// End of QC script.
