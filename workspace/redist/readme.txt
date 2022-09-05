Cold Ice Remastered Edition

This project is a modern open-sourced rebuild of Cold Ice 1.75, a popular Half-Life mod back in 1999. Set in a winter scene, its philosophy is to deliver deathmatch that doesn't take itself seriously. Only in this mod will you find voiceover cameos from Samuel L. Jackson, Hans Gruber, and "Leeroy Jenkins" by Ben Schulz. Its ethos delivers an explosively frantic fast-paced gameplay that was and always will be Cold Ice.

The whole story: https://medium.com/super-jump/building-a-popular-half-life-mod-during-the-rise-of-counter-strike-fec6a5b9fd8f?sk=6d1427b3f1d832df06bd5b07aaa456bb
Library game code: https://github.com/solidi/coldice-remastered
Project redist and assets: https://github.com/solidi/hl-mods
Join us on Discord: https://discord.gg/Hu2Q6pcJn3

This mod features works from the community. Without their dedication and hard work, this mod wouldn't look good. See the thanks section below for details!

Beta 3 Features:

- New Weapons
    - Rocket Crowbar
        - Swing / Swing + Fire Drunk Rocket
- Game Modes
    - Mutators
        - "rocketcrowbar" - includes rocket crowbar on spawn, makes all rockets act drunk
- New Player Models
    - Baer
- Maps
    - Improvements to Drift
    - snow_camp, a rebuild of boot_camp by Napoleon and reskin by AudioCraZ
- Server
    - Added "mp_mutators" to mutate gameplay
    - Added "mp_spawnweapons 1" to allow weapons to spawn or not
- Fixes
    - Even more spawn point angle corrections
    - Fixed rocket sound effects
    - Added missing Dual Mag60s into Linux version

Beta 2 Features:

- New Weapons
    - Includes SD/HD models that can switch blue/orange skins. (+) = Supports ironsight
        - Desert Eagle (+)
            - Shoot
        - Xero n2o Freeze Gun (+)
            - Shoot
        - Dual Desert Eagles
            - Shoot / Shoot Both
        - Dual RPGs
            - Shoot Both / Extreme Rockets
        - Dual Mag60s
            - Shoot Both
        - Dual SMGs
            - Shoot Both
        - Dual Wrenchs
            - Swing Both / Throw Both
        - Dual USAS-12
            - Shoot / Shoot Both
        - Snarks
            - Throw / Release All
        - Camera mode added: Tactical Nuke Launcher
            - Shoot Nuke / Camera Mode (Goodbye all!)
    - Unique hud sprites for all weapons
- New Maps
    - Snowcross, an expanded reskin of crossfire
    - Frostfire, a reskin of bounfire by TheSpacePirate
    - Drift, a reskin of dust by AudioCraZ
    - Graphic spectator overviews for all maps
- New Player Models
    - Snowman
- Dual-Wielded Weapons
    - Support for the pipe wrench, desert eagles, mag60s, smgs, usas, and rpgs!
    - "impulse 205" to swap between single and dual weapons
    - "mp_dualsonly" to play with only dual weapons
- Fear / Trepang2 / Selaco Slide
    - While looking ahead, press "+forward" three times in a row to slide
- Off-handed Punch, Kick, and Slide
    - "impulse 206" supports the kick function
    - "impulse 207" supports the punch function
    - "impulse 208" supports the slide function
- Pick up and Punch Back
    - Use button can pick up grenades and satchels, throwing them back
    - Pickup, kick, or punch back snarks, chumtoads
    - See "mp_interactiveitems" to extend this list!
- Weapon Updates
    - Crowbar/Throw decals
    - Bullet decals and ricochet sparks
    - Thicker crosshairs/crosshairs on melees/change colors with cl_icemodels
    - Support for real muzzle flash using cl_icemodels 0
    - Randomized fire sprites at the end of explosions
    - Increase grappling hook deploy speed, provide damage and speed cvars
    - Mortar turrets support ice explosions
    - Add support for unlimited throwable objects with infinite ammo mode
- Client Support
    - "snowman" supports god mode (when sv_cheats 1)
    - "cl_showtips" to show random text tips during gameplay
    - "cl_shadows" draws rendered shadows
    - "cl_glowmodels" draws glow models if available
    - Footstep sound effects for snow and other textures
- Modern weapon viewmodel improvements
    - Weapon retracts when up against a wall
- Movement
    - Added "sv_jumpheight" to adjust the amount of the player's jump height
- Powerup Runes
    - Amount of runes spawned now related to the number of connected players
