$modelname "p_weapons.mdl"
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
studio "..\p_crowbar\crowbar"
studio "..\p_knife\knife"
studio "..\p_wrench\wrench"
studio "..\p_chainsaw\chainsaw"
studio "..\p_rocketcrowbar\rocketcrowbar"
studio "..\..\p_gravitygun\gravitygun_hd"
studio "..\..\p_portalgun\p_portalgun_1_hd"
}

$bodygroup "addition_1"
{
blank
blank
blank
blank
blank
blank
studio "..\..\p_portalgun\p_portalgun_2_hd"
}

$bodygroup "addition_2"
{
blank
blank
blank
blank
blank
blank
studio "..\..\p_portalgun\p_portalgun_3_hd"
}

$texrendermode "..\p_chainsaw\chainsaw_p.BMP" "masked"

$texturegroup ice
{
  {
    "..\p_crowbar\wbottom.bmp"
    "..\p_crowbar\wnut.bmp"
    "..\p_crowbar\wtop.bmp"
    "..\p_knife\body.bmp"
    "..\p_wrench\pipewrench.bmp"
    "..\p_chainsaw\chainsaw_p.BMP"
    "..\p_rocketcrowbar\crowbar_01.bmp"
    "..\p_rocketcrowbar\chrome.bmp"
    "..\p_rocketcrowbar\rocket.bmp"
    "..\p_rocketcrowbar\rocketmotor.bmp"
    "..\..\p_gravitygun\grav_1.BMP"
    "..\..\p_gravitygun\lense.BMP"
    "..\..\p_gravitygun\phys_stuff.BMP"
    "..\..\p_gravitygun\Portal_1.BMP"
    "..\..\p_gravitygun\Portal_2.BMP"
    "..\..\p_gravitygun\v_portalgun.BMP"
    "..\..\p_gravitygun\v_superphyscannon_sheet.BMP"
    "..\..\p_portalgun\v_portalgun_glass.bmp"
    "..\..\p_portalgun\w_portalgun.bmp"
  }
  {
    "..\p_crowbar\invert_wbottom.bmp"
    "..\p_crowbar\invert_wnut.bmp"
    "..\p_crowbar\invert_wtop.bmp"
    "..\p_knife\invert_body.bmp"
    "..\p_wrench\invert_pipewrench.bmp"
    "..\p_chainsaw\invert_chainsaw_p.BMP"
    "..\p_rocketcrowbar\invert_crowbar_01.bmp"
    "..\p_rocketcrowbar\invert_chrome.bmp"
    "..\p_rocketcrowbar\invert_rocket.bmp"
    "..\p_rocketcrowbar\invert_rocketmotor.bmp"
    "..\..\p_gravitygun\invert_grav_1.BMP"
    "..\..\p_gravitygun\invert_lense.BMP"
    "..\..\p_gravitygun\invert_phys_stuff.BMP"
    "..\..\p_gravitygun\invert_Portal_1.BMP"
    "..\..\p_gravitygun\invert_Portal_2.BMP"
    "..\..\p_gravitygun\invert_v_portalgun.BMP"
    "..\..\p_gravitygun\invert_v_superphyscannon_sheet.BMP"
    "..\..\p_portalgun\invert_v_portalgun_glass.bmp"
    "..\..\p_portalgun\invert_w_portalgun.bmp"
  }
  {
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
    "..\..\ringchrome.bmp"
  }
  {
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "crowbar" -0.730000 -1.330000 -13.150000 4.860000 1.200000 13.170000
// Knife?
$hbox 0 "wrench" -1.550000 -0.810000 -2.570000 4.530000 0.830000 23.450001
$hbox 0 "chainsaw" -6.570000 -42.689999 -4.490000 10.830000 1.140000 3.840000
$hbox 0 "rocketcrowbar" -0.730000 -1.330000 -13.150000 4.860000 1.200000 13.170000
$hbox 0 "gravitygun" -7.990000 -31.690001 -9.770000 6.210000 40.860001 11.980000
$hbox 0 "portalgun" -1.180000 -0.880000 -7.840000 1.260000 11.440000 28.809999

// animation sequence(s)
$sequence "crowbar_idle" "..\p_crowbar\idle" fps 30 
$sequence "knife_idle" "..\p_knife\idle" fps 30 
$sequence "wrench_idle" "..\p_wrench\idle" fps 30 
$sequence "chainsaw_idle" "..\p_chainsaw\idle" fps 30 
$sequence "rocketcrowbar_idle" "..\p_rocketcrowbar\idle" fps 30 
$sequence "gravitygun_idle" "..\..\p_gravitygun\idle" fps 30 
$sequence "portalgun_idle" "..\..\p_portalgun\idle" fps 30 

// End of QC script.
