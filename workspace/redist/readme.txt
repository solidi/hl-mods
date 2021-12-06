Cold Ice Remastered Edition

This project is a modern rebuild of Cold Ice 1.75, a popular Half-Life mod back in 1999.

The full story: https://medium.com/super-jump/building-a-popular-half-life-mod-during-the-rise-of-counter-strike-fec6a5b9fd8f?sk=6d1427b3f1d832df06bd5b07aaa456bb
Library Game code: https://github.com/solidi/coldice-remastered
Project redist and assets: https://github.com/solidi/hl-mods
Join us on Discord: https://discord.gg/Hu2Q6pcJn3

This mod features works from the community. Without their dedication and hard work, this mod wouldn't look good. See the thanks section below for details!

Features:

- Supports Steam on Windows, Linux, and macOS 
    - Supports Xash3d (see installation for details)
- Original Weapons are back (and more)!
    - Vest Device
    - Silenced Handgun
    - Cluster Grenades
    - 12-Inch Combat Knife
    - Standard Crowbar
    - 50-lb Automatic LAW Rocket Launcher
    - Invisible Beam Tripmine
    - Chumtoads
    - 7.65mm Sniper Rifle
    - Air-Compressed Auto Boltgun
    - Quake II Railgun
    - 30mm Assault Cannon
    - Mag 60 Automatic Handgun
    - 25-Inch Chaingun
    - 120-Pound Grenade Launcher
    - Hans Gruber's Submachine gun
    - USAS-12 Auto Shotgun
    - Manos de Piedras
    - 40 Pound Monkey Wrench
    - Snowballs
    - Koshak's Chainsaw
    - Samel L. Jackson's 12 Gauge Shotgun
    - 44 Magnum Revolver
    - Explosive Assault Shotgun
    - Tactical Nuke Launcher
    - Gauss
- Original and new maps are back too!
    - Training Facility
    - Stalkyard 2
    - Snowyard
    - Cold Ice
    - Canyon
    - Focus
    - Furrow
    - Training Facility 2
    - Bounce 2
    - Catacombs
    - Fences
    - Depot
- Bot support using Grave Bots
- Modern weapon viewmodel improvements
    - Holster weapon animations!
    - Right handed or left handed models
    - Weapon sway and fidet animation for realism
    - Bullet and gun smoke animation for effect
    - Option to switch between ice model skins and real model skins!
    - Option for original models and high res models
- Modern HUD improvements
    - Hud response to motion in a glass-like effect
    - Experimental iron sights support for select weapons
- Offhand Grappling Hook
- Powerup Runes
    - "Frag" - purple - obtain twice the amount of frags
    - "Vampire" - red - obtain health when inflicting damage
    - "Protect" - green - soften the damage sustained by half
    - "Regen" - pink - continually repair health
    - "Haste" - orange - walk and run 50% faster
    - "Gravity" - blue - jump 40% farther
    - "Strength" - yellow - inflict 50% more damage
    - "Cloak" - white - 90% invisibility
- More humorous movie sound clips!
- Throwing meele weapons!
- New weapons will randomly spawn in place of original weapons
- Original Scoreboard, MOTD, view roll options!

Installation:

- For Steam: Place both ice_betax and ice_betax_hd folders in the same folder as where hl.exe is installed.
- For Xash3d: Since Xash3d does not support SD/HD model switching, install the ice_betax folder first where xash3d.exe is located. Then copy ice_betax_hd contents, and paste over the ice_betax folder, overwriting the SD models.

Commands:

Server:

- "addbot" - Add a bot
- "mp_grapplinghook 1" - Allow grappling hook on server
- "mp_grapplinghookdeploytime 1.0" - Time (seconds) when next grappling hook can deploy
- "mp_spawnweaponlist "weapon_fists;weapon_crowbar;weapon_9mmhandgun"" Modify the player's spawn weapons
- "mp_allowrunes 1" - Allow powerup runes on server
- "mp_holsterweapons 1" - Holstering weapons for more realistic gameplay
- "mp_floatingweapons 1" - Floating world weapons ala Quake
- "mp_infiniteammo 1" - Infinite ammo ala CS 1.6
    - "1" - makes the weapon clip infinite
    - "2" - makes the weapon have infinite ammo for reloading
- "mp_blueblood 1" - Enable blue blood
- "mp_moreblood 2" - Increase blood up to 0-5 times
- "mp_startwithall 0" - Start with all weapons

Client:

- Deploy grappling hook - Use "+hook"
- Drop rune - Use "drop_rune"
- Ice Models - "cl_icemodels 2" - To switch between weapon ice skins and real skins
    - "0" - real skin
    - "1" - original inverted skin
    - "2" - 1.75 blue ice skin
    - "3" - Cold Ice Remastered edition skin
- Switch between original and HD models using the "Enable HD models if available" in Video options
- Old Scoreboard - "cl_oldscoreboard 1" - To switch between old and new style scoreboards
- Old MOTD (Message of the Day) - "cl_oldmotd 1" - To switch between old and new style message of the day
- Old View Roll - "cl_viewroll 1" - To switch between view roll during movement
- Old Bob Tilt - "cl_bobtilt 1" - To switch between bob tilt walking animation
- Right Hand Models - "cl_righthand 1" - To switch between right and left handed models
- Bullet Smoke - "cl_bulletsmoke 1" - To switch between bullets creating smoke where they land
- Gun Smoke - "cl_gunsmoke 1" - To switch between weapons creating smoke when fired
- Glass Hud - "cl_glasshud 1" - To switch between motion interactive HUD elements
- Weapon Sway - "cl_weaponsway 1" - To switch between view models swaying with turn movement
- Weapon Fidget - "cl_weaponfidget 1" - To switch between view models fidgeting with jump landings
- Use iron sights when available - Use "+ironsight"
- Play buzzer/bell when frag achieved - "cl_playpoint 1" - To switch onoff playing this sound effect
- Play voice annouce / humor on weapons - "cl_annoucehumor 1" - To switch on/off playing these sound effects

