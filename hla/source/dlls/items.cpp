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

===== items.cpp ========================================================

  functions governing the selection/use of weapons for players

*/

#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "weapons.h"
#include "player.h"
#include "skill.h"
#include "items.h"
#include "gamerules.h"
//start hlpro2
#include "shake.h"
//end hlpro2

extern DLL_GLOBAL int  g_GameMode;

extern int gmsgItemPickup;

class CWorldItem : public CBaseEntity
{
public:
	void	KeyValue(KeyValueData *pkvd ); 
	void	Spawn( void );
	int		m_iType;
};

LINK_ENTITY_TO_CLASS(world_items, CWorldItem);

void CWorldItem::KeyValue(KeyValueData *pkvd)
{
	if (FStrEq(pkvd->szKeyName, "type"))
	{
		m_iType = atoi(pkvd->szValue);
		pkvd->fHandled = TRUE;
	}
	else
		CBaseEntity::KeyValue( pkvd );
}

void CWorldItem::Spawn( void )
{
	CBaseEntity *pEntity = NULL;

	switch (m_iType) 
	{
	case 44: // ITEM_BATTERY:
		pEntity = CBaseEntity::Create( "item_battery", pev->origin, pev->angles );
		break;
	case 42: // ITEM_ANTIDOTE:
		pEntity = CBaseEntity::Create( "item_antidote", pev->origin, pev->angles );
		break;
	case 43: // ITEM_SECURITY:
		pEntity = CBaseEntity::Create( "item_security", pev->origin, pev->angles );
		break;
	case 45: // ITEM_SUIT:
		pEntity = CBaseEntity::Create( "item_suit", pev->origin, pev->angles );
		break;
	}

	if (!pEntity)
	{
		ALERT( at_console, "unable to create world_item %d\n", m_iType );
	}
	else
	{
		pEntity->pev->target = pev->target;
		pEntity->pev->targetname = pev->targetname;
		pEntity->pev->spawnflags = pev->spawnflags;
	}

	REMOVE_ENTITY(edict());
}
/*
void CItem::Spin ( void )
{
	static int spin = 0;

	pev->angles.y = spin;
	spin++;

	if ( spin > 360 )
		spin = 0;

	pev->nextthink = gpGlobals->time + .1;
}

*/
void CItem::Spawn( void )
{


	pev->movetype = MOVETYPE_TOSS;
	pev->solid = SOLID_TRIGGER;
	UTIL_SetOrigin( pev, pev->origin );
	UTIL_SetSize(pev, Vector(-16, -16, 0), Vector(16, 16, 16));
	SetTouch(ItemTouch);	

	//SetThink(Spin);
	//pev->nextthink = gpGlobals->time + .1;
	
	if ( g_GameMode == GAME_LMS || g_GameMode == GAME_ARENA )
	{
		pev->effects |= EF_NODRAW;
		pev->solid = SOLID_NOT;
	}

	if (DROP_TO_FLOOR(ENT(pev)) == 0)
	{
		ALERT(at_error, "Item %s fell out of level at %f,%f,%f", STRING( pev->classname ), pev->origin.x, pev->origin.y, pev->origin.z);
		UTIL_Remove( this );
		return;
	}
}

extern int gEvilImpulse101;

void CItem::ItemTouch( CBaseEntity *pOther )
{
	// if it's not a player, ignore
	if ( !pOther->IsPlayer() )
	{
		return;
	}

	CBasePlayer *pPlayer = (CBasePlayer *)pOther;

	// ok, a player is touching this item, but can he have it?
	if ( !g_pGameRules->CanHaveItem( pPlayer, this ) )
	{
		// no? Ignore the touch.
		return;
	}

	if (MyTouch( pPlayer ))
	{
		SUB_UseTargets( pOther, USE_TOGGLE, 0 );
		SetTouch( NULL );
		
		// player grabbed the item. 
		g_pGameRules->PlayerGotItem( pPlayer, this );
		if ( g_pGameRules->ItemShouldRespawn( this ) == GR_ITEM_RESPAWN_YES )
		{
			Respawn(); 
		}
		else
		{
			UTIL_Remove( this );
		}
	}
	else if (gEvilImpulse101)
	{
		UTIL_Remove( this );
	}
}

