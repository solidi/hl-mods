$modelname "w_items.mdl"
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
studio "..\w_shell\shell"
studio "..\w_shotgunshell\shotgunshell"
studio "..\w_762shell\762shell"
studio "..\w_weaponbox\weaponbox"
studio "..\w_longjump\longjump"
studio "..\w_barrel\barrel"
studio "..\w_cabinet\cabinet"
studio "..\w_bolt\bolt"
studio "..\rpgrocket\rocket"
studio "..\w_tombstone\tombstone"
studio "..\w_tracer\tracer"
studio "..\w_hornet\hornet"
studio "..\plasma\null"
studio "..\w_contact_grenade\contactgrenade"
}

$texturegroup ice
{
  {
    "..\w_shell\back.bmp"
    "..\w_shell\bulletCHROME.bmp"
    "..\w_shell\front.bmp"
    "..\w_shotgunshell\shell.bmp"
    "..\w_762shell\556shell.bmp"
    "..\w_weaponbox\itemc_chrome.bmp"
    "..\w_weaponbox\itemtop.bmp"
    "..\w_weaponbox\sidemap.bmp"
    "..\w_longjump\back.bmp"
    "..\w_longjump\backpackfront.bmp"
    "..\w_longjump\black_chrome.bmp"
    "..\w_longjump\filler.bmp"
    "..\w_longjump\jets.bmp"
    "..\w_barrel\barrel_metal2.bmp"
    "..\w_cabinet\k.o.bmp"
    "..\w_bolt\boltCHROME.bmp"
    "..\w_bolt\finCHOME.bmp"
    "..\rpgrocket\rocket.bmp"
    "..\rpgrocket\rocketmotor.bmp"
    "..\w_tombstone\esc_heorgen_tombstone01.bmp"
    "..\w_tracer\tracer_deep.bmp"
    "..\w_hornet\HGP_Side1.bmp"
    "..\plasma\blueChrome.bmp"
    "..\w_contact_grenade\Side1.bmp"
    "..\w_contact_grenade\Tip1.bmp"
  }
  {
    "..\w_shell\invert_back.bmp"
    "..\w_shell\invert_bulletCHROME.bmp"
    "..\w_shell\invert_front.bmp"
    "..\w_shotgunshell\invert_shell.bmp"
    "..\w_762shell\invert_556shell.bmp"
    "..\w_weaponbox\invert_itemc_chrome.bmp"
    "..\w_weaponbox\invert_itemtop.bmp"
    "..\w_weaponbox\invert_sidemap.bmp"
    "..\w_longjump\invert_back.bmp"
    "..\w_longjump\invert_backpackfront.bmp"
    "..\w_longjump\invert_black_chrome.bmp"
    "..\w_longjump\invert_filler.bmp"
    "..\w_longjump\invert_jets.bmp"
    "..\w_barrel\invert_barrel_metal2.bmp"
    "..\w_cabinet\invert_k.o.bmp"
    "..\w_bolt\invert_boltCHROME.bmp"
    "..\w_bolt\invert_finCHOME.bmp"
    "..\rpgrocket\invert_rocket.bmp"
    "..\rpgrocket\invert_rocketmotor.bmp"
    "..\w_tombstone\invert_esc_heorgen_tombstone01.bmp"
    "..\w_tracer\invert_tracer_deep.bmp"
    "..\w_hornet\invert_HGP_Side1.bmp"
    "..\plasma\blueChrome.bmp"
    "..\w_contact_grenade\invert_Side1.bmp"
    "..\w_contact_grenade\invert_Tip1.bmp"
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
  }
}

$texrendermode "..\w_tracer\tracer_deep.bmp" "additive" 
$texrendermode "..\w_tracer\tracer_deep.bmp" "masked" 

// hit box(es)
$hbox 0 "shell" -0.630000 -0.740000 0.000000 0.770000 0.740000 3.000000
$hbox 0 "shotgunshell" -0.800000 -0.800000 0.000000 0.800000 0.800000 3.510000
$hbox 0 "762shell" -0.810000 -0.850000 -2.530000 0.650000 0.710000 3.900000
$hbox 0 "weaponbox" -7.120000 -5.500000 -22.920000 7.120000 5.360000 9.490000
$hbox 0 "longjump" -13.170000 -8.970000 -16.820000 13.530000 11.690000 19.469999
$hbox 0 "barrel" -12.160000 -12.290000 -18.000000 12.160000 12.290000 18.000000
$hbox 0 "cabinet" -18.00000 -18.00000 -72.000000 18.00000 18.00000 72.000000
$hbox 0 "bolt" -1.900000 -0.140000 -1.910000 1.900000 25.000000 1.910000
$hbox 0 "rocket" -14.180000 -2.840000 -2.840000 0.020000 2.840000 2.840000
$hbox 0 "tombstone" -417.339996 0.000000 0.000000 0.000000 187.690002 169.039993
$hbox 0 "tracer" -7.090000 -1.900000 -0.600800 2.880000 2.280000 0.632300
$hbox 0 "hornet" -7.090000 -1.900000 -0.600800 2.880000 2.280000 0.632300
// null
$hbox 0 "contactgrenade" -4.730000 -9.880000 -4.100000 4.730000 9.880000 4.100000

// animation sequence(s)
$sequence "shell_idle" "..\w_shell\idle" fps 30 
$sequence "shotgunshell_idle" "..\w_shotgunshell\idle" fps 30 
$sequence "762shell_idle" "..\w_762shell\idle" fps 30 
$sequence "weaponbox_idle" "..\w_weaponbox\idle" fps 30 
$sequence "longjump_idle" "..\w_longjump\idle" fps 30 
$sequence "longjump_spin" "..\w_longjump\spin" fps 21 loop 
$sequence "barrel_idle" "..\w_barrel\idle" fps 30 
$sequence "cabinet_idle" "..\w_cabinet\idle" fps 30 
$sequence "bolt_idle" "..\w_bolt\idle" fps 30 
$sequence "rocket_idle" "..\rpgrocket\idle" fps 30 
$sequence "tombstone_idle" "..\w_tombstone\idle" fps 30 
$sequence "tombstone_undertaker" "..\w_tombstone\undertaker" fps 30 
$sequence "tracer_idle" "..\w_tracer\idle" fps 30 
$sequence "hornet_idle" "..\w_hornet\idle" fps 30 loop 
$sequence "plasma_idle" "..\plasma\idle" fps 30 
$sequence "contactgrenade_idle" "..\w_contact_grenade\idle" fps 30 