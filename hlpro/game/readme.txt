
   Half-Life Pro v1.2 
   Author: Surreal (surreal@optonline.net)
   http://www.planethalflife.com/hlpro
   __________________________

   --------------------------
   01. Introduction and Features.
   02. Installation and Requirements.
   03. Running a Server.
   04. New Server Commands.
   05. New Client Commands.
   06. Deathmatch Corrections and Changes.
   07. Gui Support.
   08. Server Stats System.
   09. Voting System.
   10. PowerUps (Runes).
   11. Sprees and Awards.
   12. Heads Up Display.
   13. NightOps Arena.
   14. Armor Man Arena.
   15. One on One Arena.
   16. Last Man Standing Arena.
   17. Weapons Arena.
   18. Client Admin Support.
   19. Single Player Support.
   20. Client Logging System.
   21. Client Stats HTML System.
   22. Contact.
   23. Copyright.
   24. Disclaimer.
   --------------------------

   01. Introduction and Features.
   --------------------------
   What actually is Half-Life Pro? Well, to be quite blunt, Half-Life Pro is a
   modification for a game called Half-Life. What makes Half-Life Pro so unique
   is it tends only for deathmatch. Why deathmatch? I have decided to make this
   modification to keep the hardcore players from dropping out of the Half-Life
   scene. Since most Half-Life modifications point towards teamplay games and
   realism, Half-Life Pro has gone the opposite direction. It adds tons of new 
   features, such as a client's stats from weapon kills to weapon pickups, 
   complied in HTML after a game is over. It also has a new and improved logging
   system, with better output structure and now, not only does a server produce 
   it, so does the connected clients. Half-Life Pro is very customizable and has
   many other features to show. Lets get to the installation, shall we?

   Features in Half-Life Pro 1.2

   -Totally Rebuilt Heads Up Display.
   -Uses valves new netcode.
   -Total display of all your weapon stats on the hud, also timelimit and fraglimit displays.
   -Customable Hud colors and option to switch from the new and old hud with a cvar.
   -HTML Client stats for every area of deathmatch that can be recorded.
   -Vgui support for ingame browsing, readme file and server statistics.
   -Client sided logging of every single game.
   -5 new modes of play
       -NightOps Arena.
       -Armored Man Arena.
       -One on one Arena.
       -Last Man Standing.
       -Weapons Arena supporting all primary single typed weapons.
   -Complete voting system, with map, kick and arena majority votes.
   -Badwords filter, Anti-Spamming, Server disabling spray icons for a younger crowd.
   -Autokick of idling clients.
   -Ingame server stats for lives lost, frags and games.
   -Ingame server details of admin e-mail, name and contacts.
   -Sprees and Special Awards.
   -Client Admin Support. Allowing a connected client to control a server.
   -7 new runes, including Ammo regeneration.
   -Single Player Support.
   -Many fixes to old Half-Life Deathmatch.
   -Under 900kb!

   
   02. Installation and Requirements.
   --------------------------
   Extract this zip into your c:\sierra\half-life directory (or whatever it is).
   The zip will extract the files into the c:\sirrea\sierra\hlpro directory, so 
   you do not have to worry about making new directories. 
   
   The requirements for Half-Life Pro 1.2 are as follows:
   - Half-Life 1.1+ (1.1.0.0 patch+).
   - It is also suggested to run under 800*600 or greater to receive the full 
     advantage of the new HUD display. Run HLPRO under this suggested setting,
     and you may experience some glitches and or graphic misalignment. The new
     HUD works under any video setting, OpenGL, Software or D3D. If you have
     or experience problems, please set the cvar hud_original to 1.

   03. Running a Server.
   --------------------------
   Running a Half-Life Pro server is quite easy. Infact, its the extact same 
   procedure as constructing a Half-Life Deathmatch server. Simply run Half-Life
   with a shortcut command -game hlpro and then select Multiplayer, then 
   Internet games, and finally setup your server CVARS and create a game. It's
   that easy.

   Note: Please refer to "New Server Commands" to customize your HLPRO server.

   04. New Server Commands.
   --------------------------
   Half-Life Pro adds afew server CVARS to allow disabling or enabling of new 
   features. They are:

   mp_allowdecals - to enable or disable client spray decals.
   mp_ammospawn   - seconds inwhich ammo respawns. 
   mp_clientadmin - to give admin ability to a connected client.
   mp_gamemode    - to enable or disable arenas in Half-Life Pro.
   mp_idlereject  - mintues inwhich a idling player is kicked.
   mp_itemspawn   - seconds inwhich a item respawns. 
   mp_matchlimit  - to set the frag limit of a One on One duel.
   mp_randomarena - to enable a server to randomize arena's per map.
   mp_runes       - to enable or disable runes.
   mp_runetime    - minutes inwhich runes respawn.
   mp_votetime    - seconds inwhich a vote ends. (open voting time).
   mp_weaponspawn - seconds inwhich a weapon respawns. 
   mp_weaponarena - to enable weapon arena support. Leave blank for a normal game.

   mp_gamemode is a number cvar. The values for mp_gamemode are as follows:

   mp_gamemode 0 - Standard Deathmatch.
   mp_gamemode 1 - Night Ops Arena.
   mp_gamemode 2 - Armored Man Arena.
   mp_gamemode 3 - One on One Arena.
   mp_gamemode 4 - Last Man Standing.
   mp_gamemode 5 - Weapon Arena. (in conjuction with mp_weaponarena).

   05. New Client Commands.
   --------------------------
   Half-Life Pro adds afew client CVARS to allow disabling or enabling of new 
   features. They are:

   cl_caselife   - time before released shells disappear. In seconds.

   drop_rune     - to drop the current rune you have.

   hud_original  - to enable the old hud and hide the new HLPRO hud.
   hud_color     - color of the hud.      "192 192 192".
   hud_dcolor    - color of active data.  "255 255 255".
   hud_scolor    - color of static words. "128 128 128".
   hud_retracker - to enable or disable the weapon box around the crosshair.
   
   hud_personalstats - to show your personal stats on the hud.
   hud_weaponstats   - to show your weapon stats on the hud.

   hud_playerid      - to enable player ID on the hud.
   hud_centerid      - to show player ID in the center of the hud.

   say_haxor     - to convert a english string to simple haxor.
   
   show_gui      - to display vgui support in Half-Life Pro.

   (please read section 8 for details)
   vote          - to create a public vote.
   vote_kick     - to create a vote to kick a client. 
   vote_map      - to create a vote for a new map. 
   vote_arena    - to create a vote to begin another arena. 


   06. Deathmatch Corrections and Changes.
   --------------------------
   Corrections:
   -mp5 default clip 25 to 50.
   -rpg empty primary fire fix.
   -glock full clip reload fix.
   -used an ambit sound for talk buffer.
   -client can not spam text messages. 2 second pause.
   -precached missing buttons/sparks wav files.
   
   Changes:
   -added badwords list to chat system.
   -dropping of the real weapons instead of weapon boxes.
   -added red screenfade for easy notice of damage take.
   -clients carrying the jump pack drop it when killed.
   -noticable message of changed server CVARS to all clients.
   -removed unused items like the air-tank and antidote.
   -removed internal fvox system.
   -reduced released shell casing life to .5 seconds.
   -reduced rpg rocket trail life to .5 seconds.
   -reduced hornet trail life to .5 seconds.

   07. Gui Support.
   --------------------------
   Half-Life Pro uses the new Gui code for afew new features. At anytime in the 
   game it can be pulled up using the command "show_gui". From there, you should
   see the gui appear on your screen. You can view the server statistics, the
   readme file, the MOTD or join a new game. Half-Life Pro uses valves ingame
   browser, so it is easy to hop to different games without ever exiting to
   the multiplayer menu. If you want to return back to the game, just click
   the Exit button in the lower left corner.

   08. Server Stats System.
   --------------------------
   Half-Life Pro offers a simple system which allows a server to keep track of
   its hosted games, frags and lives lost. It also allows for the server to give
   out easy contact to its connected clients. To modify this data, open open the 
   file:
   
   serverdata.cfg in notepad.

   From there you can moidy the following:
   m_fserverdname - the name of your server.
   m_fserveradmin - the name of yourself.
   m_fserveremail - your e-mail.
   m_fserveripcfg - your ip adress and port.

   You can also edit these if you feel like doing so:
   m_fservergames - amount of games hosted.
   m_fserverfrags - amount of frags in total.
   m_fserverlives - amount of lives lost. (deaths + suicides).

   Please make sure you leave a blank space between the variable and your typed
   info. You do not need any " ", it reads to the end of the line. If Half-Life 
   Pro fails to read any information, it will refresh the file, setting all 
   counts to 0. Also, if the file does not exist, Half-Life Pro will make a 
   default file on starting up.

   Once you have completed this, Half-Life Pro takes over and reads this file at
   the beginning of each game. At the end of a game, it writes the new frags, 
   deaths and games hosted. You do not need to worry about your server crashing 
   because this file retains the current data!

   Note: All connecting clients will see your current data!

   09. Voting System.
   --------------------------
   Half-Life Pro offers a new voting system for all connected clients. Its very
   easy to use. All a clinet needs to do is type vote in his or her console. From
   there a menu pops up(if no one else is constructing a vote) and you can follow
   the directions.
   
   Note: There are 3 types of votes:
   Map
   Arena
   Kick
   
   Once the vote is in progress, all connected clients will see a message at the 
   top left corner of their hud. You can vote by simply typing in the console:

   vote_yes or vote_no.

   All votes run on a majority. If the vote is equal then its a stalement and is 
   rejected.

   Note: Preceeding desired votes are case sentitvite! If you would like to vote 
   for a arena you must use a number value. They are:

   0 - Standard Deathmatch.
   1 - Night Ops.
   2 - Armored Man.
   3 - One on One.
   4 - Last Man Standing.
   5 - Weapon Arena.

   10. PowerUps (Runes).
   --------------------------
   Half-Life Pro supports power ups (Runes) to give a client a special ability. 
   Half-Life Pro has 7 power ups. They are:

   Frag              - Gives you the ability to gain twice as many frags.
   Ammo Regeneration - Gives you the ability to gain ammo over time.
   Haste             - Gives your weapons the ability to fire twice as fast.
   Protect           - Gives you the ability to take half of any damage type.
   Gravity           - Gives you the ability to become a moon walker.
   Regeneration      - Gives you the ability to repair your armor and health over time.
   Vampire           - Gives you the ability to gain 1/2 the damage you deal.

   You can not hold more than 1 rune at a time. If you have a rune and would like
   to discard it, type in the console drop_rune. If you need to know what rune you
   are currently holding, check above your personal stats!

   Note: Since the release of the first 2 versions of Half-Life Pro, 1.2 has a new 
   system with dealing runes throughout the server. Runes are removed from the server
   everytime a new rune is created. However, if the rune is being used by the client, 
   the rune remains.

   11. Sprees and Awards.
   --------------------------
   Current Half-Life Pro adds one new award, the "First Frag" award. You can obtain 
   this by being the first person to kill at the start of a new map. This is the only
   award that is in Half-life Pro at the moment  and will be greatly improved in the
   upcoming versions.

   12. Heads Up Display.
   --------------------------
   Half-Life Pro offers a new Heads Up Display (HUD) for its players. It is very easy 
   to read. On the right side of the hud are the current stats of your selected weapon. 

   (Weapon Stats)
   Name     - The weapon selected.
   Kills    - How many people you killed with this weapon.
   Deaths   - How many people killed you with this weapon.
   Suicides - How many times you killed yourself with this weapon.

   Under this is the ammo and clip ammount.

   On the left side of the hud you will see the following:

   (Personal Stats)
   Place    - Current position you are in.    currentplace-> 1/8 <-total places.
   Frags    - How many people you killed.
   Deaths   - How many people killed you.
   Suicides - How many times you killed yourself.

   Under this it displays your netname, health and armor.

   If there is a timelimit, fraglimit or both, your hud will display these server 
   varibles in the top right corner. The timelimit will count down and the fraglimit 
   stays static.

   You may also see train and geiger counters, and current rune status above your 
   personal stats.

   If you would like to customize your hud, open up hud.cfg and edit pre defined 
   variables. hud.cfg executes itself on every connect and changelevel. Also, you 
   may hide your personal and weapon stats with the cvars hud_weaponstats and 
   hud_personal stats. Set them to a value of 0 to hide.

   13. NightOps Arena.
   --------------------------
   Half-Life Pro offers NightOps Arena for a standard duel of deathmatch in the 
   dark. This new arena works with any map that supports half-life. To set a game up
   to run this arena, simply set the mp_gamemode CVAR to 1 and restart the current 
   level or change to a new map.

   14. Armor Man Arena.
   --------------------------
   Half-Life Pro offers a unique type of arena that marks a random player connected
   to the server, gives him or her twice the value of health and armor, a regeneration
   ability and all the weapons allowed in Half-Life. The object of this arena is to kill
   this armored man and in doing so, the client recieves an extra 10 frags. After the 
   armored man has been killed, another person or the same person is picked again to 
   become the armored man and the game repeats itself. Note: there is a -1 point penalty
   if a client kills another man that is not the armored man. Another Note: the armored
   man is clearly marked with a blue glowing shell. To set a game up to run this arena, 
   simply set the mp_gamemode CVAR to 2 and restart the current level or change to a 
   new map.

   15. One on One Arena.
   --------------------------
   Half-Life Pro offers One on One Arena for a one on one duel while others watch on. 
   When there are enoguh clients connected to a Half-Life Pro server, ther server randomly
   chooses 2 clients to battle one on one up to the limit of mp_matchlimit. After one of 
   the two clients reach this limit, the game then chooses to other clients to battle it 
   out. To set a game up to run this arena, simply set the mp_gamemode CVAR to 3 and 
   restart the current level or change to a new map.

   16. Last Man Standing Arena.
   --------------------------
   Half-Life Pro offers another arena for fast heats of play. This arena, Last Man 
   Standing, is designed to award the last man standing. If you are alive and you are 
   currently the last man standing, you win! If you are killed and there are than 1 
   player standing (alive) then you loose and you have to wait till there is one man 
   left. To set a game up to run this arena, simply set the mp_gamemode CVAR to 4 and
   restart the current level or change to a new map.

   17. Weapons Arena.
   --------------------------
   Half-Life Pro offers a mode of play which involves weapon stripping and placement. 
   Its easy to make a server that has single weapon action. All the server admin has 
   to do is set the CVAR mp_gamemode to 5 and mp_weaponarena to one of these:

   crowbar     (Crowbar)
   9mmhandgun  (Glock  18)
   357         (Python)
   crossbow    (Crossbow)
   9mmAR       (Machine Guns)
   shotgun     (Shotguns)
   rpg         (Rocket Launchers)
   gauss       (Gauss's)
   egon        (Egons!)
   hornetgun   (HornetGuns)

   and after he restarts the level, all weapons besides the one selected are removed 
   from the map and are replaced with that selected. Now everyone can enjoy single weapon
   fragging.

   Note: All ammo are removed from the map and are replaced with the ammo assoicated 
   with that weapon. Also, there is no support of item_weapons such as tripmines and 
   snarks.

   18. Client Admin Support.
   --------------------------
   Half-Life Pro allows server admins to appoint a connected client that is playing 
   to be able to control a certain amount of server variables without actually controlling
   the server fully. To appoint a client that is connected to your server just type in 
   the console mp_clientadmin followed by the name of the player. Remember, you still can
   take away his rights by setting the cvar to (null) which allows no one admin 
   functionality. A client admin can control the following:

   "mp_teamplay",      "mp_fraglimit",     "mp_timelimit",    "mp_friendlyfire", 
   "mp_falldamage",    "mp_weaponstay",    "mp_forcerespawn", "mp_flashlight",    
   "mp_autocrosshair", "decalfrequency",   "mp_teamlist",     "mp_teamoverride", 
   "mp_defaultteam",   "mp_allowmonsters", "mp_idlereject",   "mp_runes",       
   "mp_runetime",      "mp_allowvote",     "mp_votetime",     "mp_matchlimit", 
   "mp_ammospawn",     "mp_itemspawn",     "mp_gamemode",     "mp_weaponarena", 
   "mp_randomarena",   "mp_clientadmin",   "cl_changelevel",  "kick",
   "mp_weaponspawn".

   This addition may come in handy if a server operator needs to leave his or her 
   machine for a long period of time. He or she can easily give the right to a trusted
   client.

   19. Single Player Support.
   --------------------------
   Half-Life Pro allows for any person to play through single player. In later editions,
   it willbe enhanced with stats and many other features to come! To play single player 
   either select it through the opening menu or type in the console   deathmatch 0  and
   then load up the map named c0a0.

   20. Client Logging System.
   --------------------------
   Half-Life Pro adds a client sided logging system very similar to server sided logging
   that is in Half-Life. This log resides in the main directory of hlpro and is written
   while a game is in progress. It records many things that are going on in the game. If
   the log file is not in  the hlpro directory, Half-Life Pro will automatically create 
   one. If there is a existing one, it will attach the new game data at the end of the 
   file. This file comes in handy when you want to refer back to a previous game.

   21. Client Stats HTML System.
   --------------------------
   Half-Life Pro adds HTML logging for each client connected to a server. All HTML 
   content is and resides in the hlpro/stats directory. If you would like to see your
   stats, simply go to this dir and you can view these files through an internet browser. 
   Each HTML file has many values that you have increased or decreased during a game. 
   Each game has its own HTML and has a game number. Lastly, a HTML file is created after
   the end of a match, map change or on your disconnecting.

   Note: -DO NOT DELETE THE HLPRO/STATS DIRECTORY!
         -You may delete the HTML files if you would like.
         -Also, HTML files will never be overwritten! 
   
   22. Contact.
   --------------------------
   If you have a general problem with Half-Life Pro, or have suggestions or 
   comments about this new version, please contact me at:

   Surreal:
   surreal@optonline.net

   If you would like to send comments or suggestions to my Beta Testers, 
   please email them at:
   
   Split Spine:
   shock@vortopia.com

   Gitbgff:
   joemcblow@canda.com

   If you would like to send comments or suggestions to my one true fan,
   please email him at:

   EnemeyZero:
   fafara_rascon@hotmail.com

   Source Code requests will not be granted, this isn't a open source project.
   Although, I will help those with questions on the actual Half-Life soruce.

   23. Copyright.
   --------------------------
   Half-Life is a trademark of Valve Software and Sierra Online, used with permission.
   Half Life Pro is (c) Copyright Dependent Studios, 2000.
   Half Life Pro is a trademark of Dependent Studios. All Rights Reserved.

   Remember, all new material, including dlls, pictures and files include in
   this zip file is property of Douglas Arcuri. Please contact Doug(Surreal), 
   surreal@optonline.net, for information on transferring this data on any 
   electronic devices. If any of this material is released in any other 
   modification, without our consent or notification, will automatically be
   charged in a legal setting ( court of law. ).

   24. Disclaimer.
   --------------------------
   This is a BETA release, I therefore will not take responsibility for your system
   blowing up after playing the game. I can however guarantee that I have not 
   purposely added any malicious content to this application. If you believe this to 
   be incorrect, then I'd be happy to discuss the matter with you.

   You may freely distribute this archive, as long as it remains PERFECTLY intact, as
   distributed on our home page: "http://www.planethalflife.com/hlpro". 

   Thanks for downloading!	

   __________________________

   Half-Life Pro 1.2 development began on:    May 19, 2000.
   Half-Life SDK 2.0 released on:            June 08, 2000.
   Half-Life Pro 1.2 development ended on: August 26, 2000.

   Estimated hours of coding: Many.
