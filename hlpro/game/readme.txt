===================================================
Half Life Pro

v 1.0

http://www.halflife.net/hlpro

Half Life Pro only runs on version 1009 of Half Life or newer.

Contents:

	 1.  Description.
	 2.  Installation.
	 3.  Client Commands.
	 4.  Explanation of the Hud.
	 5.  Server Commands.
	 6.  Server DLL Changes.
	 7.  Ultra Stats System.
	 8.  Runes.
	 9.  Night Ops Mode.
	10.  Real-Life Mode.
	11.  Adding your own maps.
	12.  Beta Testing Specs.
	13.  Bug Contact / Bug List.
	14.  Credits/Contacts.

===================================================
1.Discription:

Half Life Pro is a simple mod developed for the hardcore DM'er.

Its features are:
Totally redeveloped HUD display; 
More realistic DM play;
Night Ops Mode+;
Real-Life Mode;
Rune Support#;
Ultra stats right on a clients hud; 
Real time Geiger and train speed meters;
Total ammo display of your current weapons;
Radar system*;
Realistic dropping of the current weapons; 

*Base code taken from Botman's Radar tutorial. Modified and edited by Surreal.
#Base code taken from Phantasiere's Rune tutorial. Modified and edited by Surreal.
+Original idea credited to OZ deathmatch ( http://www.planethalflife.com/oz ).
===================================================
2.Installation: 

After downloading the hlpro.zip file from a local ftp server, Unzip this file into the Half-Life directory on your hard drive. 
Make sure that the mod has unzipped into the hlpro directory (no, do not make that dir, the zip takes care of it.). 
After you have completely installed this mod, start up Half Life (1009 or greater) and select  "custom" on the menu. 
Find the mod that displays "Half Life Pro 1.0" and activate it. Go back to the main menu and select multiplayer. 
From there, either start up a server or join a server that passes the game filter "hlpro" and has a version number of 1.0.

===================================================
3.Client Commands:

Half Life Pro 1.0 has added a few new console commands specifically for your own hud. They are:

1. hud_status* - Displays Ultra stats menu on the clients hud.
2. hud_ammo* - Displays ammo menu on the clients hud.
3. hud_radar* -  Displays radar menu on the clients hud.

There are also commands for other situations. They are:

1. hud_disabletext* - ignore those spammers while fragging in game, or just to kick back and frag without any human communication.
2. hud_playerid* - to enable or disable the player identification on a clients hud.
3. hud_centerid* - to enable or disable the player identification in center on the hud or in the bottom left hand corner.
4. hud_stats* - to enable or disable the player stats on the HUD.
5. drop_rune - type this in the console and you will discard your current rune.
6. rune_status - type this in the console and it will display what your current rune is.
7. throw_flare - to chuck a flare out into the environment.

To enter these commands into the console, hit the "~" key and type in these pervious commands.

*Denotes a 1 or 0 switch command.
===================================================
4.Explanation of the Half Life Pro Hud:

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
2.Percent of exposuor.

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
5.Server Commands:

There are currently 3 new server commands all Server Op's should know and use at will.

1. mp_radar* - used to enable or disable the client radar.
2. mp_weaponreal* - used to enable or disable realistic droping of current weapons. (disable = weaponbox(less polys))
3. mp_nightops* - used to enable or disable Night Ops+ mode.
4. mp_runes* - to disable or enable runes on the server.
5. mp_stats* - to disable or enable stats on the server. This disables all clients stats connected to the server.

*denotes a 1 or 0 switch command.
+a server op must change to a different level inorder to enable night ops.
===================================================
6.Server DLL Changes:

In Half Life Pro, we tweaked the temp entities for DM play. (As you know, temp entities cause lag). Here are a few things that we tweaked:

-Less life on RPG Rocket smoke trail.
-Less life on Hornet trails.
-Gauss effect reduced by half.
-Took out all items that were not used in multiplayer.

We have also fixed some bugs that were present in regular Half Life DM:

-Rpg clicker fixed.
-Door blocked repeated sound fixed
-Holster animations for glock and shotgun when using map entites (i.e. turrets)
-25 starting clip of mp5 to a full clip of 50.
-Fixed glock auto reload on a full clip.
-Python clicker fixed.
===================================================
7.Ultra Stats System

The Ultra Stats system is relatively an old idea in the gaming community. The reason why we are developing
our own system because no one in the half-life community has. The ultra stats system is relatively easy to read
and easy to understand. It also gives the player something to brag about. The more deathmatch you play,
the more your stats will increase.

The system is no way near finished, but its good enough for the first release of Half-Life Pro 1.0.
You only need to know a few things to display, read and hide the stats while in game.

To view your stats after you play and finish a game, all you have to do is go to the /hlpro directory in half-life and access the subdirectory /stats.
Just click on the current stats file (.html) and view your local stats.

If you have any question or errors about the logs, please e-mail us at surreal@optonline.net
===================================================
8.Runes

Before I explain what runes are present in Half-Life Pro, I want to tell you what a rune is. A rune is a power up to a player. When obtained, 
it can enhance the players attributes or skill.

As you may have experienced before, runes arent a new thing in Half-Life. They have been done
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
	-White Shell
	-Enables a player to recieve extra frags.
-Jump Rune
	-Green Shell
	-Enables a player to jump like jordan.
-Anti-Radar Rune
	-Blue Shell
	-Enables a player to lock the radar of themselves on others displays.

Dont forget, if you want to drop your current rune to obtain another in the area, simply scroll down
the console and type in "drop_rune". You can also display the current rune you have by type in "rune_stats".
===================================================
9.Night Ops Mode

Half Life Pro features a small modification inside of a modification. Night Ops mode has been done before
in the Half Life community. Personally, I believe that everything should be done again. In 
night ops mode, every client starts off with a afew high-light flares, a flashlight and a 
shotgun. This is only because everything is mostly dark. It does not require any new maps 
or ulities, it just requires a few diligent players. 

To start a server on this mode. A server op must:
1.type in the console mp_nightops 1
2.change to a different level or restart that current map.

There are also commands the client needs to know. They are:

1.throw_flare - to throw your current stock of 100% imported flares.
===================================================
10.Real-Life Mode:

Half Life Pro features a another small modification inside of a modification. Real-Life Mode is nothing to brag about.
It feautres realistic bleeding, and damage indicators. Also, the weapon damage has been increased.

To start a server on this mode. A server op must:
1.type in the console mp_reallife 1
2.change to a different level or restart that current map.
===================================================
11.Adding you're own maps:

To add your own maps in Half Life Pro, all you have to do is make a /maps directory in the hlpro directory. 
After that, just put the .bsp file into the maps dir and you can select that map while starting up a Half Life Pro server.

Note: There is a bug in Half Life itself that does not display deathmatch maps in other directories. This is not our fault.
If you would like to start up a server, just select create and after the console displays a error message  ( map change failed: 'unknown' not found on server ), type in any of the original DM maps included with Half Life.

Example:
(Console)

map change failed: 'unknown' not found on server
]map stalkyard

