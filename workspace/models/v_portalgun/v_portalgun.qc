/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

v_portalgun.mdl

Original internal name:
"v_portal.mdl"

==============================================================================
*/

$modelname "v_portalgun.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
//$body "portalgunhands" "portalgunhands"

$body "portalgungun1" "portalgungun1"

$body "portalgungun25" "portalgungun25"

$body "portalgungun26" "portalgungun26"

$body "portalgunglass" "portalgunglass"

$texrendermode "v_portalgun_glass.bmp" "additive" 

$texturegroup ice
{
  {
    "v_portalgun_glass.bmp"
    "v_portalgun.bmp"
  }
  {
    "invert_v_portalgun_glass.bmp"
    "invert_v_portalgun.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
  {
    "v_portalgun_glass.bmp"
    "v_portalgun.bmp"
  }
  {
    "..\silverCHROME.bmp"
    "..\silverCHROME.bmp"
  }
  {
    "..\goldCHROME.bmp"
    "..\goldCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "ValveBiped.Bip01_R_UpperArm" 0.000000 -2.110000 -1.540000 12.250000 1.170000 1.730000
$hbox 0 "ValveBiped.Bip01_R_Forearm" -0.280000 -1.540000 -1.710000 11.980000 1.650000 1.490000
$hbox 0 "ValveBiped.Bip01_R_Hand" -0.520000 -1.230000 -1.730000 4.240000 0.900000 1.790000
#$hbox 0 "ValveBiped.Bip01_R_Finger0" -0.560000 -0.900000 -0.710000 1.435386 0.890000 1.000000
#$hbox 0 "ValveBiped.Bip01_R_Finger01" 0.000000 -0.810000 -0.570000 1.316729 0.360000 0.740000
$hbox 0 "ValveBiped.Base" -3.410000 -0.460000 0.000000 3.940000 5.700000 22.656487
$hbox 0 "ValveBiped.Front_Cover" -4.896677 -2.690000 -9.245951 5.318144 6.422513 4.420000
$hbox 0 "ValveBiped.Front_Cover_Stop" -2.130000 -0.810000 -3.520000 2.570000 3.980000 0.030000
$hbox 0 "ValveBiped.Arm2_A" -0.630000 -0.710000 -1.230000 0.640000 2.940000 2.320000
$hbox 0 "ValveBiped.Arm3_A" -0.680000 -0.740000 -1.140000 0.590000 2.940000 2.380000
$hbox 0 "ValveBiped.Arm1_A" -0.650000 -0.810000 -1.250000 0.630000 2.950000 2.250000

// animation sequence(s)
$sequence "idle" "idle" fps 16 
$sequence "shoot1" "shoot1" fps 30 
$sequence "shoot2" "shoot2" fps 30 
$sequence "shoot3" "shoot3" fps 30 
$sequence "shootlast" "shootlast" fps 32 
$sequence "reload" "reload" fps 37 
$sequence "holster" "holster" fps 72
$sequence "draw_lowkey" "draw" fps 36 { event 5004 0 "default_draw.wav" } 
$sequence "draw" "draw" fps 36 { event 5004 0 "default_draw.wav" } { event 5005 0 "portalgun_selected.wav" } 
$sequence "shoot1_unsil" "shoot1_unsil" fps 30 
$sequence "shoot2_unsil" "shoot2_unsil" fps 30 

// End of QC script.
