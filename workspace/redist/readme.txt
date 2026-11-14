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
    - "autorun" - you can never stop running forward, only steer and strafe
    - "backwards" - forward is back, left is right
    - "blur" - motion blur, everything smears when it moves
    - "discomode" - classic 007 GameShark disco mode, every polygon flashes in shifting psychedelic colors (rapid flashing)
    - "drunk" - your view keeps swaying and spinning
    - "ducked" - everyone is stuck crouching
    - "expcrowbar" - crowbar swings detonate
    - "exploder" - everyone is a walking time bomb
    - "fadetoblack" - lower health darkens vision and boosts your damage
    - "floorislava" - the ground scorches your boots
    - "fly" - fly like noclip, but walls still block you; jump rises, duck sinks
    - "fragswap" - frag scores swap between attacker and victim
    - "goldeneye" - health and armor numbers are replaced by classic 007 curved bars that appear briefly when hurt
    - "headshot" - only a headshot final blow can kill another player
    - "heavy" - double gravity, low jumps and hard landings
    - "hitstun" - like GoldenEye 007, every hit freezes its victim, player or monster, for a moment
    - "linemode" - classic 007 line mode, everything washes out to white with black traced edges
    - "myfavtexture" - every wall wears the same texture
    - "negativepi" - pi is now -1
    - "nelliaschoice" - one random non-movement bind becomes lethal
    - "nobackgrounds" - classic 007 GameShark no background mode, walls, floors, ceilings and the sky vanish while players, items, doors and glass still show over a flat blue backdrop
    - "noduck" - no one can crouch
    - "nohud" - hide all hud elements except its own status icon
    - "nojump" - no one can jump, flip or wall climb
    - "nomouse" - alive players lose mouse input
    - "pacifist" - player-vs-player frags award +1 frag to the victim, no death increment, and no killer frag gain
    - "pinball" - walls bounce you back
    - "planted" - you cannot move while firing
    - "pogo" - every landing jumps again
    - "predator" - see like the Predator, cold blue walls with living players and monsters glowing hot in thermal vision
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
    - Shotguns no longer reload with "noreload" mutator
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
    - Hornets now bleed yellow alien blood instead of black
    - Fix rocket model orientation
    - Thrown weapons no longer leave a hidden entity behind
    - Freeze gun plasma, freeze grenades and snow bombs now freeze monsters in an ice shell, and too many hits in a row shatter them
    - Frozen players and monsters share the same freeze, so the Shidden fart freeze now lasts its full five seconds
- Bot Patches
    - Prevent bots from firing their hook when paused
    - Added "sv_botaccuracy [0-2]" so bot aim accuracy can be set and voted like any cvar
    - Added "sv_botsvote [0|1]" to let bots take part in votes (on by default, also in botoptions.txt)
    - Bots now vote like players, a few seconds after a vote menu opens instead of instantly
- Voting Improvements
    - Added a "CLEAR" button ("No mutators, please.") under CHAOS in the mutator vote; if it ties or beats the top mutator, no mutators are played
    - Added rtv of bot options; type "botoptions" in chat during a match (see botoptions.txt)
    - Vote menu configs are streamed to connecting players at a steady pace, with bot options a few seconds later
    - Votes close two seconds after everyone has voted instead of waiting for the timer, mid-game and at the end of the game
    - Fixed rtv votes not finishing until the end of the match in Teamplay (and in GunGame, every rtv except mutators)
    - An rtv vote still open when the match ends is now settled right away instead of overlapping the end of game votes
    - Rtv can no longer be started during the end of game votes, where it reset the vote in progress
    - Skipping an empty game-options or server-options vote now shortens the end of game voting as intended
- Scoreboard Improvements
    - GoldenEye-like system, weapon of choice + awards during multiplayer
    - Don't render death notices while scoreboard is showing
- Camera Improvements
    - In thirdperson, your own player turns see-through when the camera is pushed close by walls or set to a short distance, and turns solid again as the camera pulls back; only you see it, and other effects such as glow shells and invisibility stay as they are
- Visual Improvements
    - Weapons lying in the world, spawned or dropped, are lit, cast a small light and show a semi-transparent spiky starburst behind them so pickups are easier to spot; the glow matches your HUD color (gold with a yellow HUD, and red, green, blue or orange with your team or sleeves); turn it off with "cl_weaponglow 0" (not shown in Prop Hunt)
- Default Config Changes
    - Removed "No Limit" game options to keep servers rotating
    - Moved "Bots Melee" from serveroptions.txt to the new botoptions.txt
- HUD Improvements
    - Moved rune, cam icons to bottom of HUD, colorize these icons
    - Halo-style ammo warnings, a fast blinking "RELOAD", "LOW AMMO" or "NO AMMO" appears at the lower left of the crosshair (lower right when left handed with "cl_righthand 0"); shown with "cl_crosshairammo 1"

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
