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
/*

===== world.cpp ========================================================

  precaches and defs for entities and other data that must always be available.

*/

#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "nodes.h"
#include "soundent.h"
#include "client.h"
#include "decals.h"
#include "skill.h"
#include "effects.h"
#include "player.h"
#include "weapons.h"
#include "gamerules.h"
#include "teamplay_gamerules.h"
//start hlpro
#include "weapons.h"
//end hlpro

extern CGraph WorldGraph;
extern CSoundEnt *pSoundEnt;

extern CBaseEntity				*g_pLastSpawn;
DLL_GLOBAL edict_t				*g_pBodyQueueHead;
CGlobalState					gGlobalState;
extern DLL_GLOBAL	int			gDisplayTitle;

//start hlpro2
extern DLL_GLOBAL	char		g_MutatorList[32][32];
extern DLL_GLOBAL	int			g_TotalMutators;
extern DLL_GLOBAL   int         g_flWeaponArena;
extern DLL_GLOBAL   int			g_flWeaponMutators[16];
extern DLL_GLOBAL	int			g_TotalWeapons;
extern DLL_GLOBAL   int			g_flStartWeapons[16];
extern DLL_GLOBAL	int			g_TotalStartWeapons;

extern DLL_GLOBAL   int			g_GameMode;

extern DLL_GLOBAL   BOOL        g_bAntiCamper;
extern DLL_GLOBAL   BOOL        g_bInstaGib;
extern DLL_GLOBAL   BOOL        g_bFatBoy;
extern DLL_GLOBAL   BOOL        g_bEarning;
extern DLL_GLOBAL   BOOL        g_bStartFull;
extern DLL_GLOBAL   BOOL        g_bMoreGore;
extern DLL_GLOBAL   BOOL        g_bRunes;
extern DLL_GLOBAL	BOOL		g_bExplosive;
extern DLL_GLOBAL	BOOL		g_bMaxPack;
extern DLL_GLOBAL	BOOL		g_bBoobyTrap;
extern DLL_GLOBAL   BOOL        g_bSpawnProtect;
extern DLL_GLOBAL   BOOL        g_bDecay;
extern DLL_GLOBAL	BOOL		g_bRealLife;

extern cvar_t					hla_mutators;
extern cvar_t					hla_gamemode;
extern cvar_t					hla_startweapons;
//end hlpro2

extern void W_Precache(void);

//
// This must match the list in util.h
//
DLL_DECALLIST gDecals[] = {
	{ "{shot1",	0 },		// DECAL_GUNSHOT1 
	{ "{shot2",	0 },		// DECAL_GUNSHOT2
	{ "{shot3",0 },			// DECAL_GUNSHOT3
	{ "{shot4",	0 },		// DECAL_GUNSHOT4
	{ "{shot5",	0 },		// DECAL_GUNSHOT5
	{ "{lambda01", 0 },		// DECAL_LAMBDA1
	{ "{lambda02", 0 },		// DECAL_LAMBDA2
	{ "{lambda03", 0 },		// DECAL_LAMBDA3
	{ "{lambda04", 0 },		// DECAL_LAMBDA4
	{ "{lambda05", 0 },		// DECAL_LAMBDA5
	{ "{lambda06", 0 },		// DECAL_LAMBDA6
	{ "{scorch1", 0 },		// DECAL_SCORCH1
	{ "{scorch2", 0 },		// DECAL_SCORCH2
	{ "{blood1", 0 },		// DECAL_BLOOD1
	{ "{blood2", 0 },		// DECAL_BLOOD2
	{ "{blood3", 0 },		// DECAL_BLOOD3
	{ "{blood4", 0 },		// DECAL_BLOOD4
	{ "{blood5", 0 },		// DECAL_BLOOD5
	{ "{blood6", 0 },		// DECAL_BLOOD6
	{ "{yblood1", 0 },		// DECAL_YBLOOD1
	{ "{yblood2", 0 },		// DECAL_YBLOOD2
	{ "{yblood3", 0 },		// DECAL_YBLOOD3
	{ "{yblood4", 0 },		// DECAL_YBLOOD4
	{ "{yblood5", 0 },		// DECAL_YBLOOD5
	{ "{yblood6", 0 },		// DECAL_YBLOOD6
	{ "{break1", 0 },		// DECAL_GLASSBREAK1
	{ "{break2", 0 },		// DECAL_GLASSBREAK2
	{ "{break3", 0 },		// DECAL_GLASSBREAK3
	{ "{bigshot1", 0 },		// DECAL_BIGSHOT1
	{ "{bigshot2", 0 },		// DECAL_BIGSHOT2
	{ "{bigshot3", 0 },		// DECAL_BIGSHOT3
	{ "{bigshot4", 0 },		// DECAL_BIGSHOT4
	{ "{bigshot5", 0 },		// DECAL_BIGSHOT5
	{ "{spit1", 0 },		// DECAL_SPIT1
	{ "{spit2", 0 },		// DECAL_SPIT2
	{ "{bproof1", 0 },		// DECAL_BPROOF1
	{ "{gargstomp", 0 },	// DECAL_GARGSTOMP1,	// Gargantua stomp crack
	{ "{smscorch1", 0 },	// DECAL_SMALLSCORCH1,	// Small scorch mark
	{ "{smscorch2", 0 },	// DECAL_SMALLSCORCH2,	// Small scorch mark
	{ "{smscorch3", 0 },	// DECAL_SMALLSCORCH3,	// Small scorch mark
	{ "{mommablob", 0 },	// DECAL_MOMMABIRTH		// BM Birth spray
	{ "{mommablob", 0 },	// DECAL_MOMMASPLAT		// BM Mortar spray?? need decal
};