Report Bugs:

Please report defects by creating an issue here: https://github.com/solidi/hl-mods/issues

Thanks To:

- Infinity for original and resurrection Cold-Ice models https://www.chaosworx.net/
- Cathal McNally for every damn Half-Life programming tutorial brought together https://www.sourcemodding.com/
- Gamebanana for "the" archive of models, effects, and everything https://gamebanana.com/
- Various for documenting all cut items from Half-Life https://tcrf.net/Half-Life_(Windows)
- the303 for full mdl spec documentation https://the303.org/tutorials/gold_qc.htm
- Sparken for OzMod grapple hook source https://www.facebook.com/HalfLifeOzDMMod
- zikshadow with handgun silencers https://gamebanana.com/skins/158498
- chris whitman for the silencer tutorial https://web.archive.org/web/20011204054313fw_/http://www.planethalflife.com:80/wavelength/coding/tutorials/02.htm
- Slartibarty for the fixed beretta model https://gamebanana.com/skins/142561
- RR2DO2 for the cluster grenades tutorial http://web.archive.org/web/20010720214509/http://www.contaminated.net/whenitsdone/tutorials/coding/clustergrenades/index.shtml
- APGRoboCop for grave bot https://github.com/APGRoboCop/grave_bot
- MachIII for the weapons label tutorial http://web.archive.org/web/20040702181915/http://www.contaminated.net/mach3/tutorials/weapons/weapon_names.html
- MyInstants.com, soundboard.com, movie-sounds.org and MovieSoundClips for humorous movie clips https://www.myinstants.com/ http://www.moviesoundclips.net/
- RealPatryQVortex for the combat knife https://gamebanana.com/skins/174427
- Flying Crowbar tutorial http://web.archive.org/web/20020717063241/http://lambda.bubblemod.org/tuts/crowbar/
- GearBox for select sound effects from Opposing Force
- [BT]FLoyD for the adjustable tripmine beam tutorial http://web.archive.org/web/20040807130953/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=26
- Romk4 for the HD Chumtoad models and sound https://gamebanana.com/skins/174694
- L453rh4wk and sabianroberts for the view roll and bob tilt restoration https://github.com/ValveSoftware/halflife/issues/1544
- Valve for select models from Team Fortress Classic
- JoelTroch for the crowbar idle weapon fix https://github.com/ValveSoftware/halflife/issues/1585
- Powerup deathmatch runes tutorial by Phantasiere (nrich@iinet.net.au)
- Trond for the Holster animation fix tutorial https://web.archive.org/web/20011006194358fw_/http://www.planethalflife.com:80/wavelength/coding/tutorials/11.htm
- Maxxiii for HLSources/Headcrab Frenzy for left handed view model code https://github.com/HLSources
- Teh Snake for the USAS-12 model https://gamebanana.com/mods/230345
- Sgt.Leon and the HIT Forum for the HIT Fist pack https://gamebanana.com/mods/180184
- Gaming Sound FX for sound and effects https://www.youtube.com/channel/UCi-xN4ZB6e-0JcXzvBEomlw
- Audio Library - Free Sound Effects for sound and effects https://www.youtube.com/channel/UCkq5JZ2yOF7b0rkMQMgdAIA
- WastelandHL for sound effects and inspiration http://wastelandhalflife.com/screenshots.shtml
- Nucleo for the excellent pipe wrench https://gamebanana.com/mods/180196
- The classic TFC wrench model by Valve https://www.moddb.com/mods/team-fortress-classic/addons/old-wrench-model
- Snow-War for snowball models https://www.moddb.com/mods/snow-war
- Gunship Mark II and MiniMod for select sprites https://gunshipstuff.x10.mx/
- BlueNightHawk for modern camera and model view effects https://www.youtube.com/channel/UC0PNv922mRm4moyG5a7yrqA
- Koshak_HL for the HD chainsaw model and others http://www.mediafire.com/file/e58fkqupd1059qv/Half_Life_New_Weapons_Mod.rar/file
- Ghoul_bb for the SD chainsaw models https://gamebanana.com/mods/180187
- Fritz the Cat! for the hhev player model
- SMOD series for the iron sights switch sounds effects https://www.moddb.com/mods/smod-40a
- Jouko "Rapturer" Karvinen for the original Cold Ice map
- Schrade for the focus map and Apo for the furrow map
- zoonyarts and Brutal Half-Life for select sound and model assets https://www.moddb.com/mods/brutal-half-life
- mikela-valve for the infinite ammo approach https://github.com/ValveSoftware/halflife/issues/2598
- Bobito Pawner and Firearms for the M16 model with reanimations https://www.moddb.com/games/half-life/addons/m16-reanimations-released
- The Cold-Ice 2.5 for the m16 weapon model
- malortie for the crossbow and glock animation fixes https://github.com/malortie/halflife
- The overhaul pack for select sound effects https://www.moddb.com/mods/half-life-overhaul-pack
- The BFG model and flakcannon from the Weapons Edition mod https://www.moddb.com/mods/half-life-weapon-edition
- The nuclear explosion sound effect https://www.youtube.com/watch?v=BnTN19D7i0M
