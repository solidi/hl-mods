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


#define VOTE_MAP		1
#define VOTE_GAMEMODE	2
#define VOTE_KICK		3
#define VOTE_BAN		4


//start hlpro2
extern DLL_GLOBAL BOOL      g_VoteInProgress;
extern DLL_GLOBAL float     g_VoteTimer;
extern DLL_GLOBAL float     g_VoteExecute;
extern DLL_GLOBAL int       g_VotesYes;
extern DLL_GLOBAL int       g_VotesNo;
extern DLL_GLOBAL int		g_VoteType;
extern DLL_GLOBAL char		g_VoteMessage[256];

char execute[256];
int banid;

float g_GlobalVoteTime = 0;
//end hlpro2


void InitVote ( edict_t *pVoter, int vote_type, const char *cmd, int ban_id )
{
	entvars_t *pev = &pVoter->v;

	if ( g_GlobalVoteTime && g_GlobalVoteTime < gpGlobals->time )
	{
		g_GlobalVoteTime = 0;
	}
	else
	{
		if ( g_VoteInProgress )
			ClientPrint(pev, HUD_PRINTNOTIFY, "Vote is currently in progress!\n");
		else
			ClientPrint(pev, HUD_PRINTNOTIFY, UTIL_VarArgs("Next vote can be cast in %.01f seconds\n", g_GlobalVoteTime - gpGlobals->time ));
	
		return;
	}

	g_VoteInProgress = TRUE;
	g_VoteType       = vote_type;

	strcpy(execute, cmd);
	ALERT(at_console, (char *)execute);
	
	banid = ban_id;

	if ( CVAR_GET_FLOAT("hla_votetimer") >= 10 )
		g_VoteTimer = gpGlobals->time + CVAR_GET_FLOAT("hla_votetimer");
	else
	{
		CVAR_SET_FLOAT("hla_votetimer", 10);
		g_VoteTimer = gpGlobals->time + CVAR_GET_FLOAT("hla_votetimer");
	}


	//if you create, obviously for it.
	GetClassPtr((CBasePlayer *)pev)->m_bHasVotedYes = TRUE;
	ClientPrint(pev, HUD_PRINTNOTIFY, "\nYou have voted yes!\n");

	CycleInitialPlayers(STRING(pev->netname), vote_type, execute);
}

void CycleInitialPlayers ( const char *initializer, int vote_type, const char *cmd )
{
	char sz[128];

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer  )
		{
			sprintf(sz, "Vote has begun by %s!\n", initializer ); 
			pPlayer->DisplayHudMessage( sz, 3, .01, .12, 255, 128, 0, 2, .015, 1, 28, .25 );

			strcpy ( g_VoteMessage, sz );

			if ( vote_type == VOTE_MAP )
				sprintf(sz, "('vote_yes' or 'vote_no')\n\nMap: %s", cmd );
			else if ( vote_type == VOTE_GAMEMODE )
				sprintf(sz, "('vote_yes' or 'vote_no')\n\nGame Mode: %s", cmd );
			else if ( vote_type == VOTE_KICK )
				sprintf(sz, "('vote_yes' or 'vote_no')\n\nKick: %s", cmd );
			else if ( vote_type == VOTE_BAN )
				sprintf(sz, "('vote_yes' or 'vote_no')\n\nBan: %s", cmd );

			strcat ( g_VoteMessage, sz );

			pPlayer->DisplayHudMessage( sz, 4, .01, .15, 210, 210, 210, 2, .015, 1, 28, .25 );
		}

	}
}

void CycleFinalPlayers ( int result )
{
	char sz[256];
	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer  )
		{
			if ( result > 0 )
				sprintf(sz, "Vote has passed : by %d vote(s)\n", result );
			else if ( result < 0 )
				sprintf(sz, "Vote did not pass : by %d vote(s)\n", result );
			else
				sprintf(sz, "Vote did not pass : stalemate\n" );

			pPlayer->DisplayHudMessage( "Vote Result", 3, .01, .12, 255, 128, 0, 2, .015, 1, 10, .25 );
			pPlayer->DisplayHudMessage( sz, 4, .01, .15, 210, 210, 210, 2, .015, 1, 10, .25 );
			pPlayer->m_bHasVotedYes = FALSE;
			pPlayer->m_bHasVotedNo  = FALSE;
		}

	}
}

int CalculateVoteTotals ( void )
{
	int total;

	for ( int i = 1; i <= gpGlobals->maxClients; i++ )
	{
		CBasePlayer *pPlayer = (CBasePlayer *)UTIL_PlayerByIndex( i );

		if ( pPlayer )
		{
			if ( pPlayer->m_bHasVotedYes )
				g_VotesYes++;
			else if ( pPlayer->m_bHasVotedNo )
				g_VotesNo++;
		}

	}

	//positive = pass
	//negative = loss
	//zero     = stalemate
	return total = g_VotesYes - g_VotesNo; 
}

void ExecuteVote ( void )
{
	char sz[256];

	switch ( g_VoteType )
	{
	case VOTE_MAP:
		CHANGE_LEVEL((char *)execute, NULL);
		break;
	case VOTE_GAMEMODE:
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
		ResetVote();
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