/*
==============================================================================

BODY QUE

==============================================================================
*/

#define SF_DECAL_NOTINDEATHMATCH		2048

class CDecal : public CBaseEntity
{
public:
	void	Spawn( void );
	void	KeyValue( KeyValueData *pkvd );
	void	EXPORT StaticDecal( void );
	void	EXPORT TriggerDecal( CBaseEntity *pActivator, CBaseEntity *pCaller, USE_TYPE useType, float value );
};

LINK_ENTITY_TO_CLASS( infodecal, CDecal );

// UNDONE:  These won't get sent to joining players in multi-player
void CDecal :: Spawn( void )
{
	if ( pev->skin < 0 || (gpGlobals->deathmatch && FBitSet( pev->spawnflags, SF_DECAL_NOTINDEATHMATCH )) )
	{
		REMOVE_ENTITY(ENT(pev));
		return;
	}

	if ( FStringNull ( pev->targetname ) )
	{
		SetThink( StaticDecal );
		// if there's no targetname, the decal will spray itself on as soon as the world is done spawning.
		pev->nextthink = gpGlobals->time;
	}
	else
	{
		// if there IS a targetname, the decal sprays itself on when it is triggered.
		SetThink ( SUB_DoNothing );
		SetUse(TriggerDecal);
	}
}

void CDecal :: TriggerDecal ( CBaseEntity *pActivator, CBaseEntity *pCaller, USE_TYPE useType, float value )
{
	// this is set up as a USE function for infodecals that have targetnames, so that the
	// decal doesn't get applied until it is fired. (usually by a scripted sequence)
	TraceResult trace;
	int			entityIndex;

	UTIL_TraceLine( pev->origin - Vector(5,5,5), pev->origin + Vector(5,5,5),  ignore_monsters, ENT(pev), &trace );

	MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY);
		WRITE_BYTE( TE_BSPDECAL );
		WRITE_COORD( pev->origin.x );
		WRITE_COORD( pev->origin.y );
		WRITE_COORD( pev->origin.z );
		WRITE_SHORT( (int)pev->skin );
		entityIndex = (short)ENTINDEX(trace.pHit);
		WRITE_SHORT( entityIndex );
		if ( entityIndex )
			WRITE_SHORT( (int)VARS(trace.pHit)->modelindex );
	MESSAGE_END();

	SetThink( SUB_Remove );
	pev->nextthink = gpGlobals->time + 0.1;
}


void CDecal :: StaticDecal( void )
{
	TraceResult trace;
	int			entityIndex, modelIndex;

	UTIL_TraceLine( pev->origin - Vector(5,5,5), pev->origin + Vector(5,5,5),  ignore_monsters, ENT(pev), &trace );

	entityIndex = (short)ENTINDEX(trace.pHit);
	if ( entityIndex )
		modelIndex = (int)VARS(trace.pHit)->modelindex;
	else
		modelIndex = 0;

	g_engfuncs.pfnStaticDecal( pev->origin, (int)pev->skin, entityIndex, modelIndex );

	SUB_Remove();
}


