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
#if !defined( OEM_BUILD ) && !defined( HLDEMO_BUILD )

#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"
#include "gamerules.h"

#define BOLT_AIR_VELOCITY	2000
#define BOLT_WATER_VELOCITY	1000

// speed - the ideal magnitude of my velocity

class CBolt : public CBaseEntity
{
	void Spawn( void );
	void Spawn1( void );
	void Precache( void );
	int  Classify ( void );
	void EXPORT BubbleThink( void );
	void EXPORT BoltTouch( CBaseEntity *pOther );

	int m_iTrail;

public:
	static CBolt *BoltCreate( void );
};
LINK_ENTITY_TO_CLASS( boltgun_bolt, CBolt );

CBolt *CBolt::BoltCreate( void )
{
	// Create a new entity with CBolt private data
	CBolt *pBolt = GetClassPtr( (CBolt *)NULL );
	pBolt->pev->classname = MAKE_STRING("bolt");
	pBolt->Spawn();

	return pBolt;
}

void CBolt::Spawn( )
{
	Precache( );
	pev->movetype = MOVETYPE_FLY;
	pev->solid = SOLID_BBOX;

	pev->gravity = 0.5;

	SET_MODEL(ENT(pev), "models/bolt.mdl");

	UTIL_SetOrigin( pev, pev->origin );
	UTIL_SetSize(pev, Vector(0, 0, 0), Vector(0, 0, 0));

	SetTouch( BoltTouch );
	SetThink( BubbleThink );
	pev->nextthink = gpGlobals->time + 0.2;
}

void CBolt::Precache( )
{
	PRECACHE_MODEL ("models/bolt.mdl");
	PRECACHE_SOUND("weapons/xbow_hitbod1.wav");
	PRECACHE_SOUND("weapons/xbow_hitbod2.wav");
	PRECACHE_SOUND("weapons/xbow_fly1.wav");
	PRECACHE_SOUND("weapons/xbow_hit1.wav");
	PRECACHE_SOUND("fvox/beep.wav");
	m_iTrail = PRECACHE_MODEL("sprites/streak.spr");
}


int	CBolt :: Classify ( void )
{
	return	CLASS_NONE;
}

