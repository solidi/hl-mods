Cold Ice Remastered Edition

This project is a modern open-sourced rebuild of Cold Ice 1.75, a popular Half-Life mod back in 1999. Set in a winter scene, its philosophy is to deliver deathmatch that doesn't take itself seriously. Only in this mod will you find voiceover cameos from Samuel L. Jackson, Hans Gruber, and "Leeroy Jenkins" by Ben Schulz. Its ethos delivers an explosively frantic fast-paced gameplay that was and always will be Cold Ice.

The whole story: https://medium.com/super-jump/building-a-popular-half-life-mod-during-the-rise-of-counter-strike-fec6a5b9fd8f?sk=6d1427b3f1d832df06bd5b07aaa456bb
Library game code: https://github.com/solidi/coldice-remastered
Project redist and assets: https://github.com/solidi/hl-mods
Join us on Discord: https://discord.gg/Hu2Q6pcJn3

This mod features works from the community. Without their dedication and hard work, this mod wouldn't look good. See the thanks section below for details!

v1.2 Features:

- New Mutators
    - "ammoregen" - all alive non-spectator players regenerate active weapon ammo
    - "blur" - motion blur, everything smears when it moves
    - "discomode" - classic 007 GameShark disco mode, every polygon flashes in shifting psychedelic colors (rapid flashing)
    - "drunk" - your view keeps swaying and spinning
    - "expcrowbar" - crowbar swings detonate
    - "exploder" - everyone is a walking time bomb
    - "fadetoblack" - lower health darkens vision and boosts your damage
    - "floorislava" - the ground scorches your boots
    - "fragswap" - frag scores swap between attacker and victim
    - "goldeneye" - health and armor numbers are replaced by classic 007 curved bars that appear briefly when hurt
    - "headshot" - only a headshot final blow can kill another player
    - "linemode" - classic 007 line mode, everything washes out to white with black traced edges
    - "myfavtexture" - every wall wears the same texture
    - "negativepi" - pi is now -1
    - "nelliaschoice" - one random non-movement bind becomes lethal
    - "nohud" - hide all hud elements except its own status icon
    - "nomouse" - alive players lose mouse input
    - "pacifist" - player-vs-player frags award +1 frag to the victim, no death increment, and no killer frag gain
    - "regen" - everyone slowly regenerates health and armor
    - "revive" - first lethal player-vs-player frag per spawn revives the victim in-place with default spawn loadout, no killer frag gain, and no victim death increment
    - "rocketjump" - minimal self rocket damage for high jumps
    - "sleepy" - active human players get periodic black fade pulses like nodding off
    - "slide" - continuous selaco slide
    - "snarkbar" - thrown crowbar impacts release five snarks
    - "stomponhead" - land on heads for instant gibs
    - "triplebang" - every trigger pulls three shots
    - "vampire" - deal damage to drain health
    - "victor" - fragged drops fly only to the fragger
    - "virtualboy" - the game runs through a Virtual Boy, everything turns into red and black LEDs with red wireframe edges
    - "vvvvvv" - jump flips your gravity, walk on the ceiling upside down and jump again to fall back to the floor
    - "waterhurt" - touch water and explode
    - "xray" - classic 007 GameShark see-through mode, nearby walls, floors and ceilings turn semi-transparent and reveal what is behind them