void CDecal :: KeyValue( KeyValueData *pkvd )
{
	if (FStrEq(pkvd->szKeyName, "texture"))
	{
		pev->skin = DECAL_INDEX( pkvd->szValue );
		
		// Found
		if ( pev->skin >= 0 )
			return;
		ALERT( at_console, "Can't find decal %s\n", pkvd->szValue );
	}
	else
		CBaseEntity::KeyValue( pkvd );
}


// Body queue class here.... It's really just CBaseEntity
class CCorpse : public CBaseEntity
{
	virtual int ObjectCaps( void ) { return FCAP_DONT_SAVE; }	
};

LINK_ENTITY_TO_CLASS( bodyque, CCorpse );

static void InitBodyQue(void)
{
	string_t	istrClassname = MAKE_STRING("bodyque");

	g_pBodyQueueHead = CREATE_NAMED_ENTITY( istrClassname );
	entvars_t *pev = VARS(g_pBodyQueueHead);
	
	// Reserve 3 more slots for dead bodies
	for ( int i = 0; i < 3; i++ )
	{
		pev->owner = CREATE_NAMED_ENTITY( istrClassname );
		pev = VARS(pev->owner);
	}
	
	pev->owner = g_pBodyQueueHead;
}


//
// make a body que entry for the given ent so the ent can be respawned elsewhere
//
// GLOBALS ASSUMED SET:  g_eoBodyQueueHead
//
void CopyToBodyQue(entvars_t *pev) 
{
	if (pev->effects & EF_NODRAW)
		return;

	entvars_t *pevHead	= VARS(g_pBodyQueueHead);

	pevHead->angles		= pev->angles;
	pevHead->model		= pev->model;
	pevHead->modelindex	= pev->modelindex;
	pevHead->frame		= pev->frame;
	pevHead->colormap	= pev->colormap;
	pevHead->movetype	= MOVETYPE_TOSS;
	pevHead->velocity	= pev->velocity;
	pevHead->flags		= 0;
	pevHead->deadflag	= pev->deadflag;
	pevHead->renderfx	= kRenderFxDeadPlayer;
	pevHead->renderamt	= ENTINDEX( ENT( pev ) );

	pevHead->effects    = pev->effects | EF_NOINTERP;
	//pevHead->goalstarttime = pev->goalstarttime;
	//pevHead->goalframe	= pev->goalframe;
	//pevHead->goalendtime = pev->goalendtime ;
	
	pevHead->sequence = pev->sequence;
	pevHead->animtime = pev->animtime;

	UTIL_SetOrigin(pevHead, pev->origin);
	UTIL_SetSize(pevHead, pev->mins, pev->maxs);
	g_pBodyQueueHead = pevHead->owner;
}


CGlobalState::CGlobalState( void )
{
	Reset();
}

void CGlobalState::Reset( void )
{
	m_pList = NULL; 
	m_listCount = 0;
}

globalentity_t *CGlobalState :: Find( string_t globalname )
{
	if ( !globalname )
		return NULL;

	globalentity_t *pTest;
	const char *pEntityName = STRING(globalname);

	
	pTest = m_pList;
	while ( pTest )
	{
		if ( FStrEq( pEntityName, pTest->name ) )
			break;
	
		pTest = pTest->pNext;
	}

	return pTest;
}


// This is available all the time now on impulse 104, remove later
//#ifdef _DEBUG
void CGlobalState :: DumpGlobals( void )
{
	static char *estates[] = { "Off", "On", "Dead" };
	globalentity_t *pTest;

	ALERT( at_console, "-- Globals --\n" );
	pTest = m_pList;
	while ( pTest )
	{
		ALERT( at_console, "%s: %s (%s)\n", pTest->name, pTest->levelName, estates[pTest->state] );
		pTest = pTest->pNext;
	}
}
//#endif


void CGlobalState :: EntityAdd( string_t globalname, string_t mapName, GLOBALESTATE state )
{
	ASSERT( !Find(globalname) );

	globalentity_t *pNewEntity = (globalentity_t *)calloc( sizeof( globalentity_t ), 1 );
	ASSERT( pNewEntity != NULL );
	pNewEntity->pNext = m_pList;
	m_pList = pNewEntity;
	strcpy( pNewEntity->name, STRING( globalname ) );
	strcpy( pNewEntity->levelName, STRING(mapName) );
	pNewEntity->state = state;
	m_listCount++;
}


