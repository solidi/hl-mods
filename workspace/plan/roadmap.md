# Cold Ice Goldsrc Roadmap

## Mission

1. More is more with weapons - if the game can handle it, add more of it

## First Principles

1. To faithfully recreate the Cold Ice 1.75 experience that works in Half-Life GoldSource
1. To reuse models, maps, and sound effects as they were back in the original version
1. To listen to the community on playability and update direction on suggestive feedback

## Upgrades

1. Unless otherise noted, use hi-definition models in place of lower resolution models
1. Borrow CIR beta 2 models with ice over effect to this mod

## Cvars

1. Switch between iced models and standard skins

## Weapon Outline

1. Weapons (add behavior noes of each weapon after in-game review)

  | entity name | title | slot | primary | clip | amount | secondary | clip | humor? |
  | - | - | - | - | - | - | - | - | - 
  | - | 12-inch Combat Knife | 1 | swing | 0 | 0 | no | 0 | no
  | - | Standard Crowbar | 1 | swing | 0 | 0 | no | 0 | no
  | - | 40-pound Monkey Wrench | 1 | swing | 0 | 0 |  no | 0 | no
  | - | PPK, Bond Style | 2 | fire | 8 | 64 | change to silencer | 0 | yes
  | - | Mag 60 Automatic Handgun | 2 | fast fire | 22 | 150 | slow fire | 0 | no
  | - | M-16 Assault Rifle | 3 | fire | 30 | 75 | zoom | 0 | no
  | - | 12 Gauge Shotgun | 4 | fire | 2 | 45 | double fire | 0 | no
  | - | Assault Shotgun | 4 | fire | 8 | 45 | explosive buckshot | 8 | no
  | - | USAS-12 Auto Shotgun | 4 | fire | 40 | 80 | no | 0 | no
  | - | 25-inch Chaingun | 5 | fire | 60 | 200 | buckshot | 45 | no
  | - | 7.65mm Sniper Rifle | 6 | fire | 10 | 20 | zoom | 0 | no
  | - | Air Compressed Auto BoltGun | 6 | fire | 30 | 45 | no | 0 | no
  | - | 30mm Assault Cannon | 7 | fire | 6 | 18 | no | 0 | no 
  | - | 120-Pound Grenade Launcher | 7 | impact grenade | 6 | 18  | timed grenade | 8 | no
  | - | 50-pound automatic LAW rocket Launcher | 7 | rocket | 5 | 5 | 5x rockets | 2 | no
  | - | female assassin decoy bombs | 8 | throw | 4 | 0 | no | 0 | yes
  | - | 6-pack cluster grenades | 8 | throw | 4 | 0 | no | 0 | no
  | - | Chumtoad | 9 | throw | 3 | 0 | no | 0 | no
  | - | Kamikaze Dynamite Vest | 10 | detonate | 1 | 0 | no | 0 | no

1. Collaboration
    1. [ ] Reach out to [BlueNightHawk](trovymam@gmail.com) 

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
    1. [ ] Crowbar (bots disappeared?)
    1. [x] Sniper Rifle
    1. [x] Mag60
    1. [x] Chaingun
    1. [x] Grenade Launcher
    1. [x] mp5k
    1. [x] Usas
    1. [x] Fists
        1. Learned that giving a weapon on spawn that already is given with spawnweaponlist causes entities to accumulate.
    1. [x] Wrench
    1. [x] Snowball
    1. [x] Chainsaw
    1. [x] 12 Gauge
1. [ ] Testing
    1. [ ] Weapons behaviors under water
    1. [ ] Fakelag with weapons
    1. [ ] Map changes with all weapons
