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
studio "..\w_9mmAR\m16"
studio "..\w_12gauge\12gauge"
studio "..\w_shotgun\shotgun"
studio "..\w_usas\usas"
studio "..\w_crossbow\crossbow"
studio "..\w_sniperrifle\sniperrifle"
studio "..\w_chaingun\chaingun"
studio "..\w_freezegun\freezegun"
studio "..\w_rpg\rpg"
studio "..\w_gauss\gauss"
studio "..\w_egon\egon"
studio "..\w_hgun\hgun"
studio "..\..\w_railgun\railgun_hd"
studio "..\w_glauncher\glauncher"
studio "..\w_cannon\cannon"
studio "..\w_nuke\nuke"
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
    "..\w_9mmAR\m4_world.BMP"
    "..\w_12gauge\wpump.bmp"
    "..\w_shotgun\W_SPAS12_REFERENCE.BMP"
    "..\w_usas\USAS-1.bmp"
    "..\w_usas\USAS-2.bmp"
    "..\w_usas\USAS-3.bmp"
    "..\w_crossbow\bowCHROME.bmp"
    "..\w_crossbow\w_crossbow_Reference.bmp"
    "..\w_sniperrifle\wmodel.bmp"
    "..\w_chaingun\chrome1.bmp"
    "..\w_freezegun\#128128plasma_p_alpha.BMP"
    "..\w_freezegun\#256256plasma_p.bmp"
    "..\w_rpg\w_rpg_reference.BMP"
    "..\w_gauss\gaussCHROME.BMP"
    "..\w_gauss\w_gauss.BMP"
    "..\w_egon\w_egon_reference.BMP"
    "..\w_hgun\w_hivehand.bmp"
    "..\..\w_railgun\Skin.BMP"
    "..\w_glauncher\wmodel.bmp"
    "..\w_cannon\flak_cannon.bmp"
    "..\w_cannon\flak_coolant.bmp"
    "..\w_cannon\flak_handle.bmp"
    "..\w_cannon\magppkblack.bmp"
    "..\w_nuke\1.bmp"
    "..\w_nuke\2.bmp"
    "..\w_nuke\SRRAILM4.bmp"
    "..\w_nuke\w_clip_bfg.bmp"
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
    "..\w_9mmAR\invert_m4_world.BMP"
    "..\w_12gauge\invert_wpump.bmp"
    "..\w_shotgun\invert_W_SPAS12_REFERENCE.BMP"
    "..\w_usas\invert_USAS-1.bmp"
    "..\w_usas\invert_USAS-2.bmp"
    "..\w_usas\invert_USAS-3.bmp"
    "..\w_crossbow\invert_bowCHROME.bmp"
    "..\w_crossbow\invert_w_crossbow_Reference.bmp"
    "..\w_sniperrifle\invert_wmodel.bmp"
    "..\w_chaingun\invert_chrome1.bmp"
    "..\w_freezegun\invert_#128128plasma_p_alpha.BMP"
    "..\w_freezegun\invert_#256256plasma_p.bmp"
    "..\w_rpg\invert_w_rpg_reference.BMP"
    "..\w_gauss\invert_gaussCHROME.BMP"
    "..\w_gauss\invert_w_gauss.BMP"
    "..\w_egon\invert_w_egon_reference.BMP"
    "..\w_hgun\invert_w_hivehand.bmp"
    "..\..\w_railgun\invert_Skin.BMP"
    "..\w_glauncher\invert_wmodel.bmp"
    "..\w_cannon\invert_flak_cannon.bmp"
    "..\w_cannon\invert_flak_coolant.bmp"
    "..\w_cannon\invert_flak_handle.bmp"
    "..\w_cannon\invert_magppkblack.bmp"
    "..\w_nuke\invert_1.bmp"
    "..\w_nuke\invert_2.bmp"
    "..\w_nuke\invert_SRRAILM4.bmp"
    "..\w_nuke\invert_w_clip_bfg.bmp"
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
  }
}

