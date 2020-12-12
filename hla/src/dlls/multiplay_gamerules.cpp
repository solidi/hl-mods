
/***
*
*	Copyright (c) 1996-2002, Valve LLC. All rights reserved.
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
#include	"voice_gamemgr.h"
#include	"hltv.h"

extern DLL_GLOBAL CGameRules	*g_pGameRules;
extern DLL_GLOBAL BOOL	g_fGameOver;
extern int gmsgDeathMsg;	// client dll messages
extern int gmsgScoreInfo;
extern int gmsgMOTD;
extern int gmsgServerName;

//start hlpro2
#include "vote.h"
extern DLL_GLOBAL int	g_flWeaponArena;
extern DLL_GLOBAL int	g_flWeaponMutators[16];
extern DLL_GLOBAL int	g_TotalWeapons;
extern DLL_GLOBAL int	g_flStartWeapons[16];
extern DLL_GLOBAL int	g_TotalStartWeapons;
extern DLL_GLOBAL BOOL  g_VoteInProgress;
extern DLL_GLOBAL int   g_GameMode;
extern DLL_GLOBAL float g_VoteTimer;
extern DLL_GLOBAL float g_VoteExecute;
extern DLL_GLOBAL BOOL  g_bFatBoy;
extern DLL_GLOBAL BOOL  g_bEarning;
extern DLL_GLOBAL BOOL  g_bStartFull;
extern DLL_GLOBAL BOOL  g_bMaxPack;
//end hlpro2

extern int g_teamplay;

#define ITEM_RESPAWN_TIME	30
#define WEAPON_RESPAWN_TIME	20
#define AMMO_RESPAWN_TIME	20

float g_flIntermissionStartTime = 0;

CVoiceGameMgr	g_VoiceGameMgr;

class CMultiplayGameMgrHelper : public IVoiceGameMgrHelper
{
public:
	virtual bool		CanPlayerHearPlayer(CBasePlayer *pListener, CBasePlayer *pTalker)
	{
		if ( g_teamplay )
		{
			if ( g_pGameRules->PlayerRelationship( pListener, pTalker ) != GR_TEAMMATE )
			{
				return false;
			}
		}

		return true;
	}
};
static CMultiplayGameMgrHelper g_GameMgrHelper;

//*********************************************************
// Rules for the half-life multiplayer game.
//*********************************************************

//start hlpro2
BOOL g_GameInProgress;
int countdown;
BOOL _30secwarning;
BOOL _15secwarning;
BOOL _3secwarning;
float flUpdateTime;
float flTimeLimit;
int SuccessfulRounds;
float g_ShowUsVoting;

void ResetGameMode ( void )
{
	g_GameInProgress = FALSE;

	countdown = 2;

	_30secwarning = FALSE;
	_15secwarning = FALSE;
	_3secwarning = FALSE;

	SuccessfulRounds = 0;
	flUpdateTime = 0;
	flTimeLimit = 0;
}
//end hlpro2

CHalfLifeMultiplay :: CHalfLifeMultiplay()
{
	g_VoiceGameMgr.Init(&g_GameMgrHelper, gpGlobals->maxClients);

	RefreshSkillData();
	m_flIntermissionEndTime = 0;
	g_flIntermissionStartTime = 0;
	
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

		if ( lservercfgfile && lservercfgfile[0] )
		{
			char szCommand[256];
			
			ALERT( at_console, "Executing listen server config file\n" );
			sprintf( szCommand, "exec %s\n", lservercfgfile );
			SERVER_COMMAND( szCommand );
		}
	}

	
	//start hlpro2
	if ( g_VoteInProgress )
		ALERT(at_console, "Preceeding vote has been terminated.\n");
	
	g_ShowUsVoting = gpGlobals->time;

	ResetVote();
	ResetGameMode();
	//end hlpro2
}

BOOL CHalfLifeMultiplay::ClientCommand( CBasePlayer *pPlayer, const char *pcmd )
{
	if(g_VoiceGameMgr.ClientCommand(pPlayer, pcmd))
		return TRUE;

	return CGameRules::ClientCommand(pPlayer, pcmd);
}

//start hlpro2
//=========================================================
// ClientUserInfoChanged
//=========================================================
void CHalfLifeMultiplay::ClientUserInfoChanged( CBasePlayer *pPlayer, char *infobuffer )
{
	// prevent skin/color/model changes
	char *robo = "robo";
	char *recon = "recon";
	char *mdls = g_engfuncs.pfnInfoKeyValue( infobuffer, "model" );

	if ( g_GameMode == GAME_ROBO )
	{
		if ( strcmp( mdls, robo ) || strcmp( mdls, recon ) )
		{
			if ( pPlayer->IsArmoredMan )
				g_engfuncs.pfnSetClientKeyValue( ENTINDEX( pPlayer->edict() ), g_engfuncs.pfnGetInfoKeyBuffer( pPlayer->edict() ), "model", robo );
			else
				g_engfuncs.pfnSetClientKeyValue( ENTINDEX( pPlayer->edict() ), g_engfuncs.pfnGetInfoKeyBuffer( pPlayer->edict() ), "model", recon );

			ClientPrint(pPlayer->pev, HUD_PRINTCONSOLE, "Models changed due to robo arena!\n");

			return;
		}
	}
}
//end hlpro2

//=========================================================
//=========================================================
void CHalfLifeMultiplay::RefreshSkillData( void )
{
// load all default values
	CGameRules::RefreshSkillData();

// override some values for multiplay.

	// suitcharger
	gSkillData.suitchargerCapacity = 30;

	// Crowbar whack
	gSkillData.plrDmgCrowbar = 25;

	// Glock Round
	gSkillData.plrDmg9MM = 12;

	// 357 Round
	gSkillData.plrDmg357 = 40;

	// MP5 Round
	gSkillData.plrDmgMP5 = 12;

	// M203 grenade
	gSkillData.plrDmgM203Grenade = 100;

	// Shotgun buckshot
	gSkillData.plrDmgBuckshot = 20;// fewer pellets in deathmatch

	// Crossbow
	gSkillData.plrDmgCrossbowClient = 20;

	// RPG
	gSkillData.plrDmgRPG = 120;

	// Egon
	gSkillData.plrDmgEgonWide = 20;
	gSkillData.plrDmgEgonNarrow = 10;

	// Hand Grendade
	gSkillData.plrDmgHandGrenade = 100;

	// Satchel Charge
	gSkillData.plrDmgSatchel = 120;

	// Tripmine
	gSkillData.plrDmgTripmine = 150;

	// hornet
	gSkillData.plrDmgHornet = 10;
}

// longest the intermission can last, in seconds
#define MAX_INTERMISSION_TIME		120

extern cvar_t timeleft, fragsleft;

extern cvar_t mp_chattime;


//start hlpro2
int plsArena[64];

// determines current players connected to the server.
// only called when game mode is not in progress.
int CheckClients ( void )
{
	int clients = 0;

	for ( int j = 0; j < 64; j++ )
		plsArena[j] = 0;

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( plr && plr->IsPlayer() )
		{
			clients++;
			plr->IsInArena					= FALSE;
			plr->IsArmoredMan				= FALSE;
			plr->IsIt						= FALSE;
			plr->m_fArmoredManHits			= 0;
			plr->m_flForceToObserverTime	= 0;
			plsArena[clients]				= i;
		}
	}

	return clients;
}

// spawns clients into current game.
void InsertClientsIntoArena ( void )
{
	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( plr && plr->IsPlayer() )
		{ 
			MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
			WRITE_BYTE( ENTINDEX(plr->edict()) );
			if ( g_GameMode == GAME_ARENA  )
				WRITE_SHORT( plr->pev->frags = 0 );
			else if ( g_GameMode == GAME_LMS || g_GameMode == GAME_FREEZETAG )
				WRITE_SHORT( plr->pev->frags = hla_gamefrags.value );
			else
				WRITE_SHORT( 0 );
			WRITE_SHORT( plr->m_iDeaths = 0 );
			WRITE_SHORT( 0 );
			WRITE_SHORT( 0 );
			MESSAGE_END();

			ALERT(at_console, "| %s ", STRING(plr->pev->netname) );

			plr->ExitObserving();
			plr->IsInArena = TRUE;
			plr->m_iGameModePlays++;
		}
	}
}

void SuckAllToSpectator( void )
{
	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( plr && plr->IsPlayer() && !plr->IsSpectator() )
		{ 
			MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
			WRITE_BYTE( ENTINDEX(plr->edict()) );
			WRITE_SHORT( plr->pev->frags = 0 );
			WRITE_SHORT( plr->m_iDeaths = 0 );
			WRITE_SHORT( 0 );
			WRITE_SHORT( 0 );
			MESSAGE_END();

			plr->StartObserving( FALSE );
		}
	}
}

void DisplayWinnersGoods( CBasePlayer *pl )
{
	//increase his win count
	pl->m_iGameModeWins++;

	//and display to the world what he does best!
	UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* [Round #%i Report]\n", SuccessfulRounds ));
	UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s has won the round!\n", STRING(pl->pev->netname)));
	UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s record is %i for %i [%0.0f]\n", STRING(pl->pev->netname), pl->m_iGameModeWins, pl->m_iGameModePlays, ((float)pl->m_iGameModeWins / (float)pl->m_iGameModePlays) * 100 ));	
}

void SetRoundLimits( void )
{
	//enforce a fraglimit always.
	if ( CVAR_GET_FLOAT("hla_gamefrags") <= 0 )
		CVAR_SET_FLOAT("hla_gamefrags", 10);
	
	//enforce a timelimit if given proper value
	if ( CVAR_GET_FLOAT("hla_gametimer") > 0 )
		flTimeLimit = gpGlobals->time + (CVAR_GET_FLOAT("hla_gametimer") * 60.0);

	_30secwarning	= FALSE;
	_15secwarning	= FALSE;
	_3secwarning	= FALSE;
}

void CheckRounds ( void )
{
	SuccessfulRounds++;

	if ( CVAR_GET_FLOAT("hla_gamerounds") > 0 )
	{
		ALERT( at_notice, UTIL_VarArgs("SuccessfulRounds = %i\n", SuccessfulRounds ));
		if ( SuccessfulRounds >= CVAR_GET_FLOAT("hla_gamerounds") )
			g_fGameOver = TRUE;
	}
}

BOOL CheckGameTimer( void )
{
	if ( !_30secwarning && (flTimeLimit - 30) < gpGlobals->time )
	{
		UTIL_ClientPrintAll(HUD_PRINTTALK, "* 30 second warning...\n");
		_30secwarning = TRUE;
	}
	else if ( !_15secwarning && (flTimeLimit - 15) < gpGlobals->time )
	{
		UTIL_ClientPrintAll(HUD_PRINTTALK, "* 15 second warning...\n");
		_15secwarning = TRUE;
	}
	else if ( !_3secwarning && (flTimeLimit - 3) < gpGlobals->time )
	{
		UTIL_ClientPrintAll(HUD_PRINTTALK, "* 3 second warning...\n");
		_3secwarning = TRUE;
	}

//===================================================

	//time is up for this game.

//===================================================

	//time is up
	if ( flTimeLimit < gpGlobals->time )
	{
		int highest = -99999;
		BOOL IsEqual = FALSE;
		CBasePlayer *highballer;

		if ( g_GameMode == GAME_ROBO )
		{
			//find highest damage amount.
			for ( int i = 1; i <= gpGlobals->maxClients; i++ )
			{
				CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

				if ( plr && plr->IsPlayer() && plr->IsInArena )
				{
					if ( highest <= plr->m_fArmoredManHits )
					{
						if ( highest == plr->m_fArmoredManHits )
						{
							IsEqual = TRUE;
							break;
						}

						highest = plr->m_fArmoredManHits;
						highballer = plr;
					}
				}
			}

			if ( !IsEqual )
			{
				CheckRounds();
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Time is up!\n\n%s doled the most damage!\n", STRING(highballer->pev->netname)));
				DisplayWinnersGoods( highballer );
			}
			else
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, "Time is up!\nNo one has won!\n");
			}
		}
		else
		{
			for ( int i = 1; i <= gpGlobals->maxClients; i++ )
			{
				CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

				if ( plr && plr->IsPlayer() && plr->IsInArena )
				{
					if ( highest <= plr->pev->frags )
					{
						if ( highest == plr->pev->frags )
						{
							IsEqual = TRUE;
							break;
						}

						highest = plr->pev->frags;
						highballer = plr;
					}
				}
			}

			if ( !IsEqual )
			{
				CheckRounds();
				DisplayWinnersGoods( highballer );
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Time is Up: %s is the Victor!\n", STRING(highballer->pev->netname)));
			}
			else
				UTIL_ClientPrintAll(HUD_PRINTCENTER, "Time is Up: Match ends in a draw!" );

		}

		g_GameInProgress = FALSE;

		flUpdateTime = gpGlobals->time + 5.0;
		flTimeLimit = 0;
		return TRUE;
	}

	return FALSE;
}

CBasePlayer *pPlayer1;
CBasePlayer *pPlayer2;

void Arena ( void )
{
	if ( flUpdateTime > gpGlobals->time )
		return;

	if ( flTimeLimit )
	{
		if ( CheckGameTimer() )
			return;
	}

	if ( g_GameInProgress )
	{
		//when a player disconnects...
		if ( pPlayer1->HasDisconnected || pPlayer2->HasDisconnected )
		{
			//stop timer / end game.
			flTimeLimit = 0;
			g_GameInProgress = FALSE;

			CheckRounds();

			if ( pPlayer1->HasDisconnected )
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("%s is the victor!\n", STRING(pPlayer2->pev->netname)/*client_name*/ ));
				DisplayWinnersGoods( pPlayer2 );
			}
			else
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("%s is the victor!\n", STRING(pPlayer1->pev->netname)/*client_name*/ ));
				DisplayWinnersGoods( pPlayer1 );
			}

			flUpdateTime = gpGlobals->time + 5.0;
			return;
		}

		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

			//player must exist
			if ( plr && plr->IsPlayer() )
			{
				// is currently in this game of arena.
				// and frags are >= set server value.
				if ( plr->IsInArena && plr->pev->frags >= hla_gamefrags.value )
				{
					//stop timer / end game.
					flTimeLimit = 0;
					g_GameInProgress = FALSE;

					UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("%s is the victor!\n", STRING(plr->pev->netname)/*client_name*/ ));

					CheckRounds();

					DisplayWinnersGoods( plr );
					flUpdateTime = gpGlobals->time + 5.0;
					return;
				}
				else
				{
					//for clients who connected while game in progress.
					if ( plr->IsSpectator() )
						ClientPrint(plr->pev, HUD_PRINTCENTER, UTIL_VarArgs("Arena in progress\n%s (%.0f/%.0f) Vs. %s (%.0f/%.0f)\n", STRING(pPlayer1->pev->netname), pPlayer1->pev->health, pPlayer1->pev->armorvalue, STRING(pPlayer2->pev->netname), pPlayer2->pev->health, pPlayer2->pev->armorvalue /*szVictor1, szVictor2*/));
				}

			}
		}

		flUpdateTime = gpGlobals->time;
		return;
	}

