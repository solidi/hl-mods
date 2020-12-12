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
#include    "vote.h"


extern DLL_GLOBAL char			g_MutatorList[32][32];
extern DLL_GLOBAL int			g_TotalMutators;

extern DLL_GLOBAL int			g_GameMode;
extern DLL_GLOBAL BOOL			g_VoteInProgress;
extern DLL_GLOBAL float			g_VoteTimer;
extern DLL_GLOBAL float			g_VoteExecute;
extern DLL_GLOBAL int			g_VotesYes;
extern DLL_GLOBAL int			g_VotesNo;
extern DLL_GLOBAL int			g_VoteType;
extern DLL_GLOBAL char			g_VoteMessage[128];

char execute[256];
int banid = 0;

float g_GlobalVoteTime = 0;

const char *szMutators [] =
{
	"all",			//0		0-16  weapon arena
	"crowbar",		//1
	"glock",		//2
	"python",		//3
	"mp5",			//4
	"chaingun",		//5
	"crossbow",		//6
	"shotgun",		//7
	"rpg",			//8
	"gauss",		//9
	"egon",			//10
	"hornetgun",	//11
	"handgrenade",	//12
	"tripmine",		//13
	"satchel",		//14
	"snark",		//15
	"none",         //16
	//------------------
	"camper",		//17	17	anti-camper
	"gib",          //18    18  insta-gib
	"fatboy",       //19    19  fatboy
	"earning",      //20	20	earning
	"startfull",    //21    21  startfull
	"gore",         //22    22  gore
	"runes",		//23    23  runes
	"explosive",    //24    24  explosive weaponboxes
	"maxpack",      //25    25  packall
	"boobytrap",    //26    26	boobytrap
	"spawn",		//27	27	spawnprotect
	"decay",		//28	28	decay of weapons
}; 

const char *szGameModes [] =
{
	"ffa",			//0
	"arena",		//1
	"lms",			//2
	"robo",			//3
	"headhunter",	//4
	"freezetag",	//5
};


void Vote ( CBasePlayer *pPlayer, BOOL vote )
{
	if ( pPlayer->IsSpectator() )
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Spectators can not vote.\n");
		return;
	}

	if ( !g_VoteInProgress || g_VoteExecute )
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* There is no current vote.\n");
		return;
	}

	if ( !pPlayer->m_bHasVotedYes && !pPlayer->m_bHasVotedNo )
	{
		pPlayer->DisplayHudMessage( " ", 3, .01, .12, 255, 128, 0, 2, .015, 1, 6, .25 );
		pPlayer->DisplayHudMessage( " ", 4, .01, .15, 210, 210, 210, 2, .015, 1, 6, .25 );

		if ( vote )
		{
			pPlayer->m_bHasVotedYes = TRUE;
			pPlayer->DisplayHudMessage( "You have voted YES.\n", 5, .01, .12, 255, 128, 0, 2, .015, 1, 6, .25 );
			UTIL_ClientPrintAll( HUD_PRINTTALK, UTIL_VarArgs("* %s has voted YES!\n", STRING(pPlayer->pev->netname)));
		}
		else
		{
			pPlayer->m_bHasVotedNo = TRUE;
			pPlayer->DisplayHudMessage( "You have voted NO.\n", 5, .01, .12, 255, 128, 0, 2, .015, 1, 6, .25 );
			UTIL_ClientPrintAll( HUD_PRINTTALK, UTIL_VarArgs("* %s has voted NO!\n", STRING(pPlayer->pev->netname)));
		}
	}
	else
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* You have already voted!\n");
		return;
	}

	//now check to see if this was the last person to vote
	int total = 0, voted = 0;

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer && pPlayer->IsPlayer() )
		{
			if ( !pPlayer->IsSpectator() )
			{
				if ( pPlayer->m_bHasVotedNo || pPlayer->m_bHasVotedYes )
					voted++;

				total++;
			}
		}
	}

	if ( voted == total )
	{
		TallyVote();
		g_VoteTimer = 0;
	}
}

