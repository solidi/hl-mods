$modelname "w_ammo.mdl"
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
studio "..\w_9mmclip\9mmclip"
studio "..\w_9mmarclip\9mmarclip"
studio "..\w_chainammo\chainammo"
studio "..\w_argrenade\argrenades"
studio "..\w_357ammobox\357ammobox"
studio "..\w_shotbox\shotbox"
studio "..\w_crossbow_clip\crossbow_clip"
studio "..\w_rpgammo\rpgammo"
}

$texturegroup ice
{
  {
    "..\w_9mmclip\gclip.bmp"
    "..\w_9mmarclip\clipside.bmp"
    "..\w_chainammo\a_boxfront.bmp"
    "..\w_chainammo\a_boxgreen.bmp"
    "..\w_chainammo\a_boxside.bmp"
    "..\w_chainammo\a_boxtop.bmp"
    "..\w_chainammo\bullets.bmp"
    "..\w_argrenade\Side1.bmp"
    "..\w_argrenade\Tip1.bmp"
    "..\w_357ammobox\boxart1.bmp"
    "..\w_357ammobox\boxart2.bmp"
    "..\w_357ammobox\bulletCHROME.bmp"
    "..\w_357ammobox\cardboard.bmp"
    "..\w_shotbox\box.bmp"
    "..\w_shotbox\boxside.bmp"
    "..\w_shotbox\shell.bmp"
    "..\w_shotbox\topbox_shell.bmp"
    "..\w_crossbow_clip\clip_side.bmp"
    "..\w_crossbow_clip\cliprear.bmp"
    "..\w_crossbow_clip\wrld_bolt.bmp"
    "..\w_crossbow_clip\wrld_fins.bmp"
    "..\w_rpgammo\ammocan.bmp"
    "..\w_rpgammo\ammocantop.bmp"
    "..\w_rpgammo\rocket.bmp"
  }
  {
    "..\w_9mmclip\invert_gclip.bmp"
    "..\w_9mmarclip\invert_clipside.bmp"
    "..\w_chainammo\invert_a_boxfront.bmp"
    "..\w_chainammo\invert_a_boxgreen.bmp"
    "..\w_chainammo\invert_a_boxside.bmp"
    "..\w_chainammo\invert_a_boxtop.bmp"
    "..\w_chainammo\invert_bullets.bmp"
    "..\w_argrenade\invert_Side1.bmp"
    "..\w_argrenade\invert_Tip1.bmp"
    "..\w_357ammobox\invert_boxart1.bmp"
    "..\w_357ammobox\invert_boxart2.bmp"
    "..\w_357ammobox\invert_bulletCHROME.bmp"
    "..\w_357ammobox\invert_cardboard.bmp"
    "..\w_shotbox\invert_box.bmp"
    "..\w_shotbox\invert_boxside.bmp"
    "..\w_shotbox\invert_shell.bmp"
    "..\w_shotbox\invert_topbox_shell.bmp"
    "..\w_crossbow_clip\invert_clip_side.bmp"
    "..\w_crossbow_clip\invert_cliprear.bmp"
    "..\w_crossbow_clip\invert_wrld_bolt.bmp"
    "..\w_crossbow_clip\invert_wrld_fins.bmp"
    "..\w_rpgammo\invert_ammocan.bmp"
    "..\w_rpgammo\invert_ammocantop.bmp"
    "..\w_rpgammo\invert_rocket.bmp"
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
  }
}

// hit box(es)
$hbox 0 "9mmclip" -2.750000 -6.040000 0.000000 2.030000 6.720000 2.040000
$hbox 0 "9mmarclip" -3.080000 -1.270000 -3.930000 2.760000 1.270000 12.830000
$hbox 0 "chainammo" -16.950001 -5.760000 -0.430000 10.070000 12.770000 14.180000
$hbox 0 "argrenades" -2.120000 -1.840000 -5.310000 6.770000 5.680000 3.570000
$hbox 0 "357ammobox" -6.080000 -2.690000 -2.110000 5.530000 2.690000 5.620000
$hbox 0 "shotbox" -10.690000 -8.690000 -5.160000 7.190000 9.290000 12.980000
$hbox 0 "crossbow_clip" -0.920000 0.000000 0.000000 0.930000 24.030001 30.639999
$hbox 0 "rpgammo" -4.160000 -3.600000 0.000000 4.160000 3.600000 29.610001

// animation sequence(s)
$sequence "9mmclip_idle" "..\w_9mmclip\idle" fps 30 
$sequence "9mmclip_spin" "..\w_9mmclip\spin" loop fps 21 
$sequence "9mmarclip_idle" "..\w_9mmarclip\idle" fps 30 
$sequence "9mmarclip_spin" "..\w_9mmarclip\spin" loop fps 21 
$sequence "chainammo_idle" "..\w_chainammo\idle" fps 30 
$sequence "chainammo_spin" "..\w_chainammo\spin" loop fps 21 
$sequence "argrenades_idle" "..\w_argrenade\idle" fps 30 
$sequence "argrenades_spin" "..\w_argrenade\spin" loop fps 21 
$sequence "357ammobox_idle" "..\w_357ammobox\idle" fps 30 
$sequence "357ammobox_spin" "..\w_357ammobox\spin" loop fps 21 
$sequence "shotbox_idle" "..\w_shotbox\idle" fps 30 
$sequence "shotbox_spin" "..\w_shotbox\spin" loop fps 21 
$sequence "crossbow_clip_idle" "..\w_crossbow_clip\idle" fps 30 
$sequence "crossbow_clip_spin" "..\w_crossbow_clip\spin" loop fps 21 
$sequence "rpgammo_idle" "..\w_rpgammo\idle" fps 30 
$sequence "rpgammo_spin" "..\w_rpgammo\spin" loop fps 21 