//=======================================================
// execute below if we are waiting for players to join
//=======================================================

	int clients = 0;
	clients = CheckClients();

	ALERT( at_notice, UTIL_VarArgs("CheckClients(): %i\n", clients ));

	if ( clients > 1 )
	{
		if ( countdown >= 0 )
		{
			countdown--;
			UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Prepare for Arena battle\n\n%i...\n", countdown+2));
			flUpdateTime = gpGlobals->time + 1.0;
			return;
		}

		ALERT(at_console, "Players in Arena: ");

		int player1 = plsArena[RANDOM_LONG( 1, clients )];
		int player2 = plsArena[RANDOM_LONG( 1, clients )];

		while ( player1 == player2 )
		{
			//player1 = RANDOM_LONG( 1, plsArena[clients] );
			player2 = RANDOM_LONG( 1, plsArena[RANDOM_LONG( 1, clients )] );
		}

		ALERT( at_notice, UTIL_VarArgs("player1: %i | player2: %i \n", player1, player2 ));

		pPlayer1 = (CBasePlayer *)UTIL_PlayerByIndex( player1 );
		pPlayer2 = (CBasePlayer *)UTIL_PlayerByIndex( player2 );

		//frags + time
		SetRoundLimits();

		//Should really be using InsertClientsIntoArena...
		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

			if ( plr && plr->IsPlayer() )
			{ 
				if ( player1 == i || player2 == i )
				{
					MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
					WRITE_BYTE( ENTINDEX(plr->edict()) );
					WRITE_SHORT( plr->pev->frags = 0 );
					WRITE_SHORT( plr->m_iDeaths = 0 );
					WRITE_SHORT( 0 );
					WRITE_SHORT( 0 );
					MESSAGE_END();

					ALERT(at_console, "| %s ", STRING(plr->pev->netname) );

					plr->ExitObserving();
					plr->IsInArena = TRUE;
					plr->m_iGameModePlays++;
				}
				else
				{
					if ( !plr->IsSpectator() )
					{
						//just incase player played previous round
						MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
						WRITE_BYTE( ENTINDEX(plr->edict()) );
						WRITE_SHORT( plr->pev->frags = 0 );
						WRITE_SHORT( plr->m_iDeaths = 0 );
						WRITE_SHORT( 0 );
						WRITE_SHORT( 0 );
						MESSAGE_END();

						plr->StartObserving( FALSE );
					}
				}
			}
		}

		ALERT(at_console, "\n");

		countdown = 2;

		g_GameInProgress = TRUE;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Arena has begun!\n\n%s Vs. %s", STRING(pPlayer1->pev->netname), STRING(pPlayer2->pev->netname) /*szVictor1, szVictor2*/));
	}
	else
	{
		SuckAllToSpectator();
		flTimeLimit = 0;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, "Waiting for other players to begin\n\n'Arena'\n");
	}


	flUpdateTime = gpGlobals->time + 5.0;
}

void LMS ( void )
{
	if ( flUpdateTime > gpGlobals->time )
		return;

	if ( flTimeLimit )
	{
		if ( CheckGameTimer() )
			return;
	}

//===================================================

	//access this when game is in progress.
	//we are checking for the last man here.

//===================================================

	if ( g_GameInProgress )
	{
		int clients_alive = 0;
		int client_index = 0;
		const char *client_name;

		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

			//player must exist, and must be alive
			if ( plr && plr->IsPlayer() )
			{
				//player cannot be disconnected client
				//and is currently in this game of LMS.
				if ( plr->IsInArena && plr->pev->frags > 0 )
				{
					clients_alive++;
					client_index = i;
					client_name = STRING(plr->pev->netname);
				}
				else
				{
					//for clients who connected while game in progress.
					if ( plr->IsAlive() )
						ClientPrint(plr->pev, HUD_PRINTCENTER, "LMS round in progress.\n");
				}

			}
		}

		//found victor / or draw.
		if ( clients_alive <= 1 )
		{
			//stop timer / end game.
			flTimeLimit = 0;
			g_GameInProgress = FALSE;

			if ( clients_alive == 1 )
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("%s is the last man standing!\n", client_name ));

				CheckRounds();

				CBasePlayer *pl = (CBasePlayer *)UTIL_PlayerByIndex( client_index );
				DisplayWinnersGoods( pl );
			}	
			else
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, "No man is left standing!\n");
			}

			flUpdateTime = gpGlobals->time + 5.0;
			return;
		}

		flUpdateTime = gpGlobals->time;
		return;
	}