void CGlobalState :: EntitySetState( string_t globalname, GLOBALESTATE state )
{
	globalentity_t *pEnt = Find( globalname );

	if ( pEnt )
		pEnt->state = state;
}


const globalentity_t *CGlobalState :: EntityFromTable( string_t globalname )
{
	globalentity_t *pEnt = Find( globalname );

	return pEnt;
}


GLOBALESTATE CGlobalState :: EntityGetState( string_t globalname )
{
	globalentity_t *pEnt = Find( globalname );
	if ( pEnt )
		return pEnt->state;

	return GLOBAL_OFF;
}


// Global Savedata for Delay
TYPEDESCRIPTION	CGlobalState::m_SaveData[] = 
{
	DEFINE_FIELD( CGlobalState, m_listCount, FIELD_INTEGER ),
};

// Global Savedata for Delay
TYPEDESCRIPTION	gGlobalEntitySaveData[] = 
{
	DEFINE_ARRAY( globalentity_t, name, FIELD_CHARACTER, 64 ),
	DEFINE_ARRAY( globalentity_t, levelName, FIELD_CHARACTER, 32 ),
	DEFINE_FIELD( globalentity_t, state, FIELD_INTEGER ),
};


int CGlobalState::Save( CSave &save )
{
	int i;
	globalentity_t *pEntity;

	if ( !save.WriteFields( "GLOBAL", this, m_SaveData, ARRAYSIZE(m_SaveData) ) )
		return 0;
	
	pEntity = m_pList;
	for ( i = 0; i < m_listCount && pEntity; i++ )
	{
		if ( !save.WriteFields( "GENT", pEntity, gGlobalEntitySaveData, ARRAYSIZE(gGlobalEntitySaveData) ) )
			return 0;

		pEntity = pEntity->pNext;
	}
	
	return 1;
}

int CGlobalState::Restore( CRestore &restore )
{
	int i, listCount;
	globalentity_t tmpEntity;


	ClearStates();
	if ( !restore.ReadFields( "GLOBAL", this, m_SaveData, ARRAYSIZE(m_SaveData) ) )
		return 0;
	
	listCount = m_listCount;	// Get new list count
	m_listCount = 0;				// Clear loaded data

	for ( i = 0; i < listCount; i++ )
	{
		if ( !restore.ReadFields( "GENT", &tmpEntity, gGlobalEntitySaveData, ARRAYSIZE(gGlobalEntitySaveData) ) )
			return 0;
		EntityAdd( MAKE_STRING(tmpEntity.name), MAKE_STRING(tmpEntity.levelName), tmpEntity.state );
	}
	return 1;
}

void CGlobalState::EntityUpdate( string_t globalname, string_t mapname )
{
	globalentity_t *pEnt = Find( globalname );

	if ( pEnt )
		strcpy( pEnt->levelName, STRING(mapname) );
}


void CGlobalState::ClearStates( void )
{
	globalentity_t *pFree = m_pList;
	while ( pFree )
	{
		globalentity_t *pNext = pFree->pNext;
		free( pFree );
		pFree = pNext;
	}
	Reset();
}


void SaveGlobalState( SAVERESTOREDATA *pSaveData )
{
	CSave saveHelper( pSaveData );
	gGlobalState.Save( saveHelper );
}


void RestoreGlobalState( SAVERESTOREDATA *pSaveData )
{
	CRestore restoreHelper( pSaveData );
	gGlobalState.Restore( restoreHelper );
}


void ResetGlobalState( void )
{
	gGlobalState.ClearStates();
	gInitHUD = TRUE;	// Init the HUD on a new game / load game
}

// moved CWorld class definition to cbase.h
//=======================
// CWorld
//
// This spawns first when each level begins.
//=======================

LINK_ENTITY_TO_CLASS( worldspawn, CWorld );

#define SF_WORLD_DARK		0x0001		// Fade from black at startup
#define SF_WORLD_TITLE		0x0002		// Display game title at startup
#define SF_WORLD_FORCETEAM	0x0004		// Force teams

extern DLL_GLOBAL BOOL		g_fGameOver;
float g_flWeaponCheat;

//start hlpro2
const char *szMutatorList [] =
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
	"real",			//29	29  real life
};