===================================================
12.Beta Testing Specs:

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
13. Bug Contact / Bug List:

If you experience anything abnormal in Half Life Pro, please do not pass it by. Record what you see or hear. 
If you believe this is a serious or causes server crashes (or even client), please contact us, surreal@optonline.net, 
with a detailed list of your cpu specs, what the bug did, where this bug occurred and how long. With this, we can
pinpoint the problem and crush the bug for the next release.

Bug Listing as of 1.0:
(We have no knowledge of any bugs present in version 1.0 of Half-Life Pro.)

===================================================
14.Contact:

Thanks for downloading a simple yet astonishing mod for Half Life.
Please contact the following if this readme does not answer your question on HL pro.

Surreal  - Lead Programmer and Management.
surreal@optonline.net

Kurayamikage - Lead Beta Tester
kurayamikage@hotmail.com

===================================================

Half-Life is a trademark of Valve Software and Sierra Online, used with permission.
Half Life Pro is © Copyright Dependent Studios, 2000.
Half Life Pro is a trademark of Dependent Studios.  All Rights Reserved.


Remember, all new material, including dlls, pictures and files include in this zip file is property of Dependent Studios.
Please contact Surreal, surreal@optonline.net, for information on transferring this data on any transferable devices.
If any of this material is released in any other modification, with our consent and notification, will automatically be
charged in a legal setting ( court of law. ).

(THIS ALSO INCLUDES ALL WEB AND FTP SERVERS. DO NOT UPLOAD THE ZIP FILE UNLESS YOU HAVE OUR PERMISSION. THE ONLY ACCEPTION 
IS THE HALFLIFE.NET SERVER.) 

In other words:
Be respectable and honest of our hard work, or face punishment.
