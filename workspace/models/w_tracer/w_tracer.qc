/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_tracer.mdl

Original internal name:
"valve/models/hornet.mdl"

==============================================================================
*/

$modelname "w_tracer.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "tracer"

$texturegroup ice
{
  {
    "tracer_deep.bmp"
  }
  {
    "invert_tracer_deep.bmp"
  }
  {
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
  }
}

$texrendermode "tracer_deep.bmp" "additive" 
$texrendermode "tracer_deep.bmp" "masked" 

// hit box(es)
$hbox 0 "tracer" -7.090000 -1.900000 -0.600800 2.880000 2.280000 0.632300

// animation sequence(s)
$sequence "idle" "idle" fps 30 loop 

// End of QC script.
