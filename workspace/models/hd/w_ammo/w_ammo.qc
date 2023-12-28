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
studio "..\..\w_9mmclip\9mmclip_hd"
studio "..\w_9mmarclip\9mmarclip"
studio "..\..\w_chainammo\chainammo_hd"
studio "..\w_argrenade\argrenades"
studio "..\w_357ammobox\357ammobox"
studio "..\w_shotbox\shotbox"
studio "..\w_crossbow_clip\crossbow_clip"
studio "..\w_rpgammo\rpgammo"
}

$texturegroup ice
{
  {
    "..\..\w_9mmclip\gclip.bmp"
    "..\w_9mmarclip\m4_ammo.BMP"
    "..\..\w_chainammo\a_boxfront.bmp"
    "..\..\w_chainammo\a_boxgreen.bmp"
    "..\..\w_chainammo\a_boxside.bmp"
    "..\..\w_chainammo\a_boxtop.bmp"
    "..\..\w_chainammo\bullets.bmp"
    "..\w_argrenade\m4_grenade_ammo.bmp"
    "..\w_357ammobox\w_python_ammo.bmp"
    "..\w_shotbox\PRIMER_TILE.bmp"
    "..\w_shotbox\Shotgun_ammo_box.bmp"
    "..\w_shotbox\Shotgun_shell.bmp"
    "..\w_crossbow_clip\W_CROSSBOW_CLIP.BMP"
    "..\w_rpgammo\rpg_ammo.BMP"
  }
  {
    "..\..\w_9mmclip\invert_gclip.bmp"
    "..\w_9mmarclip\invert_m4_ammo.BMP"
    "..\..\w_chainammo\invert_a_boxfront.bmp"
    "..\..\w_chainammo\invert_a_boxgreen.bmp"
    "..\..\w_chainammo\invert_a_boxside.bmp"
    "..\..\w_chainammo\invert_a_boxtop.bmp"
    "..\..\w_chainammo\invert_bullets.bmp"
    "..\w_argrenade\invert_m4_grenade_ammo.bmp"
    "..\w_357ammobox\invert_w_python_ammo.bmp"
    "..\w_shotbox\invert_PRIMER_TILE.bmp"
    "..\w_shotbox\invert_Shotgun_ammo_box.bmp"
    "..\w_shotbox\invert_Shotgun_shell.bmp"
    "..\w_crossbow_clip\invert_W_CROSSBOW_CLIP.BMP"
    "..\w_rpgammo\invert_rpg_ammo.BMP"
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
  }
}

// hit box(es)
$hbox 0 "9mmclip" -2.750000 -6.040000 0.000000 2.030000 6.720000 2.040000
$hbox 0 "9mmarclip" 0.000000 -4.090000 -9.130000 2.590000 3.920000 7.850000
$hbox 0 "chainammo" -16.950001 -5.760000 -0.430000 10.070000 12.770000 14.180000
$hbox 0 "argrenade" -2.110000 -6.250000 0.000000 7.660000 2.260000 8.860000
$hbox 0 "357ammobox" -6.080000 -2.690000 -2.110000 5.530000 2.690000 5.620000
$hbox 0 "shotbox" -10.690000 -8.690000 -5.160000 7.190000 8.460000 12.980000
$hbox 0 "crossbow_clip" -0.070000 -11.580000 -10.290000 1.920000 8.390000 10.960000
$hbox 0 "rpgammo" -4.160000 -12.040000 0.000000 7.490000 3.600000 29.610001

// animation sequence(s)
$sequence "9mmclip_idle" "..\..\w_9mmclip\idle" fps 30 
$sequence "9mmclip_spin" "..\..\w_9mmclip\spin" loop fps 21 
$sequence "9mmarclip_idle" "..\w_9mmarclip\idle" fps 30 
$sequence "9mmarclip_spin" "..\w_9mmarclip\spin" loop fps 21 
$sequence "chainammo_idle" "..\..\w_chainammo\idle" fps 30 
$sequence "chainammo_spin" "..\..\w_chainammo\spin" loop fps 21 
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
