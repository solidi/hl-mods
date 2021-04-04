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
  | - | Assault Shotgun | 4 | fire | 8 | 45 | explosive buskshot | 8 | no
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

1. [ ] Convert weaponbox to dropped weapon
1. [ ] Snowball fight mutator - all weapons fire / throw snowballs - see [Snow-War](https://www.moddb.com/mods/snow-war)
1. [x] Have humorous sound effect with each weapon?
1. [x] [Throwing crowbar](http://web.archive.org/web/20020717063241/http://lambda.bubblemod.org/tuts/crowbar/)?
1. [Wall jumping](http://articles.thewavelength.net/226/)
1. [ ] Akimbo models
1. [x] Third model mode - real skins
1. [ ] Guass gun as freeze gun. See freeze effect [here](http://web.archive.org/web/20040804041434/http://www.planethalflife.com/hlprogramming/tutorial.asp?i=65)
1. [ ] [Light saber weapon](https://www.youtube.com/watch?v=-CjaytQLWFY)
1. [ ] Jetpack?
1. [ ] C4 mine placement with satchels.
1. [x] Invisible tripmines
1. [ ] [Manos de piedros](https://gamebanana.com/skins/103896) when no weapons available
1. [ ] Override texture wads to make it feel different, add similar, iced themed textures (start with stalkyard,use impulse 107)