1. [ ] Publish
    1. [ ] ModDB Entry
    1. [ ] Gamebanana Entry
    1. [ ] Write short post
        1. [ ] r/halflife
        1. [ ] fb ragegroup
        1. [ ] Steam Workshop?
        1. [ ] [TWHL](https://twhl.info/forum/view/mods)
    1. [ ] Steam Community Forums
    1. [ ] Update url_dl in liblist.gam

### Beta 1

1. Movement
    1. [ ] [Wall jumping](http://articles.thewavelength.net/226/)
    1. [x] Add offhand [grappling hook]grapple hook](https://github.com/solidi/hl-mods/blob/c91828511f455f9fe323f652379cdb287414ea0b/ci/src/dlls/player.cpp#L4863)
1. Bot support
    1. [ ] Custom map waypoints for bots
    1. [x] Add bots
        1. Add [bots](http://hpb-bot.bots-united.com/index.html)
1. Game Mechanics
    1. [ ] In-game help menu
    1. [x] HUD notification system - Identity of weapons from Rory
1. Gameplay
    1. [ ] Ultra deathmatch mutator, unlimited ammo / no reloads. See [Oz Mod video](https://www.youtube.com/watch?v=1L62nPKGlAY), Duke Nukem style.
    1. [ ] [sv_inifinite_ammo](https://github.com/ValveSoftware/halflife/issues/2598) idea
1. Weapons
    1. [ ] Skin Egon, Gauss, Python, Snark
    1. [x] Spin ammo, battery, healthkit, and longjump
    1. [ ] Punch angles for all weapons
    1. [ ] Spawn extra weapons with other matching slot number
    1. [ ] Tighten up all idle animation times to match code
    1. [ ] Correct all brass shell ejection points
        1. [ ] Use attachment point for each model
    1. [ ] Deagle
        1. [ ] Single shot weapons for semi-auto effect
    1. [ ] M16 Assault Rifle
    1. [ ] Nuke launcher (Cold Ice 2.5 model) / [Futuristic RPG model swap](https://gamebanana.com/mods/239023)
    1. [ ] Assault Shotgun
    1. [x] Vest
    1. [x] Silencer
    1. [x] Cluster Grenades
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
    1. [x] USAS-12 Auto Shotgun
    1. [x] 25-Inch Chaingun
    1. [x] 30mm Assault Cannon
    1. [x] 120-Pound Grenade Launcher
    1. [x] Female Assassin Decoy Bombs
    1. [x] Snowball
    1. [x] mp5k
    1. [x] Chainsaw
    1. [x] [Throwing crowbar](http://web.archive.org/web/20020717063241/http://lambda.bubblemod.org/tuts/crowbar/)?
    1. [x] Invisible tripmines
    1. [x] [Manos de piedros](https://gamebanana.com/skins/103896) when no weapons available
1. Weapon ViewModel / Effects
    1. [x] [Smoke effect on firing](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=106s)
    1. [x] Iron sights like [brutal hl](https://www.moddb.com/mods/brutal-half-life)
    1. [x] Spinning w_ models as a server option
    1. [x] Have humorous sound effect with each weapon?
    1. [x] Bullet smoke like [brutal mod](https://www.moddb.com/mods/brutal-half-life)
    1. [x] Viewmodel delay on yaw movement like seen in [MiniMod](https://www.youtube.com/watch?v=g3qMHpLMYPk&t=690s)
    1. [x] [Weapon fidget effect](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=540s) when jumping or landing a jump.
    1. [x] Third model mode - real skins
        1. [x] Convert weaponbox to dropped weapon
            1. [x] Convert all weapons to ground
            1. [x] Two models for w_ models - ground, and floating/spinning
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
1. Menu Graphics
    1. [ ] Cold Ice Splash with Blue Gordon, Half-Life logo -> Cold Ice
1. HUD
    1. [ ] Best effort weapon sprites
    1. [ ] Original CI numbers / Overhaul numbers
1. Player Models
    1. [ ] All Cold Ice 1.6 player models
    1. [x] All CIR player models
    1. [ ] Assassin and army models from Cold Ice 2.6
1. Package for release script
    1. [ ] Rename folder to cirm_beta1
    1. [ ] Remove config or replace with default one
    1. [x] Remove dev.cfg
    1. [x] Remove pdb files
    1. [x] Remove dSYM files
    1. [x] Remove empty models/ and sprites/
    1. [x] Build hash number in package
1. Fixes
    1. [ ] Shells and smoke are being shown from others
    1. [x] Adjust Grappling hook trail origin on player
    1. [x] Rename folder and libs to `ice`
    1. [x] Rename github repo to `coldice`
    1. [x] Bot names loading on Linux?
    1. [x] macOS zip file contains invalid paths?
    1. [x] Normalize arm skins (orange default)
1. Game Dev Tools
    1. [x] Contribute back to valve halflife repo with github actions to build the full suite

### Beta 2

1. Bot support
    1. [ ] Bot support for hook
    1. [ ] Bot support for macOS
1. Supported Systems
    1. [ ] Android and iOS support (Xash3d?)
1. Game Mechanics
    1. [ ] Jetpack?
    1. [ ] Kick function like [brutal hl](https://www.moddb.com/mods/brutal-half-life)
    1. [ ] Weapon whip like WastelandHL (most weapons) / Gun slap / punch all weapons
1. Gameplay
    1. [ ] Snowball fight mutator - all weapons fire / throw snowballs - see [Snow-War](https://www.moddb.com/mods/snow-war)
    1. [ ] Rocket/Railgun mutator, [self explanatory](https://www.youtube.com/watch?v=jY6yBTYxLko).
    1. [ ] Bell when a frag is committed (ala CS:GO)
    1. [ ] Weapon filter list
1. Environment look and feel
    1. [ ] Override texture wads to make it feel different, add similar, iced themed textures (start with stalkyard,use impulse 107)
    1. [ ] Swap blue sprites with real sprites with cl_icemodels?
    1. [ ] Bullet hole decals like BHL
1. Weapons
    1. [ ] Snowball Machine
    1. [ ] Pulse Rifle
    1. [ ] Pulse Pistol
    1. [ ] Akimbo support
    1. [ ] C4 mine placement with satchels
    1. [ ] Convert throw-hold effect to all other weapons for control
    1. [ ] Gauss gun as freeze gun. See freeze effect [here](http://web.archive.org/web/20040804041434/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=65)
    1. [ ] [Light saber weapon](https://www.youtube.com/watch?v=-CjaytQLWFY). [Closet model](https://gamebanana.com/mods/180200)?
    1. [ ] Taser
    1. [ ] Snowball Generator in place of Egon gun
    1. [ ] Decoy bombs that morph into AI assassins?
    1. Fists
        1. [ ] Big uppercut punch secondary fire with fists
    1. [ ] [Portal gun?](https://www.youtube.com/watch?v=Gf_eCVGY2pk&t=20s)
    1. [ ] [Gravity gun](https://www.youtube.com/watch?v=0maGDVs18wo)
    1. [ ] Counter-Strike penguin
    1. Knife
        1. [ ] Alt model on [this forum](https://forums.alliedmods.net/showthread.php?p=1701941)
        1. [ ] Cold Ice 2.5 model?
        1. [ ] sparks found on and [this video](https://www.youtube.com/watch?v=-CjaytQLWFY)
        1. [ ] Match a better decal
    1. Crossbow
        1. [ ] Pluck animation from (Half-Life Restored)(https://gamebanana.com/mods/download/36047)
    1. Handgrenades
        1. [ ] Roll animation from (Half-Life Restored)(https://gamebanana.com/mods/download/36047)
        1. [ ] Grenade toss option as secondary fire. See [this video](https://www.youtube.com/watch?v=e59bvmvXPk0) for more information. This [other video](https://www.youtube.com/watch?v=5-fNv9g_JLI) covers egon narrow animations.
    1. Chaingun
        1. [ ] Secondary chaingun idea?
        1. [ ] Faster spin?
    1. [ ] Third person muzzle flash placement
1. Weapon ViewModel / Effects
    1. [ ] A generic draw/holster sound? (like CS:GO)
    1. [ ] [Gun fidget / movement on landing a jump](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=526s)
    1. [ ] Gun smoke as seen in MiniMod
    1. [ ] Breakable gibs spawned from bullet damage as seen in MiniMod
    1. [ ] [Centered models?](https://gamebanana.com/mods/179800)
    1. [ ] [Third version of HD gordon arms?](https://www.moddb.com/mods/half-life-2-classic)
    1. [ ] `cl_righthand -1` where [knife is left handed, and weapons are right handed.](https://www.reddit.com/r/GlobalOffensive/comments/43y47t/is_it_possible_to_implement_cl_righthand_1_again/)
1. Configuration Support
    1. [ ] Customize iron-sight values, add support to other weapons at runtime.
1. Maps
    1. All Maps
        1. [ ] Debrief text file
        1. [ ] Overview graphic
    1. [ ] fgd file
    1. [ ] Finish arena, texture in Cold Ice style
    1. [ ] Frozen Lake map idea
1. HUD
    1. [ ] Re-enable suit voice updates?
1. Runes
    1. [ ] Ammo regeneration
1. Fixes
    1. [ ] Add faces to bottom/back of item models
    1. [ ] Railgun follows through multiple targets
    1. [ ] [Fix animations](https://github.com/ValveSoftware/halflife/issues/2495) on weapons where possible.
1. Player Models
    1. [ ] Santa
    1. [ ] Snowman
1. Game Dev Tools
    1. [ ] Compile maps in a [parallel](https://www.provartesting.com/documentation/devops/continuous-integration/github-actions/parallel-execution-in-github-actions-using-job-matrix/) [matrix](https://docs.github.com/en/actions/learn-github-actions/workflow-syntax-for-github-actions) [job](https://github.community/t/merge-matrix-build-artifacts-for-release/118190) setup.
    1. [ ] Codegen for generating new weapons
    1. [ ] Some static analysis tool to detect method signatures (e.g. Railgun holster animation missing skiplocal var)
    1. [ ] Timestamps for building artifacts
        1. If timestamp of built artifact is newer than all source artifacts, skip building again
    1. [ ] Compile mdl tool for Linux
