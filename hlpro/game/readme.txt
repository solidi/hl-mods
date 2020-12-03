===================================================
Half Life Pro

v 1.1

http://www.halflife.net/hlpro

Half Life Pro only runs on version 1009 of Half Life or newer.

Contents:

	 1.  Description.
	 2.  Installation.
	 3.  Version List/Corrections and Changes.
	 4.  Client Commands.
	 5.  Explanation of the Hud.
	 6.  Server Commands.
	 7.  Server DLL Changes.
	 8.  Ultra Stats System & HTML logging.
	 9.  Runes.
	10.  Night Ops Mode.
	11.  Weapons Arena Mode.
	12.  Real-Life Mode.
	13.  Adding your own maps.
	14.  Beta Testing Specs.
	15.  Bug Contact / Bug List.
	16.  Credits/Contacts.

===================================================
1.Description:

Half Life Pro is a simple mod developed for the hardcore DM'er.

Its features are:
Totally redeveloped HUD display; 
HTML Client Stats Logging; 
Night Ops Mode+;
Real-Life Mode;
Weapon Arena Mode^;
Rune Support#;
Real time Geiger and train speed meters;
Total ammo display of your current weapons;
Radar system*;
Realistic dropping of the current weapons; 

*Base code taken from Botman's Radar tutorial. Modified and edited by Surreal.
#Base code taken from Phantasiere's Rune tutorial. Modified and edited by Surreal.
^Original idea credited to EmenyZero (fafara_rascon@hotmail.com).
+Original idea credited to OZ deathmatch ( http://www.planethalflife.com/oz ).
===================================================
2.Installation: 

After downloading the hlpro.zip file from a local ftp server, Unzip this file into 
the Half-Life directory on your hard drive. Make sure that the mod has unzipped into 
the hlpro directory (no, do not make that dir, the zip takes care of it.). After you 
have completely installed this mod, start up Half Life (1009 or greater) and select  
"custom" on the menu. Find the mod that displays "Half Life Pro 1.1" and activate it. 
Go back to the main menu and select multiplayer. From there, either start up a server 
or join a server that passes the game filter "hlpro" and has a version number of 1.1.
===================================================
3.Version List/Corrections and Changes:

Half-Life Pro 1.1
	-Weapon Arena Mode.
		=357
		=Mp5
		=Shotgun
		=Rpg
	-Full Quake style death notices.
	-User id number on stat logs.
	-Real life Mode Tweaked. Added feature: Can only carry one item weapon and one primary weapon at a time.
	-OldSkool Observer Mode.
	-Long jump spawned if player dies. (If obtained before)
	-Night sky constant in mp_nightops.
	-Count Down Timer if there is a timelimit.
	-Added stealth rune.
	-Env Light reduced in NightOps Mode to correct "Full Light Players" in the open.
	-A few more variables on the status system as well as gray % bars.
	-Added mp_allowdeadbodies, mp_allowlongjump, mp_allowflares, mp_runetime, hud_showhistory.

Bugs Fixes:
-Server
	-Flashlight shut off after a clients dies to reduce lag ( especially in night ops mode.).
	-Cut env light in night ops mode
	-Fix mp_stats (did not work).
	-Fixed silencer/death issue
	-Rune spawn time changed to 10 minutes.
	-Fixed MOTD & HLPRO Display (Sent to player when enters the game, not just on map startup.)
-Client
	-log stats if a client disconnects.
	-datacore stats log error (data_core?->third party?).
	-corrected damage status icon's.
-Hud graphics
	-Fix deathnotice names, cut short.
	-Ammo history position.
	-rune_status haste error.
***************************************************
Half-Life Pro 1.0:
	-Totally redeveloped HUD display. 
	-Stats HTML Logging System of clients stats (112 conditions).
	-Night Ops Mode.
	-Real-Life Mode.
	-Rune Support.
	-Ultra stats right on a clients hud.
	-Real time Geiger and train speed meters.
	-Total ammo display of your current weapons.
	-Radar system.
	-Realistic dropping of the current weapons.

===================================================
4.Client Commands:

Half Life Pro 1.1 has added a few new console commands specifically for your own hud. They are:

1. hud_status*      - Displays or hides Ultra stats menu on the clients hud.
2. hud_ammo*        - Displays or hides ammo menu on the clients hud.
3. hud_radar*       - Displays or hides radar menu on the clients hud.
4. hud_disabletext* - Displays or hides talk messages on the clients hud.
5. hud_playerid*    - Displays or hides player identification on the clients hud.
6. hud_centerid*    - Displays play identification in the middle of the screen or in the bottom left hand corner.
7. hud_showhistory* - Displays or hides weapon & ammo history on the right hand side of the hud.

There are also commands for other situations. They are:

1. drop_rune        - type this in the console and you will discard your current rune.
2. rune_status      - type this in the console and it will display what your current rune is.
3. throw_flare      - to chuck a flare out into the environment.

To enter these commands into the console, hit the "~" key and type in these pervious commands.

*Denotes a 1 or 0 switch command.
===================================================
5.Explanation of the Half Life Pro Hud:

The hud design for Half Life Pro was developed for:
1. Design and Style
2. Status info

You will see this on your hud if you have the command, hud_status, active to 1.

----------------- -----------------
|[ds]Surreal	| | 10 |  14 | # 1|
----------------- -----------------
|Fine        	| |  3 | 230 | # 1|
|100 ==========	  -----------------
|100 ========== | |Gordon         |
----------------- -----------------

Starting from the left hand side and working in a down-right fashion, these numbers are:

1.NetName
2.Text Condition Status
3.Health
4.Power
5.Frags
6.Packet Loss
7.Model
8.Deaths
9.Ping
11.Currently Place
12.Number client connected since the servers last reboot.

You may also see a status box on the middle right hand side if you encounter radioactive 
material or you drive a train.

-----------------
|Geiger:700 | 4%|
-----------------

1.Meters from radioactive material.
2.Percent of exposure.

-----------------
|Train: 15mph   |
-----------------

1.Speed of train.

Lastly, you will see 2 times in the upper right hand corner of your hud. They are:

1:23
0:45

1.Time connected to server.
2.Time lasted killed.

===================================================
6.Server Commands:

There are currently 3 new server commands all Server Op's should know and use at will.

1.  mp_radar* 	        - used to enable or disable the client radar.
2.  mp_weaponreal*      - used to enable or disable realistic droping of current weapons.
3.  mp_nightops*+       - used to enable or disable Night Ops mode.
4.  mp_reallife*+       - used to enable or disable Real Life mode.
5.  mp_weaponarena%+    - used to enable or disable Weapon Arena mode.
6.  mp_runes*           - used to enable or disable runes on a server.
7.  mp_runetime&        - used to set the spawning time of runes. 600 is the lowest setting. (600(sec)/60(in a minute) = 10 Minutes).
8.  mp_stats*-          - used to enable or disable logging of html stats on a server. (all clients are affected.)
9.  mp_allowdeadbodies* - used to enable or disable deadbodies on a server.
10. mp_allowlongjump*   - used to enable or disable the longjump on a server.
11. mp_allowflares*     - used to enable or disable the flares on a server. (nightops only).

*denotes a 1 or 0 switch command.
&denotes a full integer over 6000.
%denotes a character string. python, shotgun, mp5 or rpg for that desired arena type (normal - all weapons).
+a server op must change to a different level in order to enable this mini-mod (after command has been entered).
-a server op must change the level inorder for this CVAR to take affect.
===================================================
7.Server DLL Changes:

In Half Life Pro, we tweaked the temp entities for DM play. (As you know, temp entities cause lag). Here are a few things that we tweaked:

-Less life on RPG Rocket smoke trail.
-Less life on Hornet trails.
-Less life of used shells.
-Gauss effect reduced by half.
-Took out all items that were not used in multiplayer.

We have also fixed some bugs that were present in regular Half Life DM:

-Rpg clicker fixed.
-Door blocked repeated sound fixed
-Holster animations for glock and shotgun when using map entities (i.e. turrets)
-25 starting clip of mp5 to a full clip of 50.
-Fixed glock auto reload on a full clip.
-Python clicker fixed.
===================================================
8.Ultra Stats System

The Ultra Stats system is relatively an old idea in the gaming community. The reason why we are developing
our own system because no one in the half-life community has. The ultra stats system is relatively easy to read
and easy to understand. It also gives the player something to brag about. The more deathmatch you play,
the more your stats will increase.

You only need to know a few things to display, read and hide the stats while in game.

To view your stats after you play and finish a game, all you have to do is go to the /hlpro directory in half-life and access the subdirectory /stats.
Just click on the current stats file (.html) and view your local stats.

To view your stats in game, simply check the bottom left hand corner of the screen. If you do not see a box there, type in the console, hud_status 1.

If you have any question or errors about the logs, please e-mail us at surreal@optonline.net
===================================================
9.Runes

Before I explain what runes are present in Half-Life Pro, I want to tell you what a rune is. A rune is a power up to a player. When obtained, 
it can enhance the players attributes or skill.

As you may have experienced before, runes aren't a new thing in Half-Life. They have been done
before. (i.e. Oz Deathmatch and Classic CTF)

Types of runes present in Half-Life Pro:

-Haste Rune
	-Orange shell.
	-Increases a players weapon speed by 2.
-Regeneration Rune
	-Pink Shell.
	-Increases a players health and power over time.
-Silencer Rune
	-Purple Shell.
	-Enables a player to use the silencer on the glock.
-Frag Rune
	-White Shell.
	-Enables a player to receive extra frags.
-Jump Rune
	-Green Shell.
	-Enables a player to jump like jordan.
-Anti-Radar Rune
	-Blue Shell.
	-Enables a player to lock the radar of themselves on others displays.
-Stealth Rune
	-Gray Shell.
	-Enables a player to become silent and stealthy.

Don't forget, if you want to drop your current rune to obtain another in the area, simply scroll down
the console and type in "drop_rune". You can also display the current rune you have by type in "rune_stats".
===================================================
10.Night Ops Mode

Half Life Pro features a small modification inside of a modification. Night Ops mode has been done before
in the Half Life community. Personally, I believe that everything should be done again. In 
night ops mode, every client starts off with a a few high-light flares, a flashlight and a 
shotgun. This is only because everything is mostly dark. It does not require any new maps 
or unities, it just requires a few diligent players. 

To start a server on this mode. A server op must:
1.type in the console mp_nightops 1
2.change to a different level or restart that current map.

There are also commands the client needs to know. They are:

1.throw_flare - to throw your current stock of 100% imported flares.
===================================================
11.Weapons Arena Mode:

New to Half-Life Pro, we have added another cool little mod inside!
This mod is for those haxors who like certain weapons...and only these weapons.
Before I explain what this mod is, I would like to thank Enemy Zero for this idea.

Weapons Arena mode just replaces all the map entities (spots) in a map, and swaps them
with a desired weapon. As of now, it supports python (enemy's requested idea), shotgun,
mp5 and the rpg. This mode also swaps all the ammo entities with the ammo that subsides with 
the selected weapon (i.e. rockets, shells, etc.)

To start a server on this mode. A server op must:
1.type in the console mp_weaponarena "XXXXX"
2.change to a different level or restart that current map.

XXXX = python, mp5, shotgun or rpg. 
===================================================
12.Real-Life Mode:

Half Life Pro features a another small modification inside of a modification. Real-Life Mode is nothing to brag about.
It features realistic bleeding, and damage indicators. Also, the weapon damage has been increased.

In Half-Life Pro 1.1 we have added a primary/item hold function. The client now can only hold 1 primary weapon (not handguns) 
and 1 item weapon (like snarks or grenades)

To start a server on this mode. A server op must:
1.type in the console mp_reallife 1
2.change to a different level or restart that current map.

There are also commands the client needs to know. They are:

1.drop - to throw your current weapon, so you obtain another.
===================================================
13.Adding you're own maps:

To add your own maps in Half Life Pro, all you have to do is make a /maps directory in the hlpro directory. 
After that, just put the .bsp file into the maps dir and you can select that map while starting up a Half Life Pro server.

Note: There is a bug in Half Life itself that does not display deathmatch maps in other directories. This is not our fault.
If you would like to start up a server, just select create and after the console displays a error message  ( map change failed: 'unknown' not found on server ), type in any of the original DM maps included with Half Life.

Example:
(Console)

map change failed: 'unknown' not found on server
]map stalkyard
===================================================
14.Beta Testing Specs:

Tested on:
400 mhz PII w/ 224mb ram with a 32bit TNT2 AGP video card.
733 mhz PIII w/128mb ram with a 32bit GeForce 256 video card.

Hud Pass or Fail:
512 res or lower - NOT SUPPORTED (Yes, it works, but the graphics collide and are cut from the low res.)
(Low res will be supported in next version for ultra stats, radar and ammo display.)

Res              OpenGL                     D3D                 Software (full screen)
----------------------------------------------------------------------------------------
640*480-   -	 Pass(clashing)	  |         Pass(clashing)     |        Pass(clashing)
640*480    -	 Pass	          |         Pass               |        Pass
800*600    -	 Pass	          |         Pass               |        Pass
960*720    -	 Pass	          |         Pass               |        Pass
1024*760+  -	 Pass	          |         Pass               |        Pass

800*600+  is best suited for the new hud.
===================================================
15. Bug Contact / Bug List:

If you experience anything abnormal in Half Life Pro, please do not pass it by. Record what you see or hear. 
If you believe this is a serious or causes server crashes (or even client), please contact us, surreal@optonline.net, 
with a detailed list of your cpu specs, what the bug did, where this bug occurred and how long. With this, we can
pinpoint the problem and crush the bug for the next release.

Bug Listing as of 1.1:
(We have no knowledge of any bugs present in version 1.1 of Half-Life Pro.)

===================================================
16.Contact:

Thanks for downloading a simple yet astonishing mod for Half Life.
Please contact the following if this readme does not answer your question on HL pro.

Surreal  - Lead Programmer and Management.
surreal@optonline.net

Kurayamikage - Lead Beta Tester
kurayamikage@hotmail.com

Split Spine - Beta Tester
shock@vortopia.com

===================================================

Half-Life is a trademark of Valve Software and Sierra Online, used with permission.
Half Life Pro is © Copyright Dependent Studios, 2000.
Half Life Pro is a trademark of Dependent Studios.  All Rights Reserved.


Remember, all new material, including dlls, pictures and files include in this zip file is property of Dependent Studios.
Please contact Surreal, surreal@optonline.net, for information on transferring this data on any transferable devices.
If any of this material is released in any other modification, without our consent and notification, will automatically be
charged in a legal setting ( court of law. ).

(THIS ALSO INCLUDES ALL WEB AND FTP SERVERS. DO NOT UPLOAD THE ZIP FILE UNLESS YOU HAVE OUR PERMISSION. THE ONLY ACCEPTION 
IS THE HALFLIFE.NET SERVER.) 

In other words:
Be respectable and honest of our hard work, or face punishment.