//===================================================

	//if the game is not in progress
	//make sure there is more than one player
	//dub and recheck then spawn the 
	//players out of observer.

//===================================================

	int clients = 0;
	clients = CheckClients();

	if ( clients > 1 )
	{
		if ( countdown >= 0 )
		{
			countdown--;
			UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Prepare for LMS battle\n\n%i...\n", countdown+2));
			flUpdateTime = gpGlobals->time + 1.0;
			return;
		}

		ALERT(at_console, "Players in LMS: ");

		//frags + time.
		SetRoundLimits();
		InsertClientsIntoArena();
		ALERT(at_console, "\n");

		countdown = 2;
		
		g_GameInProgress = TRUE;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, "Last man standing has begun!\n");
	}
	else
	{
		SuckAllToSpectator();
		flTimeLimit = 0;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, "Waiting for other players to begin\n\n'LMS'\n");
	}

	flUpdateTime = gpGlobals->time + 5.0;
}

CBasePlayer *pArmoredMan;

void Robo ( void )
{
	if ( flUpdateTime > gpGlobals->time )
		return;

	if ( flTimeLimit )
	{
		if ( CheckGameTimer() )
			return;
	}

	if ( g_GameInProgress )
	{
		int clients_alive = 0;

		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

			if ( plr && plr->IsPlayer() )
			{
				if ( plr->IsInArena && plr->IsAlive() )
				{
					clients_alive++; 
				}
				else
				{
					//for clients who connected while game in progress.
					if ( plr->IsSpectator() )
						ClientPrint(plr->pev, HUD_PRINTCENTER, UTIL_VarArgs("Robo Arena in progress\nRobo: %s (%.0f/%.0f)\n", STRING(pArmoredMan->pev->netname), pArmoredMan->pev->health, pArmoredMan->pev->armorvalue ));
				}

			}
		}

		//recon all dead or armored man defeated.
		if ( clients_alive <= 1 || !pArmoredMan->IsAlive() )
		{
			//stop timer / end game.
			flTimeLimit = 0;
			g_GameInProgress = FALSE;

			//hack to allow for logical code below.
			if ( pArmoredMan->HasDisconnected )
				pArmoredMan->pev->health = 0;

			//armored man is alive.
			if ( pArmoredMan->IsAlive() && clients_alive == 1 )
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("%s has defeated all Recon!\n", STRING(pArmoredMan->pev->netname) ));

				CheckRounds();

				DisplayWinnersGoods( pArmoredMan );
			}
			//the man has been killed.
			else if ( !pArmoredMan->IsAlive() )
			{
				//find highest damage amount.
				float highest = -99999;
				BOOL IsEqual = FALSE;
				CBasePlayer *highballer;

				for ( int i = 1; i <= gpGlobals->maxClients; i++ )
				{
					CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

					if ( plr && plr->IsPlayer() && plr->IsInArena )
					{
						if ( highest <= plr->m_fArmoredManHits )
						{
							if ( highest == plr->m_fArmoredManHits )
							{
								IsEqual = TRUE;
								break;
							}

							highest = plr->m_fArmoredManHits;
							highballer = plr;
						}
					}
				}


				if ( !IsEqual )
				{
					CheckRounds();
					UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("The Robo has been destroyed!\n\n%s doled the most damage!\n", STRING(highballer->pev->netname)));
					DisplayWinnersGoods( highballer );
				}
				else
				{
					UTIL_ClientPrintAll(HUD_PRINTCENTER, "The Robo has been destroyed!\n");
				}

			}
			//everyone died.
			else
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, "Everyone has been killed!\n");
			}

			flUpdateTime = gpGlobals->time + 5.0;
			return;
		}

		flUpdateTime = gpGlobals->time;
		return;
	}


	int clients = 0;
	clients = CheckClients();

	if ( clients > 1 )
	{
		if ( countdown >= 0 )
		{
			countdown--;
			UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Prepare for Robo battle\n\n%i...\n", countdown+2));
			flUpdateTime = gpGlobals->time + 1.0;
			return;
		}

		ALERT(at_console, "Players in Robo: ");

		//frags + time.
		SetRoundLimits();
				
		int armoredman = plsArena[RANDOM_LONG( 1, clients )];

		pArmoredMan = (CBasePlayer *)UTIL_PlayerByIndex( armoredman );
		pArmoredMan->IsArmoredMan = TRUE;

		InsertClientsIntoArena();

		ALERT(at_console, "\n");

		countdown = 2;
		
		g_GameInProgress = TRUE;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Robo Arena has begun!\n%s is the robo!\n", STRING(pArmoredMan->pev->netname)));
	}
	else
	{
		SuckAllToSpectator();
		flTimeLimit = 0;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, "Waiting for other players to begin\n\n'Robo'\n");
	}

	flUpdateTime = gpGlobals->time + 5.0;
}

void FreezeTag ( void )
{
	if ( flUpdateTime > gpGlobals->time )
		return;

	if ( flTimeLimit )
	{
		if ( CheckGameTimer() )
			return;
	}

	if ( g_GameInProgress )
	{
		int clients_alive = 0;

		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

			if ( plr && plr->IsPlayer() )
			{
				if ( plr->IsIt )
					pArmoredMan = plr;

				if ( plr->IsInArena && plr->pev->frags > 0 )
				{
					clients_alive++; 
				}
				else
				{
					//for clients who connected while game in progress.
					if ( plr->IsSpectator() )
						ClientPrint(plr->pev, HUD_PRINTCENTER, UTIL_VarArgs("Freeze Tag in progress\nIt: %s (%.0f/%.0f)\n", STRING(pArmoredMan->pev->netname), pArmoredMan->pev->health, pArmoredMan->pev->armorvalue ));
				}

			}
		}

		//victor has been found
		if ( clients_alive <= 2 )
		{
			//stop timer / end game.
			flTimeLimit = 0;
			g_GameInProgress = FALSE;

			//find the highest frags
			float highest = -99999;
			BOOL IsEqual = FALSE;
			CBasePlayer *highballer;

			for ( int i = 1; i <= gpGlobals->maxClients; i++ )
			{
				CBasePlayer *plr = (CBasePlayer *)UTIL_PlayerByIndex( i );

				if ( plr && plr->IsPlayer() && plr->IsInArena )
				{
					if ( highest <= plr->pev->frags )
					{
						if ( highest == plr->pev->frags )
						{
							IsEqual = TRUE;
							break;
						}

						highest = plr->pev->frags;
						highballer = plr;
					}
				}
			}


			if ( !IsEqual )
			{
				CheckRounds();
				UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("%s is the survivor!\n", STRING(highballer->pev->netname)));
				DisplayWinnersGoods( highballer );
			}
			else
			{
				UTIL_ClientPrintAll(HUD_PRINTCENTER, "Match ends in a draw!\n");
			}

			flUpdateTime = gpGlobals->time + 5.0;
			return;
		}

		flUpdateTime = gpGlobals->time;
		return;
	}


	int clients = 0;
	clients = CheckClients();

	if ( clients > 2 )
	{
		if ( countdown >= 0 )
		{
			countdown--;
			UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Prepare for Freeze Tag\n\n%i...\n", countdown+2));
			flUpdateTime = gpGlobals->time + 1.0;
			return;
		}

		ALERT(at_console, "Players in FreezeTag: ");

		//frags + time.
		SetRoundLimits();
				
		int it = plsArena[RANDOM_LONG( 1, clients )];

		pArmoredMan = (CBasePlayer *)UTIL_PlayerByIndex( it );
		pArmoredMan->IsIt = TRUE;

		InsertClientsIntoArena();

		ALERT(at_console, "\n");

		countdown = 2;
		
		g_GameInProgress = TRUE;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("Freeze Tag has begun!\n%s is It!\n", STRING(pArmoredMan->pev->netname)));
	}
	else
	{
		SuckAllToSpectator();
		flTimeLimit = 0;
		UTIL_ClientPrintAll(HUD_PRINTCENTER, "Waiting for other players to begin\n\n'Freeze Tag'\n");
	}

	flUpdateTime = gpGlobals->time + 5.0;
}
//end hlpro2

