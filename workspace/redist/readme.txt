Cold Ice GoldSrc Edition

This project is a rebuild of Cold Ice 1.75, a popular Half-Life mod back in 1999.
The full story: https://medium.com/super-jump/building-a-popular-half-life-mod-during-the-rise-of-counter-strike-fec6a5b9fd8f?sk=6d1427b3f1d832df06bd5b07aaa456bb
Source code: https://github.com/solidi/coldice-goldsrc
Project code: https://github.com/solidi/hl-mods

Features:

- Supports Windows, Linux, and macOS 
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
- Offhand Grappling Hook
- Bot support using Grave Bots
- Powerup Runes
    - "Frag" - obtain twice the amount of frags
    - "Vampire" - obtain health when inflicting damage
    - "Protect" - soften the damage sustained by half
    - "Regen" - continually repair health
    - "Haste" - walk and run 50% faster
    - "Gravity" - jump 40% farther
    - "Strength" - inflict 50% more damage
- Option for origin models and high res models
- More humorous movie sound clips!
- Throwing meele weapons!
- Option to switch between ice model skins and real model skins!
- New weapons will randomly spawn in place of original weapons
- Original Scoreboard, MOTD, view roll options!
- Holster weapon animations!
- Right handed or left handed models
- Weapon sway animation for realism
- Bullet smoke sway animation for effect

Commands:

Server:

- Allow grappling hook on server - "mp_grapplinghook 1"
- Time (seconds) when next grappling hook can deploy - "mp_grapplinghookdeploytime 1.0"
- Add a bot - Use "addbot"
- Modify the player's spawn weapons - "mp_spawnweaponlist "weapon_fists;weapon_crowbar;weapon_knife;weapon_9mmhandgun""
- Allow powerup runes on server - "mp_allowrunes 1"
- Holstering weapons for more realistic gameplay - "mp_holsterweapons 1"
- Floating wrold weapons ala Quake - "mp_floatingweapons 1"

Client:

- Deploy grappling hook - Use "+hook"
- Drop rune - Use "drop_rune"
- Ice Models - "cl_icemodels 2" - To switch between weapon ice skins and real skins
    - "0" - real skin
    - "1" - original inverted skin
    - "2" - 1.75 blue ice skin
    - "3" - Cold Ice Goldsrc edition skin
- Switch between original and HD models using the "Enable HD models if available" in Video options
- Old Scoreboard - "cl_oldscoreboard 1" - To switch between old and new style scoreboards
- Old MOTD (Message of the Day) - "cl_oldmotd 1" - To switch between old and new style message of the day
- Old View Roll - "cl_viewroll 1" - To switch between view roll during movement
- Old Bob Tilt - "cl_bobtilt 1" - To switch between bob tilt walking animation
- Right Hand Models - "cl_righthand 1" - To switch between right and left handed models
- Weapon Sway - "cl_weaponsway 1" - To switch between view models swaying with turn movement
- Bullet Smoke - "cl_bulletsmoke 1" - To switch between bullets creating smoke where they land

Thanks To:

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
- MyInstants.com, movie-sounds.org and MovieSoundClips for humorous movie clips https://www.myinstants.com/ http://www.moviesoundclips.net/
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
