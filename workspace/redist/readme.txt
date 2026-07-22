Cold Ice Remastered Edition

This project is a modern open-sourced rebuild of Cold Ice 1.75, a popular Half-Life mod back in 1999. Set in a winter scene, its philosophy is to deliver deathmatch that doesn't take itself seriously. Only in this mod will you find voiceover cameos from Samuel L. Jackson, Hans Gruber, and "Leeroy Jenkins" by Ben Schulz. Its ethos delivers an explosively frantic fast-paced gameplay that was and always will be Cold Ice.

The whole story: https://medium.com/super-jump/building-a-popular-half-life-mod-during-the-rise-of-counter-strike-fec6a5b9fd8f?sk=6d1427b3f1d832df06bd5b07aaa456bb
Library game code: https://github.com/solidi/coldice-remastered
Project redist and assets: https://github.com/solidi/hl-mods
Join us on Discord: https://discord.gg/Hu2Q6pcJn3

This mod features works from the community. Without their dedication and hard work, this mod wouldn't look good. See the thanks section below for details!

v1.1 Features:

- New Game Modes
    - "Kick the Snowball" - team-based battle to score a large snowball in the enemy's goal
    - "Loot" - team-based battle to find hidden loot in a crate and bring it back to score
        - All maps are supported
        - A re-creation of what was described by Dario Casali, author of boot_camp
        - Introduces thirdperson camera support when running with loot
- New Mutators
    - "amidead" - tilts the view by eighty degrees
    - "mcclane" - reverses the up and down weapon view model
    - "noradar" - hides the radar, compass, and world indicators from the HUD
    - "rats" - spawns numerous explosive rats on the map
    - "skyhook" - if a player touches a sky texture, they are gibbed
    - "tinnitus" - lowers sfx volume and introduces a buzzing sound
    - "upsidedown" - reverses up and down views
- New Maps
    - suspension, a rebuild of Laserus's 1999 map by b1rd
- New Command Menu
    -  "+commandmenu" (;) is now available in-game to toggle many options provided
- New Radar indicators
    - Added new compass readout in the upper-middle HUD using cl_compass 1
    - Added HUD world indicators of many targets including teammates and objectives using cl_radar 2
- New Player Mechanics
    - Forcegrab and punch enabled for single-handed weapons
    - Forcegrab now works with all stationary items on the map
    - Taunt now supports offhand use
    - Auto-taunt triggers only when using the offhand
    - Using taunt no longer prevents attacking
    - Expanded longjump so that the player can longjump in any direction
    - Players holding a single-handed weapon raise the off-hand to shield against blast damage
    - Headshots now decapitate the victim
- Expanded Real Time In-Game Voting
    - Added rtv of gamemodes; type "gamemodes" in chat to start rtv
    - Added rtv of maps; type "maps" in chat to start rtv
    - Added rtv of mutators; type "mutators" in chat to start rtv
    - Added rtv dynamic game-options; type "gameoptions" in chat (see gameoptions.txt)
    - Options vote panel sits between the gameplay and mutator phases at the end of the round
    - Added dynamic server-options; type "serveroptions" in chat (see serveroptions.txt)
    - Options vote panel sits between the gameoptions and mutator phases at the end of the round
    - Added "mp_rtvcooldown" to control the delay between successful rtv votes
- Voting Improvements
    - Dynamic map voting menu supports up to 128 maps sent from the server's mapcycle.txt
    - Vote tallies on buttons are now on the right side, and font size increased for readability
    - Added support for "rtv" in the chat as confirmation of a "vote" challenge
    - Send the current menu to a connecting player during a vote
    - Fixed menu title selection and added a brief pause for mutator menu voting
    - Spectators cannot start an rtv of mutators, gameoptions, or serveroptions
    - Self-voting selection is now clear with white highlights
    - Added gamemode to all vote panels so the current mode is clear
    - Added a "Surprise Me" button to the vote menu for a randomized selection
    - Instant mutators can now be selected from the mutator vote panel
