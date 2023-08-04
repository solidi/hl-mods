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
        1. [x] Linux
    1. [x] Railgun
    1. [x] Silencer
    1. [x] RPG
    1. [x] Chumtoad
    1. [x] Boltgun
    1. [x] Cannon
        1. [x] Linux
    1. [x] Knife
        1. [x] Linux
    1. [x] Crowbar
        1. [x] Linux
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
        1. [x] Linux
    1. [x] Chainsaw
    1. [x] 12 Gauge
    1. [x] 44 Magnum
    1. [x] M16
    1. [x] Explosive Assault Shotgun
    1. [x] Nuke Launcher
        1. [x] Linux
    1. [x] Snarks
        1. [x] Linux
    1. [x] Deagle
    1. [x] Dual Deagles
    1. [x] Dual RPG
    1. [x] Dual Wrench
    1. [x] Dual SMG
    1. [x] Dual USAS
    1. [x] Freezegun
        1. [x] Linux
    1. [x] Flamethrower
        1. [x] Linux
    1. [x] Flak Cannon
        1. [x] Linux
    1. [x] Gravity Gun
        1. [x] Linux
    1. [x] Sliding
        1. [x] Linux
    1. [x] Crossbow
        1. [x] Linux
    1. [x] Grapplehook
        1. [x] Linux
    1. [x] Portal Gun
        1. [x] Linux
    1. [x] Dual hand cannons
        1. [x] Linux
1. [ ] Testing
    1. [x] Weapons behaviors under water
    1. [ ] Fakelag with weapons
    1. [x] Map changes with all weapons
    1. [ ] Client sided test to local server
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

### Beta 4

1. Up Next
    1. [ ] Single player freeze effect for all monsters
    1. [ ] Railgun effect client side to reduce server messages?
    1. [ ] Freezegun secondary fire beam to explode primary plasma