//=========================================================
//=========================================================
void CHalfLifeMultiplay :: Think ( void )
{
	g_VoiceGameMgr.Update(gpGlobals->frametime);

	///// Check game rules /////
	static int last_frags;
	static int last_time;

	int frags_remaining = 0;
	int time_remaining = 0;

	if ( g_fGameOver )   // someone else quit the game already
	{
		// bounds check
		int time = (int)CVAR_GET_FLOAT( "mp_chattime" );
		if ( time < 1 )
			CVAR_SET_STRING( "mp_chattime", "1" );
		else if ( time > MAX_INTERMISSION_TIME )
			CVAR_SET_STRING( "mp_chattime", UTIL_dtos1( MAX_INTERMISSION_TIME ) );

		m_flIntermissionEndTime = g_flIntermissionStartTime + mp_chattime.value;

		// check to see if we should change levels now
		if ( m_flIntermissionEndTime < gpGlobals->time )
		{
			if ( m_iEndIntermissionButtonHit  // check that someone has pressed a key, or the max intermission time is over
				|| ( ( g_flIntermissionStartTime + MAX_INTERMISSION_TIME ) < gpGlobals->time) ) 
				ChangeLevel(); // intermission is over
		}

		return;
	}

	//start hlpro2
	if ( g_VoteTimer && g_VoteTimer < gpGlobals->time )
	{
		TallyVote();
		g_VoteTimer = 0;
	}

	if ( g_VoteExecute && g_VoteExecute < gpGlobals->time )
	{
		ExecuteVote();
	}

	if ( g_ShowUsVoting < gpGlobals->time )
	{
		UTIL_ClientPrintAll(HUD_PRINTTALK, "* Voting is enabled on this server.\n" );
		UTIL_ClientPrintAll(HUD_PRINTTALK, "* vote_kick <id or name>, vote_ban <id or name>, vote_map <map>\n" );
		UTIL_ClientPrintAll(HUD_PRINTTALK, "* vote_extend, vote_game <mode>, vote_mutator <mutator>.\n" );
		g_ShowUsVoting = gpGlobals->time + RANDOM_FLOAT(300.0, 350.0);
	}

	if ( g_GameMode == GAME_FREEZETAG )
	{
		FreezeTag();
		return;
	}
	else if ( g_GameMode == GAME_ROBO )
	{
		Robo();
		return;
	}
	else if ( g_GameMode == GAME_LMS )
	{
		LMS();
		return;
	}
	else if ( g_GameMode == GAME_ARENA )
	{
		Arena();
		return;
	}
	//end hlpro2

	float flTimeLimit = timelimit.value * 60;
	float flFragLimit = fraglimit.value;

	time_remaining = (int)(flTimeLimit ? ( flTimeLimit - gpGlobals->time ) : 0);
	
	if ( flTimeLimit != 0 && gpGlobals->time >= flTimeLimit )
	{
		GoToIntermission();
		return;
	}

	if ( flFragLimit )
	{
		int bestfrags = 9999;
		int remain;

		// check if any player is over the frag limit
		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBaseEntity *pPlayer = UTIL_PlayerByIndex( i );

			if ( pPlayer && pPlayer->pev->frags >= flFragLimit )
			{
				GoToIntermission();
				return;
			}


			if ( pPlayer )
			{
				remain = flFragLimit - pPlayer->pev->frags;
				if ( remain < bestfrags )
				{
					bestfrags = remain;
				}
			}

		}
		frags_remaining = bestfrags;
	}

	// Updates when frags change
	if ( frags_remaining != last_frags )
	{
		g_engfuncs.pfnCvar_DirectSet( &fragsleft, UTIL_VarArgs( "%i", frags_remaining ) );
	}

	// Updates once per second
	if ( timeleft.value != last_time )
	{
		g_engfuncs.pfnCvar_DirectSet( &timeleft, UTIL_VarArgs( "%i", time_remaining ) );
	}

	last_frags = frags_remaining;
	last_time  = time_remaining;
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
	g_VoiceGameMgr.ClientConnected(pEntity);
	return TRUE;
}

extern int gmsgSayText;
extern int gmsgGameMode;

void CHalfLifeMultiplay :: UpdateGameMode( CBasePlayer *pPlayer )
{
	MESSAGE_BEGIN( MSG_ONE, gmsgGameMode, NULL, pPlayer->edict() );
		WRITE_BYTE( 0 );  // game mode none
	MESSAGE_END();
}

void CHalfLifeMultiplay :: InitHUD( CBasePlayer *pl )
{
	// notify other clients of player joining the game
	UTIL_ClientPrintAll( HUD_PRINTNOTIFY, UTIL_VarArgs( "%s has joined the game\n", 
		( pl->pev->netname && STRING(pl->pev->netname)[0] != 0 ) ? STRING(pl->pev->netname) : "unconnected" ) );

	// team match?
	if ( g_teamplay )
	{
		UTIL_LogPrintf( "\"%s<%i><%s><%s>\" entered the game\n",  
			STRING( pl->pev->netname ), 
			GETPLAYERUSERID( pl->edict() ),
			GETPLAYERAUTHID( pl->edict() ),
			g_engfuncs.pfnInfoKeyValue( g_engfuncs.pfnGetInfoKeyBuffer( pl->edict() ), "model" ) );
	}
	else
	{
		UTIL_LogPrintf( "\"%s<%i><%s><%i>\" entered the game\n",  
			STRING( pl->pev->netname ), 
			GETPLAYERUSERID( pl->edict() ),
			GETPLAYERAUTHID( pl->edict() ),
			GETPLAYERUSERID( pl->edict() ) );
	}

	UpdateGameMode( pl );

	// sending just one score makes the hud scoreboard active;  otherwise
	// it is just disabled for single play
	MESSAGE_BEGIN( MSG_ONE, gmsgScoreInfo, NULL, pl->edict() );
		WRITE_BYTE( ENTINDEX(pl->edict()) );
		WRITE_SHORT( 0 );
		WRITE_SHORT( 0 );
		WRITE_SHORT( 0 );
		WRITE_SHORT( 0 );
	MESSAGE_END();

	SendMOTDToClient( pl->edict() );

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
				WRITE_SHORT( 0 );
				WRITE_SHORT( GetTeamIndex( plr->m_szTeamName ) + 1 );
			MESSAGE_END();
		}
	}

	if ( g_fGameOver )
	{
		MESSAGE_BEGIN( MSG_ONE, SVC_INTERMISSION, NULL, pl->edict() );
		MESSAGE_END();
	}

	//start hlpro2
	pl->m_iGameModeWins = pl->m_iGameModePlays = 0;
	pl->m_bWeaponStats = TRUE;

	//if ( !pl->IsFinishedIntroSpectating )
	pl->StartObserving( FALSE );	

	//if ( !g_GameMode )
	//	pl->m_flSpawnTime = gpGlobals->time + 10.0;

	pl->m_fDisplayMessage = gpGlobals->time + 1.0;

	for ( i = 0; i < 16; i++ )
		pl->m_iLandedHits[i] = pl->m_iMissedHits[i] = pl->m_iWeaponKills[i];
	pl->m_iTotalKills = 0;
	//end hlpro2
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

			// team match?
			if ( g_teamplay )
			{
				UTIL_LogPrintf( "\"%s<%i><%s><%s>\" disconnected\n",  
					STRING( pPlayer->pev->netname ), 
					GETPLAYERUSERID( pPlayer->edict() ),
					GETPLAYERAUTHID( pPlayer->edict() ),
					g_engfuncs.pfnInfoKeyValue( g_engfuncs.pfnGetInfoKeyBuffer( pPlayer->edict() ), "model" ) );
			}
			else
			{
				UTIL_LogPrintf( "\"%s<%i><%s><%i>\" disconnected\n",  
					STRING( pPlayer->pev->netname ), 
					GETPLAYERUSERID( pPlayer->edict() ),
					GETPLAYERAUTHID( pPlayer->edict() ),
					GETPLAYERUSERID( pPlayer->edict() ) );
			}

			//start hlpro2
			pPlayer->HasDisconnected = TRUE;

			if ( !pPlayer->IsSpectator() )
			{
				MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
				WRITE_BYTE( TE_TELEPORT	); 
				WRITE_COORD(pPlayer->pev->origin.x);
				WRITE_COORD(pPlayer->pev->origin.y);
				WRITE_COORD(pPlayer->pev->origin.z);
				MESSAGE_END();
			}

			if ( g_GameInProgress )
			{
				if ( pPlayer->IsInArena && !pPlayer->IsSpectator() )
				{
					pPlayer->IsInArena = FALSE;

					//find a new It
					// UNDONE ... 

					flUpdateTime = gpGlobals->time + 3.0;
					UTIL_ClientPrintAll(HUD_PRINTCENTER, UTIL_VarArgs("* %s has left the arena!\n", STRING(pPlayer->pev->netname)));
				}
			}
			//end hlpro2

			pPlayer->RemoveAllItems( TRUE );// destroy all of the players weapons and items
		}
	}
}