const char *szGameModeList [] =
{
	"ffa",			//0
	"arena",		//1
	"lms",			//2
	"robo",			//3
	"headhunter",	//4
	"freezetag",	//5
};

void SetGameMode( void )
{
	char textfile[64];

	g_GameMode = -1;

	for ( int i = 0; i <= GAME_FREEZETAG; i++ )
	{
		if ( !strcmp( szGameModeList[i], hla_gamemode.string ))
		{
			g_GameMode = i;
			ALERT(at_console, UTIL_VarArgs("\n\n----------------------------------------\nGamemode set to: %s\n", szGameModeList[i] ));
			
			sprintf(textfile, "modes/%s.txt", szGameModeList[i] );
			CVAR_SET_STRING( "motdfile", textfile );
		}
	}

	if ( g_GameMode == -1 )
	{
		g_GameMode = 0;
		CVAR_SET_STRING( "motdfile", "ffa.txt");
		CVAR_SET_STRING( "hla_gamemode", "ffa" );
	}
}

void SetMutatorCvars( void )
{
	int			i = 0;
	char		*pName;
	char 		list[128];
	char		currentCvar[128];

	g_TotalMutators		= 0;
	g_flWeaponArena		= 0;
	g_TotalWeapons		= 0;
	g_TotalStartWeapons	= 0;

	//clear out arrays..
	for ( i = 0; i < 16; i++ )
	{
		g_flWeaponMutators[i] = 0;
		g_flStartWeapons[i] = 0;
	}

	g_bAntiCamper	= FALSE;
	g_bInstaGib		= FALSE;
	g_bFatBoy		= FALSE;
	g_bEarning		= FALSE;
	g_bStartFull    = FALSE;
	g_bMoreGore	    = FALSE;
	g_bRunes        = FALSE;
	g_bExplosive    = FALSE;
	g_bMaxPack		= FALSE;
	g_bBoobyTrap	= FALSE;
	g_bSpawnProtect = FALSE;
	g_bDecay		= FALSE;
	g_bRealLife		= FALSE;
					
	strcpy( list, hla_mutators.string );
	pName = list;
	pName = strtok( pName, ", " );
	while ( pName != NULL && *pName /* && g_TotalMutators < 5*/ )
	{
		BOOL Duplicate = FALSE;

		for ( i = 0; i <= TOTAL_MUTATORS; i++ )
		{
			//check for duplicates
			if ( !strcmp( szMutatorList[i], pName ) )
			{ 
				for ( int j = 0; j < g_TotalMutators; j++ )
				{
					ALERT( at_console, UTIL_VarArgs( "checking %s against %s\n", szMutatorList[i], g_MutatorList[j] ));

					if ( !strcmp(g_MutatorList[j], szMutatorList[i]) )
					{
						Duplicate = TRUE;
						ALERT(at_console, "Found duplicate mutator. Ignoring.\n");
					}
				}

				//if we found a duplicate skip the code below and go to the next
				if ( Duplicate )
					continue;

				strcpy(g_MutatorList[g_TotalMutators], szMutatorList[i] );
				ALERT(at_console, UTIL_VarArgs("Copied %s[%i] to mutators...\n", g_MutatorList[g_TotalMutators], g_TotalMutators));
				
				if ( !g_TotalMutators )
					sprintf( currentCvar, "%s", g_MutatorList[g_TotalMutators]);
				else
					sprintf( currentCvar, "%s, %s", CVAR_GET_STRING("hla_mutators"), g_MutatorList[g_TotalMutators]);

				CVAR_SET_STRING( "hla_mutators", currentCvar );
				
				if ( i < 17 )
				{			
					g_flWeaponMutators[g_TotalWeapons] = i; 
					g_TotalWeapons++;
					g_flWeaponArena = 1;
				}
				else if ( i == 17 )
					g_bAntiCamper = TRUE;
				else if ( i == 18 )
					g_bInstaGib = TRUE;
				else if ( i == 19 )
					g_bFatBoy = TRUE;
				else if ( i == 20 )
					g_bEarning = TRUE;
				else if ( i == 21 )
					g_bStartFull = TRUE;
				else if ( i == 22 )
					g_bMoreGore = TRUE;
				else if ( i == 23 )
					g_bRunes = TRUE;
				else if ( i == 24 )
					g_bExplosive = TRUE;
				else if ( i == 25 )
					g_bMaxPack = TRUE;
				else if ( i == 26 )
					g_bBoobyTrap = TRUE;
				else if ( i == 27 )
					g_bSpawnProtect = TRUE;
				else if ( i == 28 )
					g_bDecay = TRUE;
				else if ( i == 29 )
					g_bRealLife = TRUE;

				g_TotalMutators++;
				//break;
			}
		}
		pName = strtok( NULL, ", " );
	}

	//set up start weapons...
	BOOL dup;
	strcpy( list, hla_startweapons.string );
	pName = list;
	pName = strtok( pName, ", " );
	while ( pName != NULL && *pName  )
	{
		for ( i = 1; i <= 15; i++ )
		{
			dup = FALSE;

			if ( !strcmp( szMutatorList[i], pName ) )
			{ 
				//lets see if we have a duplicate
				for ( int j = 0; j < g_TotalStartWeapons; j++ )
				{
					if ( g_flStartWeapons[j] == i )
						dup = TRUE;
				}

				//if no dup's, load it in.
				if ( !dup )
				{					
					g_flStartWeapons[g_TotalStartWeapons] = i;
					
					if ( !g_TotalStartWeapons )
						sprintf( currentCvar, "%s", szMutatorList[i]);
					else
						sprintf( currentCvar, "%s, %s", CVAR_GET_STRING("hla_startweapons"), szMutatorList[i]);

					CVAR_SET_STRING( "hla_startweapons", currentCvar );

					g_TotalStartWeapons++;
				}
				else
					ALERT( at_console, "Found duplicate in startweapons.\n");
			}
		}

		pName = strtok( NULL, ", " );
	}


	//cycle through weapons...
	//kill duplicates
	//special case if = 16 / no weapon spawn.
	if ( g_flWeaponArena )
	{
		for ( i = 0; i < g_TotalWeapons; i++ )
		{
			//found 'none', therefore everything else is disabled.
			if ( g_flWeaponMutators[i]  == 16 )
			{
				g_flWeaponMutators[0] = 16;
				g_TotalWeapons = 1;
				break;
			}
		}

		ALERT( at_console, UTIL_VarArgs( "Total Weapons: %i\n", g_TotalWeapons ));
	}

	if ( (g_bStartFull && g_bEarning) || (g_bStartFull && g_flWeaponArena) )
	{
		g_bStartFull = FALSE;
		ALERT(at_notice, "Disabled startfull mutator.\n");
	}

	if ( g_bEarning )
	{
		g_flWeaponArena = 0;
		ALERT(at_notice, "Disabled weapon mutator (reason: earning).\n");
	}

	if ( g_GameMode && CVAR_GET_FLOAT("mp_teamplay") )
	{
		ALERT(at_console, "Can not have teamplay enabled with game mode.\n" );
		CVAR_SET_FLOAT("mp_teamplay", 0 );
	}

	//console output
	ALERT(at_console, "Mutator list: ");

	for ( int j = 0; j < g_TotalMutators; j++ ) 
		ALERT(at_console, UTIL_VarArgs("%s[%i] ", g_MutatorList[j], j));

	ALERT(at_console, "\n----------------------------------------\n\n");
}
//end hlpro2 

