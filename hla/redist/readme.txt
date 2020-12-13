
 __________________________

 Half-Life Advanced v2.0
 dependentstudios@hotmail.com
 __________________________

 contents
 00. about half-life advanced
 01. about dependent studios
 02. installation
       a. hybird
       b. traditional
 03. executing
 04. game modes
       a. ffa
       b. arena
       c. lms
       d. robo
 05. mutators
 06. voting system
 07. cvar / command addition
 08. runes
 09. misc info
 10. contact
 11. copyright / disclaimer
 __________________________

 In a nut-shell:

 Half-life advanced stays true to three statements:

 1. original; 	where we never alter the internal workings of the game.
 2. server-sided;	where we never require a client to download an installer.
 3. simplicity; 	where we never like to memorize five hundred cvars.

 Therefore, half-life advanced is `original server-sided simplicity`.

 00. 	about half-life advanced
	---------------------------------------
	Half-life advanced is a unique blend of game modes, mutators and 
	enhancement to the game half-life, developed by valve from 1996 to 1998. 
	Its goal is to deliever renewed interest in half-life deathmatch.
	While there are many similar modifications that 
	deliever this goal, half-life advanced stands out because it is server sided. Meaning, there 
	is no need for a client to download files before joining a server. 
                Half-life advanced is designed to include all of the 
	popular game modes such as arena, made popular by the mod AG. It
	also includes many unique game modes such as head hunter, freeze-
	tag and robo. Half-life advanced also includes a list of mutators that 
	can be actived in order to enhance the game play. Such mutators as
	anti-camper, earning weapons and boobytrap can really make the gaming
	experience intense. Half-life advanced also includes a voting system
	where the clients can delegate the role of the server. Clients have the 
	option to kick or ban a selected client; can change the map or extend
	the current one; and finally change the current game mode and mutators. Half-life
	advanced also includes many miscellaneous changes to half-life deathmatch. These enhancements include 
	nine unique runes, a select amount of weapon power ups and a current weapon
	accuracy/kill ratio display for each weapon currently in use. Of course, the admin has the
	full ability to disable any addition he or she sees fit for their server.
		Half-life advanced will be executed with extreme professionalism.
	For ideas that were not thought of by the author exclusively, full credit will be given.
	Half-life advance is a culmination of ideas from past mods as well as unique
	ideas from the author. We would like to stress that no money is
	earned from the work on this project. We also like to stress the community
	to submit new ideas to the author. If the idea is feasible to the half-life source
	and makes logical sense, the author will add the brainstorming to the next version of
	half-life advanced. Half-life advanced philosophy is clear, without a community there is 
	no reason for the author to continue this project.

 01. 	about dependent studios
 	----------------------------------------
	Dependent studios is a company that strives for excellence in web page creation and
	program development. Founded in March 2000 by douglas arcuri, its sole purpurse is to
	deliever outstanding web page outlay and graphic design to small to medium sized
	businesses. 
		Dependent studios has recently begun development in programming. 
	Dependent studios first production of c++ source development has begun with half-life
	advanced v2.0, a modification to half-life deathmatch. Delievering a fresh new outlook
	on the old styled half-life deathmatch, half-life advanced delievers such enhancements
	as game modes, mutators and other miscellaneous changes. 

 02. 	installation
 	------------------
	Installation of half-life advanced comes in two ways and both are very easy to handle.

 02a.	type 1 install (hybrid)
	----------------------------------
	This is where a user can dump the `hla.dll` into the current `valve\dlls` directory.

	Step 1:	Unpackage half-life advanced and copy the `hla.dll` file located under
		`hla\dlls` to `valve\dlls` located either under `sierra\half-life` or the new
		steam system `steam\steamapps\<email of account>\half-life\`.
	Step 2:	Rename the current dll in the folder `hl.dll` to `hl.dll.old`.
	Step 3:	Rename `hla.dll` to `hl.dll`.
	Step 4:	Copy the `modes` directory from the unzipped files under `hla` and dump it into
		`valve`. The modes folder contains the text files that are displayed
		for each game mode.
	
	In effect, this installation mocks half-life advanced as an original game of valve.

 02b.	type 2 install (traditional)
	----------------------------------------
	This is the prefered method of installation, where `hla` is copied to the `half-life` directory.

	Step 1:	Unpackage half-life advanced and copy the whole `hla` directory
		and paste this it inside `sierra\half-life` or the new steam system 
		`steam\steamapps\<email of account>\half-life\`

 03. 	executing
 	----------------
	To start (or execute) a game of half-life advanced, one must do the following.
	
	For steam clients:
	
	Step1:	Log onto steam and select `half-life advanced` below the `third party modifications`
		under the `games` window.
	Step2:	Start a multiplayer server or join a half-life advanced server.

	For old style clients:

	Step1:	Start a game of half-life.
	Step2:	Go to `custom game` and select half-life advanced v2.0 and `active`.
	Step3:	Start a multiplayer server or join a half-life advanced server.

 04. 	game modes
 	---------------------
	Game modes drive half-life advance to par with other deathmatch modifications.
	Game modes are simple, they change how the game is played. Below are the current modes
	that have included in this release of half-life advanced. Please keep in mind that there are 
	a few select cvars that define the limits of each game. Some variables are universal and some are
	specific to the mode. Of these cvars, the most important are `hla_gamerounds`, `hla_gamefrags`
	and `hla_gametimer`. `hla_gamerounds` defines how many successful rounds are completed
	before the map changes. `hla_gamefrags` specifies the amount of frags a person must achieve
	before a victory, or in the case of last man standing, it is how many lives the player has.
	Lastly, `hla_gametimer` sets the amount of time allowed in the current round, which is in minutes. 

 04a.	ffa - free for all ( `hla_gamemode ffa` )
	-------------------------------------------------------------
	This game mode is the original style deathmatch. The player with the highest frags
	at `mp_timelimit` or the first player to reach the `mp_fraglimit` is considered the winner.

 04b.	arena - match based arena ( `hla_gamemode arena` )
	--------------------------------------------------------------------------------------
	A new addition to half-life advanced, arena selects two random players
	that are connected to the server to face off to the death. `hla_gamefrags` determines
	the fraglimit of the match and `hla_gametimer` determines how long, in minutes, the
	two have alotted to face off. 
		There are three possible outcomes of arena. One, a player
	becomes the victor if he or she reaches `hla_arenafrags` first. Two, `hla_gametimer`
	is reached and the player with the highest frags wins. Third, `hla_gametimer` is reached
	and both players have the same amount of frags; this is considered a draw where no
	player wins. Note that both players spawn fully loaded.

 04c.	lms - last man standing ( `hla_gamemode lms` )
	-----------------------------------------------------------------------------
	Last man standing is a unique game mode where all players connected face off to 
	do battle while dying. It is the job of each player to stay alive as long as possible.
		When the battle first begins, each player's frag count is equal to `hla_gamefrags`. When a 
	player dies, he or she will loose a frag. If the player reachs zero frags, the player is defeated.
	The last man left alive with frags is considered the winner. If `hla_gametimer` is reached the client with the highest frags wins. If this is not the
	case and two or more players with the highest equal frags, the match is considered a draw.
	Note that all weapons and items are removed from the map and that each player spawns 
	with full weapons every time. Also note that inflicting damage to an opponent gives a little
	amount of health back. Therefore it is wise to stay in the game as opposed to hiding out.
	Each man will slowly loose health regardless of action.

04d.	robo - armored man  ( `hla_gamemode robo` )
	-------------------------------------------------------------------------
	Armored Robo is a unique addition to half-life advanced. The game starts off with
	one randomly selected player as the robo, which is fully loaded, extra protected, ammo and
	health regenerated. It is the sole duty of all the other players to exterminate this man.
		Once the round begins the players who are not selected as robo are assigned to one
	team known as `recon`. It is then a race against `hla_gametimer` to exterminate the armored
	man. The player who successfully performs the most damage on him is considered the winner.
	If the robo outlasts, that is not die, this player is awarded the round win. Note that once a recon
	is killed in the round, the player cannot respawn and will have to wait till either the robo
	is killed or all the other recon are killed.

05.	mutators  ( `hla_mutators camper, gib, ...` )
	--------------
	Mutators are specific variables that alter the current conditions in the game. Mutators can 
	be mixed and matched with ease using the `hla_mutators` cvar. To specify one than one 
	mutator, the cvar must be used as follows. Ex: `hla_mutators camper, earning`, where each
	mutator is seperated by a comma. Also note that all mutators cannot be enabled at once. For
	example, it is unwieldy to enable `hla_mutators earning, startfull`, since a player has to earn
	weapons but will start with all weapons. Therefore a certain combination of mutators
	will not be allowed.

	Note that mutators 01 through 16 are weapon specific. These mutators can be combined to allow
	only these select weapons in the map. If one or more are selected, the client will start with these weapons.
	These weapons will also be randomly spawned throughout the map, including its associated ammo.

	01. `crowbar` 	- forces all global weapons to this weapon plus any other mutator weapon.
	02. `glock	`	- forces all global weapons to this weapon plus any other mutator weapon.
	03. `python`	- forces all global weapons to this weapon plus any other mutator weapon.
	04. `mp5`		- forces all global weapons to this weapon plus any other mutator weapon.
	05. `chaingun`	- forces all global weapons to this weapon plus any other mutator weapon.
	06. `crossbow`	- forces all global weapons to this weapon plus any other mutator weapon.
	07. `shotgun`	- forces all global weapons to this weapon plus any other mutator weapon.
	08. `rpg`		- forces all global weapons to this weapon plus any other mutator weapon.
	09. `gauss`	- forces all global weapons to this weapon plus any other mutator weapon.
	10. `egon`	- forces all global weapons to this weapon plus any other mutator weapon.
	11. `hornetgun`	- forces all global weapons to this weapon plus any other mutator weapon.
	12. `handgrenade`	- forces all global weapons to this weapon plus any other mutator weapon.
	13. `tripmine`	- forces all global weapons to this weapon plus any other mutator weapon.
	14. `satchel`	- forces all global weapons to this weapon plus any other mutator weapon.
	15. `snark`	- forces all global weapons to this weapon plus any other mutator weapon.
	16. `none`	- forces all global weapons not to spawn. If enabled, elimiates all other weapon mutators.
	17. `camper`	- deals a small amount of damage to players who camp.
	18. `gib`		- one shot kills.
	19. `fatboy`	- a player's shell becomes bigger and bigger when he or she frags without dying.
	20. `earning`	- a player can earn a set amount of weapons by the amount of frags he or she has.
	21. `startfull`	- player starts out with all weapons, ammo and armor.
	22. `gore`		- increase in blood and guts.
	23. `runes`	- enables runes into the map. (see section .08 for details).
	24. `explosive`	- when a player is killed he or she explodes.
	25. `maxpack`	- when a player is killed he or she will drop all their weapons in a weaponbox.
	26. `boobytrap`	- changes deployed satchels to weapons.
	27. `spawn`	- gives the player five seconds of invincibility when he or she spawns.
	28. `real`		- enables blindness, bleeding and loss of weapons when damage is taken.

06. 	voting system ( `hla_votetimer 30`, `hla_votedelay 30` )
	------------------------------------------------------------------------------------------
	Half-life advance includes a voting system for its connected clients. This system is
	very intutitive just as long as the player has the knowledge of the avaiable commands he or she can
	vote for. Currently half-life advanced has six areas where a player can vote on. They can change
	the map, change the gamemode, kick a player, ban a player, extend a map or add a mutator.
	All these votes are ruled under a few commands. `hla_votetimer` determines whether the voting system 
	is enabled on the server. If this cvar is greater than nine seconds, it is used to allow the set amount
	of time (in seconds) clients can vote on the given call. `hla_votedelay` determines how much time (in seconds)
	the next vote is allowed if the previous vote has failed.
		Initiation of vote is simple. Every three to four minutes a message is sent to all clients reminding
	them of all available voting options (that is if `hla_votetimer` is enabled). These commands are as follows:
	vote_map <map name>, vote_game <mode>, vote_kick <name or id>, vote_ban <name or id>, vote_extend,
	vote_mutator <mutator>. All these commands are self explanatory. If there is currently no vote in progress
	and `hla_votedelay` has been met with a previous vote, a new vote will be called. During the process of a vote,
	its initiator automatically votes yes. Clients will be given the option to vote either `yes` or `no`. After `hla_votetimer`
	has been met or all active players have voted, the vote ends and the votes are tallied. For a vote to pass, it must have more than 50% of all 
	connected clients to vote `yes`. Note that spectators are not allowed to vote. Also note that all `vote_...` 
	commands are realized by both the console and say buffer; this also includes the commands `yes` and `no`.

07.	cvar / command addition
	----------------------------------------
	Half-life advanced adds a select amount of new cvars to command the new features. These commands can
	be broken down into two categories: client and server. Client commands are used by connected players to
	modify settings or to create votes. Server commands modify gamerules that are active. 

	Client Commands ( addition to the standard half-life commands ):

	01. `help` 				- displays all aviable commands to the user.
	02. `stats` 				- enables or disables the weapon accuracy display.
	03. `rune`					- displays the current rune the player has.
	04. `yes`					- votes YES during a vote.
	05. `no`					- votes NO during a vote.
	06. `vote_map <map>`			- initiates a vote for a particular map.
	07. `vote_game <mode>`			- initiates a vote for a particular game mode.
	08. `vote_kick <name or id>`			- initiates a vote to kick a particular client.
	09. `vote_ban <name or id>`			- initiates a vote to ban a particular client.
	10. `vote_extend`				- initiates a vote to extend the play of the current map.
	11. `vote_mutator <mutator>` 		- initiates a vote to add a particular mutator.

	Server Commands ( addition to the standard half-life commands ):

	01. `hla_mutators "<mutator1>, <mutator2>, ..."`	- sets mutators active. (see sect. 05 for details)
	02. `hla_gamemode <mode>`			- sets game mode. (see sect. 04 for details)
	03. `hla_gamefrags <frags>`			- sets the amount of frags to achieve during a round.
	04. `hla_gametimer <seconds>`		- sets the amount of time for a round to end.
	05. `hla_gamerounds <rounds>`		- sets the amount of rounds before the change of the map.
	06. `hla_votetimer <seconds>`		- sets the amount of time for a vote. (see sect. 06 for details)
	07. `hla_votedelay <seconds>`		- sets the amount of time for the next vote.
	08. `hla_startweapons "<weap1>, <weap2>, ..."`	- sets the weapons a player spawns with.
	

11.	copyright / disclaimer
	-----------------------------------
	     IN NO EVENT WHATSOEVER SHALL dependent studios BE LIABLE FOR ANY DAMAGES
	WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DIRECT OR INDIRECT DAMAGES, DAMAGES
	FOR LOSS OF PROFITS, BUSINESS INTERRUPTION, LOSS OF INFORMATION) RESULTING FROM
	THE USE OR INABILITY TO USE THE PROGRAMS AND FILES EVEN IF dependent studios HAS 
	BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. Without limiting the generality of the foregoing,
	no warranty is made that the enclosed software will do anything you want it to, or be error free. USING
	THIS SOFTWARE IMPLIES AGREEMENT TO THESE TERMS.
	
	     This version of half-life advanced is provided free of charge and may be freely downloaded and
	redistributed under the condition that all files in the original distribution remain in the distribution and that
	all redistribution sites must inform (in the form of a hypertext link, etc.) users of the original place of 
	distribution. No person or group shall profit from the redistribution of this software in any form without 
	the consent of dependent studios. In other words, do not put this program onto a CD containing 
	shareware/freeware programs that will be sold without first consulting dependent studios);
	




 ---------------------------------------------------------
 `hla\readme.txt` revision 1 03/2004



red screen when inuried
blood stream
drop model weapons
drop long jump
voting system: map-kick-ban-mutator-arena
weapon accuracy/ratio stats
mutators: fatboy, anti-camper, insta-gib, weapon-strip, gore, earning
game modes: area, ffa, freezetag, headhunter, lms, robo