void VoteMap ( CBasePlayer *pPlayer, const char *szMap )
{
	if ( strlen(szMap) )
	{
		int result;
		result = IS_MAP_VALID( (char *)szMap );

		if ( result )
		{
			if ( !strcmp( szMap, STRING(gpGlobals->mapname ) ))
			{
				ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs("* \"%s\" is already in play.\n", szMap));
			}
			else
			{
				InitVote(pPlayer, VOTE_MAP, szMap, 0);
			}
		}
		else
		{
			ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs( "* \"%s\" was not found on the server!\n", szMap));
		}

	}
	else
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Please type in a map! (ex. `vote_map stalkyard`)\n");
	}
}

void VoteGame ( CBasePlayer *pPlayer, const char *szGameMode )
{
	if ( strlen(szGameMode) )
	{
		int result = 0;

		if ( !strcmp( szGameMode, "ffa" ) 
			|| !strcmp( szGameMode, "arena" )
			|| !strcmp( szGameMode, "lms" )
			|| !strcmp( szGameMode, "robo" )
			|| !strcmp( szGameMode, "headhunter" )
			|| !strcmp( szGameMode, "freezetag" ))
		{
			result = 1;
		}

		if ( result )
		{
			if ( !strcmp(szGameModes[g_GameMode], szGameMode) )
			{
				ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs("* \"%s\" is already in play.\n", szGameMode));
			}
			else
			{
				InitVote(pPlayer, VOTE_GAME, szGameMode, 0);
			}
		}
		else
		{
			ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Invalid game mode! (ex. `ffa`, `arena`, `lms`, `robo`, `headhunter`, `freezetag`)\n");
		}
	}
	else
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Please type in game mode! (ex. `vote_game ffa`)\n");
	}
}

void VoteKick ( CBasePlayer *pPlayer, const char *szClient, BOOL BanMe )
{
	if ( strlen(szClient) )
	{
		for ( int i = 1; i <= gpGlobals->maxClients; i++ )
		{
			CBasePlayer *pl = (CBasePlayer *)UTIL_PlayerByIndex( i );

			if ( pl && pl->IsPlayer() )
			{
				if ( ( !strcmp(szClient, STRING(pl->pev->netname)) ) || ( GETPLAYERUSERID(pl->edict()) == atoi( szClient ) ) )
				{
					if ( BanMe )
						InitVote(pPlayer, VOTE_KICK, (char *)STRING(pl->pev->netname), GETPLAYERUSERID(pl->edict()) );
					else
						InitVote(pPlayer, VOTE_BAN, (char *)STRING(pl->pev->netname), GETPLAYERUSERID(pl->edict()) );

					return;
				}
			}
		}

		ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs("* \"%s\" does not exist. Type 'status' in console for reference.\n", szClient));
	}
	else
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Please enter ID. Type 'status' in console for reference.\n");
	}
}

void VoteExtend ( CBasePlayer *pPlayer, const char *szMap )
{
	InitVote(pPlayer, VOTE_EXTEND, szMap, 0);
}

void VoteMutator ( CBasePlayer *pPlayer, const char *szMutator )
{
	if ( strlen(szMutator) )
	{
		int result = 0;

		//loop through all valid mutators.
		for ( int i = 0; i <= TOTAL_MUTATORS; i++ )
		{
			if ( !strcmp( szMutator, szMutators[i] ))
				result = 1;
		}

		//found mutator, lets set the vote.
		if ( result )
		{
			//loop through to active mutators
			//make sure we arent voting on something 
			//that is already in play.
			BOOL found = FALSE;

			for ( int i = 0; i < g_TotalMutators; i++ )
			{
				if( !strcmp(g_MutatorList[i], szMutator) )
				{
					found = true;
					break;
				}
			}

			if ( found )
			{
				ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs("* \"%s\" is already active.\n", szMutator));
			}
			else
			{
				InitVote(pPlayer, VOTE_MUTATOR, szMutator, 0);
			}
		}
		else
		{
			ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs("* \"%s\" is an invalid mutator! (ex. `shotgun`, `camper` )\n", szMutator));
		}
	}
	else
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Please type in mutator! (ex. `vote_mutator camper`)\n");
	}
}

//===================================================
// VOTE SYSTEM
//===================================================