//=========================================================
//=========================================================
float CHalfLifeMultiplay :: FlPlayerFallDamage( CBasePlayer *pPlayer )
{
	int iFallDamage = (int)falldamage.value;

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
	//start hlpro2
	if ( g_GameMode == GAME_FREEZETAG )
	{
		if ( pPlayer->m_flFrozenTime && ((CBasePlayer *)pAttacker)->IsIt )
			return FALSE;
	}
	//end hlpro2

	return TRUE;
}

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
//=========================================================
void CHalfLifeMultiplay :: PlayerSpawn( CBasePlayer *pPlayer )
{
	BOOL		addDefault;
	CBaseEntity	*pWeaponEntity = NULL;

	pPlayer->pev->weapons |= (1<<WEAPON_SUIT);
	
	//start hlpro2
	addDefault = pPlayer->IsFinishedIntroSpectating ? TRUE : FALSE;
	pPlayer->IsFinishedIntroSpectating = TRUE;

	if ( addDefault )
	{
		while ( pWeaponEntity = UTIL_FindEntityByClassname( pWeaponEntity, "game_player_equip" ))
		{
			pWeaponEntity->Touch( pPlayer );
			addDefault = FALSE;
		}

		if ( ( g_bStartFull || g_GameMode == GAME_LMS || g_GameMode == GAME_ARENA || pPlayer->IsArmoredMan ) && pPlayer->IsFinishedIntroSpectating )
		{
			pPlayer->GiveAllItems();
			return;
		}

		if ( g_GameMode == GAME_FREEZETAG )
		{
			if ( pPlayer->IsIt )
			{
				pPlayer->m_fLongJump = TRUE;
				g_engfuncs.pfnSetPhysicsKeyValue( pPlayer->edict(), "slj", "1" );
				pPlayer->GiveNamedItem( "weapon_crowbar" );
				return;
			}
		}

		if ( g_flWeaponArena  /* && g_flWeaponArena != 16 */ )
		{
			for ( int j = 0; j < g_TotalWeapons; j++ )
			{
				switch ( g_flWeaponMutators[j] )
				{
					case WEAPON_CROWBAR:		pPlayer->GiveNamedItem( "weapon_crowbar" );break;
					case WEAPON_GLOCK:			pPlayer->GiveNamedItem( "weapon_9mmhandgun" );break;
					case WEAPON_CROSSBOW:		pPlayer->GiveNamedItem( "weapon_crossbow" );break;
					case WEAPON_PYTHON:			pPlayer->GiveNamedItem( "weapon_357" );break;
					case WEAPON_EGON:			pPlayer->GiveNamedItem( "weapon_egon" );break;
					case WEAPON_GAUSS:			pPlayer->GiveNamedItem( "weapon_gauss" );break;
					case WEAPON_RPG:			pPlayer->GiveNamedItem( "weapon_rpg" );break;
					case WEAPON_SHOTGUN:		pPlayer->GiveNamedItem( "weapon_shotgun" );break;
					case WEAPON_MP5:			pPlayer->GiveNamedItem( "weapon_9mmAR" );break;
					case WEAPON_HORNETGUN:		pPlayer->GiveNamedItem( "weapon_hornetgun" );break;
					case WEAPON_HANDGRENADE:	pPlayer->GiveNamedItem( "weapon_handgrenade" );break;
					case WEAPON_TRIPMINE:		pPlayer->GiveNamedItem( "weapon_tripmine" );break;
					case WEAPON_SATCHEL:		pPlayer->GiveNamedItem( "weapon_satchel" );break;
					case WEAPON_SNARK:			pPlayer->GiveNamedItem( "weapon_snark" );break;
					default:					pPlayer->GiveNamedItem( "weapon_crowbar" );
				}
			}
		}
		else
		{
			if ( g_bEarning )
			{
				int client_frags = pPlayer->pev->frags;

				pPlayer->GiveNamedItem( "weapon_crowbar" );

				if ( client_frags >= 2 ) 
				{
					pPlayer->GiveNamedItem( "weapon_9mmhandgun" );
					pPlayer->GiveAmmo( 250, "9mm", _9MM_MAX_CARRY );
				}

				if ( client_frags >= 4 ) 
				{
					pPlayer->GiveNamedItem( "weapon_python" );
					pPlayer->GiveAmmo( 36, "357", _357_MAX_CARRY );
				}

				if ( client_frags == 6 )
					pPlayer->GiveNamedItem( "weapon_9mmAR" );

				if ( client_frags == 8 ) 
				{
					pPlayer->GiveNamedItem( "weapon_shotgun" );
					pPlayer->GiveAmmo( 125, "buckshot", BUCKSHOT_MAX_CARRY );
				}

				if ( client_frags == 10 ) 
				{
					pPlayer->GiveNamedItem( "weapon_crossbow" );
					pPlayer->GiveAmmo( 50, "bolts", BOLT_MAX_CARRY );
				}

				if ( client_frags == 12 ) 
				{
					pPlayer->GiveNamedItem( "weapon_rpg" );
					pPlayer->GiveAmmo( 5, "rockets", ROCKET_MAX_CARRY );
				}

				if ( client_frags == 14 ) 
				{
					pPlayer->GiveNamedItem( "weapon_gauss" );
					pPlayer->GiveAmmo( 100, "uranium", URANIUM_MAX_CARRY );
				}

				if ( client_frags == 16 )
					pPlayer->GiveNamedItem( "weapon_hornetgun" );

				if ( client_frags == 18 )
					pPlayer->GiveNamedItem( "weapon_egon" );
			}
			else
			{
				//pPlayer->GiveNamedItem( "weapon_crowbar" );
				//pPlayer->GiveNamedItem( "weapon_9mmhandgun" );
				pPlayer->GiveAmmo( 68, "9mm", _9MM_MAX_CARRY );// 4 full reloads

				for ( int j = 0; j < g_TotalStartWeapons; j++ )
				{
					switch ( g_flStartWeapons[j] )
					{
						case WEAPON_CROWBAR:		pPlayer->GiveNamedItem( "weapon_crowbar" );break;
						case WEAPON_GLOCK:			pPlayer->GiveNamedItem( "weapon_9mmhandgun" );break;
						case WEAPON_CROSSBOW:		pPlayer->GiveNamedItem( "weapon_crossbow" );break;
						case WEAPON_PYTHON:			pPlayer->GiveNamedItem( "weapon_357" );break;
						case WEAPON_EGON:			pPlayer->GiveNamedItem( "weapon_egon" );break;
						case WEAPON_GAUSS:			pPlayer->GiveNamedItem( "weapon_gauss" );break;
						case WEAPON_RPG:			pPlayer->GiveNamedItem( "weapon_rpg" );break;
						case WEAPON_SHOTGUN:		pPlayer->GiveNamedItem( "weapon_shotgun" );break;
						case WEAPON_MP5:			pPlayer->GiveNamedItem( "weapon_9mmAR" );break;
						case WEAPON_HORNETGUN:		pPlayer->GiveNamedItem( "weapon_hornetgun" );break;
						case WEAPON_HANDGRENADE:	pPlayer->GiveNamedItem( "weapon_handgrenade" );break;
						case WEAPON_TRIPMINE:		pPlayer->GiveNamedItem( "weapon_tripmine" );break;
						case WEAPON_SATCHEL:		pPlayer->GiveNamedItem( "weapon_satchel" );break;
						case WEAPON_SNARK:			pPlayer->GiveNamedItem( "weapon_snark" );break;
						default:					pPlayer->GiveNamedItem( "weapon_crowbar" );
					}
				}
			}
		}
		//end hlpro2
	}

}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay :: FPlayerCanRespawn( CBasePlayer *pPlayer )
{
	return TRUE;
}

//=========================================================
//=========================================================
float CHalfLifeMultiplay :: FlPlayerSpawnTime( CBasePlayer *pPlayer )
{
	return gpGlobals->time;//now!
}

BOOL CHalfLifeMultiplay :: AllowAutoTargetCrosshair( void )
{
	return ( aimcrosshair.value != 0 );
}

//=========================================================
// IPointsForKill - how many points awarded to anyone
// that kills this player?
//=========================================================
int CHalfLifeMultiplay :: IPointsForKill( CBasePlayer *pAttacker, CBasePlayer *pKilled )
{
	//start hlpro2
	if ( pAttacker->m_fHasRune == RUNE_FRAG && pAttacker != pKilled )
		return 2;
	else if ( g_GameMode == GAME_LMS || g_GameMode == GAME_FREEZETAG )
		return 0;
	else
		return 1;
	//end hlpro2
}


