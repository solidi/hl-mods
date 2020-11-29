/***
*
*	Copyright (c) 1999, Valve LLC. All rights reserved.
*	
*	This product contains software technology licensed from Id 
*	Software, Inc. ("Id Technology").  Id Technology (c) 1996 Id Software, Inc. 
*	All Rights Reserved.
*
*   Use, distribution, and modification of this source code and/or resulting
*   object code is restricted to non-commercial enhancements to products from
*   Valve LLC.  All other use, distribution, or modification is prohibited
*   without written permission from Valve LLC.
*
****/
//
// teamplay_gamerules.cpp
//
#include	"extdll.h"
#include	"util.h"
#include	"cbase.h"
#include	"player.h"
#include	"weapons.h"
#include	"gamerules.h"
#include	"skill.h"
#include	"game.h"
#include	"items.h"
#include    "shake.h"

extern DLL_GLOBAL CGameRules	*g_pGameRules;
extern DLL_GLOBAL BOOL	g_fGameOver;
extern int gmsgDeathMsg;	// client dll messages
extern int gmsgScoreInfo;
extern int gmsgMOTD;
int m_pPlayer;

#define ITEM_RESPAWN_TIME	30
#define WEAPON_RESPAWN_TIME	30
#define AMMO_RESPAWN_TIME	30

//*********************************************************
// Rules for the half-life multiplayer game.
//*********************************************************