CBaseEntity* CItem::Respawn( void )
{
	SetTouch( NULL );
	pev->effects |= EF_NODRAW;

	UTIL_SetOrigin( pev, g_pGameRules->VecItemRespawnSpot( this ) );// blip to whereever you should respawn.

	SetThink ( Materialize );
	pev->nextthink = g_pGameRules->FlItemRespawnTime( this ); 
	return this;
}

void CItem::Materialize( void )
{
	if ( pev->effects & EF_NODRAW )
	{
		// changing from invisible state to visible.
		EMIT_SOUND_DYN( ENT(pev), CHAN_WEAPON, "items/suitchargeok1.wav", 1, ATTN_NORM, 0, 150 );
		pev->effects &= ~EF_NODRAW;
		pev->effects |= EF_MUZZLEFLASH;
	}

	SetTouch( ItemTouch );
}

#define SF_SUIT_SHORTLOGON		0x0001

class CItemSuit : public CItem
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_suit.mdl");
		CItem::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_suit.mdl");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( pPlayer->pev->weapons & (1<<WEAPON_SUIT) )
			return FALSE;

		if ( pev->spawnflags & SF_SUIT_SHORTLOGON )
			EMIT_SOUND_SUIT(pPlayer->edict(), "!HEV_A0");		// short version of suit logon,
		else
			EMIT_SOUND_SUIT(pPlayer->edict(), "!HEV_AAx");	// long version of suit logon

		pPlayer->pev->weapons |= (1<<WEAPON_SUIT);
		return TRUE;
	}
};

LINK_ENTITY_TO_CLASS(item_suit, CItemSuit);



class CItemBattery : public CItem
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");
		CItem::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_battery.mdl");
		PRECACHE_SOUND( "items/gunpickup2.wav" );
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( pPlayer->pev->deadflag != DEAD_NO )
		{
			return FALSE;
		}

		if ((pPlayer->pev->armorvalue < MAX_NORMAL_BATTERY) &&
			(pPlayer->pev->weapons & (1<<WEAPON_SUIT)))
		{
			int pct;
			char szcharge[64];

			pPlayer->pev->armorvalue += gSkillData.batteryCapacity;
			pPlayer->pev->armorvalue = min(pPlayer->pev->armorvalue, MAX_NORMAL_BATTERY);

			EMIT_SOUND( pPlayer->edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );

			MESSAGE_BEGIN( MSG_ONE, gmsgItemPickup, NULL, pPlayer->pev );
				WRITE_STRING( STRING(pev->classname) );
			MESSAGE_END();

			
			// Suit reports new power level
			// For some reason this wasn't working in release build -- round it.
			pct = (int)( (float)(pPlayer->pev->armorvalue * 100.0) * (1.0/MAX_NORMAL_BATTERY) + 0.5);
			pct = (pct / 5);
			if (pct > 0)
				pct--;
		
			sprintf( szcharge,"!HEV_%1dP", pct );
			
			//EMIT_SOUND_SUIT(ENT(pev), szcharge);
			pPlayer->SetSuitUpdate(szcharge, FALSE, SUIT_NEXT_IN_30SEC);
			return TRUE;		
		}
		return FALSE;
	}
};

LINK_ENTITY_TO_CLASS(item_battery, CItemBattery);


class CItemAntidote : public CItem
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_antidote.mdl");
		CItem::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_antidote.mdl");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		pPlayer->SetSuitUpdate("!HEV_DET4", FALSE, SUIT_NEXT_IN_1MIN);
		
		pPlayer->m_rgItems[ITEM_ANTIDOTE] += 1;
		return TRUE;
	}
};