$texrendermode "..\w_freezegun\#128128plasma_p_alpha.BMP" "additive" 
$texrendermode "..\w_cannon\flak_coolant.bmp" "masked" 

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
$hbox 0 "m16" -48.009998 -8.010000 -2.230000 13.540000 14.330000 2.230000
$hbox 0 "12gauge" -20.410000 -6.680000 -2.620000 20.410000 6.680000 2.620000
$hbox 0 "shotgun" -4.970000 -27.400000 -0.630000 9.910000 20.650000 3.290000
$hbox 0 "usas" -0.610000 -12.980000 -5.220000 0.600000 22.620001 3.060000
$hbox 0 "crossbow" -27.520000 -5.730000 -24.730000 36.980000 9.250000 24.740000
$hbox 0 "sniperrifle" -36.410000 -6.680000 -2.620000 45.709999 10.480000 2.120000
$hbox 0 "chaingun" -34.980000 -19.620001 -25.650000 46.759998 12.590000 25.799999
$hbox 0 "freezegun" -1.720000 0.000000 -10.350000 1.720000 14.400000 18.150000
$hbox 0 "rpg" -6.860000 -34.560001 -12.600000 6.860000 34.560001 12.600000
$hbox 0 "gauss" -7.990000 -31.690001 -9.770000 6.210000 40.860001 11.980000
$hbox 0 "gauss_spinner" -5.760000 -2.620000 -4.030000 5.760000 2.680000 5.950000
$hbox 0 "egon" -28.680000 -35.730000 -33.130001 12.300000 3.930000 1.790000
$hbox 0 "hgun" -10.140000 -9.360000 -23.620001 11.280000 11.370000 46.910000
$hbox 0 "railgun" -20.410000 -6.680000 -2.620000 20.410000 6.680000 2.620000
$hbox 0 "glauncher" -20.410000 -6.680000 -2.620000 20.410000 6.680000 5.620000
$hbox 0 "cannon" -1.356000 -10.386000 -2.760000 1.308000 10.422001 2.346000
$hbox 0 "nuke" -8.240000 -12.720000 -45.029999 15.150000 22.230000 7.280000

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
$sequence "m16_idle" "..\w_9mmAR\idle" fps 30 
$sequence "m16_spin" "..\w_9mmAR\spin" fps 21 loop 
$sequence "12gauge_idle" "..\w_12gauge\idle" fps 30 
$sequence "12gauge_spin" "..\w_12gauge\spin" fps 21 loop 
$sequence "shotgun_idle" "..\w_shotgun\idle" fps 30 
$sequence "shotgun_spin" "..\w_shotgun\spin" fps 21 loop 
$sequence "usas_idle" "..\w_usas\idle" fps 30 
$sequence "usas_spin" "..\w_usas\spin" fps 21 loop
$sequence "crossbow_idle" "..\w_crossbow\idle" fps 30 
$sequence "crossbow_spin" "..\w_crossbow\spin" fps 21 loop
$sequence "sniperrifle_idle" "..\w_sniperrifle\idle" fps 30 
$sequence "sniperrifle_spin" "..\w_sniperrifle\spin" fps 21 loop
$sequence "chaingun_idle" "..\w_chaingun\idle" fps 30 
$sequence "chaingun_spin" "..\w_chaingun\spin" fps 21 loop
$sequence "freezegun_idle" "..\w_freezegun\idle" fps 30 
$sequence "freezegun_spin" "..\w_freezegun\spin" fps 21 loop
$sequence "rpg_idle" "..\w_rpg\idle" fps 30 
$sequence "rpg_spin" "..\w_rpg\spin" fps 21 loop
$sequence "gauss_idle" "..\w_gauss\idle" fps 30 
$sequence "gauss_spin" "..\w_gauss\spin" fps 21 loop
$sequence "egon_idle" "..\w_egon\idle" fps 30 
$sequence "egon_spin" "..\w_egon\spin" fps 21 loop
$sequence "hgun_idle" "..\w_hgun\idle" fps 30 
$sequence "hgun_spin" "..\w_hgun\spin" fps 21 loop
$sequence "railgun_idle" "..\..\w_railgun\idle" fps 30 
$sequence "railgun_spin" "..\..\w_railgun\spin" fps 21 loop 
$sequence "glauncher_idle" "..\w_glauncher\idle" fps 30 
$sequence "glauncher_spin" "..\w_glauncher\spin" fps 21 loop
$sequence "cannon_idle" "..\w_cannon\idle" fps 30 
$sequence "cannon_spin" "..\w_cannon\spin" fps 21 loop
$sequence "nuke_idle" "..\w_nuke\idle" fps 30 
$sequence "nuke_spin" "..\w_nuke\spin" fps 21 loop

// End of QC script.