- Hud
    - Include glass HUD effect to death notice and weapon identification
    - "cl_flashonpickup" flashes HUD on picking up a weapon or item
- Menu
    - Updated corner logo
    - Improved background and loading menu with new snowflake menu
- Server
    - Added "mp_icesprites 1" to switch between select ice and real environment sprites
    - Added announcement to those that join the server
    - Added "mp_randomweapon 0" to give a random weapon at spawn
    - Added "mp_interactiveitems", a semicolon-separated list of items that are "interactive" (kickable, pickupable)
    - Added "mp_snowballfight", to play with one-shot kill snowballs only!
- Fixes
    - Skinned the hev to blue
    - "mp_grapplinghook" default value now set to 1
    - Added w_egon model spin
    - Fixed hhev attachments
    - Fixed vest crash in single player
    - Fixed WILD sounds in coldice
    - Normalized sound loudness
    - Fixed medkit/battery/gauss ammo backface bug
    - Fixed missing inverted and iced skin for the player crowbar
    - Patch bots in slow motion after many map changes
    - Improved Bot weapon select and engagement of the player
    - Bots no longer engage the player with a cloak rune
    - Modernized bot library code
    - Updated Bot velocity calculations to projectiles
    - Fixed USAS-12 backface bug
    - Fixed bug where bots did not use all player models
    - Fixed weapon idle during iron sight mode
    - Fixed weapons firing underwater
    - Fixed revolver weaponbox model
    - Added 12 gauge muzzle flash
    - Fixed chainsaw hev arms
    - Increased flak cannon size and repaired spinning animation
    - Removed missing chumtoad sound effects
    - Fix flak bomb crash
    - Fix owner credit to the nuke launcher
    - Fixed bot crash during holstering weapons
    - Fixed bot waypoint crash
    - Fixed view model lag for different framerates
    - Patched some models like the throwable crowbar are not iced over
    - Fixed spawn point angles in stalkyard2, training, and fences
    - Fixed incorrect placement of gauss ammo model on floor
    - Fixed rapid fists/crowbar/knife/wrench hits
    - Fixed twisted Assassin player model
    - Fixed chumtoad and snark blood color
    - Removed empty weaponbox that only contained fists
    - Re-enabled the rocket launcher laser spot tracking
    - Fixed the grappling hook's owner in combat
    - Corrected ice explosion sprite showing a green border
    - Patch default_fov being overwritten by ironsights code
    - Improved Bounce2 by correcting bugs and adding lights
    - Fixed ppk fire timing while adding silencer
    - Fixed vest priority when picked up
    - Fixed "unnamed" bots on Linux
    - Improved chaingun performance
    - Fixed Mag60 rotation bug
    - Smoothed out the weaponsway feature
    - Reduced intensity of the weapon float/drop
    - Patch infinite ammo with items like tripmine
    - Fixed reload time on some weapons
    - Fixed inverted shotgun shell skin
    - Changed bot priority of snowballs above fists
    - Increased distance of vest attack used by bots
    - Fixed numerous spawn point angles
    - Rely on the skill.cfg damage values for Cold Ice weapons
    - Removed floating clip in view while using handgun silencer
    - Fixed high-speed empty clicking on RPGs
    - Fixed origin of the grapple hook default sound
    - Fixed nuke damage, linking it to skill.cfg value
    - Align snowball puff effect, include it if hitting player
    - Fixed floating tree in Canyon
    - Fixed swinging chainsaw sfx not heard by others
    - Patched player models not correctly appearing in options menu
    - Fixed reload times for bots and weapons
    - Added clipping borders to canyon and training2 maps

Beta 1 Features:

- Supports Steam on Windows, Linux, and macOS 
    - Supports desktop Xash3d (see installation for details - Android support coming in Beta 2)
