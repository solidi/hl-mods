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
studio "..\p_gravitygun\gravitygun"
studio "..\p_portalgun\p_portalgun_1"
studio "..\p_9mmhandguns\glock"
studio "..\p_357\python"
studio "..\p_deagle\deagle"
studio "..\p_mag60\mag60"
studio "..\p_smg\smg"
studio "..\p_sawedoff\sawedoff"
}

$bodygroup "body"
{
blank
blank
blank
blank
blank
blank
studio "..\p_portalgun\p_portalgun_2"
}

$bodygroup "body"
{
blank
blank
blank
blank
blank
blank
studio "..\p_portalgun\p_portalgun_3"
}

$texturegroup ice
{
  {
    "..\p_crowbar\p_pipe.bmp"
    "..\p_knife\Chrome2.BMP"
    "..\p_knife\Spyknife1.BMP"
    "..\p_wrench\spanner_text.bmp"
    "..\p_wrench\spannerCHROME.bmp"
    "..\p_chainsaw\box.bmp"
    "..\p_chainsaw\fuel.bmp"
    "..\p_chainsaw\dedo.bmp"
    "..\p_chainsaw\v_cortacromo.bmp"
    "..\p_chainsaw\v_sierraaccs1.bmp"
    "..\p_chainsaw\v_sierraaccs2.bmp"
    "..\p_chainsaw\v_sierrablade.bmp"
    "..\p_chainsaw\v_sierrabuts.bmp"
    "..\p_chainsaw\v_sierrachain.bmp"
    "..\p_chainsaw\v_sierracounter.bmp"
    "..\p_chainsaw\v_sierraexhaust.bmp"
    "..\p_chainsaw\v_sierrarojo.bmp"
    "..\p_chainsaw\v_sierraside.bmp"
    "..\p_rocketcrowbar\chrome_red.bmp"
    "..\p_rocketcrowbar\chrome.bmp"
    "..\p_rocketcrowbar\rocket.bmp"
    "..\p_rocketcrowbar\rocketmotor.bmp"
    "..\p_gravitygun\grav_1.BMP"
    "..\p_gravitygun\lense.BMP"
    "..\p_gravitygun\phys_stuff.BMP"
    "..\p_gravitygun\Portal_1.BMP"
    "..\p_gravitygun\Portal_2.BMP"
    "..\p_gravitygun\v_portalgun.BMP"
    "..\p_gravitygun\v_superphyscannon_sheet.BMP"
    "..\p_portalgun\v_portalgun_glass.bmp"
    "..\p_portalgun\w_portalgun.bmp"
    "..\p_9mmhandguns\back.bmp"
    "..\p_9mmhandguns\side.bmp"
    "..\p_9mmhandguns\chrome.bmp"
    "..\p_9mmhandguns\top.bmp"
    "..\p_357\wrld_python.bmp"
    "..\p_deagle\glockback.bmp"
    "..\p_deagle\glockfront.bmp"
    "..\p_deagle\glockside.bmp"
    "..\p_deagle\glocktop1.bmp"
    "..\p_mag60\glockback.bmp"
    "..\p_mag60\glockfront.bmp"
    "..\p_mag60\glockside.bmp"
    "..\p_mag60\glocktop1.bmp"
    "..\p_smg\M203.bmp"
    "..\p_smg\MP5sideview.bmp"
    "..\p_sawedoff\wmodel.bmp"
  }
  {
    "..\p_crowbar\invert_p_pipe.bmp"
    "..\p_knife\invert_Chrome2.BMP"
    "..\p_knife\invert_Spyknife1.BMP"
    "..\p_wrench\invert_spanner_text.bmp"
    "..\p_wrench\invert_spannerCHROME.bmp"
    "..\p_chainsaw\invert_box.bmp"
    "..\p_chainsaw\invert_fuel.bmp"
    "..\p_chainsaw\invert_dedo.bmp"
    "..\p_chainsaw\invert_v_cortacromo.bmp"
    "..\p_chainsaw\invert_v_sierraaccs1.bmp"
    "..\p_chainsaw\invert_v_sierraaccs2.bmp"
    "..\p_chainsaw\invert_v_sierrablade.bmp"
    "..\p_chainsaw\invert_v_sierrabuts.bmp"
    "..\p_chainsaw\invert_v_sierrachain.bmp"
    "..\p_chainsaw\invert_v_sierracounter.bmp"
    "..\p_chainsaw\invert_v_sierraexhaust.bmp"
    "..\p_chainsaw\invert_v_sierrarojo.bmp"
    "..\p_chainsaw\invert_v_sierraside.bmp"
    "..\p_rocketcrowbar\invert_chrome_red.bmp"
    "..\p_rocketcrowbar\invert_chrome.bmp"
    "..\p_rocketcrowbar\invert_rocket.bmp"
    "..\p_rocketcrowbar\invert_rocketmotor.bmp"
    "..\p_gravitygun\invert_grav_1.BMP"
    "..\p_gravitygun\invert_lense.BMP"
    "..\p_gravitygun\invert_phys_stuff.BMP"
    "..\p_gravitygun\invert_Portal_1.BMP"
    "..\p_gravitygun\invert_Portal_2.BMP"
    "..\p_gravitygun\invert_v_portalgun.BMP"
    "..\p_gravitygun\invert_v_superphyscannon_sheet.BMP"
    "..\p_portalgun\invert_v_portalgun_glass.bmp"
    "..\p_portalgun\invert_w_portalgun.bmp"
    "..\p_9mmhandguns\invert_back.bmp"
    "..\p_9mmhandguns\invert_side.bmp"
    "..\p_9mmhandguns\invert_chrome.bmp"
    "..\p_9mmhandguns\invert_top.bmp"
    "..\p_357\invert_wrld_python.bmp"
    "..\p_deagle\invert_glockback.bmp"
    "..\p_deagle\invert_glockfront.bmp"
    "..\p_deagle\invert_glockside.bmp"
    "..\p_deagle\invert_glocktop1.bmp"
    "..\p_mag60\invert_glockback.bmp"
    "..\p_mag60\invert_glockfront.bmp"
    "..\p_mag60\invert_glockside.bmp"
    "..\p_mag60\invert_glocktop1.bmp"
    "..\p_smg\invert_M203.bmp"
    "..\p_smg\invert_MP5sideview.bmp"
    "..\p_sawedoff\invert_wmodel.bmp"
  }
  {
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
    "..\ringchrome.bmp"
  }
  {
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
    "..\hd\iceCHROME.bmp"
  }
}