- Game Modes Changes
    - New celebration sequences switch to thirdperson and play sounds
    - Added a banner system so that the team objective is clear when entering the arena
    - Added initial spectator menu selection on all game modes
    - Added directional indicators with distance on the HUD to direct the player to objectives
    - Added level-up sfx and messaging in ColdSpot, ColdSkulls, Battle Royale, GunGame, and CTC
    - Added teammate radar indicators above each player's head
    - 1 vs. 1
        - Improved bot performance and seeking during gameplay
        - Player who wins a battle continues to the next battle until defeated
        - Player with the most frags, even if negative, wins if time runs out
    - Battle Royale
        - Improved bot performance and safe spot behavior during gameplay
        - Play a siren sound when the safespot shrinks
        - Added screen warning and reduced timed damage outside the safe area
        - Added a world-to-screen visual indicator of the safe spot
        - Slowly add health to players inside the safe zone
        - Improved time-up team win calculation
        - Safe spot moves to random info_player_deathmatch entities per round
        - Players outside the zone are placed into thirdperson to show their surroundings
    - Busters
        - Added mp_busterscount, expanding from 1 to 3 busters at a time
        - Improved bot behaviors, including targeting the egon and the buster when available
        - Added an explosion when picking up the egon so it clears enemies and avoids clustering
        - Places the player's view in thirdperson when holding the egon
        - The player will always switch to the egon when they pick it up
        - Busters cannot pick up weapons or ammo
        - Disconnected busters are announced, and a new player is chosen
    - Capture the Chumtoad
        - Added mp_ctctoadcount, expanding from 1 to 5 toads at a time
        - Improved bot play with more attacks and better strategy while holding the chumtoad
        - Places the player's view in thirdperson when holding the chumtoad
        - Changed the HUD to green when holding the chumtoad
        - The chumtoad holder cannot pick up weapons or ammo
        - Moved points and timer to the objective read-out
        - Sound a bell when the chumtoad is teleported
    - Capture the Flag
        - Highly improved bots that play CTF alongside team members
        - Places the player's view in thirdperson when holding the flag
        - CTF base entities now render as permanent edge indicators on the radar
    - Chilldemic
        - When a survivor dies, they immediately respawn as a skeleton in their place
        - Virus players can no longer pick up ammo and weapons
        - Places the player's view in thirdperson when transformed into a skeleton
    - Cold Skulls
        - Improved play with a better chance of hitting the collection limit
        - Bot behaviors are now optimized to seek skulls
        - Some skulls will be "magnetized" to the awarded player
        - Skulls flash the screen when picked up
        - Dropped skulls despawn after 25 seconds
    - Cold Spot
        - Improved bot behavior to seek and hold the cold spot
        - Points are awarded after 10 seconds in the spot
        - Updated HUD and added sound effects when holding the spot
        - Places the player's view in thirdperson while inside the spot
        - The spot is contested if both teams are in the zone
        - Added a world-to-screen visual indicator of the spot
        - Player scores only if they can see the center of the spot
        - Slowly adds health to players inside the spot
    - Gungame
        - Slowed weapon upgrades; waits a half second after a frag before advancing a level
        - Spectate is disabled during the round
    - Horde
        - Idling monsters are teleported around the map every thirty seconds
        - Improved bot monster-attack and team-protection behaviors
        - Waves advance only when players are successful in the previous wave
        - Added headcrab, zombie, and houndeye to the monster rounds
        - Improved aggressiveness of all monsters to directly attack players
        - Improved HUD health bar for enemies; turns red on low health
        - Wave number is now shown on the round banner
    - Jesus vs Santa
        - Each player has a chance to become Jesus in a random pool so all are cycled
    - Prophunt
        - Bots behave intelligently in this gamemode now
        - Props can now morph into nearby items using `+use`
        - Hunters lose health when shooting, controlled by mp_hunterselfcost
        - Props now have some health, controlled by mp_prophealth
        - More props spawn than hunters
        - Added "mp_prophunttime" to set time hunters are frozen
        - Props no longer register fall damage
        - Props no longer play footsteps
        - Props can now pick up health and batteries
        - Play "pause-beat" music during initial hiding
        - Disable automelee in this gamemode to avoid automatic finding
        - Hunters regain health if converting a prop to a hunter
        - Last prop notice, and prop has double health and extra grenades
        - Props run faster
    - Shidden
        - Improved bot behavior for dealter and smelter roles
        - The fart no longer instantly kills; it now freezes the player
        - Provided a knife to dealters so a frozen player can be finished with the knife
        - Dealters no longer have access to other weapons or items
        - Removed the cloak rune from gameplay
        - Adjusted scoring and tie-score handling
        - Dealters gain a head-stomp attack to finish frozen players
        - Added 2:1 player balance for smelters versus dealters
    - Snowball Fight
        - Added snowball launcher power up (ammo rune), added 12% chance of spawning
        - Snowball launcher secondary attack fires a larger snowball bomb
    - Teamplay
        - Added assists to the scoreboard
        - Show team-color HUD and radar indicators