- 30 weapons with originals included (and more)!
- Includes SD/HD models that can switch blue/orange skins. (+) = Supports ironsight
    - Manos de Piedras
        - Right / Left Jabs / Shoryuken
    - Standard Crowbar
        - Right / Left Swing / Throw
    - 12-Inch Combat Knife
        - Right / Left Stab / Throw
    - 40 Pound Monkey Wrench
        - Right / Left Swing / Throw
    - Koshak's Chainsaw
        - Right / Left Swing / Full Throttle
    - PPK Silenced Handgun (+)
        - Shoot / Add Silencer
    - 44 Magnum Revolver (+)
        - Shoot / Zoom
    - Blade's Mag 60 Automatic Handgun (+)
        - Shoot / Sideways + Voiceovers
    - Hans Gruber's Submachine gun (+)
        - Shoot / Burst Mode + Voiceovers
    - M16 Machine gun (+)
        - Shoot / M203 Grenade
    - Samuel L. Jackson's 12 Gauge Shotgun (+)
        - Shoot / Pump + Voiceovers
    - Explosive Assault Shotgun (+)
        - Shoot / Double
    - USAS-12 Auto Shotgun (+)
        - Shoot
    - Air-Compressed Auto Boltgun (+)
        - Shoot / Zoom
    - 7.65mm Sniper Rifle
        - Shoot / Zoom
    - 25-Inch Chaingun (+)
        - Spin up / Shoot 
    - 120-Pound Grenade Launcher (+)
        - Shoot M203 / Shoot Cluster
    - 50-lb Automatic LAW Rocket Launcher (+)
        - Shoot Rocket / Shoot Extreme Rockets
    - Gauss
        - Shoot / Power Shot
    - Quake II Railgun (+)
        - Shoot Rail
    - Hivehand
        - Shoot M203 / Shoot Cluster
    - Egon's Egon
        - Fire / Change Wide + Narrow
    - 30mm Assault Cannon (+)
        - Shoot Flak / Shoot Flak Bomb
    - Tactical Nuke Launcher
        - Shoot Nuke (Goodbye all!)
    - Snowballs (+)
        - Throw / Long Throw
    - Cluster Grenades (+)
        - Throw Cluster / Throw Grenade
    - Invisible Beam Tripmines
        - Place Tripmine
    - Assassin Decoy Bombs
        - Throw Decoy
    - Chumtoads
        - Throw / Release All
    - Leeroy Jenkins Dynamite Vest
        - Detonate / Cancel
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
- 14 new player models
    - Alpina
    - Army
    - Assassin
    - Commando
    - Grunt
    - HHev
    - Holo
    - Hotfire
    - Iceman (default)
    - Navy
    - Recon
    - Santa
    - Stormtrooper
    - Swat
- Server Support
    - Bot support using Grave Bots
    - Spawn starting weapons list (and spawn "with all")
    - Infinite Ammo options (for extreme/insane play)
    - Blood amount configuration
- Modern weapon viewmodel improvements
    - Holster weapon animations!
    - Right-handed or left-handed models
    - Weapon sway and fidget animation for realism
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
- Throwing melee weapons!
- New weapons will randomly spawn in place of original weapons
- Original Scoreboard, MOTD, view roll options!

Beta 3 Highly-Valued Upcoming Features:

- See more on our living roadmap: https://github.com/solidi/hl-mods/blob/master/workspace/plan/roadmap.md

Installation:

- For Steam: Place both ice_betax and ice_betax_hd folders in the same folder where hl.exe is installed.
    - See this guide for a step-by-step guide on how to install this mod: https://steamcommunity.com/sharedfiles/filedetails/?id=174908119
- For Xash3d: Since Xash3d does not support SD/HD model switching, install the ice_betax folder first where xash3d.exe is located. Then copy ice_betax_hd contents, and paste them over the ice_betax folder, overwriting the SD models.

How to Play:

Start or join a Cold Ice server. You will spawn with fists and a randomly selected melee weapon. Don't forget you have an off-handed grapple hook and iron sights! (See below). Server and client options below will dictate gameplay. Then, have fun.

If you dislike the "blue" theme, this mod has the option to switch to real skins! (See below)

Commands:

Client:

- Steam only: Switch between original and HD models using the "Enable HD models if available" in Video options
    - Or use "+_sethdmodels" in-game startup parameters
    - See installation above for Xash3d for support of HD models
- "help" - Displays specific client Cold Ice Remastered options
- "+hook" - Deploy an offhand grappling hook
- "+ironsight" - Use experimental iron sights when available 
- "impulse 206" - Use for kick function
- "impulse 207" supports the punch function
- "impulse 208" supports the slide function
- "impulse 205" - Swap between single and dual weapon, if available
- "drop_rune" - Drop rune
- "snowman" - God mode (when sv_cheats 1)
- "cl_icemodels 2" - Ice Models - To switch between weapon ice skins and real skins
    - "0" - real skin
    - "1" - original inverted skin
    - "2" - 1.75 blue ice skin
    - "3" - Cold Ice Remastered edition skin