// hit box(es)
$hbox 0 "crowbar" -1.550000 -0.810000 -2.570000 4.530000 0.830000 23.450001
// Knife?
$hbox 0 "wrench" -0.900000 -8.330000 -1.560000 0.900000 8.330000 1.550000
$hbox 0 "chainsaw" -22.780001 -4.700000 -3.460000 8.640000 4.330000 7.320000
$hbox 0 "rocketcrowbar" -1.550000 -0.810000 -2.570000 4.530000 0.830000 23.450001
$hbox 0 "gravitygun" -7.990000 -31.690001 -9.770000 6.210000 40.860001 11.980000
$hbox 0 "portalgun" -1.180000 -0.880000 -7.840000 1.260000 11.440000 28.809999
$hbox 0 "glock" -4.120000 -0.790000 -2.650000 4.120000 0.790000 2.650000
$hbox 0 "python" -1.060000 -4.490000 -3.670000 1.050000 1.560000 8.060000
$hbox 0 "deagle" -4.120000 -0.790000 -2.650000 4.120000 0.790000 2.650000
$hbox 0 "mag60" -4.120000 -0.790000 -2.650000 4.120000 0.790000 2.650000
$hbox 0 "smg" -7.610000 -6.110000 -0.530000 12.380000 5.200000 1.600000
$hbox 0 "sawedoff" -0.370000 -11.990000 -24.270000 1.750000 2.520000 2.850000

// animation sequence(s)
$sequence "crowbar_idle" "..\p_crowbar\idle" fps 30 
$sequence "knife_idle" "..\p_knife\idle" fps 30 
$sequence "wrench_idle" "..\p_wrench\idle" fps 30 
$sequence "chainsaw_idle" "..\p_chainsaw\idle" fps 30 
$sequence "rocketcrowbar_idle" "..\p_rocketcrowbar\idle" fps 30 
$sequence "gravitygun_idle" "..\p_gravitygun\idle" fps 30 
$sequence "portalgun_idle" "..\p_portalgun\idle" fps 30 
$sequence "glock_idle" "..\p_9mmhandguns\idle" fps 30 
$sequence "python_idle" "..\p_357\idle" fps 30 
$sequence "deagle_idle" "..\p_deagle\idle" fps 30 
$sequence "mag60_idle" "..\p_mag60\idle" fps 30 
$sequence "smg_idle" "..\p_smg\idle" fps 30 
$sequence "sawedoff_idle" "..\p_sawedoff\idle" fps 30 
