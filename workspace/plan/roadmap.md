# Cold Ice Remastered Roadmap

## Mission

To faithfully recreate the Cold Ice 1.75 experience that works in Half-Life GoldSrc.

## First Principles

1. To reuse models, maps, and sound effects as they were back in the original version
1. More is more with weapons - if the game can handle it, add more of it
1. To listen to the community on playability and update direction on suggestive feedback

# Launch List

1. [ ] Burn in mod with bots on dedicated server for hours
    1. [x] Cluster Grenades
    1. [x] Railgun
    1. [x] Silencer
    1. [x] RPG
    1. [x] Chumtoad
    1. [x] Boltgun
    1. [x] Cannon
    1. [x] Knife
        1. [x] Match a better decal
    1. [ ] Crowbar (bots disappeared?)
    1. [x] Sniper Rifle
    1. [x] Mag60
    1. [x] Chaingun
    1. [x] Grenade Launcher
    1. [x] mp5k
    1. [x] Usas
    1. [x] Fists
        1. Learned that giving a weapon on spawn that already is given with spawnweaponlist causes entities to accumulate.
        1. [x] Big uppercut punch secondary fire with fists (Shoryuken)
    1. [x] Wrench
    1. [x] Snowball
    1. [x] Chainsaw
    1. [x] 12 Gauge
    1. [x] 44 Magnum
    1. [x] M16
    1. [x] Explosive Assault Shotgun
    1. [x] Nuke Launcher
    1. [x] Snarks
        1. [x] Odd sz_getspace error, bots walking slowly?
    1. [x] Deagle
    1. [x] Dual Deagles
    1. [x] Dual RPG
    1. [x] Dual Wrench
    1. [x] Dual SMG
    1. [x] Dual USAS
    1. [x] Freezegun
1. [ ] Testing
    1. [x] Weapons behaviors under water
    1. [ ] Fakelag with weapons
    1. [x] Map changes with all weapons