void CBolt::BoltTouch( CBaseEntity *pOther )
{
	SetTouch( NULL );
	SetThink( NULL );

	if (pOther->pev->takedamage)
	{
		TraceResult tr = UTIL_GetGlobalTrace( );
		entvars_t	*pevOwner;

		pevOwner = VARS( pev->owner );

		// UNDONE: this needs to call TraceAttack instead
		ClearMultiDamage( );

		if ( pOther->IsPlayer() )
		{
			pOther->TraceAttack(pevOwner, gSkillData.plrDmgBoltgun, pev->velocity.Normalize(), &tr, DMG_NEVERGIB ); 
		}

		ApplyMultiDamage( pev, pevOwner );
		UTIL_Remove(this); //remove!

		pev->velocity = Vector( 0, 0, 0 );
		// play body "thwack" sound
		switch( RANDOM_LONG(0,1) )
		{
		case 0:
			EMIT_SOUND(ENT(pev), CHAN_WEAPON, "weapons/xbow_hitbod1.wav", 1, ATTN_NORM); break;
		case 1:
			EMIT_SOUND(ENT(pev), CHAN_WEAPON, "weapons/xbow_hitbod2.wav", 1, ATTN_NORM); break;
		}

		if ( !g_pGameRules->IsMultiplayer() )
		{
			Killed( pev, GIB_NEVER );
		}
	}
	else
	{
		EMIT_SOUND_DYN(ENT(pev), CHAN_WEAPON, "weapons/xbow_hit1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 98 + RANDOM_LONG(0,7));

		SetThink( SUB_Remove );
		pev->nextthink = gpGlobals->time;// this will get changed below if the bolt is allowed to stick in what it hit.

		if ( FClassnameIs( pOther->pev, "worldspawn" ) )
		{
			// if what we hit is static architecture, can stay around for a while.
			Vector vecDir = pev->velocity.Normalize( );
			UTIL_SetOrigin( pev, pev->origin - vecDir * 12 );
			pev->angles = UTIL_VecToAngles( vecDir );
			pev->solid = SOLID_NOT;
			pev->movetype = MOVETYPE_FLY;
			pev->velocity = Vector( 0, 0, 0 );
			pev->avelocity.z = 0;
			pev->angles.z = RANDOM_LONG(0,360);
			pev->nextthink = gpGlobals->time + 10.0;
		}

		if (UTIL_PointContents(pev->origin) != CONTENTS_WATER)
		{
			UTIL_Sparks( pev->origin );
		}
	}

	{
 
		
	}
}

void CBolt::BubbleThink( void )
{
	pev->nextthink = gpGlobals->time + 0.1;

	if (pev->waterlevel == 0)
		return;

	UTIL_BubbleTrail( pev->origin - pev->velocity * 0.1, pev->origin, 1 );
}
enum boltgun_e {
	CROSSBOW_IDLE1 = 0,	// full
	CROSSBOW_IDLE2,		// empty
	CROSSBOW_FIDGET1,	// full
	CROSSBOW_FIDGET2,	// empty
	CROSSBOW_FIRE1,		// full
	CROSSBOW_FIRE2,		// reload
	CROSSBOW_FIRE3,		// empty
	CROSSBOW_RELOAD,	// from empty
	CROSSBOW_DRAW1,		// full
	CROSSBOW_DRAW2,		// empty
	CROSSBOW_HOLSTER1,	// full
	CROSSBOW_HOLSTER2,	// empty
};


class CBoltgun : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( ) { return 3; }
	int GetItemInfo(ItemInfo *p);

	void FireBolt( void );
	void PrimaryAttack( void );
	void SecondaryAttack( void );
	int AddToPlayer( CBasePlayer *pPlayer );
	BOOL Deploy( );
	void Holster( );
	void Reload( void );
	void WeaponIdle( void );

	int m_fInZoom; // don't save this
};
LINK_ENTITY_TO_CLASS( weapon_boltgun, CBoltgun );

void CBoltgun::Spawn( )
{
	if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" )  == 2  )
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_BOLTGUN;
	SET_MODEL(ENT(pev), "models/w_crossbow.mdl");

	m_iDefaultAmmo = BOLTGUN_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
	}
}

int CBoltgun::AddToPlayer( CBasePlayer *pPlayer )
{
	if ( CBasePlayerWeapon::AddToPlayer( pPlayer ) )
	{
		MESSAGE_BEGIN( MSG_ONE, gmsgWeapPickup, NULL, pPlayer->pev );
			WRITE_BYTE( m_iId );
		MESSAGE_END();
		return TRUE;
	}
	return FALSE;
}

void CBoltgun::Precache( void )
{
	PRECACHE_MODEL("models/w_crossbow.mdl");
	PRECACHE_MODEL("models/vmodels/v_boltgun.mdl");
	PRECACHE_MODEL("models/pmodels/p_boltgun.mdl");
	PRECACHE_SOUND("weapons/boltgun1.wav");
	PRECACHE_SOUND("weapons/xbow_reload1.wav");

	UTIL_PrecacheOther( "boltgun_bolt" );
}


int CBoltgun::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "bolt";
	p->iMaxAmmo1 = BOLT_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = BOLTGUN_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 11;
	p->iId = m_iId = WEAPON_BOLTGUN;
	p->iFlags = 0;
	p->iWeight = BOLTGUN_WEIGHT;
	p->weaponName = "Air-Compressed Auto Boltgun";    
	return 1;
}


BOOL CBoltgun::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_boltgun.mdl", "models/pmodels/p_boltgun.mdl", CROSSBOW_DRAW2, "bow" );
}

void CBoltgun::Holster( )
{
	m_fInReload = FALSE;// cancel any reload in progress.

	if ( m_fInZoom )
	{
		SecondaryAttack( );
	}

	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	if (m_iClip)
		SendWeaponAnim( CROSSBOW_HOLSTER1 );
	else
		SendWeaponAnim( CROSSBOW_HOLSTER2 );
}

