/*
==============================================================================

QC script generated by Half-Life MDL Decompiler 1.2 
2003, Kratisto. Based on code from Valve's HL SDK.

hhev.mdl

Original internal name:
"C:/Sierra/Half-Life/valve/models/player/HHEVa/HHEVa.mdl"

==============================================================================
*/

$modelname "hhev.mdl"
$cd ".\"
$cdtexture ".\"
$scale 1.0
$cliptotextures


$bbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$cbox 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000
$eyeposition 0.000000 0.000000 0.000000


//reference mesh(es)
$body "body" "hhev"


// attachment(s)
$attachment 0 "Bip01 R Hand" 20.000000 2.000000 5.000000
$attachment 1 "Bip01 R Hand" 15.000000 1.500000 3.750000
$attachment 2 "Bip01 R Hand" 30.000000 3.000000 7.500000
$attachment 3 "Bip01 L Hand" 15.000000 3.000000 -3.500000

// bone controller(s)
$controller 0 "Bip01 Spine" XR -30.000000 30.000000
$controller 1 "Bip01 Spine1" XR -30.000000 30.000000
$controller 2 "Bip01 Spine2" XR -30.000000 30.000000
$controller 3 "Bip01 Spine3" XR -30.000000 30.000000

// hit box(es)
$hbox 0 "Bip01 Pelvis" -4.610000 -4.430000 -8.040000 3.330000 6.190000 7.730000
$hbox 0 "Bip01 L Leg" 0.000000 -6.590000 -5.740000 19.850296 5.680000 4.560000
$hbox 0 "Bip01 L Leg1" 0.000000 -5.750000 -5.630000 13.081773 4.710000 4.590000
$hbox 0 "Bip01 L Foot" 0.000000 -3.840000 -4.260000 5.580000 9.290450 4.140000
$hbox 0 "Bip01 L Toe0" -0.160000 -0.120000 -5.110000 3.469095 1.960000 4.270000
$hbox 0 "Bip01 R Leg" 0.000000 -6.570000 -4.420000 20.030750 5.710000 5.890000
$hbox 0 "Bip01 R Leg1" -0.120000 -5.680000 -4.750000 14.220000 4.770000 5.470000
$hbox 0 "Bip01 R Foot" 0.000000 -3.730000 -4.490000 5.462048 9.290450 3.910000
$hbox 0 "Bip01 R Toe0" -0.050000 0.000000 -4.620000 3.469095 2.150000 4.760000
$hbox 0 "Bip01 Spine2" -7.410000 -10.060000 -16.260000 20.500000 10.210000 16.540001
$hbox 0 "Bone01" -2.420000 -9.310000 -2.200000 9.340000 0.000000 4.010000
$hbox 0 "Bip01 Neck" -4.043139 0.000000 -5.641002 0.000000 1.969623 5.641009
$hbox 0 "Bip01 L Arm1" -0.170000 -4.580000 -3.730000 8.620000 3.090000 3.420000
$hbox 0 "Bip01 L Arm2" 0.000000 -3.370000 -3.040000 10.615021 2.240000 3.530000
$hbox 0 "Bip01 L Hand" -0.610000 -0.740000 -2.102163 4.782308 2.280000 2.350000
$hbox 0 "Bip01 L Finger01" 0.000000 -0.090000 -1.010000 1.420321 0.960000 0.640000
$hbox 0 "Bip01 L Finger1" 0.000000 -0.200000 -2.110000 2.201496 1.380000 2.210000
$hbox 0 "Bip01 L Finger12" 0.000000 0.000000 -1.700000 2.540000 1.130000 1.630000
$hbox 0 "Bip01 R Arm1" -0.160000 -4.580000 -3.720000 8.620000 3.090000 3.430000
$hbox 0 "Bip01 R Arm2" 0.000000 -3.800000 -3.830000 10.615021 2.230000 2.740000
$hbox 0 "Bip01 R Hand" -0.590000 -1.040000 -2.340000 4.782305 1.970000 2.102163
$hbox 0 "Bip01 R Finger1" 0.000000 -0.630000 -2.200000 2.201494 0.950000 2.120000