void InitVote ( CBasePlayer *pPlayer, int vote_type, const char *cmd, int ban_id )
{
	int count = 0;

	//spectators can not initiate vote
	if ( pPlayer->IsSpectator() )
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Spectators can not initiate a vote.\n");
		return;
	}

	//cycle through players first to see if we can make a vote.
	//votes can't happen with just one player.
	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer && pPlayer->IsPlayer() )
		{
			if ( !pPlayer->IsSpectator() )
				count++;
		}
	}

	//test to see if there is more than one player
	if ( count <= 1 )
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Need two or more active players to initiate vote.\n");
		return;
	}

	//test hla_votetimer
	if ( CVAR_GET_FLOAT("hla_votetimer") >= 10 )
	{
		g_VoteTimer = gpGlobals->time + CVAR_GET_FLOAT("hla_votetimer");
	}
	else
	{
		ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Voting has been disabled on this server.\n");
		g_VoteTimer = 0;

		return;
	}

	//====================================

	if ( g_GlobalVoteTime && g_GlobalVoteTime < gpGlobals->time )
	{
		g_GlobalVoteTime = 0;
	}
	else
	{
		if ( g_VoteInProgress )
			ClientPrint(pPlayer->pev, HUD_PRINTTALK, "* Vote is currently in progress!\n");
		else
			ClientPrint(pPlayer->pev, HUD_PRINTTALK, UTIL_VarArgs("* Next vote can be cast in %.0f second(s)\n", g_GlobalVoteTime - gpGlobals->time ));
	
		return;
	}

	g_VoteInProgress = TRUE;
	g_VoteType       = vote_type;

	strcpy(execute, cmd);
	ALERT(at_console, (char *)execute);
	
	banid = ban_id;

	//if you create, obviously for it.
	Vote( pPlayer, TRUE );


	CycleInitialPlayers(STRING(pPlayer->pev->netname), vote_type, execute);
}

void CycleInitialPlayers ( const char *initializer, int vote_type, const char *cmd )
{
	char sz[128];

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer && pPlayer->IsPlayer() )
		{
			if ( !pPlayer->IsSpectator() )
			{
				sprintf(sz, "[Vote has begun by %s!]\n", initializer ); 
				pPlayer->DisplayHudMessage( sz, 3, .01, .12, 255, 128, 0, 2, .015, 1, 28, .25 );

				//strcpy ( g_VoteMessage, sz );

				if ( vote_type == VOTE_MAP )
					sprintf(sz, "('yes' or 'no')\n\nMap: %s", cmd );
				else if ( vote_type == VOTE_GAME )
					sprintf(sz, "(''yes' or 'no')\n\nGame Mode: %s", cmd );
				else if ( vote_type == VOTE_KICK )
					sprintf(sz, "('yes' or 'no')\n\nKick: %s", cmd );
				else if ( vote_type == VOTE_BAN )
					sprintf(sz, "('yes' or 'no')\n\nBan: %s", cmd );
				else if ( vote_type == VOTE_EXTEND )
					sprintf(sz, "('yes' or 'no')\n\nExtend Map", cmd );
				else if ( vote_type == VOTE_MUTATOR )
					sprintf(sz, "('yes' or 'no')\n\nMutator: %s", cmd );

				strcpy ( g_VoteMessage, sz );

				pPlayer->DisplayHudMessage( sz, 4, .01, .15, 210, 210, 210, 2, .015, 1, 28, .25 );
			}
		}

	}
}

void CycleFinalPlayers ( int result )
{
	char sz[256];
	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer && pPlayer->IsPlayer() )
		{
			if ( !pPlayer->IsSpectator() )
			{
				if ( result > 0 )
					sprintf(sz, "Vote has passed!\n");
					//: by %d vote(s)\n", result );
				else if ( result < 0 )
					sprintf(sz, "Vote did not pass!\n");
					//: by %d vote(s)\n", result );
				else
					sprintf(sz, "Vote did not pass : stalemate!\n" );

				pPlayer->DisplayHudMessage( "[Vote Result]", 3, .01, .12, 255, 128, 0, 2, .015, 1, 10, .25 );
				pPlayer->DisplayHudMessage( sz, 4, .01, .15, 210, 210, 210, 2, .015, 1, 10, .25 );
				pPlayer->m_bHasVotedYes = FALSE;
				pPlayer->m_bHasVotedNo  = FALSE;
			}
		}

	}
}