- New Instant Mutators (index in brackets, for sv_addinstantmutator)
    - "accept all cookies" [4] - a cookie consent wall interrupts play; accept to keep playing, reject to be disconnected
    - "allguns" [5] - you get every weapon the game allows (single player only)
    - "bsod" [6] - a blue screen of death takes over the screen until you click "Failed Successfully"
    - "butterfingers" [7] - everyone drops the weapon in their hands
    - "drugparty" [8] - an armed drug proximity mine drops at everyone's feet, run!
    - "dryfire" [9] - everyone's clip is emptied, time to reload
    - "dualwield" [10] - the weapon in your hands gets its dual version
    - "hotfingers" [13] - everyone throws the weapon in their hands as a live explosive
    - "kaboom" [15] - every breakable on the map breaks and explodes at once
    - "knifevolley" [16] - everyone throws a fan of five knives that vanish on impact
    - "maxammo" [17] - your current weapon's ammo is filled to the max
    - "noarmor" [19] - everyone loses all their armor
    - "nukeparty" [21] - an armed nuclear proximity mine drops at everyone's feet, run!
    - "passitleft" [22] - everyone hands the weapon in their hands to the next player
    - "pipevolley" [25] - everyone throws a fan of five crowbars that vanish on impact
    - "proxparty" [26] - an armed proximity mine drops at everyone's feet, run!
    - "randomammo" [28] - everyone gets the same random ammo pickup
    - "randomitem" [29] - everyone gets the same random item (health kit, battery or long jump)
    - "randomrune" [30] - everyone gets the same random rune, replacing the one they held
    - "randomweapon" [31] - everyone gets the same random weapon
    - "remove func_*" [32] - one random kind of map brush entity (doors, walls, buttons, lifts, ...) disappears until the next map
    - "robinhood" [33] - the top fragger is disarmed and last place gets their guns
    - "roulette" [34] - everyone gets a different random weapon
    - "runeburst" [35] - everyone holding a rune drops it at once
    - "runeshuffle" [36] - held runes rotate to the next rune holder
    - "unarm" [40] - everyone is stripped down to their fists
    - "wrenchvolley" [41] - everyone throws a fan of five wrenches that vanish on impact
- Mutator Patches
    - Added console warning if an unkown mutator is applied
    - Added "sv_addinstantmutator [index]" to apply any instant mutator on demand; every index is listed in server_commands.txt
    - Instant mutators are now numbered in alphabetical order
- Gamemode Patches
    - Added scrum lockup detection in Kick the Snowball
    - Jesus now receives the cloak rune in Jesus vs Santa
    - Filtered sanic mutator from Prophunt and Shidden
    - Filtered 999 mutator from chilldemic
- Weapon Patches
    - View weapons react to player sprinting
    - Fixed ironsights server crash (thanks to albatross)
    - Fixed flak sound effects
    - Hornets no longer track teammates incorrectly nor invisible foes
    - Fix rocket model orientation
    - Thrown weapons no longer leave a hidden entity behind
- Bot Patches
    - Prevent bots from firing their hook when paused

Highly-Valued Upcoming Features:

- See more on our living roadmap: https://github.com/solidi/hl-mods/blob/master/workspace/plan/roadmap.md

Installation:

- For Steam: Place ice_vx, ice_vx_hd, and ice_vx_sp, folders in the same folder where hl.exe is installed.
    - See this guide for a step-by-step guide on how to install this mod: https://steamcommunity.com/sharedfiles/filedetails/?id=174908119
- For Xash3d: Since Xash3d does not support SD/HD model switching, install the ice_vx folder first where xash3d.exe is located. Then copy ice_vx_hd contents, and paste them over the ice_vx folder, overwriting the SD models.

How to Play:

Start or join a Cold Ice server. You will spawn with fists and a randomly selected melee weapon. Don't forget you have an off-handed grapple hook and iron sights! (See below). Server and client options below will dictate gameplay. Then, have fun.

If you dislike the "blue" theme, this mod has the option to switch to real skins! Use cl_weaponmodel (see below).

Dedicated Server:

Cold Ice Remastered can be launched as a dedicated server, following the normal commands. We suggest a "-heapsize" of at least 524288.

Commands:

For a list of client commands, see client_commands.txt; for a list of server commands, see server_commands.txt.

Report Bugs:

Please report defects by creating an issue here or in discord: https://github.com/solidi/hl-mods/issues

Credits:

For acknowledgements and contributor credits, please see credits.txt