LINK_ENTITY_TO_CLASS(item_antidote, CItemAntidote);


class CItemSecurity : public CItem
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_security.mdl");
		CItem::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_security.mdl");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		pPlayer->m_rgItems[ITEM_SECURITY] += 1;
		return TRUE;
	}
};

LINK_ENTITY_TO_CLASS(item_security, CItemSecurity);

class CItemLongJump : public CItem
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_longjump.mdl");
		CItem::Spawn( );

/*		
		pev->rendermode = kRenderTransTexture;
		pev->renderamt = 200;

		pev->renderfx |= kRenderFxGlowShell;
		pev->rendercolor = Vector(100,100,100);
		pev->renderamt = 10;
*/
	//	UTIL_SetOrigin( pev, Vector(pev->origin.x, pev->origin.y, pev->origin.z));
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_longjump.mdl");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( pPlayer->m_fLongJump )
		{
			return FALSE;
		}

		if ( ( pPlayer->pev->weapons & (1<<WEAPON_SUIT) ) )
		{
			pPlayer->m_fLongJump = TRUE;// player now has longjump module

			g_engfuncs.pfnSetPhysicsKeyValue( pPlayer->edict(), "slj", "1" );

			MESSAGE_BEGIN( MSG_ONE, gmsgItemPickup, NULL, pPlayer->pev );
				WRITE_STRING( STRING(pev->classname) );
			MESSAGE_END();

			EMIT_SOUND_SUIT( pPlayer->edict(), "!HEV_A1" );	// Play the longjump sound UNDONE: Kelly? correct sound?
			return TRUE;		
		}
		return FALSE;
	}
};

LINK_ENTITY_TO_CLASS( item_longjump, CItemLongJump );


//start hlpro2
void CRune::Spawn( void )
{
	pev->angles.x = 0;
	pev->angles.z = 0;
	pev->velocity.x = RANDOM_FLOAT( -300, 300 );
	pev->velocity.y = RANDOM_FLOAT( -300, 300 );
	pev->velocity.z = RANDOM_FLOAT( 0, 300 );
	pev->movetype = MOVETYPE_TOSS;
	//pev->movetype = MOVETYPE_FLY;
	pev->solid = SOLID_TRIGGER;

	UTIL_SetOrigin( pev, pev->origin );
	UTIL_SetSize(pev, Vector(-16, -16, 0), Vector(16, 16, 16));
	SetTouch(RuneTouch);

	//kill
	//pev->renderamt = 255;
	pev->rendermode |= kRenderNormal;
	SetThink( SUB_StartFadeOut );
	pev->nextthink = gpGlobals->time + 25.0;

	//animate
	pev->sequence = 0;
	pev->animtime = gpGlobals->time;
	pev->framerate = 1.0;

	//EMIT_SOUND_DYN( ENT(pev), CHAN_WEAPON, "items/env_materialize2.wav", 1, ATTN_NORM, 0, 150 );	
}

void CRune::RuneTouch( CBaseEntity *pOther )
{
	// if it's not a player, ignore
	if ( !pOther->IsPlayer() )
	{
		return;
	}

	CBasePlayer *pPlayer = (CBasePlayer *)pOther;

	if (MyTouch( pPlayer ))
	{
		EMIT_SOUND( pPlayer->edict(), CHAN_ITEM, "items/env_materialize1.wav", 1, ATTN_NORM );

		SUB_UseTargets( pOther, USE_TOGGLE, 0 );
		SetTouch( NULL );
		
		UTIL_Remove( this );
	}
}

//===================================================================
//===================================================================

class CStrengthRune : public CRune
{
	Vector Color;

	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");

		Color = Vector(0,200,200);

		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z + 32);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)47);
			WRITE_BYTE( 5 );
		MESSAGE_END();

		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Color;
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_STRENGTH - 1;
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_battery.mdl");
		PRECACHE_SOUND ("items/env_materialize1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_STRENGTH;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Color;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)47);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup STRENGTH\n");
			UTIL_ScreenFade( pPlayer, Color, 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_strength, CStrengthRune );