int CalculateVoteTotals ( void )
{
	int total = 0;
	int total_people = 0;
	double decide = 0;

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer && pPlayer->IsPlayer() )
		{
			if ( !pPlayer->IsSpectator() )
			{
				if ( pPlayer->m_bHasVotedYes )
					g_VotesYes++;
				else if ( pPlayer->m_bHasVotedNo )
					g_VotesNo++;
			}

			total_people++;
		}
	}

	decide = total_people / 2;

	ALERT ( at_console, UTIL_VarArgs("Ceiling is %.0f\n", decide) );

	UTIL_ClientPrintAll(HUD_PRINTTALK, UTIL_VarArgs("* Vote called: %i for, %i against. Amount to win: %.0f\n", g_VotesYes, g_VotesNo, decide+1) );
	if ( g_VotesYes > decide )
		total = 1;
	else
		total = -1;

	//positive = pass
	//negative = loss
	//zero     = stalemate
	return total; //= g_VotesYes - g_VotesNo; 
}

void ExecuteVote ( void )
{
	char sz[256];

	switch ( g_VoteType )
	{
	case VOTE_MAP:
		CHANGE_LEVEL((char *)execute, NULL);
		break;
	case VOTE_GAME:
		CVAR_SET_STRING( "hla_gamemode", execute );
			CHANGE_LEVEL((char *)STRING(gpGlobals->mapname), NULL);
		break;
	case VOTE_KICK:
		ALERT(at_console, "EXECUTING KICK!\n");
		sprintf(sz, "kick %s\n", execute);
		SERVER_COMMAND(sz);
		SERVER_EXECUTE();
		break;
	case VOTE_BAN:
		ALERT(at_console, "EXECUTING BAN!\n");
		sprintf(sz, "banid 10 #%d kick\n", banid);
		SERVER_COMMAND(sz);
		SERVER_EXECUTE();
		break;
	case VOTE_EXTEND:
		if ( g_GameMode )
			CVAR_SET_FLOAT("hla_gamerounds", CVAR_GET_FLOAT("hla_gamerounds") + 15);
		else
		{
			CVAR_SET_FLOAT("mp_timelimit", CVAR_GET_FLOAT("mp_timelimit") + 30);
			CVAR_SET_FLOAT("mp_fraglimit", CVAR_GET_FLOAT("mp_fraglimit") + 25);
		}
		break;
	case VOTE_MUTATOR:
		sprintf( sz, "%s, %s", CVAR_GET_STRING("hla_mutators"), execute);
		CVAR_SET_STRING( "hla_mutators", sz );
			CHANGE_LEVEL((char *)STRING(gpGlobals->mapname), NULL);
		break;
	}

	ResetVote();
}


void TallyVote ( void )
{
	int result;

	result = CalculateVoteTotals();
	CycleFinalPlayers( result );

	if ( result > 0 )
	{
		g_VoteExecute = gpGlobals->time + 5.0;
		ALERT(at_console, "EXECUTING VOTE RESULT IN 5 SECONDS\n");
	}
	else
	{
		ResetVote();
	}
}

void ResetVote ( void )
{
	g_VoteInProgress = 0;
	g_VoteTimer      = 0;
	g_VoteExecute	 = 0;
	g_VoteType		 = 0;
	g_VotesYes       = 0;
	g_VotesNo        = 0;

	if ( CVAR_GET_FLOAT("hla_votedelay") >= 10 )
		g_GlobalVoteTime = gpGlobals->time + CVAR_GET_FLOAT("hla_votedelay");
	else
	{
		CVAR_SET_FLOAT("hla_votedelay", 10);
		g_GlobalVoteTime = gpGlobals->time + CVAR_GET_FLOAT("hla_votedelay");
	}

	ALERT(at_console, "Reset Vote System.\n");
}