- Mutator Changes
    - Added support for per-mutator duration declaration
        - Example: sv_addmutator "longjump" sets the duration to whatever sv_mutatortime is (in seconds)
        - Example: sv_addmutator "longjump 120" for 120 seconds
        - Example: sv_addmutator "longjump 0" for a permanent duration until map change or until it is cleared
    - Goldenguns now turns players into gold statues
    - The mirror mutator now fully inverses the on-screen play
    - Improved the mutator voting menu with a scrolling panel
    - In chaos mode, each mutator rotates in a shrinking random pool so every mutator is experienced
    - Mutators are now paused in between rounds and during intermission
    - Re-enabled screeneffect mutators oldtime, inverse, and sildenafil
    - Improved player rendering under the minime mutator
    - Improved loopback so that the player copies the viewangles of their victim
    - Added an fvox countdown when a chaos mutator is about to rotate
    - Weapons are hidden while the ricochet mutator is active
    - Weapons fire faster under the sildenafil mutator
    - Added the snowball launcher and instagib hornets during the snowballs and instagib mutators
    - The instant health/armor swap no longer frags the player; it drops health to 1
- Bot Changes
    - Bots use the grappling hook in combat with sv_bots_hook "1"
    - Tuned bots to act more human-like in combat, and adjusted aim
    - Added bot_aim_difficulty [0-2] where zero is perfect and 2 is sloppy
    - Tuned and improved bot behavior across all custom game modes
    - Bots no longer attempt wallclimbing
    - Bots intelligently select runes during gameplay
    - Bots no longer counter snarks/chumtoads by deploying snarks/chumtoads while being attacked by the same
    - Bots now use freeze grenades when available
    - Bots release the grappling hook when they are frozen or their role changes
- Weapons Additions and Changes
    - Freeze Grenade
        - Use "reload" on hand grenades to throw a freeze grenade
    - Freeze Gun
        - Added a laser to +attack2 so ice plasma can be detonated midair
    - Proximity Mine
        - Use "reload" on either the tripmine or the satchel to place a proximity mine
    - Snowball
        - Snowballs now slightly bend to the player its aimed at for greater chance of hit
        - Make new snowballs with the reload button
        - Improved throw performance so it is more predictable
        - Primary attack is a medium throw; secondary is hold/charge for a longer throw
    - Hand grenades explode on contact with living targets (players/monsters)
    - Zapgun
        - Added a triple zap secondary attack
        - Added a stun gun laser attack when pressing the reload button
    - Railgun
        - Firing is now client-side predicted for smoother play
    - Vest
        - Switches to thirdperson on button push
        - Use "reload" to switch to proximity mode
- Runes
    - Added support for unique runes, one of each type. For abundant/duplicate rune spawning, use mp_allowrunes 2 (or higher)
- Server
    - Added "botfinditem [0-1]" to turn the bot item search logic on or off
    - Added "mp_rtvtime [sec]" for real-time voting duration
    - Added "mp_rtvcooldown [sec]" to gate the delay between successful rtv votes
    - Added "mp_ktsspawn1" and "mp_ktsspawn2" for the blue and red KTS goal spawn entities
    - Added server timestamps to chat messaging