CHalfLifeMultiplay :: CHalfLifeMultiplay()
{
	RefreshSkillData();
	m_flIntermissionEndTime = 0;
	
	// 11/8/98
	// Modified by YWB:  Server .cfg file is now a cvar, so that 
	//  server ops can run multiple game servers, with different server .cfg files,
	//  from a single installed directory.
	// Mapcyclefile is already a cvar.

	// 3/31/99
	// Added lservercfg file cvar, since listen and dedicated servers should not
	// share a single config file. (sjb)
	if ( IS_DEDICATED_SERVER() )
	{
		
		// dedicated server
		char *servercfgfile = (char *)CVAR_GET_STRING( "servercfgfile" );

		// Check All CVARS!
		if ( ( CVAR_GET_FLOAT( "mp_runes" )  > 0 ) )
			ALERT( at_console, "\n\n------Cold Ice Settings------\nRunes             On\n" );
		else
			ALERT( at_console,  "Runes             Off\n" );

		if ( ( CVAR_GET_FLOAT( "mp_hook" ) > 0 ) )
		    ALERT( at_console,  "Hook              On\n"  );
		else
			ALERT ( at_console, "Hook              Off\n" );

			if ( ( CVAR_GET_FLOAT( "secretweapons" ) > 0 ) )
		    ALERT( at_console,  "Secret Weapons  On\n"  );
		else
			ALERT ( at_console, "Secret Weapons  Off\n" );
		
		if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) )
			ALERT( at_console, "Bot Arena         On\n" );
		else
			ALERT( at_console, "Bot Arena         Off\n" );

		if ( ( CVAR_GET_FLOAT( "automatic_arena" )   == 2   ) )
			ALERT( at_console, "Automatic Arena On\n" );
		else
			ALERT( at_console, "Automatic Arena Off\n" );

		if ( ( CVAR_GET_FLOAT( "rocket_arena" )   == 2   ) )
			ALERT( at_console, "Rocket Arena     On\n--------------------------\n\n" );
		else
			ALERT( at_console, "Rocket Arena     Off\n--------------------------\n\n" );
		
		// HACK!
		if ( ( CVAR_GET_FLOAT( "rocket_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "bot_arena" )   == 2   )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

	
		else if ( ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

		else if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

		else if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  ) && ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  )  )
		{
			ALERT( at_console, "\nWARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n\n\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}


		if ( servercfgfile && servercfgfile[0] )
		{
			char szCommand[256];
			
			ALERT( at_console, "Executing dedicated server config file\n" );
			sprintf( szCommand, "exec %s\n", servercfgfile );
			SERVER_COMMAND( szCommand );
		}
	}
	else
	{	
		
		// listen server
		char *lservercfgfile = (char *)CVAR_GET_STRING( "lservercfgfile" );

		
			// Check All CVARS!
		if ( ( CVAR_GET_FLOAT( "mp_runes" )  > 0 ) )
			ALERT( at_console, "\n\n------Cold Ice Settings------\nRunes             On\n" );
		else
			ALERT( at_console,  "Runes             Off\n" );

		if ( ( CVAR_GET_FLOAT( "mp_hook" ) > 0 ) )
		    ALERT( at_console,  "Hook              On\n"  );
		else
			ALERT ( at_console, "Hook              Off\n" );

			if ( ( CVAR_GET_FLOAT( "secretweapons" ) > 0 ) )
		    ALERT( at_console,  "Secret Weapons  On\n"  );
		else
			ALERT ( at_console, "Secret Weapons  Off\n" );
		
		if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) )
			ALERT( at_console, "Bot Arena         On\n" );
		else
			ALERT( at_console, "Bot Arena         Off\n" );

		if ( ( CVAR_GET_FLOAT( "automatic_arena" )   == 2   ) )
			ALERT( at_console, "Automatic Arena On\n" );
		else
			ALERT( at_console, "Automatic Arena Off\n" );

		if ( ( CVAR_GET_FLOAT( "rocket_arena" )   == 2   ) )
			ALERT( at_console, "Rocket Arena     On\n--------------------------\n\n" );
		else
			ALERT( at_console, "Rocket Arena     Off\n--------------------------\n\n" );
		
		// HACK!
		if ( ( CVAR_GET_FLOAT( "rocket_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "bot_arena" )   == 2   )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

	
		else if ( ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

		else if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

		else if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  ) && ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  )  )
		{
			ALERT( at_console, "\nWARNING!! 2 or more arenas are active.\n*Killing all to preserve gameplay.\n\n\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

		if ( lservercfgfile && lservercfgfile[0] )
		{
			char szCommand[256];
			
			ALERT( at_console, "Executing listen server config file\n" );
			sprintf( szCommand, "exec %s\n", lservercfgfile );
			SERVER_COMMAND( szCommand );
		}
	}
}

//=========================================================
//=========================================================
void CHalfLifeMultiplay::RefreshSkillData( void )
{
// load all default values
	CGameRules::RefreshSkillData();

// override some values for multiplay.

	// suitcharger
	gSkillData.suitchargerCapacity = 150;

	// Knife Slice
	gSkillData.plrDmgKnife = 30;     // Manual row of 10's.  
                                     // We want fast weapons on top,
	// Crowbar whack                 //and slow but dealy on 'da bottom.
	gSkillData.plrDmgCrowbar = 35;

	// Wrench smack
	gSkillData.plrDmgWrench = 40;

	// Glock Round
	gSkillData.plrDmg9MM = 20;

	// 357 Round
	gSkillData.plrDmg357 = 30;

	// MP5 Round
	gSkillData.plrDmgMP5 = 15;
	
	// ChainGun Rounds
	gSkillData.plrDmgMini = 16;

	// Street Sweeper Rounds
	gSkillData.plrDmgStreet = 18;

	// M203 grenade
	gSkillData.plrDmgM203Grenade = 130;

	//Kamikaze vest!
	gSkillData.plrDmgKamikaze = 230;

	// Timed grenade
	gSkillData.plrDmgTimedGrenade = 180;

	// Pellet Explosive!
	gSkillData.plrDmgPellet = 65;

	// Shotgun buckshot
	gSkillData.plrDmgBuckshot = 10;

	// Boltgun
	gSkillData.plrDmgBoltgun = 30;

	// Sniper Rifle
	gSkillData.plrDmg765mm = 400;

	// RPG
	gSkillData.plrDmgRPG = 150;

	//RPG Tank Rockets
	gSkillData.plrDmgRocketTank = 250;

	// Pipebomb --Remember 1996 olymipics hhehehehe.
	gSkillData.plrDmgPipebomb = 100;

	//30mmShell
	gSkillData.plrDmg30mmshell = 110;

	// Hand Grenade
	gSkillData.plrDmgHandGrenade = 100;

	// Satchel Charge
	gSkillData.plrDmgSatchel = 150;

	// Tripmine
	gSkillData.plrDmgTripmine = 120;
	
}

// longest the intermission can last, in seconds
#define MAX_INTERMISSION_TIME		120

//=========================================================
//=========================================================
void CHalfLifeMultiplay :: Think ( void )
{
	///// Check game rules /////

	if ( g_fGameOver )   // someone else quit the game already
	{
		if ( m_flIntermissionEndTime < gpGlobals->time )
		{
			if ( m_iEndIntermissionButtonHit  // check that someone has pressed a key, or the max intermission time is over
				|| ((m_flIntermissionEndTime + MAX_INTERMISSION_TIME) < gpGlobals->time) ) 
				ChangeLevel(); // intermission is over
		}
		return;
	}

	float flTimeLimit = timelimit.value * 60;
	float flFragLimit = fraglimit.value;
	
	if ( flTimeLimit != 0 && gpGlobals->time >= flTimeLimit )
	{
		GoToIntermission();
		return;
	}
	if ( ( CVAR_GET_FLOAT( "rocket_arena" )  == 1  ) )
	{
		ALERT( at_console, "Rocket Arena Now Activated\n" );
		SERVER_COMMAND( "rocket_arena 2\n" );
		ALERT( at_console, "*Rocket Arena Now Active*\n" );
		GoToIntermission();
	}
	if ( ( CVAR_GET_FLOAT( "bot_arena" )  == 1  ) )
	{
		ALERT( at_console, "Bot Arena Now Activated\n" );
		SERVER_COMMAND( "bot_arena 2\n" );
		ALERT( at_console, "*Bot Arena Now Active*\n" );
		GoToIntermission();
	}
	if ( ( CVAR_GET_FLOAT( "automatic_arena" )  == 1  ) )
	{
		ALERT( at_console, "Automatic Arena Now Activated\n" );
		SERVER_COMMAND( "automatic_arena 2\n" );
		ALERT( at_console, "*Automatic Arena Now Active*\n" );
		GoToIntermission();
	}
		// HACK!
		if ( ( CVAR_GET_FLOAT( "rocket_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "bot_arena" )   == 2   )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n" );
		    SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

	
		else if ( ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n" );
		       SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");

		}

		else if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  )  )
		{
			ALERT( at_console, "WARNING!! 2 or more arenas are active.\n" );
		       SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

		else if ( ( CVAR_GET_FLOAT( "bot_arena" )   == 2   ) && ( CVAR_GET_FLOAT( "automatic_arena" )  == 2  ) && ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  )  )
		{
			ALERT( at_console, "\nWARNING!! 2 or more arenas are active.\n" );
		       SERVER_COMMAND( "rocket_arena 0\n" );
		    SERVER_COMMAND( "bot_arena 0\n" );
			SERVER_COMMAND( "automatic_arena 0\n");
		}

	if ( flFragLimit )
	{
		// check if any player is over the frag limit
		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBaseEntity *pPlayer = UTIL_PlayerByIndex( i );

			if ( pPlayer && pPlayer->pev->frags >= flFragLimit )
			{
				GoToIntermission();
				return;
			}
		}
	}
}


//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::IsMultiplayer( void )
{
	return TRUE;
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::IsDeathmatch( void )
{
	return TRUE;
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::IsCoOp( void )
{
	return gpGlobals->coop;
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::FShouldSwitchWeapon( CBasePlayer *pPlayer, CBasePlayerItem *pWeapon )
{
	if ( !pWeapon->CanDeploy() )
	{
		// that weapon can't deploy anyway.
		return FALSE;
	}

	if ( !pPlayer->m_pActiveItem )
	{
		// player doesn't have an active item!
		return TRUE;
	}

	if ( !pPlayer->m_pActiveItem->CanHolster() )
	{
		// can't put away the active item.
		return FALSE;
	}

	if ( pWeapon->iWeight() > pPlayer->m_pActiveItem->iWeight() )
	{
		return TRUE;
	}

	return FALSE;
}

BOOL CHalfLifeMultiplay :: GetNextBestWeapon( CBasePlayer *pPlayer, CBasePlayerItem *pCurrentWeapon )
{

	CBasePlayerItem *pCheck;
	CBasePlayerItem *pBest;// this will be used in the event that we don't find a weapon in the same category.
	int iBestWeight;
	int i;

	iBestWeight = -1;// no weapon lower than -1 can be autoswitched to
	pBest = NULL;

	if ( !pCurrentWeapon->CanHolster() )
	{
		// can't put this gun away right now, so can't switch.
		return FALSE;
	}

	for ( i = 0 ; i < MAX_ITEM_TYPES ; i++ )
	{
		pCheck = pPlayer->m_rgpPlayerItems[ i ];

		while ( pCheck )
		{
			if ( pCheck->iWeight() > -1 && pCheck->iWeight() == pCurrentWeapon->iWeight() && pCheck != pCurrentWeapon )
			{
				// this weapon is from the same category. 
				if ( pCheck->CanDeploy() )
				{
					if ( pPlayer->SwitchWeapon( pCheck ) )
					{
						return TRUE;
					}
				}
			}
			else if ( pCheck->iWeight() > iBestWeight && pCheck != pCurrentWeapon )// don't reselect the weapon we're trying to get rid of
			{
				//ALERT ( at_console, "Considering %s\n", STRING( pCheck->pev->classname ) );
				// we keep updating the 'best' weapon just in case we can't find a weapon of the same weight
				// that the player was using. This will end up leaving the player with his heaviest-weighted 
				// weapon. 
				if ( pCheck->CanDeploy() )
				{
					// if this weapon is useable, flag it as the best
					iBestWeight = pCheck->iWeight();
					pBest = pCheck;
				}
			}

			pCheck = pCheck->m_pNext;
		}
	}

	// if we make it here, we've checked all the weapons and found no useable 
	// weapon in the same catagory as the current weapon. 
	
	// if pBest is null, we didn't find ANYTHING. Shouldn't be possible- should always 
	// at least get the crowbar, but ya never know.
	if ( !pBest )
	{
		return FALSE;
	}

	pPlayer->SwitchWeapon( pBest );

	return TRUE;
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay :: ClientConnected( edict_t *pEntity, const char *pszName, const char *pszAddress, char szRejectReason[ 128 ] )
{
	return TRUE;
}

extern int gmsgSayText;
extern int gmsgGameMode;
extern float g_flSecretWeapons;

void CHalfLifeMultiplay :: UpdateGameMode( CBasePlayer *pPlayer )
{
	MESSAGE_BEGIN( MSG_ONE, gmsgGameMode, NULL, pPlayer->edict() );
		WRITE_BYTE( 0 );  // game mode none
	MESSAGE_END();
}

void CHalfLifeMultiplay :: InitHUD( CBasePlayer *pl )
{


	UTIL_LogPrintf( "\"%s<%i>\" has entered Cold Ice\n",  STRING( pl->pev->netname ), GETPLAYERUSERID( pl->edict() ) );

	UpdateGameMode( pl );

	// sending just one score makes the hud scoreboard active;  otherwise
	// it is just disabled for single play
	MESSAGE_BEGIN( MSG_ONE, gmsgScoreInfo, NULL, pl->edict() );
		WRITE_BYTE( ENTINDEX(pl->edict()) );
		WRITE_SHORT( 0 );
		WRITE_SHORT( 0 );
	MESSAGE_END();

	SendMOTDToClient( pl->edict() );

//	ShowSmartAll ( pl, 0X7, 3, 1, STRING( pl->pev->netname ));

	// loop through all active players and send their score info to the new client
	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		// FIXME:  Probably don't need to cast this just to read m_iDeaths
		CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( plr )
		{
			MESSAGE_BEGIN( MSG_ONE, gmsgScoreInfo, NULL, pl->edict() );
				WRITE_BYTE( i );	// client number
				WRITE_SHORT( plr->pev->frags );
				WRITE_SHORT( plr->m_iDeaths );
			MESSAGE_END();
		}
	}

	if ( g_fGameOver )
	{
		MESSAGE_BEGIN( MSG_ONE, SVC_INTERMISSION, NULL, pl->edict() );
		MESSAGE_END();
	}


	//======================
	// Styles of play ..Decide where to go here!
	//=====================

	if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  )
	{
		pl->StartSpectatorMenu();
	    pl->m_nMenu = Menu_Spec;
	    ShowMenu(pl, 0x1, 0, FALSE,"Cold Ice Server\n\nRocket Style Arena\n1. Join game");
		return;
	}

	if ( CVAR_GET_FLOAT( "automatic_arena" )  > 0  )
	{
		pl->StartSpectatorMenu();
	    ShowMenu(pl, 0x1, 0, FALSE,"Cold Ice Server\n\nAutomatic Style Arena\n\nChoose a auto handgun\n\n1. Mag 60\n2. Full Auto Glock ");
		pl->m_nMenu = Menu_AutoArena1;
		return;
	}
	
	pl->StartSpectatorMenu();
	pl->m_nMenu = Menu_Weap1;
	ShowMenu(pl, 0x7, 0, FALSE,"Welcome to Cold Ice Beta1 2x\n\nDeathmatch/Frag & Gain Activated \n\n Select Close Range Weapon\n1. Survival Knife\n2. Crowbar\n3. Monkey Wrench\n4. Bastardized Sword");

	if ( CVAR_GET_FLOAT( "bot_arena" ) == 2 )
	{
		ShowMenu(pl, 0x1, 10, FALSE,"Cold Ice Server\n\nBot Arena");
	    pl->m_nMenu = Menu_Weap4;
		pl->StopSpectator();
	}

}

//=========================================================
//=========================================================
void CHalfLifeMultiplay :: ClientDisconnected( edict_t *pClient )
{
	if ( pClient )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)CBaseEntity::Instance( pClient );

		if ( pPlayer )
		{
			FireTargets( "game_playerleave", pPlayer, pPlayer, USE_TOGGLE, 0 );
			UTIL_LogPrintf( "\"%s<%i>\" disconnected from Cold Ice\n",  STRING( pPlayer->pev->netname ), GETPLAYERUSERID( pPlayer->edict() ) );


			pPlayer->RemoveAllItems( TRUE );// destroy all of the players weapons and items
		}
	}
}

//=========================================================
//=========================================================
float CHalfLifeMultiplay :: FlPlayerFallDamage( CBasePlayer *pPlayer )
{
	int iFallDamage = (int)CVAR_GET_FLOAT("mp_falldamage");

	switch ( iFallDamage )
	{
	case 1://progressive
		pPlayer->m_flFallVelocity -= PLAYER_MAX_SAFE_FALL_SPEED;
		return pPlayer->m_flFallVelocity * DAMAGE_FOR_FALL_SPEED;
		break;
	default:
	case 0:// fixed
		return 10;
		break;
	}
} 

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::FPlayerCanTakeDamage( CBasePlayer *pPlayer, CBaseEntity *pAttacker )
{
	return TRUE;
}
//=========================================================
//=========================================================

//=========================================================
//=========================================================
void CHalfLifeMultiplay :: PlayerThink( CBasePlayer *pPlayer )
{

	if ( g_fGameOver )
	{
		// check for button presses
		if ( pPlayer->m_afButtonPressed & ( IN_DUCK | IN_ATTACK | IN_ATTACK2 | IN_USE | IN_JUMP ) )
			m_iEndIntermissionButtonHit = TRUE;

		// clear attack/use commands from player
		pPlayer->m_afButtonPressed = 0;
		pPlayer->pev->button = 0;
		pPlayer->m_afButtonReleased = 0;

	}
}
//=========================================================
// Menus For Cold Ice
//=========================================================
BOOL CHalfLifeMultiplay :: ClientCommand( CBasePlayer *pPlayer, const char *pcmd )
{
	if ( FStrEq( pcmd, "menuselect" ) )
	{

		int slot = atoi( CMD_ARGV(1) );

		// select the item from the current menu
		switch(pPlayer->m_nMenu) {
		case Menu_Spec: {
			if(slot == 1){
				pPlayer->StopSpectator();
			} else if (slot == 2) {
				pPlayer->StartSpectator();
					ShowMenu (pPlayer, 0x7, 5, 0, "Currently In Spectator Mode. \n\n Type in the console \"stopboserv\" \n to exit and join the game.  " );
			}
			break;
		}
		case Menu_Weap1: {
			if(slot == 1)
				pPlayer->m_cWeapon1 = "weapon_knife";
			else if(slot == 2)
				pPlayer->m_cWeapon1 = "weapon_crowbar";
			else if(slot == 3)
				pPlayer->m_cWeapon1 = "weapon_wrench";
			else if(slot == 4)
				pPlayer->m_cWeapon1 = "weapon_sword";

			pPlayer->m_nMenu = Menu_Spec;
			ShowMenu(pPlayer, 0x7, 0, FALSE,"Choose a Method of Play\n\n1. Jump In!\n2. Observe Game\n");
			break;
		}
			case Menu_Change1: {
			if(slot == 1)
				pPlayer->m_cWeapon1 = "weapon_knife";
			else if(slot == 2)
				pPlayer->m_cWeapon1 = "weapon_crowbar";
			else if(slot == 3)
				pPlayer->m_cWeapon1 = "weapon_wrench";

			pPlayer->m_nMenu = Menu_Change2;
			ShowMenu(pPlayer, 0x3, 0, FALSE,"Select Weapon\n\n1. 12-Gauge Shotgun\n2. Walter PPK\n");
			break;
		}
		case Menu_Change2: {
			if(slot == 1)
				pPlayer->m_cWeapon2 = "weapon_sshotgun";
			else if(slot == 2)
				pPlayer->m_cWeapon2 = "weapon_ppk";
			pPlayer->m_nMenu = Menu_Change3;
			ShowMenu(pPlayer, 0x3, 0, FALSE,"Select Weapon\n\n1. M-16 A2 Assault Rifle\n2. Uzi 9mm Sub Machinegun\n");	
			break;
		}
		case Menu_Change3: {
			if(slot == 1)
				pPlayer->m_cWeapon3 = "weapon_m16";
			else if(slot == 2)
				pPlayer->m_cWeapon3 = "weapon_uzi";
			pPlayer->m_nMenu = Menu_Change4;
			ShowMenu(pPlayer, 0x3, 0, FALSE,"Choose a High Tech Device\n\n1. High Energy Taser\n2. High Energy Laser Rifle");
			break;
		}
		case Menu_AutoArena1: {
			if(slot == 1)
				pPlayer->m_cWeapon1 = "weapon_mag60";
			else if(slot == 2)
				pPlayer->m_cWeapon1 = "weapon_autoglock";
			pPlayer->m_nMenu = Menu_AutoArena2;
			ShowMenu(pPlayer, 0x7, 0, FALSE,"Chose a Auto Rifle/Submachinegun\n\n1. M-16\n2. Uzi\n3. 9mmAR");
			break;
		}
		case Menu_AutoArena2: {
			if(slot == 1)
				pPlayer->m_cWeapon2 = "weapon_m16";
			else if(slot == 2)
				pPlayer->m_cWeapon2 = "weapon_uzi";
			else if(slot == 3)
				pPlayer->m_cWeapon2 = "weapon_9mmauto";
			pPlayer->m_nMenu = Menu_AutoArena3;
			ShowMenu(pPlayer, 0x7, 0, FALSE,"Choose a high power automatic weapon\n\n1. Chaingun\n2. Twin - Uzis");
			break;
		}
		case Menu_AutoArena3: {
			if(slot == 1)
				pPlayer->m_cWeapon3 = "weapon_chaingun";
			else if(slot == 2)
				pPlayer->m_cWeapon3 = "weapon_doubleuzi";
			pPlayer->m_nMenu = Menu_Spec;
			ShowMenu(pPlayer, 0x7, 0, FALSE,"Choose a Method of Play\n\n1. Jump In!\n2. Observe Game\n");
			break;
		
		}
		}
		return TRUE;
	}
	else if ( FStrEq( pcmd, "stopobserv" ) ) 
	{
		pPlayer->StopSpectator();
	    return TRUE;
	}
   	else if ( FStrEq( pcmd, "startobserv" ) ) 
	{
		pPlayer->StartSpectator();
	    return TRUE;
	}
//==================================================
//	Changes Weapons Support
//==================================================
	 if ( FStrEq( pcmd, "changeweapons" ) && ( CVAR_GET_FLOAT( "rocket_arena" ) == 0 &&  CVAR_GET_FLOAT( "automatic_arena" ) == 0 ) )
	{
           
		ShowMenu (pPlayer, 0x1, 0, 0, "Select Weapons To Swap:\n\nThese weapons will appear\n on the next respawn\n\n1. Show Weapons" );
		// Go from here
		pPlayer->m_nMenu = Menu_Change1;

		return TRUE;
	}
//===================================================
// Special Weapon Cheat 
//===================================================
	else if ( FStrEq( pcmd, "poweron!" ) && ( CVAR_GET_FLOAT( "secretweapons" ) > 0 ) ) 
	{
        pPlayer->GiveNamedItem( "weapon_taser" );
		UTIL_ClientPrintAll( HUD_PRINTCENTER,"Someone Obtained a Taser\n" );
     	return TRUE;
	}
	else if ( FStrEq( pcmd, "smokeagrunt" ) && ( CVAR_GET_FLOAT( "secretweapons" ) > 0) ) 
	{
        pPlayer->GiveNamedItem( "weapon_smokegrenade" );
		UTIL_ClientPrintAll( HUD_PRINTCENTER,"Someone Obtained SmokeBombs\n" );
     	return TRUE;
	}
		else if ( FStrEq( pcmd, "thejoyofcola" ) && ( CVAR_GET_FLOAT( "secretweapons" ) > 0) ) 
	{
        pPlayer->GiveNamedItem( "weapon_pepsibomb" );
		UTIL_ClientPrintAll( HUD_PRINTCENTER,"Someone Obtained Pepsi Bombs\n" );
     	return TRUE;
	}
	return FALSE;
}
//=========================================================
//=========================================================
void CHalfLifeMultiplay :: PlayerSpawn( CBasePlayer *pPlayer )
{
	
	BOOL		addDefault;
	CBaseEntity	*pWeaponEntity = NULL;

	pPlayer->pev->weapons |= (1<<WEAPON_SUIT);
	

	addDefault = TRUE;

	while ( pWeaponEntity = UTIL_FindEntityByClassname( pWeaponEntity, "game_player_equip" ))
	{
		pWeaponEntity->Touch( pPlayer );
		addDefault = FALSE;
	}


	if ( addDefault )
	{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2)
		{
		   pPlayer->GiveNamedItem( "weapon_helilauncher" );
		   return;
		}
		if ( CVAR_GET_FLOAT( "bot_arena" ) == 2)
		{
		   pPlayer->GiveNamedItem( "weapon_knife" );
		   pPlayer->GiveNamedItem( "weapon_sshotgun" );
		   return;
		}
		pPlayer->GiveNamedItem( pPlayer->m_cWeapon1 );   // give them their first choice
		pPlayer->GiveNamedItem( pPlayer->m_cWeapon2 );	 // second
		pPlayer->GiveNamedItem( pPlayer->m_cWeapon3 );   // forth
		pPlayer->GiveNamedItem( pPlayer->m_cWeapon4 );
		pPlayer->GiveAmmo( 16, "ppk", PPK_MAX_CARRY );// 2 full reloads
		pPlayer->GiveAmmo( 2, "timed", TIMED_MAX_CARRY );

	}
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay :: FPlayerCanRespawn( CBasePlayer *pPlayer )
{
	return pPlayer->m_fWantRespawn;
}	

//=========================================================
//=========================================================
float CHalfLifeMultiplay :: FlPlayerSpawnTime( CBasePlayer *pPlayer )
{
	return gpGlobals->time;//now!
}

BOOL CHalfLifeMultiplay :: AllowAutoTargetCrosshair( void )
{
	return ( CVAR_GET_FLOAT( "mp_autocrosshair" ) != 0 );
}

//=========================================================
// IPointsForKill - how many points awarded to anyone
// that kills this player?
//=========================================================
int CHalfLifeMultiplay :: IPointsForKill( CBasePlayer *pAttacker, CBasePlayer *pKilled )
{
	return 1;
}


//=========================================================
// PlayerKilled - someone/something killed this player
//=========================================================
void CHalfLifeMultiplay :: PlayerKilled( CBasePlayer *pVictim, entvars_t *pKiller, entvars_t *pInflictor )
{
	DeathNotice( pVictim, pKiller, pInflictor );

	pVictim->m_iDeaths += 1;

	FireTargets( "game_playerdie", pVictim, pVictim, USE_TOGGLE, 0 );
	CBasePlayer *peKiller = NULL;
	CBaseEntity *ktmp = CBaseEntity::Instance( pKiller );
	if ( ktmp && (ktmp->Classify() == CLASS_PLAYER) )
		peKiller = (CBasePlayer*)ktmp;

	if ( pVictim->pev == pKiller )  
	{  // killed self
		pKiller->frags -= 1;
	}
	else if ( ktmp && ktmp->IsPlayer() )
	{
		// if a player dies in a deathmatch game and the killer is a client, award the killer some points
		pKiller->frags += IPointsForKill( peKiller, pVictim );
		
		FireTargets( "game_playerkill", ktmp, ktmp, USE_TOGGLE, 0 );
	}
	else
	{  // killed by the world
		pKiller->frags -= 1;
	}

	// update the scores
	// killed scores
	MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
		WRITE_BYTE( ENTINDEX(pVictim->edict()) );
		WRITE_SHORT( pVictim->pev->frags );
		WRITE_SHORT( pVictim->m_iDeaths );
	MESSAGE_END();

	// killers score, if it's a player
	CBaseEntity *ep = CBaseEntity::Instance( pKiller );
	if ( ep && ep->Classify() == CLASS_PLAYER )
	{
		CBasePlayer *PK = (CBasePlayer*)ep;

		MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
			WRITE_BYTE( ENTINDEX(PK->edict()) );
			WRITE_SHORT( PK->pev->frags );
			WRITE_SHORT( PK->m_iDeaths );
		MESSAGE_END();

		// let the killer paint another decal as soon as he'd like.
		PK->m_flNextDecalTime = gpGlobals->time;
	}
#ifndef HLDEMO_BUILD
		if ( pVictim->HasNamedPlayerItem("weapon_decoybomb") )
	{
		DeactivateSatchels( pVictim );
			
	}

#endif
}

//=========================================================
// Deathnotice. 
//=========================================================
void CHalfLifeMultiplay::DeathNotice( CBasePlayer *pVictim, entvars_t *pKiller, entvars_t *pevInflictor )
{
	// Work out what killed the player, and send a message to all clients about it
	CBaseEntity *Killer = CBaseEntity::Instance( pKiller );

	const char *killer_weapon_name = "world";		// by default, the player is killed by the world
	int killer_index = 0;
	
	// Hack to fix name change
	char *tau = "30mm Cannon";
	char *gluon = "Grenade Launcher";

	if ( pKiller->flags & FL_CLIENT )
	{
		killer_index = ENTINDEX(ENT(pKiller));
		
		if ( pevInflictor )
		{
			if ( pevInflictor == pKiller )
			{
				// If the inflictor is the killer,  then it must be their current weapon doing the damage
				CBasePlayer *pPlayer = (CBasePlayer*)CBaseEntity::Instance( pKiller );
//				ShowSmart (pVictim, 0x7, 5, 1, "--Frag Notice--\nYou Have fragged " );
//				ShowSmart (pVictim, 0x7, 5, 0, STRING( pVictim->pev->netname ));
				
				if ( pPlayer->m_pActiveItem )
				{
					killer_weapon_name = pPlayer->m_pActiveItem->pszName();
				}
			}
			else
			{
				killer_weapon_name = STRING( pevInflictor->classname );  // it's just that easy
			}
		}
	}
	else
	{
		killer_weapon_name = STRING( pevInflictor->classname );
	}

	// strip the monster_* or weapon_* from the inflictor's classname
	if ( strncmp( killer_weapon_name, "weapon_", 7 ) == 0 )
		killer_weapon_name += 7;
	else if ( strncmp( killer_weapon_name, "monster_", 8 ) == 0 )
		killer_weapon_name += 8;
	else if ( strncmp( killer_weapon_name, "func_", 5 ) == 0 )
		killer_weapon_name += 5;

	MESSAGE_BEGIN( MSG_ALL, gmsgDeathMsg );
		WRITE_BYTE( killer_index );						// the killer
		WRITE_BYTE( ENTINDEX(pVictim->edict()) );		// the victim
		WRITE_STRING( killer_weapon_name );		// what they were killed by (should this be a string?)
	MESSAGE_END();

}

//=========================================================
// PlayerGotWeapon - player has grabbed a weapon that was
// sitting in the world
//=========================================================
void CHalfLifeMultiplay :: PlayerGotWeapon( CBasePlayer *pPlayer, CBasePlayerItem *pWeapon )
{
}

//=========================================================
// FlWeaponRespawnTime - what is the time in the future
// at which this weapon may spawn?
//=========================================================
float CHalfLifeMultiplay :: FlWeaponRespawnTime( CBasePlayerItem *pWeapon )
{
	if ( CVAR_GET_FLOAT("mp_weaponstay") > 0 )
	{
		// make sure it's only certain weapons
		if ( !(pWeapon->iFlags() & ITEM_FLAG_LIMITINWORLD) )
		{
			return gpGlobals->time + 0;		// weapon respawns almost instantly
		}
	}

	return gpGlobals->time + WEAPON_RESPAWN_TIME;
}

// when we are within this close to running out of entities,  items 
// marked with the ITEM_FLAG_LIMITINWORLD will delay their respawn
#define ENTITY_INTOLERANCE	100

//=========================================================
// FlWeaponRespawnTime - Returns 0 if the weapon can respawn 
// now,  otherwise it returns the time at which it can try
// to spawn again.
//=========================================================
float CHalfLifeMultiplay :: FlWeaponTryRespawn( CBasePlayerItem *pWeapon )
{
	if ( pWeapon && pWeapon->m_iId && (pWeapon->iFlags() & ITEM_FLAG_LIMITINWORLD) )
	{
		if ( NUMBER_OF_ENTITIES() < (gpGlobals->maxEntities - ENTITY_INTOLERANCE) )
			return 0;

		// we're past the entity tolerance level,  so delay the respawn
		return FlWeaponRespawnTime( pWeapon );
	}

	return 0;
}

//=========================================================
// VecWeaponRespawnSpot - where should this weapon spawn?
// Some game variations may choose to randomize spawn locations
//=========================================================
Vector CHalfLifeMultiplay :: VecWeaponRespawnSpot( CBasePlayerItem *pWeapon )
{
	return pWeapon->pev->origin;
}

//=========================================================
// WeaponShouldRespawn - any conditions inhibiting the
// respawning of this weapon?
//=========================================================
int CHalfLifeMultiplay :: WeaponShouldRespawn( CBasePlayerItem *pWeapon )
{
	if ( pWeapon->pev->spawnflags & SF_NORESPAWN )
	{
		return GR_WEAPON_RESPAWN_NO;
	}

	return GR_WEAPON_RESPAWN_YES;
}

//=========================================================
// CanHaveWeapon - returns FALSE if the player is not allowed
// to pick up this weapon
//=========================================================
BOOL CHalfLifeMultiplay::CanHavePlayerItem( CBasePlayer *pPlayer, CBasePlayerItem *pItem )
{
	if ( CVAR_GET_FLOAT("mp_weaponstay") > 0 )
	{
		if ( pItem->iFlags() & ITEM_FLAG_LIMITINWORLD )
			return CGameRules::CanHavePlayerItem( pPlayer, pItem );

		// check if the player already has this weapon
		for ( int i = 0 ; i < MAX_ITEM_TYPES ; i++ )
		{
			CBasePlayerItem *it = pPlayer->m_rgpPlayerItems[i];

			while ( it != NULL )
			{
				if ( it->m_iId == pItem->m_iId )
				{
					return FALSE;
				}

				it = it->m_pNext;
			}
		}
	}

	return CGameRules::CanHavePlayerItem( pPlayer, pItem );
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::CanHaveItem( CBasePlayer *pPlayer, CItem *pItem )
{
	return TRUE;
}

//=========================================================
//=========================================================
void CHalfLifeMultiplay::PlayerGotItem( CBasePlayer *pPlayer, CItem *pItem )
{
}

//=========================================================
//=========================================================
int CHalfLifeMultiplay::ItemShouldRespawn( CItem *pItem )
{
	if ( pItem->pev->spawnflags & SF_NORESPAWN )
	{
		return GR_ITEM_RESPAWN_NO;
	}

	return GR_ITEM_RESPAWN_YES;
}


//=========================================================
// At what time in the future may this Item respawn?
//=========================================================
float CHalfLifeMultiplay::FlItemRespawnTime( CItem *pItem )
{
	return gpGlobals->time + ITEM_RESPAWN_TIME;
}

//=========================================================
// Where should this item respawn?
// Some game variations may choose to randomize spawn locations
//=========================================================
Vector CHalfLifeMultiplay::VecItemRespawnSpot( CItem *pItem )
{
	return pItem->pev->origin;
}

//=========================================================
//=========================================================
void CHalfLifeMultiplay::PlayerGotAmmo( CBasePlayer *pPlayer, char *szName, int iCount )
{
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay::IsAllowedToSpawn( CBaseEntity *pEntity )
{
//	if ( pEntity->pev->flags & FL_MONSTER )
//		return FALSE;

	return TRUE;
}

//=========================================================
//=========================================================
int CHalfLifeMultiplay::AmmoShouldRespawn( CBasePlayerAmmo *pAmmo )
{
	if ( pAmmo->pev->spawnflags & SF_NORESPAWN )
	{
		return GR_AMMO_RESPAWN_NO;
	}

	return GR_AMMO_RESPAWN_YES;
}

//=========================================================
//=========================================================
float CHalfLifeMultiplay::FlAmmoRespawnTime( CBasePlayerAmmo *pAmmo )
{
	return gpGlobals->time + AMMO_RESPAWN_TIME;
}

//=========================================================
//=========================================================
Vector CHalfLifeMultiplay::VecAmmoRespawnSpot( CBasePlayerAmmo *pAmmo )
{
	return pAmmo->pev->origin;
}

//=========================================================
//=========================================================
float CHalfLifeMultiplay::FlHealthChargerRechargeTime( void )
{
	return 10;
}


float CHalfLifeMultiplay::FlHEVChargerRechargeTime( void )
{
	return 10;
}

//=========================================================
//=========================================================
int CHalfLifeMultiplay::DeadPlayerWeapons( CBasePlayer *pPlayer )
{
	return GR_PLR_DROP_GUN_ACTIVE;
}

//=========================================================
//=========================================================
int CHalfLifeMultiplay::DeadPlayerAmmo( CBasePlayer *pPlayer )
{
	return GR_PLR_DROP_AMMO_ACTIVE;
}

edict_t *CHalfLifeMultiplay::GetPlayerSpawnSpot( CBasePlayer *pPlayer )
{
	edict_t *pentSpawnSpot = CGameRules::GetPlayerSpawnSpot( pPlayer );	
	if ( IsMultiplayer() && pentSpawnSpot->v.target )
	{
		FireTargets( STRING(pentSpawnSpot->v.target), pPlayer, pPlayer, USE_TOGGLE, 0 );
	}

	return pentSpawnSpot;
}


//=========================================================
//=========================================================
int CHalfLifeMultiplay::PlayerRelationship( CBaseEntity *pPlayer, CBaseEntity *pTarget )
{
	// half life deathmatch has only enemies
	return GR_NOTTEAMMATE;
}

BOOL CHalfLifeMultiplay :: PlayFootstepSounds( CBasePlayer *pl, float fvol )
{
	if ( CVAR_GET_FLOAT( "mp_footsteps" ) == 0 )
		return FALSE;

	if ( pl->IsOnLadder() || pl->pev->velocity.Length2D() > 220 )
		return TRUE;  // only make step sounds in multiplayer if the player is moving fast enough

	return FALSE;
}

BOOL CHalfLifeMultiplay :: FAllowFlashlight( void ) 
{ 
	return CVAR_GET_FLOAT( "mp_flashlight" ) != 0; 
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay :: FAllowMonsters( void )
{
	return ( CVAR_GET_FLOAT( "mp_allowmonsters" ) != 0 );
}

//=========================================================
//======== CHalfLifeMultiplay private functions ===========
#define INTERMISSION_TIME		12

void CHalfLifeMultiplay :: GoToIntermission( void )
{
	if ( g_fGameOver )
		return;  // intermission has already been triggered, so ignore.

	MESSAGE_BEGIN(MSG_ALL, SVC_INTERMISSION);
	MESSAGE_END();

	m_flIntermissionEndTime = gpGlobals->time + INTERMISSION_TIME;
	g_fGameOver = TRUE;
	m_iEndIntermissionButtonHit = FALSE;
}

void CHalfLifeMultiplay :: ChangeLevel( void )
{
	char szNextMap[32];
	char szFirstMapInList[32];
	strcpy( szFirstMapInList, "hldm1" );  // the absolute default level is hldm1

	// find the map to change to

	char *mapcfile = (char*)CVAR_GET_STRING( "mapcyclefile" );
	ASSERT( mapcfile != NULL );
	strcpy( szNextMap, STRING(gpGlobals->mapname) );
	strcpy( szFirstMapInList, STRING(gpGlobals->mapname) );

	int length;
	char *pFileList;
	char *aFileList = pFileList = (char*)LOAD_FILE_FOR_ME( mapcfile, &length );
	if ( pFileList && length )
	{
		// the first map name in the file becomes the default
		sscanf( pFileList, " %32s", szNextMap );
		if ( IS_MAP_VALID( szNextMap ) )
			strcpy( szFirstMapInList, szNextMap );

		// keep pulling mapnames out of the list until the current mapname
		// if the current mapname isn't found,  load the first map in the list
		BOOL next_map_is_it = FALSE;
		while ( 1 )
		{
			while ( *pFileList && isspace( *pFileList ) ) pFileList++; // skip over any whitespace
			if ( !(*pFileList) )
				break;

			char cBuf[32];
			int ret = sscanf( pFileList, " %32s", cBuf );
			// Check the map name is valid
			if ( ret != 1 || *cBuf < 13 )
				break;

			if ( next_map_is_it )
			{
				// check that it is a valid map file
				if ( IS_MAP_VALID( cBuf ) )
				{
					strcpy( szNextMap, cBuf );
					break;
				}
			}

			if ( FStrEq( cBuf, STRING(gpGlobals->mapname) ) )
			{  // we've found our map;  next map is the one to change to
				next_map_is_it = TRUE;
			}

			pFileList += strlen( cBuf );
		}

		FREE_FILE( aFileList );
	}

	if ( !IS_MAP_VALID(szNextMap) )
		strcpy( szNextMap, szFirstMapInList );

	g_fGameOver = TRUE;

	ALERT( at_console, "CHANGE LEVEL: %s\n", szNextMap );
	
	CHANGE_LEVEL( szNextMap, NULL );
}

#define MAX_MOTD_CHUNK	  60
#define MAX_MOTD_LENGTH   (MAX_MOTD_CHUNK * 4)

void CHalfLifeMultiplay :: SendMOTDToClient( edict_t *client )
{
	// read from the MOTD.txt file
	int length, char_count = 0;
	char *pFileList;
	char *aFileList = pFileList = (char*)LOAD_FILE_FOR_ME( "motd.txt", &length );

	// Send the message of the day
	// read it chunk-by-chunk,  and send it in parts

	while ( pFileList && *pFileList && char_count < MAX_MOTD_LENGTH )
	{
		char chunk[MAX_MOTD_CHUNK+1];
		
		if ( strlen( pFileList ) < MAX_MOTD_CHUNK )
		{
			strcpy( chunk, pFileList );
		}
		else
		{
			strncpy( chunk, pFileList, MAX_MOTD_CHUNK );
			chunk[MAX_MOTD_CHUNK] = 0;		// strncpy doesn't always append the null terminator
		}

		char_count += strlen( chunk );
		if ( char_count < MAX_MOTD_LENGTH )
			pFileList = aFileList + char_count; 
		else
			*pFileList = 0;

		MESSAGE_BEGIN( MSG_ONE, gmsgMOTD, NULL, client );
			WRITE_BYTE( *pFileList ? FALSE : TRUE );	// FALSE means there is still more message to come
			WRITE_STRING( chunk );
		MESSAGE_END();
	}

	FREE_FILE( aFileList );
}
	