class CProtectRune : public CRune
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");
		
		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)178);
			WRITE_BYTE( 5 );
		MESSAGE_END();
				
		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Vector(0,200,0);
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_PROTECT - 1;
	}
	void Precache( void )
	{
		//PRECACHE_MODEL ("models/w_runes.mdl");
		//PRECACHE_SOUND ("items/env_runepickup1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_PROTECT;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor.x = 0;
			pPlayer->pev->rendercolor.y = 200;
			pPlayer->pev->rendercolor.z = 0;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)178);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup PROTECT");
			UTIL_ScreenFade( pPlayer, Vector(0,200,0), 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_protect, CProtectRune );

class CFragRune : public CRune
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");
		
		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)13);
			WRITE_BYTE( 5 );
		MESSAGE_END();
				
		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Vector(200,200,200);
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_PROTECT - 1;
	}
	void Precache( void )
	{
		//PRECACHE_MODEL ("models/w_runes.mdl");
		//PRECACHE_SOUND ("items/env_runepickup1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_FRAG;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Vector(200,200,200);

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)13);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup FRAG");
			UTIL_ScreenFade( pPlayer, Vector(200,200,200), 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_frag, CFragRune );


class CAmmoRune : public CRune
{
	Vector Color;

	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");

		Color = Vector(200,128,0);
		
		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)107);
			WRITE_BYTE( 5 );
		MESSAGE_END();
				
		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Color;
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_PROTECT - 1;
	}
	void Precache( void )
	{
		//PRECACHE_MODEL ("models/w_runes.mdl");
		//PRECACHE_SOUND ("items/env_runepickup1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_AMMO;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Color;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)107);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup AMMO REGEN");
			UTIL_ScreenFade( pPlayer, Color, 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_ammo, CAmmoRune );


class CRegenRune : public CRune
{
	Vector Color;

	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");

		Color = Vector(200,0,200);

		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z + 32);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)144);
			WRITE_BYTE( 5 );
		MESSAGE_END();

		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Color;
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_STRENGTH - 1;
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_battery.mdl");
		PRECACHE_SOUND ("items/env_materialize1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_REGEN;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Color;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)144);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup REGEN\n");
			UTIL_ScreenFade( pPlayer, Color, 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_regen, CRegenRune );



class CGravityRune : public CRune
{
	Vector Color;

	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");

		Color = Vector(0,115,230);

		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z + 32);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)212);
			WRITE_BYTE( 5 );
		MESSAGE_END();

		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Color;
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_STRENGTH - 1;
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_battery.mdl");
		PRECACHE_SOUND ("items/env_materialize1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_GRAVITY;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Color;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)212);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup GRAVITY\n");
			UTIL_ScreenFade( pPlayer, Color, 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_gravity, CGravityRune );


class CCloakRune : public CRune
{
	Vector Color;

	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");

		Color = Vector(100,100,100);

		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z + 32);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)11);
			WRITE_BYTE( 5 );
		MESSAGE_END();

		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Color;
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_STRENGTH - 1;
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_battery.mdl");
		PRECACHE_SOUND ("items/env_materialize1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_CLOAK;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Color;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)11);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup CLOAK\n");
			UTIL_ScreenFade( pPlayer, Color, 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_cloak, CCloakRune );


class CVampireRune : public CRune
{
	Vector Color;

	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_battery.mdl");

