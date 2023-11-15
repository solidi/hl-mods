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
studio "..\p_9mmhandguns\beretta"
studio "..\p_357\python"
studio "..\p_deagle\deagle"
studio "..\p_mag60\mag60"
studio "..\p_smg\smg"
studio "..\..\p_sawedoff\sawedoff_hd"
studio "..\p_9mmAR\m16"
studio "..\p_12gauge\12gauge"
studio "..\p_shotgun\shotgun"
studio "..\p_usas\usas"
studio "..\p_crossbow\crossbow"
studio "..\p_sniperrifle\sniperrifle"
studio "..\p_chaingun\chaingun"
studio "..\p_freezegun\freezegun"
studio "..\p_rpg\rpg"
studio "..\p_gauss\gauss"
studio "..\p_egon\egon"
studio "..\p_hgun\hgun"
studio "..\..\p_railgun\railgun_hd"
studio "..\p_glauncher\glauncher"
studio "..\p_cannon\cannon"
studio "..\p_nuke\nuke"
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
$texrendermode "..\p_freezegun\#128128plasma_p_alpha.BMP" "additive" 
$texrendermode "..\p_cannon\flak_coolant.bmp" "masked" 

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
    "..\p_9mmhandguns\chrome.bmp"
    "..\p_9mmhandguns\glockfront.bmp"
    "..\p_9mmhandguns\v_beretta_main.bmp"
    "..\p_357\wmodel.bmp"
    "..\p_deagle\w_deagle.bmp"
    "..\p_mag60\wmodel.bmp"
    "..\p_smg\wmodel1.bmp"
    "..\..\p_sawedoff\wmodel.bmp"
    "..\p_9mmAR\m4_world.BMP"
    "..\p_12gauge\wpump.bmp"
    "..\p_shotgun\W_SPAS12_REFERENCE.BMP"
    "..\p_usas\USAS-1.bmp"
    "..\p_usas\USAS-2.bmp"
    "..\p_usas\USAS-3.bmp"
    "..\p_crossbow\bowCHROME.bmp"
    "..\p_crossbow\p_crossbow_Reference.bmp"
    "..\p_sniperrifle\wmodel.bmp"
    "..\p_chaingun\chrome1.bmp"
    "..\p_freezegun\#128128plasma_p_alpha.BMP"
    "..\p_freezegun\#256256plasma_p.bmp"
    "..\p_rpg\w_rpg_reference.BMP"
    "..\p_gauss\gaussCHROME.BMP"
    "..\p_gauss\w_gauss.BMP"
    "..\p_egon\w_egon_reference.BMP"
    "..\p_hgun\w_hivehand.bmp"
    "..\..\p_railgun\Skin.bmp"
    "..\p_glauncher\wmodel.bmp"
    "..\p_cannon\flak_cannon.bmp"
    "..\p_cannon\flak_coolant.bmp"
    "..\p_cannon\flak_handle.bmp"
    "..\p_cannon\magppkblack.bmp"
    "..\p_nuke\1.bmp"
    "..\p_nuke\2.bmp"
    "..\p_nuke\SRRAILM4.bmp"
    "..\p_nuke\w_clip_bfg.bmp"
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
    "..\p_9mmhandguns\invert_chrome.bmp"
    "..\p_9mmhandguns\invert_glockfront.bmp"
    "..\p_9mmhandguns\invert_v_beretta_main.bmp"
    "..\p_357\invert_wmodel.bmp"
    "..\p_deagle\invert_w_deagle.bmp"
    "..\p_mag60\invert_wmodel.bmp"
    "..\p_smg\invert_wmodel1.bmp"
    "..\..\p_sawedoff\invert_wmodel.bmp"
    "..\p_9mmAR\invert_m4_world.BMP"
    "..\p_12gauge\invert_wpump.bmp"
    "..\p_shotgun\invert_W_SPAS12_REFERENCE.BMP"
    "..\p_usas\invert_USAS-1.bmp"
    "..\p_usas\invert_USAS-2.bmp"
    "..\p_usas\invert_USAS-3.bmp"
    "..\p_crossbow\invert_bowCHROME.bmp"
    "..\p_crossbow\invert_p_crossbow_Reference.bmp"
    "..\p_sniperrifle\invert_wmodel.bmp"
    "..\p_chaingun\invert_chrome1.bmp"
    "..\p_freezegun\invert_#128128plasma_p_alpha.BMP"
    "..\p_freezegun\invert_#256256plasma_p.bmp"
    "..\p_rpg\invert_w_rpg_reference.BMP"
    "..\p_gauss\invert_gaussCHROME.BMP"
    "..\p_gauss\invert_w_gauss.BMP"
    "..\p_egon\invert_w_egon_reference.BMP"
    "..\p_hgun\invert_w_hivehand.bmp"
    "..\..\p_railgun\invert_Skin.bmp"
    "..\p_glauncher\invert_wmodel.bmp"
    "..\p_cannon\invert_flak_cannon.bmp"
    "..\p_cannon\invert_flak_coolant.bmp"
    "..\p_cannon\invert_flak_handle.bmp"
    "..\p_cannon\invert_magppkblack.bmp"
    "..\p_nuke\invert_1.bmp"
    "..\p_nuke\invert_2.bmp"
    "..\p_nuke\invert_SRRAILM4.bmp"
    "..\p_nuke\invert_w_clip_bfg.bmp"
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
$hbox 0 "beretta" -4.120000 -0.790000 -2.650000 4.120000 0.790000 2.650000
$hbox 0 "python" -1.060000 -4.490000 -3.670000 1.050000 1.560000 8.060000
$hbox 0 "deagle" -4.120000 -0.790000 -2.650000 4.120000 0.790000 2.650000
$hbox 0 "mag60" -0.740000 -4.930000 -4.140000 0.740000 5.070000 5.410000
$hbox 0 "smg" -7.610000 -6.110000 -0.530000 12.380000 5.200000 1.600000
$hbox 0 "sawedoff" -0.370000 -11.990000 -24.270000 1.750000 2.520000 2.850000
$hbox 0 "m16" -27.719999 -4.620000 -1.290000 7.820000 8.270000 1.290000
$hbox 0 "12gauge" -12.260000 -4.010000 -1.570000 12.260000 4.010000 1.570000
$hbox 0 "shotgun" -0.370000 -11.990000 -24.270000 1.750000 2.520000 2.850000
$hbox 0 "usas" -0.610000 -12.980000 -5.220000 0.600000 22.620001 3.060000
$hbox 0 "crossbow" -13.450000 -7.080000 -10.180000 15.830000 4.410000 10.820000
$hbox 0 "sniperrifle" -21.559999 -4.160000 -1.570000 27.660000 6.810000 1.570000
$hbox 0 "chaingun" -11.980000 -6.720000 -8.780000 16.010000 4.130000 8.830000
$hbox 0 "freezegun" -8.280000 -4.820000 -1.020000 17.500000 5.250000 2.090000
$hbox 0 "rpg" -4.190000 -21.110001 -7.690000 4.190000 21.129999 7.700000
$hbox 0 "gauss" -3.990000 -15.840000 -4.880000 3.100000 20.430000 6.000000
// Egon?
$hbox 0 "hgun" -5.180000 -3.660000 -11.100000 4.950000 6.510000 18.510000
$hbox 0 "railgun" -5.180000 -3.660000 -11.100000 4.950000 6.510000 18.510000
$hbox 0 "glauncher" -12.260000 -4.010000 -1.570000 12.260000 4.010000 1.570000
$hbox 0 "cannon" -1.356000 -10.386000 -2.760000 1.308000 10.422001 2.346000
$hbox 0 "nuke" -8.240000 -12.720000 -45.029999 15.150000 22.230000 7.280000