// animation sequence(s)
$sequence "look_idle" "look_idle" fps 14 loop ACT_IDLE 2 
$sequence "idle" "idle" fps 14 loop ACT_IDLE 1 
$sequence "deep_idle" "deep_idle" fps 12 loop ACT_IDLE 4 
$sequence "run2" "run2" LX fps 40 loop ACT_RUN 1 
$sequence "walk2handed" "walk2handed" LX fps 26 loop ACT_WALK 1 
$sequence "2handshoot" "2handshoot" fps 20 ACT_RANGE_ATTACK1 1 
$sequence "crawl" "crawl" LX fps 22 loop ACT_CROUCH 1 
$sequence "crouch_idle" "crouch_idle" fps 12 loop ACT_CROUCHIDLE 1 
$sequence "jump" "jump" fps 30 ACT_HOP 1 
$sequence "long_jump" "long_jump" LX fps 24 ACT_LEAP 1 
$sequence "swim" "swim" fps 14 loop ACT_SWIM 1 
$sequence "treadwater" "treadwater" fps 14 loop ACT_HOVER 1 
$sequence "run" "run" LX fps 31 loop 
$sequence "walk" "walk" LX fps 31 loop 
$sequence "aim_2" "aim_2_blend1" "aim_2_blend2" blend XR -45 45 fps 14 loop 
$sequence "shoot_2" "shoot_2_blend1" "shoot_2_blend2" blend XR -45 45 fps 14 loop 
$sequence "aim_1" "aim_1_blend1" "aim_1_blend2" blend XR -45 45 fps 14 loop 
$sequence "shoot_1" "shoot_1_blend1" "shoot_1_blend2" blend XR -45 45 fps 14 loop 
$sequence "die_simple" "die_simple" fps 22 ACT_DIESIMPLE 1 { event 2001 9 } 
$sequence "die_backwards1" "die_backwards1" fps 26 ACT_DIEBACKWARD 4 { event 2001 13 } 
$sequence "die_backwards" "die_backwards" fps 30 ACT_DIEBACKWARD 1 { event 2001 15 } 
$sequence "die_forwards" "die_forwards" fps 26 ACT_DIEFORWARD 1 { event 2001 8 } 
$sequence "headshot" "headshot" fps 24 ACT_DIE_HEADSHOT 4 { event 2001 22 } 
$sequence "die_spin" "die_spin" fps 30 ACT_DIE_HEADSHOT 1 { event 2001 16 } 
$sequence "gutshot" "gutshot" fps 26 ACT_DIE_GUTSHOT 1 { event 2001 22 } 
$sequence "ref_aim_crowbar" "ref_aim_crowbar_blend1" "ref_aim_crowbar_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_crowbar" "ref_shoot_crowbar_blend1" "ref_shoot_crowbar_blend2" blend XR -45 45 fps 24
$sequence "crouch_aim_crowbar" "crouch_aim_crowbar_blend1" "crouch_aim_crowbar_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_crowbar" "crouch_shoot_crowbar_blend1" "crouch_shoot_crowbar_blend2" blend XR -45 45 fps 24 
$sequence "ref_aim_trip" "ref_aim_trip_blend1" "ref_aim_trip_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_trip" "ref_shoot_trip_blend1" "ref_shoot_trip_blend2" blend XR -45 45 fps 18 
$sequence "crouch_aim_trip" "crouch_aim_trip_blend1" "crouch_aim_trip_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_trip" "crouch_shoot_trip_blend1" "crouch_shoot_trip_blend2" blend XR -45 45 fps 16 
$sequence "ref_aim_onehanded" "ref_aim_onehanded_blend1" "ref_aim_onehanded_blend2" blend XR -50 35 fps 12 loop 
$sequence "ref_shoot_onehanded" "ref_shoot_onehanded_blend1" "ref_shoot_onehanded_blend2" blend XR -50 35 fps 16 { event 5011 0 "21" } 
$sequence "crouch_aim_onehanded" "crouch_aim_onehanded_blend1" "crouch_aim_onehanded_blend2" blend XR -50 35 fps 12 loop 
$sequence "crouch_shoot_onehanded" "crouch_shoot_onehanded_blend1" "crouch_shoot_onehanded_blend2" blend XR -50 35 fps 16 { event 5011 0 "21" } 
$sequence "ref_aim_python" "ref_aim_python_blend1" "ref_aim_python_blend2" blend XR -50 35 fps 12 loop 
$sequence "ref_shoot_python" "ref_shoot_python_blend1" "ref_shoot_python_blend2" blend XR -50 35 fps 16 { event 5011 0 "31" } 
$sequence "crouch_aim_python" "crouch_aim_python_blend1" "crouch_aim_python_blend2" blend XR -50 35 fps 12 loop 
$sequence "crouch_shoot_python" "crouch_shoot_python_blend1" "crouch_shoot_python_blend2" blend XR -50 35 fps 16 { event 5011 0 "31" } 
$sequence "ref_aim_shotgun" "ref_aim_shotgun_blend1" "ref_aim_shotgun_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_shotgun" "ref_shoot_shotgun_blend1" "ref_shoot_shotgun_blend2" blend XR -45 45 fps 15 { event 5021 0 "51" } 
$sequence "crouch_aim_shotgun" "crouch_aim_shotgun_blend1" "crouch_aim_shotgun_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_shotgun" "crouch_shoot_shotgun_blend1" "crouch_shoot_shotgun_blend2" blend XR -45 45 fps 15 { event 5021 0 "51" } 
$sequence "ref_aim_gauss" "ref_aim_gauss_blend1" "ref_aim_gauss_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_gauss" "ref_shoot_gauss_blend1" "ref_shoot_gauss_blend2" blend XR -45 45 fps 15 
$sequence "crouch_aim_gauss" "crouch_aim_gauss_blend1" "crouch_aim_gauss_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_gauss" "crouch_shoot_gauss_blend1" "crouch_shoot_gauss_blend2" blend XR -45 45 fps 15 
$sequence "ref_aim_mp5" "ref_aim_mp5_blend1" "ref_aim_mp5_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_mp5" "ref_shoot_mp5_blend1" "ref_shoot_mp5_blend2" blend XR -45 45 fps 20 loop { event 5001 0 "40" } 
$sequence "crouch_aim_mp5" "crouch_aim_mp5_blend1" "crouch_aim_mp5_blend2" blend XR -30 40 fps 12 loop 
$sequence "crouch_shoot_mp5" "crouch_shoot_mp5_blend1" "crouch_shoot_mp5_blend2" blend XR -30 40 fps 20 loop { event 5001 0 "40" } 
$sequence "ref_aim_rpg" "ref_aim_rpg_blend1" "ref_aim_rpg_blend2" blend XR -45 40 fps 12 loop 
$sequence "ref_shoot_rpg" "ref_shoot_rpg_blend1" "ref_shoot_rpg_blend2" blend XR -45 40 fps 18 
$sequence "crouch_aim_rpg" "crouch_aim_rpg_blend1" "crouch_aim_rpg_blend2" blend XR -45 40 fps 12 loop 
$sequence "crouch_shoot_rpg" "crouch_shoot_rpg_blend1" "crouch_shoot_rpg_blend2" blend XR -45 40 fps 18 
$sequence "ref_aim_egon" "ref_aim_egon_blend1" "ref_aim_egon_blend2" blend XR -45 35 fps 12 loop 
$sequence "ref_shoot_egon" "ref_shoot_egon_blend1" "ref_shoot_egon_blend2" blend XR -45 35 fps 18 loop 
$sequence "crouch_aim_egon" "crouch_aim_egon_blend1" "crouch_aim_egon_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_egon" "crouch_shoot_egon_blend1" "crouch_shoot_egon_blend2" blend XR -45 45 fps 18 loop 
$sequence "ref_aim_squeak" "ref_aim_squeak_blend1" "ref_aim_squeak_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_squeak" "ref_shoot_squeak_blend1" "ref_shoot_squeak_blend2" blend XR -45 45 fps 14 
$sequence "crouch_aim_squeak" "crouch_aim_squeak_blend1" "crouch_aim_squeak_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_squeak" "crouch_shoot_squeak_blend1" "crouch_shoot_squeak_blend2" blend XR -45 45 fps 14 
$sequence "ref_aim_hive" "ref_aim_hive_blend1" "ref_aim_hive_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_hive" "ref_shoot_hive_blend1" "ref_shoot_hive_blend2" blend XR -45 45 fps 15 
$sequence "crouch_aim_hive" "crouch_aim_hive_blend1" "crouch_aim_hive_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_hive" "crouch_shoot_hive_blend1" "crouch_shoot_hive_blend2" blend XR -45 45 fps 15 
$sequence "ref_aim_bow" "ref_aim_bow_blend1" "ref_aim_bow_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_bow" "ref_shoot_bow_blend1" "ref_shoot_bow_blend2" blend XR -45 45 fps 16 
$sequence "crouch_aim_bow" "crouch_aim_bow_blend1" "crouch_aim_bow_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_bow" "crouch_shoot_bow_blend1" "crouch_shoot_bow_blend2" blend XR -45 45 fps 16 
$sequence "deadback" "deadback" fps 10 
$sequence "deadsitting" "deadsitting" fps 10 
$sequence "deadstomach" "deadstomach" fps 10 
$sequence "deadtable" "deadtable" fps 10 
$sequence "kick" "../common/kick" fps 25 ACT_KICK 1 
$sequence "ref_aim_akimbo" "../common/ref_aim_akimbo_blend1" "../common/ref_aim_akimbo_blend2" blend XR -45 45 fps 20 loop 
$sequence "ref_shoot_akimbo" "../common/ref_shoot_akimbo_blend1" "../common/ref_shoot_akimbo_blend2" blend XR -45 45 fps 32 { event 5001 0 "31" } { event 5031 1 "31" } 
$sequence "crouch_aim_akimbo" "../common/crouch_aim_akimbo_blend1" "../common/crouch_aim_akimbo_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_akimbo" "../common/crouch_shoot_akimbo_blend1" "../common/crouch_shoot_akimbo_blend2" blend XR -45 45 fps 30 { event 5001 0 "31" } { event 5031 1 "31" }
$sequence "ref_aim_dual_rpg" "../common/ref_aim_dual_rpg_blend1" "../common/ref_aim_dual_rpg_blend2" blend XR -45 40 fps 12 loop
$sequence "ref_shoot_dual_rpg" "../common/ref_shoot_dual_rpg_blend1" "../common/ref_shoot_dual_rpg_blend2" blend XR -45 40 fps 12 loop
$sequence "crouch_aim_dual_rpg" "../common/crouch_aim_dual_rpg_blend1" "../common/crouch_aim_dual_rpg_blend2" blend XR -45 40 fps 12 loop 
$sequence "crouch_shoot_dual_rpg" "../common/crouch_shoot_dual_rpg_blend1" "../common/crouch_shoot_dual_rpg_blend2" blend XR -45 45 fps 30
$sequence "ref_aim_dual_club" "ref_aim_crowbar_blend1" "ref_aim_crowbar_blend2" blend XR -45 40 fps 12 loop
$sequence "ref_shoot_dual_club" "../common/ref_shoot_dual_club_blend1_shift" "../common/ref_shoot_dual_club_blend2_shift" blend XR -45 40 fps 24 loop
$sequence "crouch_aim_dual_club" "crouch_aim_crowbar_blend1" "crouch_aim_crowbar_blend2" blend XR -45 40 fps 12 loop 
$sequence "crouch_shoot_dual_club" "../common/crouch_shoot_dual_club_blend1_shift" "../common/crouch_shoot_dual_club_blend2_shift" blend XR -45 45 fps 24
$sequence "ref_aim_dual_shotgun" "../common/ref_aim_dual_shotgun_blend1" "../common/ref_aim_dual_shotgun_blend2" blend XR -45 45 fps 12 loop 
$sequence "ref_shoot_dual_shotgun" "../common/ref_shoot_dual_shotgun_blend1_shift" "../common/ref_shoot_dual_shotgun_blend2_shift" blend XR -45 45 fps 25 { event 5001 0 "51" } { event 5031 1 "51" } 
$sequence "crouch_aim_dual_shotgun" "../common/crouch_aim_dual_shotgun_blend1" "../common/crouch_aim_dual_shotgun_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_dual_shotgun" "../common/crouch_shoot_dual_shotgun_blend1_shift" "../common/crouch_shoot_dual_shotgun_blend2_shift" blend XR -45 45 fps 25 { event 5001 0 "51" } { event 5031 1 "51" }
$sequence "ref_aim_dual_egon" "../common/ref_aim_dual_egon_blend1" "../common/ref_aim_dual_egon_blend2" blend XR -45 35 fps 12 loop 
$sequence "ref_shoot_dual_egon" "../common/ref_aim_dual_egon_blend1" "../common/ref_aim_dual_egon_blend2" blend XR -45 45 fps 25 { event 5001 0 "51" } { event 5031 1 "51" } 
$sequence "crouch_aim_dual_egon" "../common/crouch_aim_dual_egon_blend1" "../common/crouch_aim_dual_egon_blend2" blend XR -45 45 fps 12 loop 
$sequence "crouch_shoot_dual_egon" "../common/crouch_aim_dual_egon_blend1" "../common/crouch_aim_dual_egon_blend2" blend XR -45 45 fps 25 { event 5001 0 "51" } { event 5031 1 "51" }
$sequence "frozen" "../common/frozen" fps 16 ACT_FROZEN 1 
$sequence "slide" "../common/slide" fps 10 ACT_SLIDE 1 
$sequence "right_flip" "../common/wheel_r" LX LY fps 40 ACT_RIGHT_FLIP 1 
$sequence "left_flip" "../common/wheel_l" LX LY fps 40 ACT_LEFT_FLIP 1 
$sequence "back_flip" "../common/wheel_b" LX LY fps 40 ACT_BACK_FLIP 1 
$sequence "front_flip" "../common/wheel_f" LX LY fps 40 ACT_FRONT_FLIP 1 
$sequence "pullup" "../common/pullup" fps 30 ACT_PULL_UP 1 
$sequence "punch" "../common/punch" fps 40 ACT_PUNCH 1 
$sequence "hurricane_kick" "../common/hurricane_kick" fps 40 ACT_HURRICANE_KICK 1 
$sequence "celebrate" "../common/celebrate" fps 40 ACT_CELEBRATE 1 

// End of QC script.