void CBoltgun::PrimaryAttack( void )
{
	//if ( m_fInZoom && g_pGameRules->IsMultiplayer() )
	{
		FireBolt();
		return;
	}

	//FireBolt();
}
void CBoltgun::FireBolt()
{
	TraceResult tr;

	if (m_iClip == 0)
	{
		PlayEmptySound( );
		return;
	}

	m_pPlayer->m_iWeaponVolume = QUIET_GUN_VOLUME;

	m_iClip--;

	// make twang sound
	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/boltgun1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 93 + RANDOM_LONG(0,0xF));

	//if (m_iClip)
//	{

	//	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/xbow_reload1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 93 + RANDOM_LONG(0,0xF));
		SendWeaponAnim( CROSSBOW_FIRE3 );
	//}
	//else if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] == 0)
	//{
	//	SendWeaponAnim( CROSSBOW_FIRE3 );
	//}

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	Vector anglesAim = m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle;
	UTIL_MakeVectors( anglesAim );

	// Vector vecSrc	 = pev->origin + gpGlobals->v_up * 16 + gpGlobals->v_forward * 20 + gpGlobals->v_right * 4;
	anglesAim.x		= -anglesAim.x;
	Vector vecSrc	 = m_pPlayer->GetGunPosition( ) - gpGlobals->v_up * 2;
	Vector vecDir	 = gpGlobals->v_forward;

	//CBaseEntity *pBolt = CBaseEntity::Create( "crossbow_bolt", vecSrc, anglesAim, m_pPlayer->edict() );
	CBolt *pBolt = CBolt::BoltCreate();
	pBolt->pev->origin = vecSrc;
	pBolt->pev->angles = anglesAim;
	pBolt->pev->owner = m_pPlayer->edict();

	if (m_pPlayer->pev->waterlevel == 3)
	{
		pBolt->pev->velocity = vecDir * BOLT_WATER_VELOCITY;
		pBolt->pev->speed = BOLT_WATER_VELOCITY;
	}
	else
	{
		pBolt->pev->velocity = vecDir * BOLT_AIR_VELOCITY;
		pBolt->pev->speed = BOLT_AIR_VELOCITY;
	}
	pBolt->pev->avelocity.z = 10;

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_flNextPrimaryAttack = gpGlobals->time + 0.1;

	m_flNextSecondaryAttack = gpGlobals->time + 0.1;
	if (m_iClip != 0)
		m_flTimeWeaponIdle = gpGlobals->time + 5.0;
	else
		m_flTimeWeaponIdle = 0.75;

	m_pPlayer->pev->punchangle.x -= 1;
}
void CBoltgun::SecondaryAttack()
{
	
}

void CBoltgun::Reload( void )
{
	if ( m_fInZoom )
	{
		SecondaryAttack();
	}

	if (DefaultReload( 30, CROSSBOW_RELOAD, 4.5 ))
	{
		EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/xbow_reload1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 93 + RANDOM_LONG(0,0xF));
	}
}


void CBoltgun::WeaponIdle( void )
{
	m_pPlayer->GetAutoaimVector( AUTOAIM_2DEGREES );  // get the autoaim vector but ignore it;  used for autoaim crosshair in DM

	ResetEmptySound( );
	
	if (m_flTimeWeaponIdle < gpGlobals->time)
	{
		float flRand = RANDOM_FLOAT(0, 1);
		if (flRand <= 0.75)
		{
			if (m_iClip)
			{
				SendWeaponAnim( CROSSBOW_IDLE1 );
			}
			else
			{
				SendWeaponAnim( CROSSBOW_IDLE2 );
			}
			m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
		}
		else
		{
			if (m_iClip)
			{
				SendWeaponAnim( CROSSBOW_FIDGET1 );
				m_flTimeWeaponIdle = gpGlobals->time + 90.0 / 30.0;
			}
			else
			{
				SendWeaponAnim( CROSSBOW_FIDGET2 );
				m_flTimeWeaponIdle = gpGlobals->time + 80.0 / 30.0;
			}
		}
	}
}



#endif