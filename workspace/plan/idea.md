# Cold Ice Goldsrc

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

## Outline

1. Add [bots](http://hpb-bot.bots-united.com/index.html)
1. Add Off-hand [grapple hook](https://github.com/solidi/hl-mods/blob/c91828511f455f9fe323f652379cdb287414ea0b/ci/src/dlls/player.cpp#L4863)
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
  

1. HUD notification system
    1. Identity of weapons from Rory

## Nice to Haves

1. Game Mechanics
    1. [ ] [Wall jumping](http://articles.thewavelength.net/226/)
    1. [ ] Jetpack?
    1. [x] Iron sights like [brutal hl](https://www.moddb.com/mods/brutal-half-life)
    1. [ ] Kick function like [brutal hl](https://www.moddb.com/mods/brutal-half-life)
    1. [ ] Weapon whip like WastelandHL (most weapons)
1. Environment look and feel
    1. [ ] Override texture wads to make it feel different, add similar, iced themed textures (start with stalkyard,use impulse 107)
    1. [ ] Swap blue sprites with real sprites with cl_icemodels?
    1. [ ] Bullet hole decals like BHL
1. Gameplay
    1. [ ] Snowball fight mutator - all weapons fire / throw snowballs - see [Snow-War](https://www.moddb.com/mods/snow-war)
    1. [ ] Ultra deathmatch mutator, unlimited ammo / no reloads. See [Oz Mod video](https://www.youtube.com/watch?v=1L62nPKGlAY), Duke Nukem style.
    1. [ ] Rocket/Railgun mutator, [self explanatory](https://www.youtube.com/watch?v=jY6yBTYxLko).
    1. [ ] Bell when a frag is committed (ala CS:GO)
    1. [ ] Weapon filter list
    1. [ ] [sv_inifinite_ammo](https://github.com/ValveSoftware/halflife/issues/2598) idea
1. Weapons
    1. [x] Have humorous sound effect with each weapon?
    1. [x] [Throwing crowbar](http://web.archive.org/web/20020717063241/http://lambda.bubblemod.org/tuts/crowbar/)?
    1. [x] Invisible tripmines
    1. [x] [Manos de piedros](https://gamebanana.com/skins/103896) when no weapons available
    1. [ ] C4 mine placement with satchels.
    1. [ ] Gauss gun as freeze gun. See freeze effect [here](http://web.archive.org/web/20040804041434/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=65)
    1. [ ] [Light saber weapon](https://www.youtube.com/watch?v=-CjaytQLWFY). [Closet model](https://gamebanana.com/mods/180200)?
    1. [ ] Akimbo models
    1. [ ] Taser
    1. [ ] Nuke launcher (Cold Ice 2.5 model)
    1. [ ] Pulse Rifle
    1. [ ] Snowball Generator in place of Egon gun
    1. [ ] Decoy bombs that morph into AI assassins?
    1. [ ] `cl_righthand -1` where [knife is left handed, and weapons are right handed.](https://www.reddit.com/r/GlobalOffensive/comments/43y47t/is_it_possible_to_implement_cl_righthand_1_again/)
    1. [ ] [Futuristic RPG model swap](https://gamebanana.com/mods/239023)
    1. [ ] Big uppercut punch secondary fire with fists
    1. [x] Chainsaw
    1. [ ] [Portal gun?](https://www.youtube.com/watch?v=Gf_eCVGY2pk&t=20s)
    1. [ ] [Gravity gun](https://www.youtube.com/watch?v=0maGDVs18wo)
    1. [ ] Counter-Strike penguin
1. Weapon Effects
    1. [ ] [Smoke effect on firing](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=106s)
    1. [ ] A generic draw/holster sound? (like CS:GO)
    1. [ ] [Gun fidget / movement on landing a jump](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=526s)
    1. [x] Bullet smoke like [brutal mod](https://www.moddb.com/mods/brutal-half-life)
    1. [x] Viewmodel delay on yaw movement like seen in [MiniMod](https://www.youtube.com/watch?v=g3qMHpLMYPk&t=690s)
    1. [ ] Gun smoke as seen in MiniMod
    1. [ ] Breakable gibs spawned from bullet damage as seen in MiniMod
1. Model Ideas
    1. [x] Third model mode - real skins
        1. [ ] Convert weaponbox to dropped weapon
            1. [ ] Convert all weapons to ground
            1. [ ] Two models for w_ models - ground, and floating/spinning
    1. [ ] Grenade toss option as secondary fire. See [this video](https://www.youtube.com/watch?v=e59bvmvXPk0) for more information. This [other video](https://www.youtube.com/watch?v=5-fNv9g_JLI) covers egon narrow animations.
    1. [ ] [Centered models?](https://gamebanana.com/mods/179800)
    1. [ ] [Third version of HD gordon arms?](https://www.moddb.com/mods/half-life-2-classic)
    1. [x] [Weapon fidget effect](https://www.youtube.com/watch?v=ktk0wxVhFqs&t=540s) when jumping or landing a jump.
1. Game Dev Tools
    1. [x] Contribute back to valve halflife repo with github actions to build the full suite
    1. [ ] Codegen for generating new weapons
    1. [ ] Some static analysis tool to detect method signatures (e.g. Railgun holster animation missing skiplocal var)
    1. [ ] Timestamps for building artifacts
        1. If timestamp of built artifact is newer than all source artifacts, skip building again
    1. [ ] Compile mdl tool for Linux
1. Supported Systems
    1. [ ] macOS support for grave_bot
    1. [ ] Android and iOS support (Xash3d?)
1. Collaboration
    1. [ ] Reach out to [BlueNightHawk](trovymam@gmail.com) 
