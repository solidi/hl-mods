#include "extdll.h" 
#include "decals.h" 
#include "util.h" 
#include "cbase.h" 
#include "monsters.h" 
#include "weapons.h" 
#include "nodes.h" 
#include "player.h" 
#include "soundent.h" 
#include "shake.h" 
#include "gamerules.h"


class CBaseRune : public CBaseEntity

{

public:

char *m_szModel;
char *m_szClassName;
int m_iRuneFlag;
int m_iShellRed;
int m_iShellGreen;
int m_iShellBlue;
void Spawn( );
void Precache( );
void RuneTouch( CBaseEntity * );
void RuneThink( );

};

void CBaseRune::Spawn( )

{

m_szModel = "models/w_suit.mdl";
Precache( );
SET_MODEL( ENT(pev), m_szModel );
pev->movetype = MOVETYPE_TOSS; 
pev->solid = SOLID_TRIGGER; 
pev->rendermode = kRenderNormal;
pev->renderamt = 255;
UTIL_SetSize( pev, Vector(-5, -5, -5), Vector(5, 5, 5) ); 
UTIL_SetOrigin( pev, pev->origin ); 
pev->classname = MAKE_STRING( m_szClassName );
SetThink( RuneThink ); 
SetTouch( RuneTouch );
pev->rendermode = kRenderNormal;
pev->rendercolor.x = m_iShellRed;
pev->rendercolor.y = m_iShellGreen;
pev->rendercolor.z = m_iShellBlue;
pev->renderamt = 255;
pev->renderfx = kRenderFxGlowShell;
pev->gravity = 0; 
pev->nextthink = gpGlobals->time + 10.0; 

}

void CBaseRune::Precache( )

{

PRECACHE_MODEL("models/w_suit.mdl");
PRECACHE_SOUND( "items/gunpickup2.wav" );

}

void CBaseRune::RuneTouch( CBaseEntity *pOther)

{

if ( !pOther->IsPlayer() )

{

return;

}

CBasePlayer *pPlayer = (CBasePlayer *)pOther;


if(pPlayer->m_iPlayerRune == 0)

{

EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/gunpickup2.wav", 0.5, ATTN_NORM);

pPlayer->m_iPlayerRune |= m_iRuneFlag;

if ( m_iRuneFlag == RUNE_SPEED )
	    ShowMenu (pPlayer, 0x7, 5, 0, "--Obtained Rune--\n\n -Speed-\nIncreases your speed X3" );
if ( m_iRuneFlag == RUNE_RESIST )
		ShowMenu (pPlayer, 0x7, 5, 0, "--Obtained Rune--\n\n -Resist-\nResist attacks by % 25" );
if ( m_iRuneFlag == RUNE_STRENGTH )
		ShowMenu (pPlayer, 0x7, 5, 0, "--Obtained Rune--\n\n -Strength-\n2x infiction damage" );
if ( m_iRuneFlag == RUNE_HEALTH )
		ShowMenu (pPlayer, 0x7, 5, 0, "--Obtained Rune--\n\n -Regeneration-\nSlowly increases health and armor" );

SUB_Remove( );

return;

}

}

void CBaseRune::RuneThink( )

{

}

/*********************************************************************

*********************************************************************/

class CSpeedRune : public CBaseRune

{

void Spawn( );

};

 

LINK_ENTITY_TO_CLASS( rune_speed, CSpeedRune );

void CSpeedRune::Spawn( )

{

m_iRuneFlag = RUNE_SPEED;
m_iShellRed = 255;
m_iShellGreen = 0;
m_iShellBlue = 0;
m_szModel = "models/w_suit.mdl";
m_szClassName = "rune_speed";

CBaseRune::Spawn( );

}

/*********************************************************************

*********************************************************************/


class CFragsRune : public CBaseRune

{

void Spawn( );

};

 

LINK_ENTITY_TO_CLASS( rune_frags, CFragsRune );

void CFragsRune::Spawn( )

{

m_iRuneFlag = RUNE_FRAGS;
m_iShellRed = 255;
m_iShellGreen = 255;
m_iShellBlue = 255;
m_szModel = "models/w_suit.mdl";
m_szClassName = "rune_frags";

CBaseRune::Spawn( );

}

/*********************************************************************

*********************************************************************/

class CStrengthRune : public CBaseRune

{

void Spawn( );

};

LINK_ENTITY_TO_CLASS( rune_strength, CStrengthRune );

void CStrengthRune::Spawn( )

{

m_iRuneFlag = RUNE_STRENGTH;
m_iShellRed = 0;
m_iShellGreen = 0;
m_iShellBlue = 255;
m_szModel = "models/w_suit.mdl";
m_szClassName = "rune_strength";
CBaseRune::Spawn( );

}

/*********************************************************************

*********************************************************************/

class CResistRune : public CBaseRune

{

void Spawn( );

};

LINK_ENTITY_TO_CLASS( rune_resist, CResistRune );

void CResistRune::Spawn( )

{

m_iRuneFlag = RUNE_RESIST;
m_iShellRed = 0;
m_iShellGreen = 255;
m_iShellBlue = 0;
m_szModel = "models/w_suit.mdl";
m_szClassName = "rune_resist";
CBaseRune::Spawn( );

}

/*********************************************************************

*********************************************************************/

class CHeathRune : public CBaseRune

{

void Spawn( );

};

LINK_ENTITY_TO_CLASS( rune_health, CHeathRune );

void CHeathRune::Spawn( )

{

m_iRuneFlag = RUNE_HEALTH;
m_iShellRed = 255;
m_iShellGreen = 0;
m_iShellBlue = 150;
m_szModel = "models/w_suit.mdl";
m_szClassName = "rune_health";
CBaseRune::Spawn( );

}

/*********************************************************************

*********************************************************************/

void CWorldRunes::Spawn( )

{

m_pSpot = NULL;

Precache( );

SetThink( SpawnRunes );

pev->nextthink = gpGlobals->time + 5.0; 

}

void CWorldRunes::Precache( )

{


}

CBaseEntity *CWorldRunes::SelectSpawnPoint(CBaseEntity *pSpot)

{

for ( int i = RANDOM_LONG(1,5); i > 0; i-- )

pSpot = UTIL_FindEntityByClassname( pSpot, "info_player_deathmatch" );

return pSpot;

}

void CWorldRunes::CreateRune(char *sz_RuneClass)

{

m_pSpot = SelectSpawnPoint( m_pSpot );


if(m_pSpot == NULL)

{

ALERT ( at_console, "Error Creating Runes\n" );

return;

}

CBaseEntity *CRune = CBaseEntity::Create(sz_RuneClass, m_pSpot->pev->origin, Vector(0, 0,0), NULL );

}

 

void CWorldRunes::SpawnRunes( )
{
if ( CVAR_GET_FLOAT( "mp_runes" ) == 0 )
    return;

CreateRune("rune_speed");
CreateRune("rune_strength");
CreateRune("rune_resist");
CreateRune("rune_health");
//CreateRune("rune_frags");

}

CWorldRunes *CWorldRunes::Create( )

{
CWorldRunes* WorldRunes = GetClassPtr( (CWorldRunes*)NULL ); 
WorldRunes->Spawn( ); 

return WorldRunes; 

}