1. Maps
    1. [x] Private repo build pipeline for quadfrost
        1. [x] Launch quadfrost in Feb 2023 as an add on
    1. [x] [dm_lister](https://gamebanana.com/mods/59480) reskin
    1. [x] thehill
    1. [x] rustmill
1. Game Modes
    1. [x] [Gungame](http://web.archive.org/web/20150823030120/http://avalanche.gungame.org/about.php)
    1. [x] Capture the Chumtoad (Audiocraz)
        1. The object of 'Catch the Chumtoad' is to hold onto the toad as long as you can without being fragged by your friends. You receive 1 point for every 10 seconds you hold onto the toad (the time of course is variable). Players without the toad can only hurt the toad holder, not each other or themselves, so you can use big weapons as recklessly as you like.
        1. When someone picked up the Chumtoad, it made several loud clucks, and a text announcement was made "player picked up the Chumtoad".
        1. When you ran around, there were feathers would fall to the ground in a path and not fade away for 10-15 seconds.
        1. If you stood still, the Chumtoad would make a long drawn out "bawk" every few seconds.
        1. You could "throw" the Chumtoad either at the ground, or at another player. If caught by the player, they would immediately catch it (this lead to tactics as throwing a Chumtoad at a player, killing them, and taking the Chumtoad back)
        1. I can't remember if there were weapons allowed or mele only. I believe there were modifiers.
        1. Chumtoad holder had extra health
        1. Chumtoad holder had faster run speed (I believe this was with guns enabled).
        1. [Quake 3 example](https://www.youtube.com/watch?v=b0RIB6th91M), and [summary](https://lvlworld.com/mod/id:5)
    1. [ ] Brawler mode - like River City Ransom. Weapons removed. Provide menu for weapons at a cost. Drop money as coins when killed. Use Barf, and other sayings in game as taunts.
    1. [ ] What about "kick the Santa hat"? Where you are just kicking the hat (or frosty head) around the map? Randomly chose two spawn points as goals? (AudioCraZ)
1. Game Mechanics
    1. [x] Feign death binding (Napoleon/Rocket Crowbar)
    1. [ ] Front flip
    1. [ ] [Leaning](https://github.com/bacontsu/codename-borea/commit/68ca10f31aa74c50f9e58e6b756b151657fd00ab)
    1. [ ] [Running viewweapon animation](https://github.com/bacontsu/codename-borea/commit/3c0179a138db9d17054b8c341467f21ad49e206d)
    1. [ ] Grapple hook support for bots
    1. [ ] [Elbow smash](https://discord.com/channels/790549024373604353/1010386771168722954/1070360359124336720)
    1. [ ] Auto melee when close to player - may help lead the way to pistol whip for all
    1. [ ] Back slide [like trepang2](https://www.youtube.com/watch?v=CnXyAzi6tOg&t=1007s)
    1. [ ] Choke / throw [like trepang2](https://www.youtube.com/watch?v=CnXyAzi6tOg&t=740s)
1. Weapons
    1. [x] Flame Thrower (Napoleon)
    1. [x] Port [portal gun](https://www.youtube.com/watch?v=Gf_eCVGY2pk&t=20s), [suggested code](http://amx-x.ru/viewtopic.php?f=11&t=3823&start=10)
    1. [x] Satchel Assassins become fully animated monsters (and can be exploded anytime)
    1. [x] Hand cannon
    1. [x] Dual hand cannon
    1. [ ] Explosive shells to dragons breath, light on fire?
    1. [ ] OP4 model from OP4n for deagle
        1. [ ] [Laser sight](https://twhl.info/wiki/page/Weapons_Programming_-_Standard_Weapons) for deagle
    1. [ ] Increase accuracy of weapons when in ironsights mode
    1. [ ] Improved [full bright implementation](https://github.com/BlueNightHawk/halflife_fullbright/commits/master) without second models
1. Server
    1. [ ] [Respawn Breakables](https://web.archive.org/web/20080915083720/http://hlpp.thewavelength.net/tuts/respawnentities.txt)
    1. [ ] Color [bullet tracers](https://twhl.info/thread/view/19663?page=last#post-341544)
    1. [ ] Assisted frag credit in iceman
1. Client
    1. [ ] Time remaining counter like op4dm
    1. [ ] [Radar minimap from spectator](https://www.moddb.com/mods/xdm/downloads) version would be a nice touch?
    1. [ ] Better [flashlight](https://gamebanana.com/tuts/14971) effect on client side
    1. [ ] Better [dynamic client lighting](https://twhl.info/wiki/page/Tutorial%3A_Client_sided_dynamic_lights_%28muzzle_flash%2C_flashlight...%29)
    1. [ ] [Classic Menu and Console](https://github.com/BlueNightHawk/nlui-classic/commit/6e429891eba259bd404eeec08ac5960a2329883b)
    1. [ ] [Motion blur](https://github.com/bacontsu/codename-borea/commit/c6e5ffedb3dc256a6caed8484eb4396bef8bc54b) and [update](https://github.com/bacontsu/codename-borea/commit/c0acfcaf5d799b37468e3044be3c53e8118734b8)
    1. [ ] [Water Splash](https://github.com/bacontsu/codename-borea/commit/89a0c080f99faed3cc1a3f175d608ec37d6e4376)
    1. [ ] [Realtime use sprite](https://github.com/bacontsu/codename-borea/commit/2a3fc957be406a16bca6570cb9ea368c07abea4d)
    1. [x] [Radar](https://web.archive.org/web/20011211004512/http://hlpp.valveworld.com:80/tuts/attrd.html)
    1. [x] Head shot and first blood voice award announcements
1. Game Mutators
    1. [ ] Disable mutator list [via a file](https://github.com/bacontsu/codename-borea/blob/spirit/spirit-1.8-trinity-op4/dlls/util.cpp#L3340)
    1. [ ] Mutators as [indepedent timers](https://www.youtube.com/watch?v=oMeVxnFytJk&t=260s)
1. Single Player
    1. [x] [Chapter Select Menu](https://github.com/BlueNightHawk/testflight/commits/master?after=144d73f461c6b83c818131b0536d3450a4266e8a+34&branch=master&qualified_name=refs%2Fheads%2Fmaster)
1. Environment look and feel
    1. [ ] [Fog effect](https://twhl.info/wiki/page/Tutorial%3A_Coding_Fog) and [this tutorial](https://web.archive.org/web/20040902100119/http://www.3rdlife.net:80/3port/articles/show.php/2)
    1. [ ] [Sun/lens flare effect](https://github.com/HLSources/Spirit-of-Half-Life/blob/5ad2e00fe1546cc73e19255c75512a11ee3980c8/dlls/effects.cpp#L195), better implementation [codename-boera](https://github.com/bacontsu/codename-borea/commit/84c02ef7031f4d0098ab041eeac19c44f5bdfd09)
1. Fixes
    1. [ ] Player projectiles follow aiment while flipping
    1. [ ] Reduce overflow with cannons wth 20 players, make one model with all flak
    1. [ ] More parametter support for [env_snow](https://gamebanana.com/questions/21021)
    1. [x] Fix the [player images](https://gamebanana.com/mods/24527) so they reflect correct colors
    1. [x] Re-review why deploy sounds fire twice, assume deploy animation is being called by client and server
1. Game Dev Tools
    1. [x] Add support for resgen for all maps in pipeline (https://github.com/kriswema/resgen)
        1. [ ] Add support for map brief text file
        1. [ ] Add support for detailed textures
    1. [ ] Update studiomdl to [funnky's toolset](https://github.com/fnky/studiomdl)

### Unscheduled

1. Supported Systems
    1. [ ] Android support [hlsdk-xash3d](https://github.com/FWGS/hlsdk-xash3d)
    1. [ ] Convert game code to [halflife-updated](https://github.com/SamVanheer/halflife-updated)
    1. [ ] Source version
    1. [ ] Add compiled mmod linux library
    1. [ ] Make it easy to add bots on "Create Server"
        1. [ ] New Life Launcher program?
    1. [ ] [Inno Setup](https://github.com/N7P0L3ON/Flatline-Arena-Master/commit/5158ce7977d7a0a5ba5ff9bc2d6dcce5350b1697) install script
1. Game Modes
    1. [ ] Support
        1. [ ] Wins / Rounds Left visual support
        1. [ ] [Active timer on HUD](https://github.com/YaLTeR/OpenAG/blob/master/cl_dll/hud_customtimer.cpp)
    1. [ ] [Arcade mode](https://wiki.sourceruns.org/wiki/Adrenaline_Gamer) but with points
        1. [ ] HUD that pops points [underneath crosshair](https://twitter.com/VRGgameofficial/status/1626341887534829568)
        1. [ ] Point awards like [Maximum Action](https://www.youtube.com/watch?v=17isfGEjf20) (in death queue messages?)
    1. [ ] Only with melee weapons And forced in 3rd person (Napoleon)
    1. [ ] Race to bottom (most deaths wins)
    1. [ ] [Source other GMod ideas](https://steamcommunity.com/sharedfiles/filedetails/?id=2792185122) from this thread - 300+ game modes
    1. [ ] Basic CTF mode
1. Future Game Mutators
    1. [ ] [Not the hornets!](https://www.youtube.com/watch?v=oMeVxnFytJk&t=240s) Hornets randomly spawn and attack player.
    1. [ ] Blue takis, hornetguns replaced with blue takis
    1. [ ] Pong - [pong](https://www.youtube.com/watch?v=oMeVxnFytJk&t=260s) is played on players screen
    1. [ ] Golden Gun - all guns are gold, bullets kill in one shot
    1. [x] [Bullets are slower moving projectiles](https://www.youtube.com/watch?v=V75s9tagMyk&t=217s) seen in HL Loop.
    1. [ ] [Rolling on the floor](https://www.youtube.com/clip/UgkxGDswiSRVQhEH4hN-N775AfBGuqerdbur)
    1. [x] All obtain long jump module
    1. [ ] Continuous slide (crazydog)
    1. [ ] Bullets penerate walls
    1. [ ] Available weapons can explode if damaged
    1. [ ] [Leeroy Jenkins] mode (start with vest)
    1. [ ] [Explosive crowbar](https://www.youtube.com/watch?v=Ykm7ENrQZZ8) mode
    1. [ ] Sanic mode with custom spray as sprite (Crazydog)
    1. [ ] Rising ice / lava (CrazyO)
    1. [ ] rocket jumping, your rockets do not to much damage to owner
    1. [ ] Frag swap - if you get killed, you drop to 0 points, and the killer gets your frags (Napoleon)
    1. [ ] [In the eyes of](https://www.youtube.com/watch?v=5RaZGXd96VU)
    1. [x] [Invert](https://github.com/N7P0L3ON/Flatline-Arena-Master/commit/bed81a3c7396bc94e9b620188142270be53a5081)
    1. [x] [NPCs randomly blow up](https://www.youtube.com/watch?v=RNy42Wd9gfI)
    1. [ ] CrazyO - track reel of a person speaking
    1. [ ] Oneshot - 1 health start or reduce
    1. [x] Jope - All names turns to Jope
    1. [ ] Ricochet - no view angles or weapons fire discs
    1. [ ] Goldeneye - removes health and armor counts, changes to classic 007 bars when hurt
    1. [ ] Lightsout updates
        1. [ ] Light up melee weapons
        1. [ ] Light effects all firing
    1. [ ] SlappersOnly - remove all weapons, change behavior of fists to slaps with classic sound/slap
    1. [ ] Rubberband (Players who are at the bottom get max health)
    1. [ ] License to Kill
    1. [ ] [Ghost riders](https://gamebanana.com/mods/167145) add players to wheelthrones
    1. [ ] Tiny
    1. [ ] Tiktok - exploder (random explosions of people)
    1. [ ] Floor is lava
    1. [ ] Hardcore - 1 health, one weapon, 1 clip (yai boi) idea
    1. [ ] 10x mode (yai boi)
    1. [ ] penguins in place of toads
    1. [ ] [VVVVV mode/metal storm](https://www.youtube.com/watch?v=1h3nTAeNvl4)
    1. [ ] RandomNuke - idea by Mitchell The BoneLord
    1. [ ] SUPERCOOL
    1. [ ] grunts
    1. [ ] The Farm (mix of monsters)
        1. [ ] zombies
        1. [ ] headcrabs
        1. [ ] houndeye
    1. [ ] apache helicopter
    1. [ ] mutator idea: infected - 1 person spawns as infected (they have 1000 health, 10-20% faster movement speed, melee only). if the infected kills someone then that person becomes infected. if at least 1 of the not infected is alive then they win, but if everyone becomes infected the infected win (ya boi)
    1. [ ] chums/snarks wont die
    1. [ ] [can punter](https://www.moddb.com/mods/can-punter)
    1. [ ] Lite version of [Base Defense](https://www.moddb.com/mods/b-def) horde mode
    1. [ ] Random bind key blows you up (Nellia's Choice)
    1. [ ] For every 3 seconds you dont shoot you lose 5 health (Yaboi idea on weapon idling damage)
    1. [ ] Rocket/Railgun mutator, [self explanatory](https://www.youtube.com/watch?v=jY6yBTYxLko).
1. New Weapons
    1. [ ] [Blue Takis](https://www.youtube.com/watch?v=2LaOo_xo7O0)
    1. [ ] [Freeze Grenade](http://web.archive.org/web/20040804044629/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=71) (Napoleon)
    1. [ ] Bio weapon (pigcop)
    1. [ ] [Boomerang (AudoCraZ)](https://twitter.com/JoinDeepRock/status/1568229337647685633?t=8vCgTQm8vuHP2T9rQnZ5Jw&s=19)
    1. [ ] [Light saber weapon](https://www.youtube.com/watch?v=-CjaytQLWFY). [Closet model](https://gamebanana.com/mods/180200)? [Beam sword](https://cso.fandom.com/wiki/Beam_Sword)
        1. [ ] Customizable color
    1. [ ] Snowball Machine / Snowball Generator in place of Egon gun
    1. [ ] Pulse Rifle
    1. [ ] Pulse Pistol
    1. [ ] Taser
    1. [ ] Counter-Strike penguin
1. Weapons Mechanics
    1. [ ] [Reload / No Ammo indicator](https://www.youtube.com/watch?v=r5dXK9f2DGE&t=380s) from Halo Combar Evolved
    1. [ ] Akimbo's (select weapons)
        1. [ ] Gauss (Order of _billy recommendations)
        1. [ ] Egon
        1. [ ] Crossbow
        1. [ ] Snark
        1. [ ] Tripmine
        1. [ ] Clusters
        1. [ ] Dual berettas (GSS #73 idea)
    1. [ ] [Allow holstering completely](https://github.com/bacontsu/spirit-op4/commit/d63aee33fa4dc170e916b93de8fe95c70a51241a) that allows [monsters to be gentle](https://github.com/bacontsu/spirit-op4/commit/1b5f5f6bc91c101d41dd7ffe24ab0c6ebc452e33).
    1. [ ] [Smoking cigarette](https://www.youtube.com/watch?v=kv0lLYG4eiE)
        1. [ ] your weapon takes 10x more the amount of damage
        1. [ ] but the recoil is 10x more high and the accuracy is garbage
    1. [ ] Scientist Gun from RocketCrowbar
    1. [ ] Throw any weapon as an attack
    1. [ ] Reduce animations in ironsights
    1. [ ] Throw any weapon
    1. [ ] Quad weapon attachment?
    1. Crossbow
        1. [ ] Pluck animation from (Half-Life Restored)(https://gamebanana.com/mods/download/36047)
    1. Handgrenades
        1. [ ] [Dual wield grenades](https://twitter.com/kirkhamilton/status/1244786371253788673) - second fire?
        1. [ ] Roll animation from (Half-Life Restored)(https://gamebanana.com/mods/download/36047)
        1. [ ] Grenade toss option as secondary fire. See [this video](https://www.youtube.com/watch?v=e59bvmvXPk0) for more information. This [other video](https://www.youtube.com/watch?v=5-fNv9g_JLI) covers egon narrow animations.
        1. [ ] Hand grenade blows up on contact with enemy
    1. [ ] Weapon/pistol whip like WastelandHL (most weapons) / Gun slap / punch all weapons
    1. [ ] C4 mine placement with satchels
    1. [ ] Convert throw-hold effect to all other weapons for control
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
    1. [ ] [Homing rockets](http://web.archive.org/web/20040804045551/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=72)
    1. [ ] Grenades that randomly teleport when they bounce? (AudioCraZ)
    1. [ ] Grenades that never stop bouncing and have a random timer to detonate. (Flubber bomb) (AudioCraZ)
1. Weapon ViewModel / Effects
    1. [ ] Bob up/down like HL New Light v3
    1. [ ] Breakable gibs spawned from bullet damage as seen in MiniMod
    1. [ ] [Centered models?](https://gamebanana.com/mods/179800)
    1. [ ] [Third version of HD gordon arms?](https://www.moddb.com/mods/half-life-2-classic)
    1. [ ] `cl_righthand -1` where [knife is left handed, and weapons are right handed.](https://www.reddit.com/r/GlobalOffensive/comments/43y47t/is_it_possible_to_implement_cl_righthand_1_again/)
    1. [ ] Ice hands in addition
    1. [x] Blue arms + real skins
    1. [ ] Additional attachment values for configurable speeds and fov
    1. [ ] Damage / blood / stains on view model and player as seen in bhl
    1. [ ] Customize iron-sight values, add support to other weapons at runtime.
    1. [ ] Support mdl model [fullbrights] and sven texturerender mode using [this repo](https://github.com/BlueNightHawk/halflife_fullbright)
1. Server Support
    1. [ ] mp_semiauto
        1. Wire server to client message when changed
1. Movement
    1. [ ] [Wall jumping](http://articles.thewavelength.net/226/)
1. Bot support
    1. [ ] [Better bot support, actively developed](https://github.com/tschumann/sandbot)
    1. [ ] [Pull zbots out of Counter-Strike](https://github.com/s1lentq/ReGameDLL_CS/tree/master/regamedll/dlls/bot)
    1. [ ] Bot support for hook
    1. [ ] Bot support for macOS
1. Game Mechanics
    1. [ ] Fall smash like [from boltgun](https://www.youtube.com/watch?v=ZUcAQC8gCyM&t=125s)
    1. [ ] [Wall running](https://github.com/bacontsu/codename-borea/blob/spirit/spirit-1.8-trinity-op4/dlls/player.cpp#L6270-L6501)
    1. [ ] [Head "twisting"](https://discord.com/channels/790549024373604353/1010386771168722954/1044952465692442724)
    1. [ ] [Jetpack](https://github.com/N7P0L3ON/Flatline-Arena-Master/commit/ec6d4ed14c2046f4459092cbe28011d0a28daaf5)
    1. [ ] Visual hitpoint deductions during play? [See potential tech](https://github.com/YaLTeR/OpenAG/pull/103/files)
    1. [ ] Player jump and land sound effects
    1. [ ] [See own legs](https://www.youtube.com/watch?v=mpKld-jZF7c&t=9s), code [found here](https://github.com/BlueNightHawk/halflife-newlight/commit/c1d189bd67e0f18e219f4fe71a24dccb04307eb6).
    1. [ ] Improved player kick animation from grunt player model
1. Gameplay
    1. [ ] random map select
    1. [ ] Stream VOs from UT (when you dont die)
    1. [ ] Snowball fight mutator - all weapons fire / throw snowballs - see [Snow-War](https://www.moddb.com/mods/snow-war)
    1. [ ] Ultra deathmatch mutator, unlimited ammo / no reloads. See [Oz Mod video](https://www.youtube.com/watch?v=1L62nPKGlAY), Duke Nukem style.
    1. [ ] mp_startonlywith "weapon_*"
    1. [ ] Weapon filter list
1. Environment look and feel
    1. [ ] Add transparent sprite around floating weapon for visual identification - [from boltgun.](https://www.youtube.com/watch?v=ZNSgulYUor8&t=50s)
    1. [ ] [Physics Engine](https://github.com/anchurcn/GoldsrcPhysics)
        1. [ ] Ragdoll effect (speak to Napoleon)
    1. [ ] Shader water implementation...(something that's not Trinity, (speak to Napoleon))
    1. [ ] Override texture wads to make it feel different, add similar, iced themed textures (start with stalkyard,use impulse 107)
    1. [ ] Swap blue sprites with real sprites with cl_icemodels?
1. UI / Menu
    1. [ ] Orange text in [xash3d menu](http://xash3d.ru/doku.php?id=xashcookbook:en:recipes:art:custom_menu_art)
1. Runes
    1. [ ] Quad damage (Napoleon's [model idea](https://cdn.discordapp.com/attachments/923312701252460544/980739942168793178/cir_logo_3D.7z))
    1. [x] Ammo regeneration
    1. [ ] Super jump rune
1. Prefabs / Extras
    1. [Decay wall chargers](https://github.com/FWGS/hlsdk-portable/blob/decay-pc/dlls/healthkit.cpp#L255-L609), models can be [found here](https://www.moddb.com/games/half-life-decay/addons/hev-charger-and-healt-charger-from-half-life-decay)
1. HUD
    1. [ ] Add large health bar and player name or monster name above in hud - [from boltgun.](https://www.youtube.com/watch?v=VMt67r4EYBU&t=166s)
    1. [ ] Re-enable suit voice updates?
    1. [ ] Add map name to the scoreboard
    1. [ ] Slanted health and armor sprites like [Operation: Black Mesa Blue Shift](https://gamerant.com/half-life-black-mesa-blue-shift-opposing-force-campaigns-screenshots/)
1. Maps
    1. [x] Reskin [boot_camp](https://cdn.discordapp.com/attachments/923312701252460544/997489879996969080/boot_camp2k.rmf)
    1. [x] fgd file
    1. [ ] Finish arena, texture in Cold Ice style
    1. [ ] Training 2
        1. [ ] Frozen pool in new area opposite of garage
    1. [ ] Frozen Lake map idea
    1. [ ] datacore (crystalcore)
    1. [ ] rapidcore (icecore)
    1. [ ] Add info_intermission points
    1. [ ] Realign large blue crate textures so detailed textures is left to right
    1. [ ] Clip sky in Focus
    1. [ ] Update lights.rad production to use Napoleon's lights.rad file
    1. [ ] [fy_iceworld](https://www.rockpapershotgun.com/the-legacy-of-fy_iceworld-counter-strikes-divisive-and-hugely-popular-custom-map)
    1. [ ] [Real 3d skybox](https://discord.com/channels/511209951923011604/511212204121653258/1084687068246069259)
    1. [ ] jope by pigcop
    1. [ ] glupshitto by pigcop
    1. [ ] [ts_frigid remake](https://www.tsmod.net/maps/?vp_page=3)
    1. [ ] [thetemple](https://cohost.org/b1rd/post/1185353-thetemple-it-s-the)
1. Player Models
    1. [ ] All Cold Ice 1.6 player models
1. Models
    1. [x] Gold Skin? (Radu Matei Ionut)
    1. [x] Silver Skin?
    1. [x] [Better Video Game Cabinets](https://gamebanana.com/mods/4846)
1. Integrations
    1. [ ] [Discord RPC](https://github.com/YaLTeR/discord-rpc) rpc integration while playing. Good example is here: [halflife-extended](https://github.com/bacontsu/codename-borea/commit/4dc88f3e32b0c8bd8c8fbaec8fdba805f406750f)
1. Fixes
    1. [ ] Nuke to kill monsters
    1. [ ] mp_infiniteammo -> sv_infiniteammo
    1. [ ] Add git hash to server name in dll
    1. [ ] Improve Crowbar animation from another v_ model
    1. [ ] [Fix animations](https://github.com/ValveSoftware/halflife/issues/2495) on weapons where possible.
    1. [ ] Snowball not exhaustable?
    1. [ ] RPG clip / shotgun box / snark nest / 357 box missing bottom face
    1. [ ] Bots will use snarks to defeat snarks if equipped
1. Clean up
    1. [ ] Separate hev arms/hands cleanly to all v_ models for customization
    1. [x] Compact w_ moels into one
    1. [ ] Compact p_ moels into one
    1. [ ] Compact w_ models into p_
    1. [ ] Extend length of viewmodel arms, so larger fov's do not show disconnected arms from body
    1. [x] Increase tempent limit from 500 to 2048 from [solokillers impl](https://github.com/SamVanheer/halflife-unified-sdk/commit/1a7c61aa0b58eceab6768712617ae224d3842a07)
1. Game Dev Tools
    1. [ ] [Cache modeling check](https://github.com/bacontsu/spirit-op4/commit/2adf21717c39628b6629c83c5cc34dc03b3790b5)
    1. [ ] Include pdb files, debug libraries on builds off master.
    1. [ ] Cache compile_tools artifacts using [workflow caching](https://docs.github.com/en/actions/advanced-guides/caching-dependencies-to-speed-up-workflows)
    1. [ ] Codegen for generating new weapons
    1. [ ] Some static analysis tool to detect method signatures (e.g. Railgun holster animation missing skiplocal var)
    1. [ ] Timestamps for building artifacts
        1. If timestamp of built artifact is newer than all source artifacts, skip building again
    1. [ ] Compile mdl tool for Linux
    1. [ ] Post process all sounds in folder with reduced volume
    1. [ ] Update map tools to [SDHLT](https://github.com/seedee/SDHLT/)
1. Client
    1. [ ] [Water Renderer](https://github.com/BlueNightHawk/testflight/commit/bb1d8ef445c8e26207d7072d3fd33dd07cecef87)
1. Community ideas
    1. [ ] Rune power degradation / Power consumption of the cloak rune? 
    1. [ ] OICW weapon ([Walt](https://discord.com/channels/790549024373604353/790549024373604356/937299092554518589))
    1. [ ] Explode player if using impulse cheat but sv_cheats on server is 0 (Napoleon)
    1. [ ] Freeze grenades ([Audiocraz](https://discord.com/channels/790549024373604353/790549024373604356/959832759612899348))
    1. [ ] Inciderary buckshot (dragons breath) from handcannon ([LambdaParrot](https://discord.com/channels/790549024373604353/790549024373604356/960733589471911977))
    1. [ ] Ice grenade or big ice blast as secondary attack for freezegun (Napoleon)
    1. [ ] Self sign the server and client dlls with [Napoleons tutorial](https://www.moddb.com/mods/flatlinea/tutorials/how-to-do-versioninfo-how-to-do-code-signing-using-self-signed-certificate)
    1. [ ] Taunts from player (Napoleon), [nice animation from boltgun here](https://www.youtube.com/watch?v=bPphPZoagsA&t=194s).
    1. [ ] Rune that will give you unlimited snowballs, and the throw speed for the snowball will be increased (Napoleon)
    1. [ ] Multiple rune equip (Napoleon)
    1. [ ] Ice spike gun (AudioCraZ)
    1. [ ] “fight club mode” no weapons. Just fists, slides, health packs and batteries and buffs. (AudioCraZ)
    1. [ ] "ice spike gun" (AudioCraZ)
    1. [ ] Do not drop list, nuke and vest on that list. (AudioCraZ)
    1. [ ] Russian translations (berry from moddb)
    1. [ ] Small radius device that delivers [continious damage](https://discord.com/channels/849001008645668874/900139554185547776/1035274797569015931)
    1. [ ] Respawning breakable glass (Napoleon)
    1. [ ] what about instead of a jet pack, you have the “go away boost” where you mele range with a “rocket” (slap a rocket on another player) and they take off like a rocket from a rocket crowbar? (AudioCraZ)

### Beta 3

1. Gameplay Modes
    1. [x] Mutators
        1. [x] RocketCrowbar
        1. [x] Volatile
        1. [x] Instagib
        1. [x] Plumber
        1. [x] Paintball
        1. [x] DK Mode
        1. [x] Night-ops (lights out)
        1. [x] [topsy-turvy](https://youtu.be/MJPoK3qEQMM?t=82)
            1. [x] Random three like [Reelism](https://reelism.dog/)
        1. [x] Turret - sentrys spawned and fire at people randomly
        1. [x] Slowmo
        1. [x] Superjump
        1. [x] Superfast
        1. [x] Floor is ice: slip and slide everywhere, grenades and launchers only (yai boi)
        1. [x] Loopback (spawn to where you killed someone)
        1. [x] Santa Hat (add hats to players, shoot off)
        1. [x] chumtoads from explosions
        1. [x] random weapon
        1. [x] speedup (75% faster)
        1. [x] eat gibs
        1. [x] sanic
        1. [x] maxpack
        1. [x] Snowball
        1. [x] Gravity
        1. [x] Transparent
1. Gameplay
    1. [x] Unreal tournament [kill announcements](https://unreal.fandom.com/wiki/Achievements_and_awards)
1. Weapons
    1. [x] Railgun follows through multiple targets
    1. [x] [Gravity gun](https://www.youtube.com/watch?v=0maGDVs18wo)
    1. [x] Offhand grenade seen in [Maximum Action](https://youtu.be/DCrv8BxuM6I?t=200)
1. Mechanics
    1. [x] Make offhand kick/punch more useful
    1. [x] Damaging somersault left / right, [Somersaults](https://www.moddb.com/mods/the-specialists)
1. Maps
    1. [x] frost_pit (snark_pit reskin)
    1. [x] snow_camp (boot_camp reskin)
    1. [x] frozen_bunker (lambda_bunker reskin)
    1. [x] snowtransit (subtransit reskin)
    1. [x] doublecross (doublefrost)
    1. [x] mill (reboot)
    1. [x] chillworks (gasworks reskin)
    1. [x] frenzy (frosty)
    1. [x] undertow (overflow)
1. Environment
    1. [x] Snow effect / console mechanic/trigger, turn on/off in snowyard
    1. [x] Explosive barrels / generator
1. Runes
    1. [x] Add text about rune and what it does
1. Client Support
    1. [x] cl_autoweaponswitch
    1. [x] cl_hudscale
    1. [x] Better labeling of runes
    1. [x] cl_autoweaponswitch ([@Runner](https://discord.com/channels/790549024373604353/790549024373604356/1010565554161057872))
1. Support
    1. [x] Patch singleplayer crashes
1. Tools
    1. [x] Verify [sound loudness](https://superuser.com/questions/1183663/determining-audio-level-peaks-with-ffmpeg) before packaging with ffmpeg?
    1. [x] Automatic kick all and rejoin bots on a [timed basis](https://wiki.sourceruns.org/wiki/Half-Life_Scripts).

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
1. [ ] Write script for [Robo](https://community.lambdageneration.com/user/robo)
1. [ ] Reach out to [maxvollmer](https://github.com/maxvollmer/Half-Life-VR) on VR integration

## Tutorials

1. [ ] Turret and airstrike credit
1. [ ] Walk back commits and see if any other tutorials can be posted to ModDB
    1. [ ] [Fastswitch tutorial](https://twhl.info/wiki/page/Tutorial%3A_Change_hud_fastswitch_to_behave_like_Half-Life_Source) on TWHL