- Client
    - Added "cl_thirdcamera" so the player can enable or disable the third-person camera in supported scenarios
    - Added damage numbers rendered on the HUD when hitting an enemy
    - Damage numbers are colored blue or orange based on team
    - Improved voting menus for mutators and maps; panels are now scrollable
    - Sort certain team-based game modes (like CTC) by lowest team member count for objective visibility
    - Removed the useless team score and ping total columns from scoreboards
    - Dead hands now lock when on the ground
    - HUD blinks red on low health
    - Removed unneeded rune title and messages
    - Added a longjump icon to the HUD when the item is acquired
    - Added a godmode icon to the HUD when using "snowman"
    - Removed "cl_shadows" ("r_shadows" was fixed by Valve)
    - Show total position in individual game modes
    - Spawn protection ends early when the player attacks
- Maps
    - Includes high-res detailed textures for all new deathmatch maps
        - Detailed textures are now enabled by default (use r_detailtextures 1 to force on)
- Media
    - Added two new music tracks by Napoleon
        - snowcross, themill, latenightxmas, and glupshitto tracks were updated
- Fixes
    - Combat
        - Players bleed only when damaged, not in godmode or when damage is disabled
        - Players can no longer pogo flip in the air
        - Fixed player flip animations based on velocity and direction
        - Fixed backflip animation when moving backward
    - Bots
        - Bots no longer melee-attack frozen players
        - Patched traceline crashes
        - Fixed BotFindItem crash, including a Linux server crash
        - Fixed issues with sv_defaultbots
            - Initial map load value is respected
            - When sv_defaultbots is lowered, excess bots are kicked
            - Added sv_defaultbots -1 where the operator can manually add or remove bots
        - Reduced the chance of a message-destination crash
        - Bots will advance to a visible waypoint if no paths exist
    - Gamemodes
        - Skip disconnected players in the spectator player list
        - Don't show the respawn bar on the HUD when your round is over
        - Fixed auto-balance bug for team players
        - Frag assists are removed from individual play and corrected for teamplay modes
        - Fixed invisible view model render properties
        - Fixed issue related to cleaning up the area before gameplay
        - Changed the default observer mode to free roaming
        - 1 vs. 1
            - Fixed bug related to disconnected player
            - Refresh scoreboard when round ends to reflect scores
        - Battle Royale
            - Randomly select buster for a pool of least scorers
            - Fixed safe spot hurt after round ends
            - Fixed green safe zone texture
        - Busters
            - Fixed support for force-grabbing the buster's egon
            - Fixed bug where disconnected clients could become busters
            - Fixed the mode so only one person can be a buster at a time
            - Disable the "busters" mutator to prevent more than one buster
            - Disabled throwing the egon in this game mode
            - Disabled random change of egon spawning
        - Capture the Chumtoad
            - Chumtoad is removed when the holder disconnects
            - Do not allow the instant chumtoad mutator
        - Capture the Flag
            - Added fallback support if a flag/base cannot be placed
            - Fixed double-return flag bug
            - Fixed numerous incorrect readouts
            - Fixed spectator status
            - Fixed flag status issues with bots
            - Fixed spectator objective readouts
        - Chilldemic
            - Renamed skeleton team to skeletons
            - Fixed round start when no skeletons were selected
        - Cold Spot
            - Prevent scoring after the round ends
        - Cold Skulls
            - Fixed skull limit ending game
            - Fixed skull shell colors
        - Gun Game
            - Fixed bug where the level did not advance
        - Horde
            - End horde when the scorelimit is reached
            - Improved panthereye leaping and made it easier to land damage
            - Improved winner determination when there is a tie
            - Monsters no longer engage spectators
        - Instagib
            - Fixed spread calculations
            - Zapgun gibs monsters
            - Removed useless runes like strength
            - Tombstones now face the killer without tilt
            - Fixed the game loop to respect intermission
        - Jesus vs Santa
            - Fixed new scoreboard team names
            - Fixed shutdown caused by a "not a client" network message when a player was missing
            - Fixed Jesus extra health and armor
        - Prophunt
            - Fixed spinning animations on numerous props
            - Fixed repeating wading sound on props
            - Prevent props from picking up weapons
            - Fixed ammo decoy model drops
            - Props are no longer deducted points if they destroy decoys
        - Shidden
            - Fixed missing messages when dealters are defeated
            - Fixed HUD scoreboard for remaining players
        - Snowball Fight
            - Fixed numerous crashes due to incomplete weapon management
        - Teamplay
            - Reset the default teamlist if a previous gamemode changed it
        - Fixed numerous gamemodes where "trigger_hurt" did not register
        - Removed runes and mutator entities in between rounds
    - Maps
        - Fixed spawnpoints in snowtransit, depot, focus
        - Fixed inverted textures on blue crates in snowyard
        - Added missing sounds for thetemple
        - Fixed overview bmp of frostfire
        - Fixed missing comet sound effects
        - Improved numerous map waypoints for bots
    - Mutators
        - Ricochet discs no longer apply a double death, fixed team colors
        - Made ricochet disc easier to decap
        - Fixed snowballs mutator icon
        - Patched 999 mutator creating dead walking players
        - Patched fog mutator to correctly pass alpha
        - Patched waypoints for fences.bsp
    - Client
        - Fixed team scoreboard team color; usernames in spectator are neutral
        - Reduced the chaos HUD bar by one unit
        - Center protips across the screen correctly
        - Fixed in-eye spectator secondary weapon models not appearing
        - Fixed observer moveleft and moveright so they remain straight
        - Fixed fire loop sound if on fire and placed in observer
        - Fixed follow-next targeting when the current target becomes a spectator
        - Fixed ejection shell after respawn
        - Don't show the health bar of a player while in in-view spectator mode
        - Forcegrab now ignores teammates
        - Fixed player weapon animation after taunting
        - Additional row added to the old scoreboard to accommodate the server name
        - Patched server crash in rune_ammo
        - Fixed cutoff scoreboard voice column
    - Server
        - Added support for Ubuntu 22+ on Linux
        - Added missing wav file, ambience/water_flowing2.wav
        - Added missing wav file, ambience/thunder_clap.wav
        - Fixed a possible ammo pack crash
        - Fixed memory leaks accumulated across map changes
        - Prevented voting crash on 32 players
    - Weapons
        - Improved chainsaw climb when looking up
        - Fixed ghost walking caused by the vest weapon
        - Fixed scale of knife world models
        - Fixed missing portalgun on HUD
        - Disabled weapon throw of cigarettes
        - Fixed floating animations of satchels and tripmines
        - Hornet damage now linked to sk_hornet_damage
        - Improved railgun firing sound
        - Fixed weapon sprite flashes