- "cl_oldscoreboard 1" - Old Scoreboard - To switch between old and new style scoreboards
- "cl_oldmotd 1" - Old MOTD (Message of the Day) - To switch between old and new style message of the day
- "cl_viewroll 1" - Old View Roll - To switch between view roll during movement
- "cl_bobtilt 1" - Old Bob Tilt - To switch between bob tilt walking animation
- "cl_righthand 1" - Right-Hand Models - To switch between right and left-handed models
- "cl_bulletsmoke 1" - Bullet Smoke - To switch between bullets creating smoke where they land
- "cl_gunsmoke 1" - Gun Smoke - To switch between weapons creating smoke when fired
- "cl_glasshud 1" - Glass Hud - To switch between motion interactive HUD elements
- "cl_weaponsway 1" - Weapon Sway - To switch between view models swaying with turn movement
- "cl_weaponfidget 1" - Weapon Fidget - To switch between view models fidgeting with jump landings
- "cl_weaponretract 1" - Weapon Retracts - To switch between view models that retract against walls
- "cl_playpoint 1" - Play buzzer/bell when frag achieved - To switch onoff playing this sound effect
- "cl_announcehumor 1" - Play voice announce / humor on weapons - To switch on/off playing these sound effects
- "cl_showtips 1" - Show helpful text tips during gameplay
- "cl_shadows 1" - Show rendered shadows underneath models
- "cl_glowmodels 1" - Show models with a glow effect if available
- "cl_flashonpickup 1" - Flash HUD when picking up a weapon or item

Server:

- "help_server" - Displays specific server Cold Ice Remastered options
- "addbot" - Add a bot
- "botdontshoot 0" - Enable or disable bots attacking others
- "mp_grapplinghook 1" - Allow grappling hook on server
- "mp_grapplinghookdeploytime 1.0" - Time (seconds) when next grappling hook can deploy
- "mp_spawnweaponlist "weapon_fists;weapon_crowbar;weapon_9mmhandgun"" Modify the player's spawn weapons
- "mp_allowrunes 1" - Allow powerup runes on server
- "mp_holsterweapons 1" - Holstering weapons for more realistic gameplay
- "mp_floatingweapons 1" - Floating world weapons ala Quake
- "mp_infiniteammo 1" - Infinite ammo ala CS 1.6
    - "1" - makes the weapon clip infinite
    - "2" - makes the weapon have infinite ammo for reloading
- "mp_iceblood 1" - Enable blue blood
- "mp_moreblood 2" - Increase blood up to 0-5 times
- "mp_startwithall 0" - Start with all weapons
- "mp_allowvoiceovers 1" - Allow public voiceovers
- "mp_dualsonly 0" - Allow dual weapons only
- "sv_jumpheight 45" - Adjustable player's jump height
- "mp_icesprites 1" - Switch between select ice and real environment sprites
- "mp_interactiveitems "grenade;monster_satchel;monster_chumtoad;monster_snark"", a semicolon separated list of items that are "interactive" (kickable, pickupable)
- "mp_snowballfight 0" - Replace all weapons with deadly snowballs!
- "mp_mutators" - Add mutators to gameplay
    - "rocketcrowbar" - includes rocket crowbar on spawn, makes all rockets act drunk
- "mp_spawnweapons 1" - Spawn weapons or not

Report Bugs:

Please report defects by creating an issue here or in discord: https://github.com/solidi/hl-mods/issues

Thanks To:

