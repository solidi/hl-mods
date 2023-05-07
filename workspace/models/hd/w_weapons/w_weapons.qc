$modelname "w_weapons.mdl"
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
studio "..\w_crowbar\crowbar"
studio "..\w_knife\knife"
studio "..\w_wrench\wrench"
studio "..\w_chainsaw\chainsaw"
studio "..\w_rocketcrowbar\rocketcrowbar"
studio "..\..\w_gravitygun\gravitygun_hd"
studio "..\..\w_portalgun\portalgun_front_hd"
studio "..\w_9mmhandguns\silencer"
studio "..\w_357\python"
studio "..\w_deagle\deagle"
studio "..\w_mag60\mag60"
studio "..\w_smg\smg"
}

$bodygroup "addition"
{
blank
blank
blank
blank
blank
blank
studio "..\..\w_portalgun\portalgun_back_hd"
}


$texturegroup ice
{
  {
    "..\w_crowbar\wbottom.bmp"
    "..\w_crowbar\wnut.bmp"
    "..\w_crowbar\wtop.bmp"
    "..\w_knife\body.bmp"
    "..\w_wrench\pipewrench.bmp"
    "..\w_chainsaw\chainsaw_p.BMP"
    "..\w_rocketcrowbar\crowbar_01.bmp"
    "..\w_rocketcrowbar\chrome.bmp"
    "..\w_rocketcrowbar\rocket.bmp"
    "..\w_rocketcrowbar\rocketmotor.bmp"
    "..\..\w_gravitygun\grav_1.BMP"
    "..\..\w_gravitygun\lense.BMP"
    "..\..\w_gravitygun\phys_stuff.BMP"
    "..\..\w_gravitygun\Portal_1.BMP"
    "..\..\w_gravitygun\Portal_2.BMP"
    "..\..\w_gravitygun\v_portalgun.BMP"
    "..\..\w_gravitygun\v_superphyscannon_sheet.BMP"
    "..\..\w_portalgun\w_portalgun.bmp"
    "..\w_9mmhandguns\chrome.bmp"
    "..\w_9mmhandguns\glockfront.bmp"
    "..\w_9mmhandguns\v_beretta_main.bmp"
    "..\w_357\wmodel.bmp"
    "..\w_deagle\w_deagle.bmp"
    "..\w_mag60\wmodel.bmp"
    "..\w_smg\wmodel1.bmp"
  }
  {
    "..\w_crowbar\invert_wbottom.bmp"
    "..\w_crowbar\invert_wnut.bmp"
    "..\w_crowbar\invert_wtop.bmp"
    "..\w_knife\invert_body.bmp"
    "..\w_wrench\invert_pipewrench.bmp"
    "..\w_chainsaw\invert_chainsaw_p.BMP"
    "..\w_rocketcrowbar\invert_crowbar_01.bmp"
    "..\w_rocketcrowbar\invert_chrome.bmp"
    "..\w_rocketcrowbar\invert_rocket.bmp"
    "..\w_rocketcrowbar\invert_rocketmotor.bmp"
    "..\..\w_gravitygun\invert_grav_1.BMP"
    "..\..\w_gravitygun\invert_lense.BMP"
    "..\..\w_gravitygun\invert_phys_stuff.BMP"
    "..\..\w_gravitygun\invert_Portal_1.BMP"
    "..\..\w_gravitygun\invert_Portal_2.BMP"
    "..\..\w_gravitygun\invert_v_portalgun.BMP"
    "..\..\w_gravitygun\invert_v_superphyscannon_sheet.BMP"
    "..\..\w_portalgun\invert_w_portalgun.bmp"
    "..\w_9mmhandguns\invert_chrome.bmp"
    "..\w_9mmhandguns\invert_glockfront.bmp"
    "..\w_9mmhandguns\invert_v_beretta_main.bmp"
    "..\w_357\invert_wmodel.bmp"
    "..\w_deagle\invert_w_deagle.bmp"
    "..\w_mag60\invert_wmodel.bmp"
    "..\w_smg\invert_wmodel1.bmp"
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
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
    "..\iceCHROME.bmp"
  }
}

// hit box(es)
$hbox 0 "crowbar" -1.250000 -2.170000 -22.530001 8.420000 2.170000 22.549999
$hbox 0 "knife" -12.860000 -29.110001 -3.920000 7.700000 28.840000 3.780000
$hbox 0 "wrench" -2.580000 -1.360000 -4.290000 7.550000 1.360000 39.070000
$hbox 0 "chainsaw" -3.800000 -21.639999 0.000000 4.490000 12.700000 27.639999
$hbox 0 "rocketcrowbar" -1.250000 -2.170000 -22.530001 8.420000 2.170000 22.549999
$hbox 0 "gravitygun" -7.990000 -31.690001 -9.770000 6.210000 40.860001 11.980000
$hbox 0 "portalgun" -13.480000 -9.130000 -3.610000 8.650000 8.440000 7.050000
$hbox 0 "silencer" -4.890000 -6.370000 -0.840000 4.890000 6.370000 0.840000
$hbox 0 "python" -4.890000 -6.370000 -0.840000 4.890000 6.370000 0.840000
$hbox 0 "deagle" -10.620000 -1.080000 -6.170000 12.060000 1.160000 5.640000
$hbox 0 "mag60" -7.190000 -11.110000 -0.840000 8.930000 9.650000 1.600000
$hbox 0 "smg" -13.060000 -10.490000 -0.910000 21.250000 8.930000 2.750000

// animation sequence(s)
$sequence "crowbar_idle" "..\w_crowbar\idle" fps 30 
$sequence "crowbar_spin" "..\w_crowbar\spin" fps 21 loop 
$sequence "knife_idle" "..\w_knife\idle" fps 30 
$sequence "knife_spin" "..\w_knife\spin" fps 21 loop 
$sequence "wrench_idle" "..\w_wrench\idle" fps 30 
$sequence "wrench_spin" "..\w_wrench\spin" fps 21 loop 
$sequence "chainsaw_idle" "..\w_chainsaw\idle" fps 30 
$sequence "chainsaw_spin" "..\w_chainsaw\spin" fps 21 loop 
$sequence "rocketcrowbar_idle" "..\w_rocketcrowbar\idle" fps 30 
$sequence "rocketcrowbar_spin" "..\w_rocketcrowbar\spin" fps 21 loop 
$sequence "gravitygun_idle" "..\..\w_gravitygun\idle" fps 30 
$sequence "gravitygun_spin" "..\..\w_gravitygun\spin" fps 21 loop 
$sequence "portalgun_idle" "..\..\w_portalgun\idle" fps 30 
$sequence "portalgun_spin" "..\..\w_portalgun\spin" fps 21 loop 
$sequence "silencer_idle" "..\w_9mmhandguns\idle" fps 30 
$sequence "silencer_spin" "..\w_9mmhandguns\spin" fps 21 loop 
$sequence "python_idle" "..\w_357\idle" fps 30 
$sequence "python_spin" "..\w_357\spin" fps 21 loop 
$sequence "deagle_idle" "..\w_deagle\idle" fps 30 
$sequence "deagle_spin" "..\w_deagle\spin" fps 21 loop 
$sequence "mag60_idle" "..\w_mag60\idle" fps 30 
$sequence "mag60_spin" "..\w_mag60\spin" fps 21 loop 
$sequence "smg_idle" "..\w_smg\idle" fps 30 
$sequence "smg_spin" "..\w_smg\spin" fps 21 loop 

// End of QC script.