//=========================================================
// PlayerKilled - someone/something killed this player
//=========================================================
void CHalfLifeMultiplay :: PlayerKilled( CBasePlayer *pVictim, entvars_t *pKiller, entvars_t *pInflictor )
{
	DeathNotice( pVictim, pKiller, pInflictor );

	//start hlpro2
	if ( g_GameInProgress )
	{
		if ( g_GameMode == GAME_ARENA )
		{
			float result = (hla_gamefrags.value - pKiller->frags) - 1;

			if ( result > 0 )
			{
				//where killer has been on top.
				if ( pKiller->frags > pVictim->pev->frags )
				{
					ClientPrint(pKiller, HUD_PRINTCENTER, UTIL_VarArgs("%0.0f frags to go...\n", result));
					UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s has %0.0f frags to go!\n", STRING(pKiller->netname), result));
				}
				else if ( pKiller->frags == pVictim->pev->frags )
				{
					//taken the lead.
					if ( pKiller != pVictim->pev )
					{
						ClientPrint(pKiller, HUD_PRINTCENTER, "You have taken the lead!\n");
						UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s has taken the lead!\n", STRING(pKiller->netname)));
					}
					else
					{
						//due to pKiller's own fault.
						if ( pKiller == pPlayer2->pev )
						{
							if ( pPlayer1->pev->frags == pKiller->frags )
							{
								ClientPrint(pPlayer1->pev, HUD_PRINTCENTER, "You have taken the lead!\n");
								UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s has taken the lead!\n", STRING(pPlayer1->pev->netname)));
							}
						}
						else
						{
							if ( pPlayer2->pev->frags == pKiller->frags )
							{
								ClientPrint(pPlayer2->pev, HUD_PRINTCENTER, "You have taken the lead!\n");
								UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s has taken the lead!\n", STRING(pPlayer2->pev->netname)));
							}
						}
					}
				}
				else	//love this.
				{
					UTIL_ClientPrintAll(HUD_PRINTTALK, "* Game is tied!\n");
				}				
			}
		}
		else if ( g_GameMode == GAME_LMS )
		{
			pVictim->pev->frags -= 1;

			if ( !pVictim->pev->frags )
				UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* %s has been eliminated from the round!\n", STRING(pVictim->pev->netname)));
		}
		else if ( g_GameMode == GAME_ROBO )
		{
			if ( !pVictim->IsArmoredMan )
				UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* Recon %s has been eliminated from the round!\n", STRING(pVictim->pev->netname)));
		}
	}
	//end hlpro2

	pVictim->m_iDeaths += 1;


	FireTargets( "game_playerdie", pVictim, pVictim, USE_TOGGLE, 0 );
	CBasePlayer *peKiller = NULL;
	CBaseEntity *ktmp = CBaseEntity::Instance( pKiller );
	if ( ktmp && (ktmp->Classify() == CLASS_PLAYER) )
		peKiller = (CBasePlayer*)ktmp;

	if ( pVictim->pev == pKiller )  
	{  // killed self
		//start hlpro2
		if ( g_GameMode != GAME_LMS && g_GameMode != GAME_FREEZETAG )
			pKiller->frags -= 1;
		//end hlpro2
	}
	else if ( ktmp && ktmp->IsPlayer() )
	{
		// if a player dies in a deathmatch game and the killer is a client, award the killer some points
		pKiller->frags += IPointsForKill( peKiller, pVictim );
		
		FireTargets( "game_playerkill", ktmp, ktmp, USE_TOGGLE, 0 );
	}
	else
	{  // killed by the world
		//start hlpro2
		if ( g_GameMode != GAME_LMS && g_GameMode != GAME_FREEZETAG )
			pKiller->frags -= 1;
		//end hlpro2
	}

	//start hlpro2
	
/*#define WEAPON_NONE				0
#define WEAPON_CROWBAR			1
#define	WEAPON_GLOCK			2
#define WEAPON_PYTHON			3
#define WEAPON_MP5				4
#define WEAPON_CHAINGUN			5
#define WEAPON_CROSSBOW			6
#define WEAPON_SHOTGUN			7
#define WEAPON_RPG				8
#define WEAPON_GAUSS			9
#define WEAPON_EGON				10
#define WEAPON_HORNETGUN		11
#define WEAPON_HANDGRENADE		12
#define WEAPON_TRIPMINE			13
#define	WEAPON_SATCHEL			14
#define	WEAPON_SNARK			15 */
	if ( g_bEarning )
	{
		int client_frags = peKiller->pev->frags;

		if ( client_frags == 2 ) {
			peKiller->GiveNamedItem( "weapon_9mmhandgun" );
			peKiller->GiveAmmo( 250, "9mm", _9MM_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the glock!\n" );
			//peKiller->DisplayHudMessage( "Earned the glock!", 25, -1, .4, 255, 128, 0, 2, .015, 1, 1, .25 );
		}
		else if ( client_frags == 4 ) {
			peKiller->GiveNamedItem( "weapon_python" );
			peKiller->GiveAmmo( 36, "357", _357_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the python!\n" );
		}
		else if ( client_frags == 6 ) {
			peKiller->GiveNamedItem( "weapon_9mmAR" );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the 9mmAR!\n" );
		}
		else if ( client_frags == 8 ) {
			peKiller->GiveNamedItem( "weapon_shotgun" );
			peKiller->GiveAmmo( 125, "buckshot", BUCKSHOT_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the shotgun!\n" );
		}
		else if ( client_frags == 10 ) {
			peKiller->GiveNamedItem( "weapon_crossbow" );
			peKiller->GiveAmmo( 50, "bolts", BOLT_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the crossbow!\n" );
		}
		else if ( client_frags == 12 ) {
			peKiller->GiveNamedItem( "weapon_rpg" );
			peKiller->GiveAmmo( 5, "rockets", ROCKET_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the RPG!\n" );
		}
		else if ( client_frags == 14 ) {
			peKiller->GiveNamedItem( "weapon_gauss" );
			peKiller->GiveAmmo( 100, "uranium", URANIUM_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the gauss!\n" );
		}
		else if ( client_frags == 16 ) {
			peKiller->GiveNamedItem( "weapon_hornetgun" );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the hornetgun!\n" );
		}
		else if ( client_frags == 18 ) {
			peKiller->GiveNamedItem( "weapon_egon" );
			peKiller->GiveAmmo( 100, "uranium", URANIUM_MAX_CARRY );
			ClientPrint( peKiller->pev, HUD_PRINTCENTER, "Earned the egon!\n" );
		}
	}
	//end hlpro2

	// update the scores
	// killed scores
	MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
		WRITE_BYTE( ENTINDEX(pVictim->edict()) );
		WRITE_SHORT( pVictim->pev->frags );
		WRITE_SHORT( pVictim->m_iDeaths );
		WRITE_SHORT( 0 );
		WRITE_SHORT( GetTeamIndex( pVictim->m_szTeamName ) + 1 );
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
			WRITE_SHORT( 0 );
			WRITE_SHORT( GetTeamIndex( PK->m_szTeamName) + 1 );
		MESSAGE_END();

		// let the killer paint another decal as soon as he'd like.
		PK->m_flNextDecalTime = gpGlobals->time;
	}
#ifndef HLDEMO_BUILD
	if ( pVictim->HasNamedPlayerItem("weapon_satchel") )
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
	char *tau = "tau_cannon";
	char *gluon = "gluon gun";

	if ( pKiller->flags & FL_CLIENT )
	{
		killer_index = ENTINDEX(ENT(pKiller));
		
		if ( pevInflictor )
		{
			if ( pevInflictor == pKiller )
			{
				// If the inflictor is the killer,  then it must be their current weapon doing the damage
				CBasePlayer *pPlayer = (CBasePlayer*)CBaseEntity::Instance( pKiller );
				
				if ( pPlayer->m_pActiveItem )
				{
					killer_weapon_name = pPlayer->m_pActiveItem->pszName();

					//start hlpro2
					int weapon_used = pPlayer->m_pActiveItem->m_iId;
					if ( pPlayer != pVictim )
					{
						pPlayer->m_iWeaponKills[weapon_used]++;
						//ALERT(at_console, UTIL_VarArgs("weapon: weapon_used = %d\n", weapon_used ));
						//pPlayer->DisplayKillDeathRatio( weapon_used );
					}
					else
					{
						pPlayer->m_iWeaponKills[weapon_used]--;
					}

					pPlayer->m_iTotalKills++;
					//end hlpro2
				}
			}
			else
			{
				killer_weapon_name = STRING( pevInflictor->classname );  // it's just that easy

				//start hlpro2
				CBasePlayer *pPlayer = (CBasePlayer*)CBaseEntity::Instance( pKiller );

				//if ( pPlayer != pVictim )
				//{
					char sz[32];
					int weapon_used = 0;

					if ( !strcmp( killer_weapon_name, "ar_grenade" ) )
					{
						weapon_used = WEAPON_MP5;
						strcpy( sz, "9mmAR" );
					}
					else if ( !strcmp( killer_weapon_name, "rpg_rocket" ) )
					{
						weapon_used = WEAPON_RPG;
						strcpy( sz, "RPG" );
					}
					else if ( !strcmp( killer_weapon_name, "bolt" ) || !strcmp( killer_weapon_name, "weapon_crossbow" ) )
					{
						weapon_used = WEAPON_CROSSBOW;
						strcpy( sz, "Crossbow" );
					}
					else if ( !strcmp( killer_weapon_name, "hornet" ) )
					{
						weapon_used = WEAPON_HORNETGUN;
						strcpy( sz, "Hornetgun" );
					}
					else if ( !strcmp( killer_weapon_name, "grenade" ) )
					{
						weapon_used = WEAPON_HANDGRENADE;
						strcpy( sz, "Handgrenade" );
					}
					else if ( !strcmp( killer_weapon_name, "monster_satchel" ) )
					{
						weapon_used = WEAPON_SATCHEL;
						strcpy( sz, "Satchel" );
					}
					else if ( !strcmp( killer_weapon_name, "monster_tripmine" ) )
					{
						weapon_used = WEAPON_TRIPMINE;
						strcpy( sz, "Tripmine" );
					}
					else if ( !strcmp( killer_weapon_name, "monster_snark" ) )
					{
						weapon_used = WEAPON_SNARK;
						strcpy( sz, "Snark" );
					}
					else if ( !strcmp( killer_weapon_name, "weapon_gauss" ) )
					{
						weapon_used = WEAPON_GAUSS;
						strcpy( sz, "Gauss" );
					}
					else if ( !strcmp( killer_weapon_name, "weapon_egon" ) )
					{
						weapon_used = WEAPON_EGON;
						strcpy( sz, "Egon" );
					}

					//ALERT(at_console, UTIL_VarArgs("non-weapon: weapon_used = %d\n", weapon_used ));
					//ALERT(at_console, UTIL_VarArgs("%s\n", STRING( pevInflictor->classname )));

					if ( pPlayer != pVictim )
						pPlayer->m_iWeaponKills[weapon_used]++;
					else
						pPlayer->m_iWeaponKills[weapon_used]--;

					pPlayer->m_iTotalKills++;
					pPlayer->DisplayAccuracy(weapon_used, sz);

					if ( weapon_used == WEAPON_MP5 )
						killer_weapon_name = "grenade"; //hack ! convert back from ar_grenade`
				//}
				//end hlpro2
			}

			
			//start hlpro2
			if ( g_bFatBoy )
			{
				CBasePlayer *pPlayer = (CBasePlayer*)CBaseEntity::Instance( pKiller );

				if ( pPlayer->m_iFatAmount < 500 )
					pPlayer->m_iFatAmount += 25;

				pPlayer->pev->renderfx = kRenderFxGlowShell;
				pPlayer->pev->renderamt = pPlayer->m_iFatAmount;
				pPlayer->pev->rendercolor.x = 255;
				pPlayer->pev->rendercolor.y = 255;
				pPlayer->pev->rendercolor.z = 255;
			}
			//end hlpro2
		}
	}
	else
	{
		killer_weapon_name = STRING( pevInflictor->classname );
		ALERT(at_console, "no inflictor\n");
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

	// replace the code names with the 'real' names
	if ( !strcmp( killer_weapon_name, "egon" ) )
		killer_weapon_name = gluon;
	else if ( !strcmp( killer_weapon_name, "gauss" ) )
		killer_weapon_name = tau;

	if ( pVictim->pev == pKiller )  
	{
		// killed self

		// team match?
		if ( g_teamplay )
		{
			UTIL_LogPrintf( "\"%s<%i><%s><%s>\" committed suicide with \"%s\"\n",  
				STRING( pVictim->pev->netname ), 
				GETPLAYERUSERID( pVictim->edict() ),
				GETPLAYERAUTHID( pVictim->edict() ),
				g_engfuncs.pfnInfoKeyValue( g_engfuncs.pfnGetInfoKeyBuffer( pVictim->edict() ), "model" ),
				killer_weapon_name );		
		}
		else
		{
			UTIL_LogPrintf( "\"%s<%i><%s><%i>\" committed suicide with \"%s\"\n",  
				STRING( pVictim->pev->netname ), 
				GETPLAYERUSERID( pVictim->edict() ),
				GETPLAYERAUTHID( pVictim->edict() ),
				GETPLAYERUSERID( pVictim->edict() ),
				killer_weapon_name );		
		}
	}
	else if ( pKiller->flags & FL_CLIENT )
	{
		// team match?
		if ( g_teamplay )
		{
			UTIL_LogPrintf( "\"%s<%i><%s><%s>\" killed \"%s<%i><%s><%s>\" with \"%s\"\n",  
				STRING( pKiller->netname ),
				GETPLAYERUSERID( ENT(pKiller) ),
				GETPLAYERAUTHID( ENT(pKiller) ),
				g_engfuncs.pfnInfoKeyValue( g_engfuncs.pfnGetInfoKeyBuffer( ENT(pKiller) ), "model" ),
				STRING( pVictim->pev->netname ),
				GETPLAYERUSERID( pVictim->edict() ),
				GETPLAYERAUTHID( pVictim->edict() ),
				g_engfuncs.pfnInfoKeyValue( g_engfuncs.pfnGetInfoKeyBuffer( pVictim->edict() ), "model" ),
				killer_weapon_name );
		}
		else
		{
			UTIL_LogPrintf( "\"%s<%i><%s><%i>\" killed \"%s<%i><%s><%i>\" with \"%s\"\n",  
				STRING( pKiller->netname ),
				GETPLAYERUSERID( ENT(pKiller) ),
				GETPLAYERAUTHID( ENT(pKiller) ),
				GETPLAYERUSERID( ENT(pKiller) ),
				STRING( pVictim->pev->netname ),
				GETPLAYERUSERID( pVictim->edict() ),
				GETPLAYERAUTHID( pVictim->edict() ),
				GETPLAYERUSERID( pVictim->edict() ),
				killer_weapon_name );
		}
	}
	else
	{ 
		// killed by the world

		// team match?
		if ( g_teamplay )
		{
			UTIL_LogPrintf( "\"%s<%i><%s><%s>\" committed suicide with \"%s\" (world)\n",
				STRING( pVictim->pev->netname ), 
				GETPLAYERUSERID( pVictim->edict() ), 
				GETPLAYERAUTHID( pVictim->edict() ),
				g_engfuncs.pfnInfoKeyValue( g_engfuncs.pfnGetInfoKeyBuffer( pVictim->edict() ), "model" ),
				killer_weapon_name );		
		}
		else
		{
			UTIL_LogPrintf( "\"%s<%i><%s><%i>\" committed suicide with \"%s\" (world)\n",
				STRING( pVictim->pev->netname ), 
				GETPLAYERUSERID( pVictim->edict() ), 
				GETPLAYERAUTHID( pVictim->edict() ),
				GETPLAYERUSERID( pVictim->edict() ),
				killer_weapon_name );		
		}
	}

	MESSAGE_BEGIN( MSG_SPEC, SVC_DIRECTOR );
		WRITE_BYTE ( 9 );	// command length in bytes
		WRITE_BYTE ( DRC_CMD_EVENT );	// player killed
		WRITE_SHORT( ENTINDEX(pVictim->edict()) );	// index number of primary entity
		if (pevInflictor)
			WRITE_SHORT( ENTINDEX(ENT(pevInflictor)) );	// index number of secondary entity
		else
			WRITE_SHORT( ENTINDEX(ENT(pKiller)) );	// index number of secondary entity
		WRITE_LONG( 7 | DRC_FLAG_DRAMATIC);   // eventflags (priority and flags)
	MESSAGE_END();

//  Print a standard message
	// TODO: make this go direct to console
	return; // just remove for now
/*
	char	szText[ 128 ];

	if ( pKiller->flags & FL_MONSTER )
	{
		// killed by a monster
		strcpy ( szText, STRING( pVictim->pev->netname ) );
		strcat ( szText, " was killed by a monster.\n" );
		return;
	}

	if ( pKiller == pVictim->pev )
	{
		strcpy ( szText, STRING( pVictim->pev->netname ) );
		strcat ( szText, " commited suicide.\n" );
	}
	else if ( pKiller->flags & FL_CLIENT )
	{
		strcpy ( szText, STRING( pKiller->netname ) );

		strcat( szText, " : " );
		strcat( szText, killer_weapon_name );
		strcat( szText, " : " );

		strcat ( szText, STRING( pVictim->pev->netname ) );
		strcat ( szText, "\n" );
	}
	else if ( FClassnameIs ( pKiller, "worldspawn" ) )
	{
		strcpy ( szText, STRING( pVictim->pev->netname ) );
		strcat ( szText, " fell or drowned or something.\n" );
	}
	else if ( pKiller->solid == SOLID_BSP )
	{
		strcpy ( szText, STRING( pVictim->pev->netname ) );
		strcat ( szText, " was mooshed.\n" );
	}
	else
	{
		strcpy ( szText, STRING( pVictim->pev->netname ) );
		strcat ( szText, " died mysteriously.\n" );
	}

	UTIL_ClientPrintAll( szText );
*/
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
	if ( weaponstay.value > 0 )
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
	if ( weaponstay.value > 0 )
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
	//start hlpro2
	return Vector ( pAmmo->pev->origin.x, pAmmo->pev->origin.y, pAmmo->pev->origin.z );
	//end hlpro2
}

//=========================================================
//=========================================================
float CHalfLifeMultiplay::FlHealthChargerRechargeTime( void )
{
	return 60;
}


float CHalfLifeMultiplay::FlHEVChargerRechargeTime( void )
{
	return 30;
}

//=========================================================
//=========================================================
int CHalfLifeMultiplay::DeadPlayerWeapons( CBasePlayer *pPlayer )
{
	//start hlpro2
	if ( g_bMaxPack )
		return GR_PLR_DROP_GUN_ALL;
	else
		return GR_PLR_DROP_GUN_ACTIVE;
	//end hlpro2
}

//=========================================================
//=========================================================
int CHalfLifeMultiplay::DeadPlayerAmmo( CBasePlayer *pPlayer )
{
	//start hlpro2
	if ( g_bMaxPack )
		return GR_PLR_DROP_AMMO_ALL;
	else
		return GR_PLR_DROP_AMMO_ACTIVE;
	//end hlpro2
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
	if ( g_footsteps && g_footsteps->value == 0 )
		return FALSE;

	if ( pl->IsOnLadder() || pl->pev->velocity.Length2D() > 220 )
		return TRUE;  // only make step sounds in multiplayer if the player is moving fast enough

	return FALSE;
}

BOOL CHalfLifeMultiplay :: FAllowFlashlight( void ) 
{ 
	return flashlight.value != 0; 
}

//=========================================================
//=========================================================
BOOL CHalfLifeMultiplay :: FAllowMonsters( void )
{
	return ( allowmonsters.value != 0 );
}

//=========================================================
//======== CHalfLifeMultiplay private functions ===========
#define INTERMISSION_TIME		6

void CHalfLifeMultiplay :: GoToIntermission( void )
{
	if ( g_fGameOver )
		return;  // intermission has already been triggered, so ignore.

	MESSAGE_BEGIN(MSG_ALL, SVC_INTERMISSION);
	MESSAGE_END();

	// bounds check
	int time = (int)CVAR_GET_FLOAT( "mp_chattime" );
	if ( time < 1 )
		CVAR_SET_STRING( "mp_chattime", "1" );
	else if ( time > MAX_INTERMISSION_TIME )
		CVAR_SET_STRING( "mp_chattime", UTIL_dtos1( MAX_INTERMISSION_TIME ) );

	m_flIntermissionEndTime = gpGlobals->time + ( (int)mp_chattime.value );
	g_flIntermissionStartTime = gpGlobals->time;

	g_fGameOver = TRUE;
	m_iEndIntermissionButtonHit = FALSE;
}

#define MAX_RULE_BUFFER 1024

typedef struct mapcycle_item_s
{
	struct mapcycle_item_s *next;

	char mapname[ 32 ];
	int  minplayers, maxplayers;
	char rulebuffer[ MAX_RULE_BUFFER ];
} mapcycle_item_t;

typedef struct mapcycle_s
{
	struct mapcycle_item_s *items;
	struct mapcycle_item_s *next_item;
} mapcycle_t;

/*
==============
DestroyMapCycle

Clean up memory used by mapcycle when switching it
==============
*/
void DestroyMapCycle( mapcycle_t *cycle )
{
	mapcycle_item_t *p, *n, *start;
	p = cycle->items;
	if ( p )
	{
		start = p;
		p = p->next;
		while ( p != start )
		{
			n = p->next;
			delete p;
			p = n;
		}
		
		delete cycle->items;
	}
	cycle->items = NULL;
	cycle->next_item = NULL;
}

static char com_token[ 1500 ];

/*
==============
COM_Parse

Parse a token out of a string
==============
*/
char *COM_Parse (char *data)
{
	int             c;
	int             len;
	
	len = 0;
	com_token[0] = 0;
	
	if (!data)
		return NULL;
		
// skip whitespace
skipwhite:
	while ( (c = *data) <= ' ')
	{
		if (c == 0)
			return NULL;                    // end of file;
		data++;
	}
	
// skip // comments
	if (c=='/' && data[1] == '/')
	{
		while (*data && *data != '\n')
			data++;
		goto skipwhite;
	}
	

// handle quoted strings specially
	if (c == '\"')
	{
		data++;
		while (1)
		{
			c = *data++;
			if (c=='\"' || !c)
			{
				com_token[len] = 0;
				return data;
			}
			com_token[len] = c;
			len++;
		}
	}

// parse single characters
	if (c=='{' || c=='}'|| c==')'|| c=='(' || c=='\'' || c == ',' )
	{
		com_token[len] = c;
		len++;
		com_token[len] = 0;
		return data+1;
	}

// parse a regular word
	do
	{
		com_token[len] = c;
		data++;
		len++;
		c = *data;
	if (c=='{' || c=='}'|| c==')'|| c=='(' || c=='\'' || c == ',' )
			break;
	} while (c>32);
	
	com_token[len] = 0;
	return data;
}

/*
==============
COM_TokenWaiting

Returns 1 if additional data is waiting to be processed on this line
==============
*/
int COM_TokenWaiting( char *buffer )
{
	char *p;

	p = buffer;
	while ( *p && *p!='\n')
	{
		if ( !isspace( *p ) || isalnum( *p ) )
			return 1;

		p++;
	}

	return 0;
}



/*
==============
ReloadMapCycleFile


Parses mapcycle.txt file into mapcycle_t structure
==============
*/
int ReloadMapCycleFile( char *filename, mapcycle_t *cycle )
{
	char szBuffer[ MAX_RULE_BUFFER ];
	char szMap[ 32 ];
	int length;
	char *pFileList;
	char *aFileList = pFileList = (char*)LOAD_FILE_FOR_ME( filename, &length );
	int hasbuffer;
	mapcycle_item_s *item, *newlist = NULL, *next;

	if ( pFileList && length )
	{
		// the first map name in the file becomes the default
		while ( 1 )
		{
			hasbuffer = 0;
			memset( szBuffer, 0, MAX_RULE_BUFFER );

			pFileList = COM_Parse( pFileList );
			if ( strlen( com_token ) <= 0 )
				break;

			strcpy( szMap, com_token );

			// Any more tokens on this line?
			if ( COM_TokenWaiting( pFileList ) )
			{
				pFileList = COM_Parse( pFileList );
				if ( strlen( com_token ) > 0 )
				{
					hasbuffer = 1;
					strcpy( szBuffer, com_token );
				}
			}

			// Check map
			if ( IS_MAP_VALID( szMap ) )
			{
				// Create entry
				char *s;

				item = new mapcycle_item_s;

				strcpy( item->mapname, szMap );

				item->minplayers = 0;
				item->maxplayers = 0;

				memset( item->rulebuffer, 0, MAX_RULE_BUFFER );

				if ( hasbuffer )
				{
					s = g_engfuncs.pfnInfoKeyValue( szBuffer, "minplayers" );
					if ( s && s[0] )
					{
						item->minplayers = atoi( s );
						item->minplayers = max( item->minplayers, 0 );
						item->minplayers = min( item->minplayers, gpGlobals->maxClients );
					}
					s = g_engfuncs.pfnInfoKeyValue( szBuffer, "maxplayers" );
					if ( s && s[0] )
					{
						item->maxplayers = atoi( s );
						item->maxplayers = max( item->maxplayers, 0 );
						item->maxplayers = min( item->maxplayers, gpGlobals->maxClients );
					}

					// Remove keys
					//
					g_engfuncs.pfnInfo_RemoveKey( szBuffer, "minplayers" );
					g_engfuncs.pfnInfo_RemoveKey( szBuffer, "maxplayers" );

					strcpy( item->rulebuffer, szBuffer );
				}

				item->next = cycle->items;
				cycle->items = item;
			}
			else
			{
				ALERT( at_console, "Skipping %s from mapcycle, not a valid map\n", szMap );
			}

		}

		FREE_FILE( aFileList );
	}

	// Fixup circular list pointer
	item = cycle->items;

	// Reverse it to get original order
	while ( item )
	{
		next = item->next;
		item->next = newlist;
		newlist = item;
		item = next;
	}
	cycle->items = newlist;
	item = cycle->items;

	// Didn't parse anything
	if ( !item )
	{
		return 0;
	}

	while ( item->next )
	{
		item = item->next;
	}
	item->next = cycle->items;
	
	cycle->next_item = item->next;

	return 1;
}

/*
==============
CountPlayers

Determine the current # of active players on the server for map cycling logic
==============
*/
int CountPlayers( void )
{
	int	num = 0;

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBaseEntity *pEnt = UTIL_PlayerByIndex( i );

		if ( pEnt )
		{
			num = num + 1;
		}
	}

	return num;
}

/*
==============
ExtractCommandString

Parse commands/key value pairs to issue right after map xxx command is issued on server
 level transition
==============
*/
void ExtractCommandString( char *s, char *szCommand )
{
	// Now make rules happen
	char	pkey[512];
	char	value[512];	// use two buffers so compares
								// work without stomping on each other
	char	*o;
	
	if ( *s == '\\' )
		s++;

	while (1)
	{
		o = pkey;
		while ( *s != '\\' )
		{
			if ( !*s )
				return;
			*o++ = *s++;
		}
		*o = 0;
		s++;

		o = value;

		while (*s != '\\' && *s)
		{
			if (!*s)
				return;
			*o++ = *s++;
		}
		*o = 0;

		strcat( szCommand, pkey );
		if ( strlen( value ) > 0 )
		{
			strcat( szCommand, " " );
			strcat( szCommand, value );
		}
		strcat( szCommand, "\n" );

		if (!*s)
			return;
		s++;
	}
}

/*
==============
ChangeLevel

Server is changing to a new level, check mapcycle.txt for map name and setup info
==============
*/
void CHalfLifeMultiplay :: ChangeLevel( void )
{
	static char szPreviousMapCycleFile[ 256 ];
	static mapcycle_t mapcycle;

	char szNextMap[32];
	char szFirstMapInList[32];
	char szCommands[ 1500 ];
	char szRules[ 1500 ];
	int minplayers = 0, maxplayers = 0;
	strcpy( szFirstMapInList, "hldm1" );  // the absolute default level is hldm1

	int	curplayers;
	BOOL do_cycle = TRUE;

	// find the map to change to
	char *mapcfile = (char*)CVAR_GET_STRING( "mapcyclefile" );
	ASSERT( mapcfile != NULL );

	szCommands[ 0 ] = '\0';
	szRules[ 0 ] = '\0';

	curplayers = CountPlayers();

	// Has the map cycle filename changed?
	if ( stricmp( mapcfile, szPreviousMapCycleFile ) )
	{
		strcpy( szPreviousMapCycleFile, mapcfile );

		DestroyMapCycle( &mapcycle );

		if ( !ReloadMapCycleFile( mapcfile, &mapcycle ) || ( !mapcycle.items ) )
		{
			ALERT( at_console, "Unable to load map cycle file %s\n", mapcfile );
			do_cycle = FALSE;
		}
	}

	if ( do_cycle && mapcycle.items )
	{
		BOOL keeplooking = FALSE;
		BOOL found = FALSE;
		mapcycle_item_s *item;

		// Assume current map
		strcpy( szNextMap, STRING(gpGlobals->mapname) );
		strcpy( szFirstMapInList, STRING(gpGlobals->mapname) );

		// Traverse list
		for ( item = mapcycle.next_item; item->next != mapcycle.next_item; item = item->next )
		{
			keeplooking = FALSE;

			ASSERT( item != NULL );

			if ( item->minplayers != 0 )
			{
				if ( curplayers >= item->minplayers )
				{
					found = TRUE;
					minplayers = item->minplayers;
				}
				else
				{
					keeplooking = TRUE;
				}
			}

			if ( item->maxplayers != 0 )
			{
				if ( curplayers <= item->maxplayers )
				{
					found = TRUE;
					maxplayers = item->maxplayers;
				}
				else
				{
					keeplooking = TRUE;
				}
			}

			if ( keeplooking )
				continue;

			found = TRUE;
			break;
		}

		if ( !found )
		{
			item = mapcycle.next_item;
		}			
		
		// Increment next item pointer
		mapcycle.next_item = item->next;

		// Perform logic on current item
		strcpy( szNextMap, item->mapname );

		ExtractCommandString( item->rulebuffer, szCommands );
		strcpy( szRules, item->rulebuffer );
	}

	if ( !IS_MAP_VALID(szNextMap) )
	{
		strcpy( szNextMap, szFirstMapInList );
	}

	g_fGameOver = TRUE;

	ALERT( at_console, "CHANGE LEVEL: %s\n", szNextMap );
	if ( minplayers || maxplayers )
	{
		ALERT( at_console, "PLAYER COUNT:  min %i max %i current %i\n", minplayers, maxplayers, curplayers );
	}
	if ( strlen( szRules ) > 0 )
	{
		ALERT( at_console, "RULES:  %s\n", szRules );
	}
	
	CHANGE_LEVEL( szNextMap, NULL );
	if ( strlen( szCommands ) > 0 )
	{
		SERVER_COMMAND( szCommands );
	}
}

#define MAX_MOTD_CHUNK	  60
#define MAX_MOTD_LENGTH   1536 // (MAX_MOTD_CHUNK * 4)

void CHalfLifeMultiplay :: SendMOTDToClient( edict_t *client )
{
	// read from the MOTD.txt file
	int length, char_count = 0;
	char *pFileList;
	char *aFileList = pFileList = (char*)LOAD_FILE_FOR_ME( (char *)CVAR_GET_STRING( "motdfile" ), &length );

	// send the server name
	MESSAGE_BEGIN( MSG_ONE, gmsgServerName, NULL, client );
		WRITE_STRING( CVAR_GET_STRING("hostname") );
	MESSAGE_END();

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
	