// animation sequence(s)
$sequence "crowbar_idle" "..\p_crowbar\idle" fps 30 
$sequence "knife_idle" "..\p_knife\idle" fps 30 
$sequence "wrench_idle" "..\p_wrench\idle" fps 30 
$sequence "chainsaw_idle" "..\p_chainsaw\idle" fps 30 
$sequence "rocketcrowbar_idle" "..\p_rocketcrowbar\idle" fps 30 
$sequence "gravitygun_idle" "..\..\p_gravitygun\idle" fps 30 
$sequence "portalgun_idle" "..\..\p_portalgun\idle" fps 30 
$sequence "9mmhandguns_idle" "..\p_9mmhandguns\idle" fps 30 
$sequence "python_idle" "..\p_357\idle" fps 30 
$sequence "deagle_idle" "..\p_deagle\idle" fps 30 
$sequence "mag60_idle" "..\p_mag60\idle" fps 30 
$sequence "smg_idle" "..\p_smg\idle" fps 30 
$sequence "sawedoff_idle" "..\..\p_sawedoff\idle" fps 30 
$sequence "m16_idle" "..\p_9mmAR\idle" fps 30 
$sequence "12gauge_idle" "..\p_12gauge\idle" fps 30 
$sequence "shotgun_idle" "..\p_shotgun\idle" fps 30 
$sequence "usas_idle" "..\p_usas\idle" fps 30 
$sequence "crossbow_idle" "..\p_crossbow\idle" fps 30 
$sequence "sniperrifle_idle" "..\p_sniperrifle\idle" fps 30 
$sequence "chaingun_idle" "..\p_chaingun\idle" fps 30 
$sequence "freezegun_idle" "..\p_freezegun\idle" fps 30 
$sequence "rpg_idle" "..\p_rpg\idle" fps 30 
$sequence "gauss_idle" "..\p_gauss\idle" fps 30 
$sequence "egon_idle" "..\p_egon\idle" fps 30 
$sequence "hgun_idle" "..\p_hgun\idle" fps 30 
$sequence "railgun_idle" "..\..\p_railgun\idle" fps 30 
$sequence "glauncher_idle" "..\p_glauncher\idle" fps 30 
$sequence "cannon_idle" "..\p_cannon\idle" fps 30 
$sequence "nuke_idle" "..\p_nuke\idle" fps 30 


// End of QC script.