		Color = Vector(200,0,0);

		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pev->origin.x);
			WRITE_COORD(pev->origin.y);
			WRITE_COORD(pev->origin.z + 32);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)73);
			WRITE_BYTE( 5 );
		MESSAGE_END();

		pev->renderfx = kRenderFxGlowShell;
		pev->rendercolor = Color;
		pev->renderamt = 10;

		CRune::Spawn( );

		//pev->body = RUNE_STRENGTH - 1;
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_battery.mdl");
		PRECACHE_SOUND ("items/env_materialize1.wav");
	}
	BOOL MyTouch( CBasePlayer *pPlayer )
	{
		if ( !pPlayer->m_fHasRune )
		{
			pPlayer->m_fHasRune = RUNE_VAMPIRE;
					
			pPlayer->pev->renderfx = kRenderFxGlowShell;
			pPlayer->pev->renderamt = 5;
			pPlayer->pev->rendercolor = Color;

			MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
			WRITE_BYTE( TE_PARTICLEBURST ); 
			WRITE_COORD(pPlayer->pev->origin.x);
			WRITE_COORD(pPlayer->pev->origin.y);
			WRITE_COORD(pPlayer->pev->origin.z);
			WRITE_SHORT( 50 );
			WRITE_BYTE((unsigned short)73);
			WRITE_BYTE( 5 );
			MESSAGE_END();

			ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Obtained powerup VAMPIRE\n");
			UTIL_ScreenFade( pPlayer, Color, 1, 1, 64, FFADE_IN); 

			return TRUE;
		}

		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( rune_vampire, CVampireRune );

//===================================================================
//===================================================================

void CWorldRunes::Spawn( )
{
	m_pSpot = NULL;
	Precache( );

	SetThink( SpawnRunes );
	pev->nextthink = gpGlobals->time + 5.0; 
}

void CWorldRunes::Precache( )
{
	UTIL_PrecacheOther("rune_frag");
	UTIL_PrecacheOther("rune_ammo");
	UTIL_PrecacheOther("rune_vampire");
	UTIL_PrecacheOther("rune_protect");
	UTIL_PrecacheOther("rune_regen");
	//UTIL_PrecacheOther("rune_haste");
	UTIL_PrecacheOther("rune_gravity");
	UTIL_PrecacheOther("rune_strength");
	UTIL_PrecacheOther("rune_cloak");
}

CBaseEntity *CWorldRunes::SelectSpawnPoint(CBaseEntity *pSpot)
{
	for ( int i = RANDOM_LONG(1,8); i > 0; i-- )
		pSpot = UTIL_FindEntityByClassname( pSpot, "info_player_deathmatch" );

	return pSpot;
}

void CWorldRunes::CreateRune(char *sz_RuneClass)
{
	m_pSpot = SelectSpawnPoint( m_pSpot );

	if( m_pSpot == NULL )
	{
		ALERT ( at_console, "Error Creating Powerups\n" );
		return;
	}

	CBaseEntity *CRune = CBaseEntity::Create(sz_RuneClass, m_pSpot->pev->origin, Vector(0, 0,0), NULL );
}

void CWorldRunes::SpawnRunes( )
{
	ALERT ( at_console, "Creating Powerups\n" );
	CreateRune( "rune_frag" );
	CreateRune( "rune_frag" );
	CreateRune( "rune_ammo" );
	CreateRune( "rune_ammo" );
	CreateRune( "rune_vampire" );
	CreateRune( "rune_vampire" );
	CreateRune( "rune_protect" );
	CreateRune( "rune_protect" );
	CreateRune( "rune_regen" );
	CreateRune( "rune_regen" );
	CreateRune( "rune_cloak" );
	CreateRune( "rune_cloak" );
	//CreateRune( "rune_haste" );
	CreateRune( "rune_gravity" );
	CreateRune( "rune_gravity" );
	CreateRune( "rune_strength" );
	CreateRune( "rune_strength" );

	SetThink( SpawnRunes );
	pev->nextthink = gpGlobals->time + 30.0; 
}

CWorldRunes *CWorldRunes::Create( )
{
	CWorldRunes* WorldRunes = GetClassPtr( (CWorldRunes*)NULL ); 
	WorldRunes->Spawn( ); 

	return WorldRunes; 
}
//end hlpro2