- Infinity for original and resurrection Cold-Ice models https://www.chaosworx.net/
- Cathal McNally for every damn Half-Life programming tutorial brought together https://www.sourcemodding.com/
- Gamebanana for "the" archive of models, effects, and everything https://gamebanana.com/
- Various for documenting all cut items from Half-Life https://tcrf.net/Half-Life_(Windows)
- the303 for full mdl spec documentation https://the303.org/tutorials/gold_qc.htm
- Sparken for OzMod grapple hook source https://www.facebook.com/HalfLifeOzDMMod
- zikshadow with handgun silencers https://gamebanana.com/skins/158498
- Chris Whitman for the silencer tutorial https://web.archive.org/web/20011204054313fw_/http://www.planethalflife.com:80/wavelength/coding/tutorials/02.htm
- Slartibarty for the fixed beretta model https://gamebanana.com/skins/142561
- RR2DO2 for the cluster grenades tutorial http://web.archive.org/web/20010720214509/http://www.contaminated.net/whenitsdone/tutorials/coding/clustergrenades/index.shtml
- APGRoboCop for grave bot https://github.com/APGRoboCop/grave_bot
- MachIII for the weapons label tutorial http://web.archive.org/web/20040702181915/http://www.contaminated.net/mach3/tutorials/weapons/weapon_names.html
- MyInstants.com, soundboard.com, movie-sounds.org and MovieSoundClips for humorous movie clips https://www.myinstants.com/ http://www.moviesoundclips.net/
- RealPatryQVortex for the combat knife https://gamebanana.com/skins/174427
- Flying Crowbar tutorial http://web.archive.org/web/20020717063241/http://lambda.bubblemod.org/tuts/crowbar/
- GearBox for select sound effects and hud sprites from Opposing Force
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
- WastelandHL for sound effects, animation, models, and inspiration http://wastelandhalflife.com/screenshots.shtml
- Nucleo for the excellent pipe wrench https://gamebanana.com/mods/180196
- The classic TFC wrench model by Valve https://www.moddb.com/mods/team-fortress-classic/addons/old-wrench-model
- Snow-War for snowball models https://www.moddb.com/mods/snow-war
- Gunship Mark II and MiniMod for select sprites https://gunshipstuff.x10.mx/
- BlueNightHawk for modern camera and model view effects https://www.youtube.com/channel/UC0PNv922mRm4moyG5a7yrqA
- Koshak_HL for the HD chainsaw model and hud sprites http://www.mediafire.com/file/e58fkqupd1059qv/Half_Life_New_Weapons_Mod.rar/file
- Ghoul_bb for the SD chainsaw models https://gamebanana.com/mods/180187
- Fritz the Cat! for the hhev player model
- SMOD series for the iron sights switch sounds effects https://www.moddb.com/mods/smod-40a
- Jouko "Rapturer" Karvinen for the original Cold Ice map
- Schrade for the focus map and Apo for the furrow map
- zoonyarts and Brutal Half-Life for select sound, decals, and model assets https://www.moddb.com/mods/brutal-half-life
- mikela-valve for the infinite ammo approach https://github.com/ValveSoftware/halflife/issues/2598
- Bobito_Pawner and Firearms for the M16 model with reanimations https://www.moddb.com/games/half-life/addons/m16-reanimations-released
- The Cold-Ice team 2.5 for the m16 weapon model
- malortie for the crossbow and glock animation fixes https://github.com/malortie/halflife
- The overhaul pack for select glow models and sound effects https://www.moddb.com/mods/half-life-overhaul-pack
- The BFG model and flakcannon from the Weapons Edition mod https://www.moddb.com/mods/half-life-weapon-edition
- The nuclear explosion sound effect https://www.youtube.com/watch?v=BnTN19D7i0M
- Valve? for the Santa player model https://www.moddb.com/games/half-life/addons/santa-claus
- Nikolay Aulov for posting demos of interesting mod work https://www.youtube.com/channel/UC84fg8XhWXVhaw4Kfy2ch1g
- AudioCraZ for the dedicated server and last minute testing for Beta 1
- Napoleon for 64+ weapon support tutorial, game icons, and select sprites https://www.moddb.com/mods/flatlinea, https://hlfx.ru/forum/printthread.php?s=bfe881fac5dfaa3d7ba925e6641576ad&threadid=5299
- Bobito_Pawner for select weapon animations https://www.moddb.com/members/bobitopawner
- BlueNightHawk for thicker crosshairs from New Light https://www.moddb.com/mods/half-life-new-light
- Illya and Ku2zoff for plasma rifle / freeze gun code, CSO's plasma gun model https://cso.fandom.com/wiki/Plasma_Gun
- Zarko 'Napoleon' Dinev for crossfire2k source as reskinned as snowcross https://gamebanana.com/mods/59331
- BlackShadow306 for the cl_shadows tutorial https://twhl.info/thread/view/20220 
- BlueNightHawk for weapon retract code https://github.com/BlueNightHawk/hl-newlight / https://www.moddb.com/mods/half-life-new-light
- TheSpacePirate for frostfire, a reskin of bounfire https://www.reddit.com/r/HalfLife/comments/n0eq4o/i_made_all_the_original_halflife_multiplayer_maps/ / https://twhl.info/vault/view/6608
- Bacontsu and others for glow model code found in Half-Life Extended SDK https://github.com/bacontsu/halflife-extended
- Unnamed for the startup jingle from Stanley Steemer (call them for carpets cleaned!) https://www.youtube.com/watch?v=kda7SJHtUhk
- Radiation Hazard for testing Beta 2 and uncovering bugs https://www.youtube.com/c/radiationhazardyt
- Kralich/David for helping up get headlines on ModDB! https://www.moddb.com/members/kralichddg
- Dave Johnston for dust, and AudioCraZ for his reskin called "drift"
- suXin and the Half-Payne team for the dual mag60 animations https://www.moddb.com/mods/half-payne
- Laser for the rocketcrowbar standard model https://gamebanana.com/mods/38100
- Dario Casali for the original boot_camp, Napoleon for the rebuild, and AudioCraZ for the reskin of snow_camp 
- Romka, A.I., Valve (PS HD Pack), Napoleon for the baer model