void CWorld :: Spawn( void )
{
	g_fGameOver = FALSE;
	Precache( );
	g_flWeaponCheat = CVAR_GET_FLOAT( "sv_cheats" );  // Is the impulse 101 command allowed?

	//start hlpro2
	SetGameMode();
	SetMutatorCvars();
	if ( g_bRunes )
		CWorldRunes *WorldRunes = CWorldRunes::Create( );
	//end hlpro2
}

void CWorld :: Precache( void )
{
	g_pLastSpawn = NULL;
	
#if 1
	CVAR_SET_STRING("sv_gravity", "800"); // 67ft/sec
	CVAR_SET_STRING("sv_stepsize", "18");
#else
	CVAR_SET_STRING("sv_gravity", "384"); // 32ft/sec
	CVAR_SET_STRING("sv_stepsize", "24");
#endif

	CVAR_SET_STRING("room_type", "0");// clear DSP

	// Set up game rules
	if (g_pGameRules)
	{
		delete g_pGameRules;
	}

	g_pGameRules = InstallGameRules( );

	//!!!UNDONE why is there so much Spawn code in the Precache function? I'll just keep it here 

	///!!!LATER - do we want a sound ent in deathmatch? (sjb)
	//pSoundEnt = CBaseEntity::Create( "soundent", g_vecZero, g_vecZero, edict() );
	pSoundEnt = GetClassPtr( ( CSoundEnt *)NULL );
	pSoundEnt->Spawn();

	if ( !pSoundEnt )
	{
		ALERT ( at_console, "**COULD NOT CREATE SOUNDENT**\n" );
	}

	InitBodyQue();
	
// init sentence group playback stuff from sentences.txt.
// ok to call this multiple times, calls after first are ignored.

	SENTENCEG_Init();

// init texture type array from materials.txt

	TEXTURETYPE_Init();


// the area based ambient sounds MUST be the first precache_sounds

// player precaches     
	W_Precache ();									// get weapon precaches

	ClientPrecache();

// sounds used from C physics code
	PRECACHE_SOUND("common/null.wav");				// clears sound channels

	PRECACHE_SOUND( "items/suitchargeok1.wav" );//!!! temporary sound for respawning weapons.
	PRECACHE_SOUND( "items/gunpickup2.wav" );// player picks up a gun.

	PRECACHE_SOUND( "common/bodydrop3.wav" );// dead bodies hitting the ground (animation events)
	PRECACHE_SOUND( "common/bodydrop4.wav" );
	
	g_Language = (int)CVAR_GET_FLOAT( "sv_language" );
	if ( g_Language == LANGUAGE_GERMAN )
	{
		PRECACHE_MODEL( "models/germangibs.mdl" );
	}
	else
	{
		PRECACHE_MODEL( "models/hgibs.mdl" );
		PRECACHE_MODEL( "models/agibs.mdl" );
	}

	PRECACHE_SOUND ("weapons/ric1.wav");
	PRECACHE_SOUND ("weapons/ric2.wav");
	PRECACHE_SOUND ("weapons/ric3.wav");
	PRECACHE_SOUND ("weapons/ric4.wav");
	PRECACHE_SOUND ("weapons/ric5.wav");
//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	//start hlpro2
/*	if ( g_DarkMatch )
	{
		LIGHT_STYLE(0, "a");
		LIGHT_STYLE(1, "a");
		LIGHT_STYLE(2, "a");
		LIGHT_STYLE(3, "a");
		LIGHT_STYLE(4, "a");
		LIGHT_STYLE(5, "a");
		LIGHT_STYLE(6, "a");
		LIGHT_STYLE(7, "a");
		LIGHT_STYLE(8, "a");
		LIGHT_STYLE(9, "a");
		LIGHT_STYLE(10, "a");
		LIGHT_STYLE(11, "a");
		LIGHT_STYLE(12, "a");
		LIGHT_STYLE(63, "a");
	}
	else
	{*/
		// 0 normal
		LIGHT_STYLE(0, "m");
	
		// 1 FLICKER (first variety)
		LIGHT_STYLE(1, "mmnmmommommnonmmonqnmmo");
	
		// 2 SLOW STRONG PULSE
		LIGHT_STYLE(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
		// 3 CANDLE (first variety)
		LIGHT_STYLE(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
		// 4 FAST STROBE
		LIGHT_STYLE(4, "mamamamamama");
	
		// 5 GENTLE PULSE 1
		LIGHT_STYLE(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
		// 6 FLICKER (second variety)
		LIGHT_STYLE(6, "nmonqnmomnmomomno");
	
		// 7 CANDLE (second variety)
		LIGHT_STYLE(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
		// 8 CANDLE (third variety)
		LIGHT_STYLE(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
		// 9 SLOW STROBE (fourth variety)
		LIGHT_STYLE(9, "aaaaaaaazzzzzzzz");
	
		// 10 FLUORESCENT FLICKER
		LIGHT_STYLE(10, "mmamammmmammamamaaamammma");

		// 11 SLOW PULSE NOT FADE TO BLACK
		LIGHT_STYLE(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
		// 12 UNDERWATER LIGHT MUTATION
		// this light only distorts the lightmap - no contribution
		// is made to the brightness of affected surfaces
		LIGHT_STYLE(12, "mmnnmmnnnmmnn");
	
		// styles 32-62 are assigned by the light program for switchable lights

		// 63 testing
		LIGHT_STYLE(63, "a");
//	}
	//end hlpro2

	for ( int i = 0; i < ARRAYSIZE(gDecals); i++ )
		gDecals[i].index = DECAL_INDEX( gDecals[i].name );

// init the WorldGraph.
	WorldGraph.InitGraph();

// make sure the .NOD file is newer than the .BSP file.
	if ( !WorldGraph.CheckNODFile ( ( char * )STRING( gpGlobals->mapname ) ) )
	{// NOD file is not present, or is older than the BSP file.
		WorldGraph.AllocNodes ();
	}
	else
	{// Load the node graph for this level
		if ( !WorldGraph.FLoadGraph ( (char *)STRING( gpGlobals->mapname ) ) )
		{// couldn't load, so alloc and prepare to build a graph.
			ALERT ( at_console, "*Error opening .NOD file\n" );
			WorldGraph.AllocNodes ();
		}
		else
		{
			ALERT ( at_console, "\n*Graph Loaded!\n" );
		}
	}

	if ( pev->speed > 0 )
		CVAR_SET_FLOAT( "sv_zmax", pev->speed );
	else
		CVAR_SET_FLOAT( "sv_zmax", 4096 );

	if ( pev->netname )
	{
		ALERT( at_aiconsole, "Chapter title: %s\n", STRING(pev->netname) );
		CBaseEntity *pEntity = CBaseEntity::Create( "env_message", g_vecZero, g_vecZero, NULL );
		if ( pEntity )
		{
			pEntity->SetThink( SUB_CallUseToggle );
			pEntity->pev->message = pev->netname;
			pev->netname = 0;
			pEntity->pev->nextthink = gpGlobals->time + 0.3;
			pEntity->pev->spawnflags = SF_MESSAGE_ONCE;
		}
	}

	if ( pev->spawnflags & SF_WORLD_DARK )
		CVAR_SET_FLOAT( "v_dark", 1.0 );
	else
		CVAR_SET_FLOAT( "v_dark", 0.0 );

	if ( pev->spawnflags & SF_WORLD_TITLE )
		gDisplayTitle = TRUE;		// display the game title if this key is set
	else
		gDisplayTitle = FALSE;

	if ( pev->spawnflags & SF_WORLD_FORCETEAM )
	{
		CVAR_SET_FLOAT( "mp_defaultteam", 1 );
	}
	else
	{
		CVAR_SET_FLOAT( "mp_defaultteam", 0 );
	}
}


//
// Just to ignore the "wad" field.
//
void CWorld :: KeyValue( KeyValueData *pkvd )
{
	if ( FStrEq(pkvd->szKeyName, "skyname") )
	{
		// Sent over net now.
		CVAR_SET_STRING( "sv_skyname", pkvd->szValue );
		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "sounds") )
	{
		gpGlobals->cdAudioTrack = atoi(pkvd->szValue);
		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "WaveHeight") )
	{
		// Sent over net now.
		pev->scale = atof(pkvd->szValue) * (1.0/8.0);
		pkvd->fHandled = TRUE;
		CVAR_SET_FLOAT( "sv_wateramp", pev->scale );
	}
	else if ( FStrEq(pkvd->szKeyName, "MaxRange") )
	{
		pev->speed = atof(pkvd->szValue);
		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "chaptertitle") )
	{
		pev->netname = ALLOC_STRING(pkvd->szValue);
		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "startdark") )
	{
		// UNDONE: This is a gross hack!!! The CVAR is NOT sent over the client/sever link
		// but it will work for single player
		int flag = atoi(pkvd->szValue);
		pkvd->fHandled = TRUE;
		if ( flag )
			pev->spawnflags |= SF_WORLD_DARK;
	}
	else if ( FStrEq(pkvd->szKeyName, "newunit") )
	{
		// Single player only.  Clear save directory if set
		if ( atoi(pkvd->szValue) )
			CVAR_SET_FLOAT( "sv_newunit", 1 );
		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "gametitle") )
	{
		if ( atoi(pkvd->szValue) )
			pev->spawnflags |= SF_WORLD_TITLE;

		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "mapteams") )
	{
		pev->team = ALLOC_STRING( pkvd->szValue );
		pkvd->fHandled = TRUE;
	}
	else if ( FStrEq(pkvd->szKeyName, "defaultteam") )
	{
		if ( atoi(pkvd->szValue) )
		{
			pev->spawnflags |= SF_WORLD_FORCETEAM;
		}
		pkvd->fHandled = TRUE;
	}
	else
		CBaseEntity::KeyValue( pkvd );
}