Highly-Valued Upcoming Features:

- See more on our living roadmap: https://github.com/solidi/hl-mods/blob/master/workspace/plan/roadmap.md

Installation:

- For Steam: Place ice_vx, ice_vx_hd, and ice_vx_sp, folders in the same folder where hl.exe is installed.
    - See this guide for a step-by-step guide on how to install this mod: https://steamcommunity.com/sharedfiles/filedetails/?id=174908119
- For Xash3d: Since Xash3d does not support SD/HD model switching, install the ice_vx folder first where xash3d.exe is located. Then copy ice_vx_hd contents, and paste them over the ice_vx folder, overwriting the SD models.

How to Play:

Start or join a Cold Ice server. You will spawn with fists and a randomly selected melee weapon. Don't forget you have an off-handed grapple hook and iron sights! (See below). Server and client options below will dictate gameplay. Then, have fun.

If you dislike the "blue" theme, this mod has the option to switch to real skins! Use cl_icemodels (see below).

Dedicated Server:

Cold Ice Remastered can be launched as a dedicated server, following the normal commands. We suggest a "-heapsize" of at least 524288.

Commands:

For a list of client commands, see client_commands.txt; for a list of server commands, see server_commands.txt.

Report Bugs:

Please report defects by creating an issue here or in discord: https://github.com/solidi/hl-mods/issues

Credits:

For acknowledgements and contributor credits, please see credits.txt
