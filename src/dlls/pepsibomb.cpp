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
#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"


#define	PEPSIBOMB_PRIMARY_VOLUME		450

enum handgrenade_e {
	HANDGRENADE_IDLE = 0,
	HANDGRENADE_FIDGET,
	HANDGRENADE_PINPULL,
	HANDGRENADE_THROW1,	// toss
	HANDGRENADE_THROW2,	// medium
	HANDGRENADE_THROW3,	// hard
	HANDGRENADE_HOLSTER,
	HANDGRENADE_DRAW
};


class CPepsiBomb : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 5; }
	int GetItemInfo(ItemInfo *p);

	void PrimaryAttack( void );
	BOOL Deploy( void );
	BOOL CanHolster( void );
	void Holster( void );
	void WeaponIdle( void );
	float m_flStartThrow;
	float m_flReleaseThrow;
	int   m_iPlayerRune;
};
LINK_ENTITY_TO_CLASS( weapon_pepsibomb, CPepsiBomb );


void CPepsiBomb::Spawn( )
{
	    if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_PEPSIBOMB;
	SET_MODEL(ENT(pev), "models/pepsi.mdl");

	pev->dmg = gSkillData.plrDmgHandGrenade;

	m_iDefaultAmmo = HANDGRENADE_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
	}
}


void CPepsiBomb::Precache( void )
{
	PRECACHE_MODEL("models/pepsi.mdl");
	PRECACHE_MODEL("models/vmodels/v_pepsibomb.mdl");
	PRECACHE_MODEL("models/pmodels/p_pepsibomb.mdl");
	PRECACHE_SOUND("weapons/pinpull.wav");
}

int CPepsiBomb::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname); 
	p->pszAmmo1 = "pepsibomb"; 
	p->iMaxAmmo1 = CLUSTERGRENADE_MAX_CARRY; 
	p->pszAmmo2 = NULL; 
	p->iMaxAmmo2 = -1; 
	p->iMaxClip = WEAPON_NOCLIP; 
	p->iSlot = 1; 
	p->iPosition = 0; 
	p->iId = m_iId = WEAPON_PEPSIBOMB; 
	p->iWeight = CLGRENADE_WEIGHT; 
	p->iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE; 
	p->weaponName = "Pepsi Bomb";   
	return 1;
}


BOOL CPepsiBomb::Deploy( )
{
    m_flReleaseThrow = -1;
	return DefaultDeploy( "models/vmodels/v_pepsibomb.mdl", "models/pmodels/p_pepsibomb.mdl", HANDGRENADE_DRAW, "crowbar" );
}

BOOL CPepsiBomb::CanHolster( void )
{
	// can only holster hand grenades when not primed!
	return ( m_flStartThrow == 0 );
}

void CPepsiBomb::Holster( )
{
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
	{
		SendWeaponAnim( HANDGRENADE_HOLSTER );
	}
	else
	{
		// no more grenades!
		m_pPlayer->pev->weapons &= ~(1<<WEAPON_PEPSIBOMB);
		SetThink( DestroyItem );
		pev->nextthink = gpGlobals->time + 0.1;
	}
    //ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Switching Cluster Grenades\n");
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "common/null.wav", 1.0, ATTN_NORM);
}

void CPepsiBomb::PrimaryAttack()
{
	if (!m_flStartThrow && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] > 0)
	{
		m_flStartThrow = gpGlobals->time;
		m_flReleaseThrow = 0;

		SendWeaponAnim( HANDGRENADE_PINPULL );
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/pinpull.wav", 1.0, ATTN_NORM);
//		ShowSmart (m_pPlayer, 0x7, 2, 0, "--Action--\nPin Pulled..." );
		m_flTimeWeaponIdle = gpGlobals->time + 0.5;
	}
}


void CPepsiBomb::WeaponIdle( void )
{
	if (m_flReleaseThrow == 0)
		m_flReleaseThrow = gpGlobals->time;

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	if (m_flStartThrow)
	{
		Vector angThrow = m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle;

		if (angThrow.x < 0)
			angThrow.x = -10 + angThrow.x * ((90 - 10) / 90.0);
		else
			angThrow.x = -10 + angThrow.x * ((90 + 10) / 90.0);

		float flVel = (90 - angThrow.x) * 4;
		if (flVel > 500)
			flVel = 500;

		UTIL_MakeVectors( angThrow );

		Vector vecSrc = m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_forward * 16;

		Vector vecThrow = gpGlobals->v_forward * flVel + m_pPlayer->pev->velocity;

		// alway explode 3 seconds after the pin was pulled
		float time = m_flStartThrow - gpGlobals->time + 3.0;

		if (time < 0)
			time = 0;
//            ShowSmart (m_pPlayer, 0x7, 2, 0, "--Action--\nCluster Grenade Thorwn!" );

		CGrenade::Pepsi( m_pPlayer->pev, vecSrc, vecThrow, time );

		if (flVel < 500)
		{
			SendWeaponAnim( HANDGRENADE_THROW1 );
		}
		else if (flVel < 1000)
		{
			SendWeaponAnim( HANDGRENADE_THROW2 );
		}
		else
		{
			SendWeaponAnim( HANDGRENADE_THROW3 );
		}

		// player "shoot" animation
		m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

		m_flStartThrow = 0;
		m_flNextPrimaryAttack = gpGlobals->time + 0.5;
		m_flTimeWeaponIdle = gpGlobals->time + 0.5;

		m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType]--;

		if ( !m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] )
		{
			// just threw last grenade
			// set attack times in the future, and weapon idle in the future so we can see the whole throw
			// animation, weapon idle will automatically retire the weapon for us.
			m_flTimeWeaponIdle = m_flNextSecondaryAttack = m_flNextPrimaryAttack = gpGlobals->time + 0.5;// ensure that the animation can finish playing
		}
		return;
	}
	else if (m_flReleaseThrow > 0)
	{
		// we've finished the throw, restart.
		m_flStartThrow = 0;

		if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
		{
			SendWeaponAnim( HANDGRENADE_DRAW );
		}
		else
		{
			RetireWeapon();
			SetThink( DestroyItem );
		    pev->nextthink = gpGlobals->time + 0.1;
		}

		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
		m_flReleaseThrow = -1;
		return;
	}

	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
	{
		int iAnim;
		float flRand = RANDOM_FLOAT(0, 1);
		if (flRand <= 0.75)
		{
			iAnim = HANDGRENADE_FIDGET;
			m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
		}
		else 
		{
			iAnim = HANDGRENADE_FIDGET;
			m_flTimeWeaponIdle = gpGlobals->time + 75.0 / 30.0;
		}

		SendWeaponAnim( iAnim );
	}
}




