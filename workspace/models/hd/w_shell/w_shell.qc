/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

w_shell.mdl

Original internal name:
"c:/sierra/half-life/valve/models/shell.mdl"

==============================================================================
*/

$modelname "w_shell.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "studio" "shell_reference"

$texturegroup ice
{
  {
    "shell.bmp"
  }
  {
    "invert_shell.bmp"
  }
  {
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
  }
}


// 1 hit box(es)
$hbox 0 "SHELL" -0.570000 -0.570000 -1.510000 0.570000 0.570000 1.510000

// 1 animation sequence(s)
$sequence "shell" "shell" fps 30 

// End of QC script.