1. [ ] Publish
    1. [x] [ModDB Entry](https://www.moddb.com/mods/cold-ice-remastered)
    1. [ ] Gamebanana Entry
    1. [x] Write short post
        1. [x] r/halflife
        1. [x] fb ragegroup
        1. [ ] Steam Workshop?
        1. [ ] [TWHL](https://twhl.info/forum/view/mods)
    1. [x] [Steam Community Forums](https://steamcommunity.com/app/70/discussions/0/1489992713697672376/)
    1. [x] Update url_dl in liblist.gam

### Beta 3

1. Gameplay Modes
    1. [ ] Mutators
        1. [x] RocketCrowbar
        1. [x] Volatile
        1. [x] Instagib
        1. [x] Plumber
        1. [x] Paintball
        1. [ ] SlappersOnly
        1. [ ] DK Mode
        1. [ ] Rubberband (Players who are at the bottom get max health)
        1. [ ] License to Kill
        1. [ ] Night-ops
        1. [ ] Tiny
        1. [ ] Snowball
    1. [ ] Capture the Chumtoad
        1. The object of 'Catch the Chumtoad' is to hold onto the toad as long as you can without being fragged by your friends. You receive 1 point for every 10 seconds you hold onto the toad (the time of course is variable). Players without the toad can only hurt the toad holder, not each other or themselves, so you can use big weapons as recklessly as you like.
        1. When someone picked up the Chumtoad, it made several loud clucks, and a text announcement was made "player picked up the Chumtoad".
        1. When you ran around, there were feathers would fall to the ground in a path and not fade away for 10-15 seconds.
        1. If you stood still, the Chumtoad would make a long drawn out "bawk" every few seconds.
        1. You could "throw" the Chumtoad either at the ground, or at another player. If caught by the player, they would immediately catch it (this lead to tactics as throwing a Chumtoad at a player, killing them, and taking the Chumtoad back)
        1. I can't remember if there were weapons allowed or mele only. I believe there were modifiers.
        1. Chumtoad holder had extra health
        1. Chumtoad holder had faster run speed (I believe this was with guns enabled).
1. Weapons
    1. [x] Railgun follows through multiple targets
    1. [ ] Throw any weapon as an attack
    1. [ ] Reduce punch / animations in ironsights
    1. [ ] Hand cannon / Dual hand cannon
    1. [ ] [Boomerang (AudoCraZ)](https://twitter.com/JoinDeepRock/status/1568229337647685633?t=8vCgTQm8vuHP2T9rQnZ5Jw&s=19)
    1. [ ] [Blue Takis](https://www.youtube.com/watch?v=2LaOo_xo7O0)
    1. [ ] Gold Skins?
1. Mechanics
    1. [ ] Make offhand kick/punch more useful
    1. [ ] Damaging somersault left / right
1. Maps
    1. [x] frost_pit (snark_pit reskin)
    1. [x] snow_camp (boot_camp reskin)
    1. [ ] mill (reboot)
    1. [ ] Add info_intermission points
    1. [ ] Realign large blue crate textures so detailed textures is left to right
1. Models
    1. [ ] Gold Skin? (Radu Matei Ionut)
1. Environment
    1. [ ] Explosive barrels / generator
    1. [ ] Snow effect
1. Runes
    1. [ ] Add text about rune and what it does
1. Client Support
    1. [x] cl_autoweaponswitch
    1. [ ] cl_hudscale
    1. [ ] Better labeling of runes
    1. [ ] Russian translations
1. Support
    1. [ ] Add compiled mmod linux library
    1. [ ] Patch singleplayer crashes
    1. [ ] Make it easy to add bots on "Create Server"

### Beta 2

1. Weapon Themes
    1. [x] 64 weapons
    1. [x] Akimbo's (select weapons)
        1. One each slot?
            1. [x] Wrench
            1. [x] Deagle
            1. [x] SMG
            1. [X] USAS
            1. [x] RPG
    1. Throw (all weapons)
        1. [x] Throw back grenade
    1. [x] [Freeze gun](https://www.youtube.com/watch?v=k0Tl06wRjlE)
        1. [x] Freeze player, explode in pieces
        1. [x] A shoryuken on a frozen player automatically blows them up
1. More Valve maps reskinned
    1. [x] Crossfire
1. Movement
    1. [x] [Jump height](https://twitter.com/gvarados/status/1510759376247734274)
1. Bot support
    1. [x] Tweaked support for grave_bot
1. Game Mechanics
    1. [x] Kick function like [brutal hl](https://www.moddb.com/mods/brutal-half-life)
    1. In-game help menu
        1. [x] Show version in message
        1. [x] Random "did you know" messages during play to expose options
    1. [x] Player snow footstep sounds / materials
    1. [x] Punch while holding weapon?
    1. [x] Selaco styled sliding, as seen [here](https://twitter.com/SelacoGame/status/1512832439172968465?s=20&t=Xma6sO4FhVjL1v4eXpiY4A)
1. Gameplay
    1. [x] mp_dualsonly - only allow dual type weapons
    1. [x] mp_snowballfight - only allow snowballs
1. Environment look and feel
    1. [x] Bullet hole decals like BHL
    1. [x] [r_shadows tutorial](https://twhl.info/thread/view/20220)
    1. [x] Random fire sprite at end of explosion like BHL
1. Weapons
    1. [x] [64 weapon support](https://github.com/SamVanheer/halflife-updated/commit/c633af888fb276d9572dc77df328d7724a206ff2)
    1. [x] Deagle
        1. [x] Single shot weapons for semi-auto effect
    1. [x] Akimbo support
    1. [x] Gauss gun as freeze gun. See freeze effect [here](http://web.archive.org/web/20040804041434/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=65)
    1. [x] Nuke launcher secondary fire [SET_VIEW mode](https://github.com/HLSources/hl-weapon-edition/blob/eb978fb6450949b6c998ac683803361a29a94734/dlls/projectiles/proj_nuke.cpp)
1. Weapon ViewModel / Effects
    1. [x] A generic draw/holster sound? (like CS:GO)
1. Configuration Support
    1. [x] cl_weaponvoice - disable or enable humor/voice sound effects
1. UI / Menu
    1. [x] Cold Ice logo at bottom of menu
    1. [x] Cold Ice Splash with Blue Gordon, Half-Life logo -> Iceman + Cold Ice Logo in HEV suit
1. Maps
    1. All Maps
        1. [x] Overview graphic
    1. [x] Crossfire re-skinned
1. HUD
    1. [x] Highlight HUD when picking up item (bhl)
    1. [x] Best sprite effort weapon 
        1. [x] Pipewrench, knife, deagle, and rifler from OpFor?
        1. [x] Weapon Sprite + text at bottom as compromise?
1. Fixes
    1. [x] Bots harder to see player with cloak rune.
    1. [x] Make grappling hook default enabled
    1. [x] Rename release zip to `cold-ice-remastered-<hash>`
    1. [x] Repair backs of health kits
    1. [x] Throwable crowbar sometimes not iced?
    1. [x] Skin blue item_suit
    1. [x] Knife / Crowbar / Wrench next attack instant after death: (Fix [can be found](https://github.com/FWGS/hlsdk-xash3d/pull/251/files) in xash3d)
    1. [x] Add faces to bottom/back of item models
    1. [x] Turn 180 spawn point in training by range / door
    1. [x] Twisted assassin player model
    1. [x] Spawn x / 2 runes per currently connected players?
    1. [x] Patch canyon and other maps that have skybox holes (thanks to RadHaz)
    1. [ ] Stop weapon animation during freeing (chaingun)
1. Player Models
    1. [x] [Snowman](https://gamebanana.com/mods/179220)
1. Game Dev Tools
    1. [x] Compile maps in a [parallel](https://www.provartesting.com/documentation/devops/continuous-integration/github-actions/parallel-execution-in-github-actions-using-job-matrix/) [matrix](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions) [job](https://github.community/t/merge-matrix-build-artifacts-for-release/118190) setup.
    1. [x] God mode (for recording, etc)
1. Community ideas
    1. [x] Give option to player to adjust sway of weapon magnitude, or find the framerate and match it (see HL-NewLight)
    1. [x] Improve crosshair visibility ([Bonhomme](https://discord.com/channels/790549024373604353/790549024373604356/927735897959575572))

### Unscheduled

1. Supported Systems
    1. [ ] Android support [hlsdk-xash3d](https://github.com/FWGS/hlsdk-xash3d)
    1. [ ] Convert game code to [halflife-updated](https://github.com/SamVanheer/halflife-updated)
    1. [ ] Source version
1. Weapons
    1. [ ] Throw any weapon
    1. [ ] Quad weapon attachment?
    1. [ ] Hand cannon
    1. Crossbow
        1. [ ] Pluck animation from (Half-Life Restored)(https://gamebanana.com/mods/download/36047)
    1. Handgrenades
        1. [ ] [Dual wield grenades](https://twitter.com/kirkhamilton/status/1244786371253788673) - second fire?
        1. [ ] Roll animation from (Half-Life Restored)(https://gamebanana.com/mods/download/36047)
        1. [ ] Grenade toss option as secondary fire. See [this video](https://www.youtube.com/watch?v=e59bvmvXPk0) for more information. This [other video](https://www.youtube.com/watch?v=5-fNv9g_JLI) covers egon narrow animations.
    1. [ ] [Portal gun?](https://www.youtube.com/watch?v=Gf_eCVGY2pk&t=20s)
    1. [ ] Weapon/pistol whip like WastelandHL (most weapons) / Gun slap / punch all weapons
    1. [ ] Akimbo's (select weapons)
        1. [ ] Clusters
    1. [ ] Snowball Machine / Snowball Generator in place of Egon gun
    1. [ ] Pulse Rifle
    1. [ ] Pulse Pistol
    1. [ ] C4 mine placement with satchels
    1. [ ] Convert throw-hold effect to all other weapons for control
    1. [ ] [Light saber weapon](https://www.youtube.com/watch?v=-CjaytQLWFY). [Closet model](https://gamebanana.com/mods/180200)?
        1. [ ] Customizable color
    1. [ ] Taser
    1. [ ] Decoy bombs that morph into AI assassins?
    1. [ ] [Gravity gun](https://www.youtube.com/watch?v=0maGDVs18wo)
    1. [ ] Counter-Strike penguin
    1. Knife
        1. [ ] Alt model on [this forum](https://forums.alliedmods.net/showthread.php?p=1701941)
        1. [ ] Cold Ice 2.5 model?
        1. [ ] sparks found on and [this video](https://www.youtube.com/watch?v=-CjaytQLWFY)
    1. [ ] Third person muzzle flash placement
    1. [ ] mag60 sd model from cold ice 2.5
    1. [ ] RPG v_ model with hand on barrel from [New Light](https://www.moddb.com/mods/half-life-new-light)
    1. [ ] Python v_ from brutal HL for focusing animation
    1. [ ] Punch angle for draw and holstering
    1. [ ] Tighten up all idle animation times to match code
    1. [ ] Correct all brass shell ejection points
    1. [ ] Use attachment point for each model
    1. Chaingun
        1. [ ] Secondary chaingun idea?
        1. [ ] Faster spin?
        1. [ ] Tracers on all bullets?
1. Weapon ViewModel / Effects
    1. [ ] Bob up/down like HL New Light v3
    1. [ ] Breakable gibs spawned from bullet damage as seen in MiniMod
    1. [ ] [Centered models?](https://gamebanana.com/mods/179800)
    1. [ ] [Third version of HD gordon arms?](https://www.moddb.com/mods/half-life-2-classic)
    1. [ ] `cl_righthand -1` where [knife is left handed, and weapons are right handed.](https://www.reddit.com/r/GlobalOffensive/comments/43y47t/is_it_possible_to_implement_cl_righthand_1_again/)
    1. [ ] Ice hands in addition
    1. [ ] Blue arms + real skins
    1. [ ] Additional attachment values for configurable speeds and fov
    1. [ ] Damage / blood / stains on view model and player as seen in bhl
    1. [ ] Customize iron-sight values, add support to other weapons at runtime.
1. Server Support
    1. [ ] mp_semiauto
        1. Wire server to client message when changed
1. Movement
    1. [ ] [Somersaults](https://www.moddb.com/mods/the-specialists)
    1. [ ] [Wall jumping](http://articles.thewavelength.net/226/)
1. Bot support
    1. [ ] [Better bot support, actively developed](https://github.com/tschumann/sandbot)
    1. [ ] Bot support for hook
    1. [ ] Bot support for macOS
1. Game Mechanics
    1. [ ] Jetpack?
    1. [ ] Visual hitpoint deductions during play? [See potential tech](https://github.com/YaLTeR/OpenAG/pull/103/files)
    1. [ ] Player jump and land sound effects
    1. [ ] [See own legs](https://www.youtube.com/watch?v=mpKld-jZF7c&t=9s), code [found here](https://github.com/BlueNightHawk/halflife-newlight/commit/c1d189bd67e0f18e219f4fe71a24dccb04307eb6).
    1. [ ] Improved player kick animation from grunt player model
1. Gameplay
    1. [ ] Snowball fight mutator - all weapons fire / throw snowballs - see [Snow-War](https://www.moddb.com/mods/snow-war)
    1. [ ] Unreal tournament [kill announcements](https://unreal.fandom.com/wiki/Achievements_and_awards)
    1. [ ] Ultra deathmatch mutator, unlimited ammo / no reloads. See [Oz Mod video](https://www.youtube.com/watch?v=1L62nPKGlAY), Duke Nukem style.
    1. [ ] mp_startonlywith "weapon_*"
    1. [ ] Rocket/Railgun mutator, [self explanatory](https://www.youtube.com/watch?v=jY6yBTYxLko).
    1. [ ] Weapon filter list
1. Environment look and feel
    1. [ ] Override texture wads to make it feel different, add similar, iced themed textures (start with stalkyard,use impulse 107)
    1. [ ] Swap blue sprites with real sprites with cl_icemodels?
1. UI / Menu
    1. [ ] Orange text in [xash3d menu](http://xash3d.ru/doku.php?id=xashcookbook:en:recipes:art:custom_menu_art)
1. Runes
    1. [ ] Quad damage (Napoleon's [model idea](https://cdn.discordapp.com/attachments/923312701252460544/980739942168793178/cir_logo_3D.7z))
    1. [ ] Ammo regeneration
    1. [ ] Super jump rune
1. HUD
    1. [ ] Re-enable suit voice updates?
    1. [ ] Add map name to the scoreboard
    1. [ ] Slanted health and armor sprites like [Operation: Black Mesa Blue Shift](https://gamerant.com/half-life-black-mesa-blue-shift-opposing-force-campaigns-screenshots/)
1. Maps
    1. [x] Reskin [boot_camp](https://cdn.discordapp.com/attachments/923312701252460544/997489879996969080/boot_camp2k.rmf)
    1. [ ] fgd file
    1. [ ] Finish arena, texture in Cold Ice style
    1. [ ] Training 2
        1. [ ] Frozen pool in new area opposite of garage
    1. [ ] Frozen Lake map idea
    1. [ ] Snow console mechanic/trigger, turn on/off in snowyard
1. Player Models
    1. [ ] All Cold Ice 1.6 player models
1. Integrations
    1. [ ] [Discord](https://github.com/YaLTeR/discord-rpc) rpc integration while playing. Good example is here: [halflife-extended](https://github.com/bacontsu/halflife-extended/tree/main/source-code)
1. Fixes
    1. [ ] mp_infiniteammo -> sv_infiniteammo
    1. [ ] Add git hash to server name in dll
    1. [ ] Improve Crowbar animation from another v_ model
    1. [ ] [Fix animations](https://github.com/ValveSoftware/halflife/issues/2495) on weapons where possible.
    1. [ ] Snowball not exhaustable?
    1. [ ] RPG clip / shotgun box / snark nest / 357 box missing bottom face
1. Clean up
    1. [ ] Separate hev arms/hands cleanly to all v_ models for customization
    1. [ ] Compact w_ models into p_
    1. [ ] Extend length of viewmodel arms, so larger fov's do not show disconnected arms from body
1. Game Dev Tools
    1. [ ] Cache compile_tools artifacts using [workflow caching](https://docs.github.com/en/actions/advanced-guides/caching-dependencies-to-speed-up-workflows)
    1. [ ] Codegen for generating new weapons
    1. [ ] Some static analysis tool to detect method signatures (e.g. Railgun holster animation missing skiplocal var)
    1. [ ] Timestamps for building artifacts
        1. If timestamp of built artifact is newer than all source artifacts, skip building again
    1. [ ] Compile mdl tool for Linux
    1. [ ] Verify [sound loudness](https://superuser.com/questions/1183663/determining-audio-level-peaks-with-ffmpeg) before packaging with ffmpeg?
    1. [ ] Automatic kick all and rejoin bots on a [timed basis](https://wiki.sourceruns.org/wiki/Half-Life_Scripts).
1. Community ideas
    1. [ ] Rune power degradation / Power consumption of the cloak rune? 
    1. [ ] OICW weapon ([Walt](https://discord.com/channels/790549024373604353/790549024373604356/937299092554518589))
    1. [ ] Explode player if using impulse cheat but sv_cheats on server is 0 (Napoleon)
    1. [ ] Freeze grenades ([Audiocraz](https://discord.com/channels/790549024373604353/790549024373604356/959832759612899348))
    1. [ ] Inciderary buckshot (dragons breath) from handcannon ([LambdaParrot](https://discord.com/channels/790549024373604353/790549024373604356/960733589471911977))
    1. [ ] Ice grenade or big ice blast as secondary attack for freezegun (Napoleon)
    1. [ ] Self sign the server and client dlls with [Napoleons tutorial](https://www.moddb.com/mods/flatlinea/tutorials/how-to-do-versioninfo-how-to-do-code-signing-using-self-signed-certificate)
    1. [ ] Taunts from player (Napoleon)
    1. [ ] Rune that will give you unlimited snowballs, and the throw speed for the snowball will be increased (Napoleon)
    1. [ ] Multiple rune equip (Napoleon)
    1. [ ] Ice spike gun (AudioCraZ)
    1. [ ] “fight club mode” no weapons. Just fists, slides, health packs and batteries and buffs. (AudioCraZ)
    1. [ ] "ice spike gun" (AudioCraZ)
    1. [x] cl_autoweaponswitch ([@Runner](https://discord.com/channels/790549024373604353/790549024373604356/1010565554161057872))
    1. [ ] mutators ```mp_mutators "blowup (Napoleon);weapon_(AudioCraZ);insta(The_Pacific_gamer);jetpack(Napoleon);tiny"```
    1. [ ] Do not drop list, nuke and vest on that list. (AudioCraZ)
    1. [ ] Translate to russian (berry from moddb)
    1. [ ] Capture the Chumtoad (AudioCraZ)

### Beta 1

1. Movement
    1. [x] Add offhand [grappling hook]grapple hook](https://github.com/solidi/hl-mods/blob/c91828511f455f9fe323f652379cdb287414ea0b/ci/src/dlls/player.cpp#L4863)
1. Bot support
    1. [x] Custom map waypoints for bots
    1. [x] Add bots
        1. Add [bots](http://hpb-bot.bots-united.com/index.html)
1. Game Mechanics
    1. [x] In-game help menu
    1. [x] HUD notification system - Identity of weapons from Rory
1. Gameplay
    1. [x] mp_startwithall "1"
    1. [x] [sv_inifinite_ammo](https://github.com/ValveSoftware/halflife/issues/2598) idea
    1. [x] Bell when a frag is committed (ala CS:GO)
1. Weapons
    1. [x] Skin Egon, Gauss, Hornetgun, Snark
    1. [x] Spin ammo, battery, healthkit, and longjump
    1. [x] Punch angles for all weapons
    1. [x] Spawn extra weapons with other matching slot number
    1. [x] M16 Assault Rifle
    1. [x] Nuke launcher (Cold Ice 2.5 model) / [Futuristic RPG model swap](https://gamebanana.com/mods/239023)
    1. [x] Assault Shotgun
    1. [x] Vest
    1. [x] Silencer
    1. [x] Cluster Grenades
        1. [x] Pin pull sfx
    1. [x] Knife
    1. [x] Rocket Launcher
    1. [x] Inivisible Tripmines
    1. [x] Chumtoad
    1. [x] Sniper Rifle
    1. [x] Boltgun
    1. [x] Rail Gun
    1. [x] Monkey Wrench
    1. [x] Mag 60
    1. [x] 12 Gauge Shotgun
        1. [x] Jackson randomized sayings during pump select
    1. [x] USAS-12 Auto Shotgun
    1. [x] 25-Inch Chaingun
    1. [x] 30mm Assault Cannon
        1. [x] UT HD model from HLWE
        1. [x] Swap fire modes
    1. [x] 120-Pound Grenade Launcher
    1. [x] Female Assassin Decoy Bombs
    1. [x] Snowball
    1. [x] mp5k
        1. [x] Hans randomized sayings during fire select
    1. [x] Chainsaw
    1. [x] [Throwing crowbar](http://web.archive.org/web/20020717063241/http://lambda.bubblemod.org/tuts/crowbar/)?
    1. [x] Invisible tripmines
    1. [x] [Manos de piedros](https://gamebanana.com/skins/103896) when no weapons available
    1. [x] Increase ammo total counts to match bhl
1. Weapon ViewModel / Effects
    1. [x] [Smoke effect on firing](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=106s)
    1. [x] Iron sights like [brutal hl](https://www.moddb.com/mods/brutal-half-life)
    1. [x] Spinning w_ models as a server option
    1. [x] Have humorous sound effect with each weapon?
    1. [x] Bullet smoke like [brutal mod](https://www.moddb.com/mods/brutal-half-life)
    1. [x] Viewmodel delay on yaw movement like seen in [MiniMod](https://www.youtube.com/watch?v=g3qMHpLMYPk&t=690s)
    1. [x] [Weapon fidget effect / movement on landing a jump](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=540s) when jumping or landing a jump.
    1. [x] Pull back viewmodel on moving forward 
    1. [x] Third model mode - real skins
        1. [x] Convert weaponbox to dropped weapon
            1. [x] Convert all weapons to ground
            1. [x] Two models for w_ models - ground, and floating/spinning
    1. [x] Move HUD elements based on movement to give glass heads up like effect
1. Old School
    1. [x] Scoreboard
    1. [x] MOTD
    1. [x] [Screen tilting](https://github.com/ValveSoftware/halflife/issues/1544)
    1. [x] Holster weapons [animation](https://web.archive.org/web/20011006194358fw_/http://www.planethalflife.com:80/wavelength/coding/tutorials/11.htm)
1. Environment Compile
    1. [x] so's?
    1. [x] dylib's?
    1. [x] Convert Windows endlines to Linux
    1. [x] Debug build pipeline
    1. [x] Edict count
1. Runes
    1. [x] Glowing shell on view model
    1. [x] Cloak rune
1. Skins
    1. [x] Blue blood?
    1. [x] Inverted original weapons
1. Maps
    1. [x] Compile originals
    1. [x] Depot
1. HUD
    1. [x] Original CI numbers / Overhaul numbers
1. Player Models
    1. [x] All CIR player models
    1. [x] Assassin and army models from Cold Ice 2.5
    1. [x] [Santa](https://www.moddb.com/games/half-life/addons/santa-claus)
1. Package for release script
    1. [x] Rename folder to ice_beta1
    1. [x] Remove config or replace with default one
    1. [x] Remove dev.cfg
    1. [x] Remove pdb files
    1. [x] Remove dSYM files
    1. [x] Remove empty models/ and sprites/
    1. [x] Build hash number in package
1. Fixes
    1. [x] Shells and smoke are being shown from others
    1. [x] Adjust Grappling hook trail origin on player
    1. [x] Rename folder and libs to `ice`
    1. [x] Rename github repo to `coldice`
    1. [x] Bot names loading on Linux?
    1. [x] macOS zip file contains invalid paths?
    1. [x] Normalize arm skins (orange default)
    1. [x] [Xash3d orange menu items](http://xash3d.ru/doku.php?id=xashcookbook:en:recipes:art:custom_menu_art)
1. Game Dev Tools
    1. [x] Contribute back to valve halflife repo with github actions to build the full suite

## Collaboration

1. [x] Reach out to [BlueNightHawk](trovymam@gmail.com)
