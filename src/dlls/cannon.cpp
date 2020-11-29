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
#include "soundent.h"
#include "shake.h"
#include "gamerules.h"

enum cannon_e {
	CANNON_NULL = 0,
	CANNON_NULL1,
	CANNON_SPINUP,
	CANNON_FIRE,
	CANNON_NULL2,
	CANNON_NULL3,
	CANNON_NULL4,
	CANNON_DRAW,
	CANNON_HOLSTER,
	CANNON_IDLE1,
	CANNON_IDLE,
	
};

class CCannon : public CBasePlayerWeapon
{
public:

	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 4; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	BOOL Deploy( void );
	void Reload( void );
	void Holster( void );

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	void WeaponIdle( void );
	int m_fInReload;
	float m_flNextReload;
	float m_flNextAnimTime;

	int m_iShell;


};
LINK_ENTITY_TO_CLASS( weapon_cannon, CCannon );



void CCannon::Spawn( )
{
	if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ||  CVAR_GET_FLOAT( "automatic_arena" )  == 2  )
	{
		return;
	}
	else
	{

	Precache( );
	m_iId = WEAPON_GAUSS;
	SET_MODEL(ENT(pev), "models/wmodels/w_cannon.mdl");

	m_iDefaultAmmo = CANNON_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
	}
}


void CCannon::Precache( void )
{
	PRECACHE_MODEL("models/wmodels/w_cannon.mdl");
	PRECACHE_MODEL("models/vmodels/v_cannon.mdl");
	PRECACHE_MODEL("models/pmodels/p_cannon.mdl");

	m_iShell = PRECACHE_MODEL ("models/30mm/w_flakshell.mdl");// Big ass shell

    PRECACHE_SOUND("weapons/cannon1.wav");
	PRECACHE_SOUND("weapons/cannon2.wav");
	PRECACHE_SOUND("weapons/shellfly.wav");
	PRECACHE_SOUND("weapons/reloadcannon.wav");
	
}

int CCannon::AddToPlayer( CBasePlayer *pPlayer )
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

int CCannon::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "Shells";
	p->iMaxAmmo1 = M203_GRENADE_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = CANNON_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 13;
	p->iId = m_iId = WEAPON_GAUSS;
	p->iFlags = 0;
	p->iWeight = CANNON_WEIGHT;
	p->weaponName = "30mm Shell Assault Cannon";        

	return 1;
}


BOOL CCannon::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_cannon.mdl", "models/pmodels/p_cannon.mdl", CANNON_DRAW, "gauss" );
}


void CCannon::Holster( )
{
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	SendWeaponAnim( CANNON_HOLSTER );
}


void CCannon::PrimaryAttack()
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	 if (m_iClip == 0)
	{
	    PlayEmptySound( );
		SendWeaponAnim( CANNON_IDLE );
		m_flNextPrimaryAttack = gpGlobals->time + .8;
		return;
	}

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;
	
	MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, pev->origin );
			WRITE_BYTE( TE_SMOKE );
			WRITE_COORD( pev->origin.x );
			WRITE_COORD( pev->origin.y );
			WRITE_COORD( pev->origin.z );
			WRITE_SHORT( g_sModelIndexSmoke );
			WRITE_BYTE( 10 ); // scale * 10
			WRITE_BYTE( 12  ); // framerate
		MESSAGE_END();
			
	m_iClip--;

	SendWeaponAnim( CANNON_FIRE );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	if ( RANDOM_LONG(0,1) )
	{
		// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/cannon1.wav", 0.8, ATTN_NORM);
	}
	else
	{
		// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/cannon1.wav", 0.8, ATTN_NORM);
	}
 
	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	// Shoot an Contact Grenade. When touch surface, EXPLODE!
	CGrenade::ShootShellContact ( m_pPlayer->pev, 
							m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_forward * 5, 
							gpGlobals->v_forward * 2000 );

	EMIT_SOUND( ENT(pev), CHAN_VOICE, "weapons/shellfly.wav", 1, 0.5 );

	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(200,200) 
							 + gpGlobals->v_up * RANDOM_FLOAT(200,200) //x,y values? 
							 + gpGlobals->v_forward * 25;
	EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs
					+ gpGlobals->v_up * -12 
					+ gpGlobals->v_forward * 25 
					+ gpGlobals->v_right * 8, vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHELL); 

	m_flNextPrimaryAttack = gpGlobals->time + 1.0;
	m_flNextSecondaryAttack = gpGlobals->time + 1.0;
	m_flTimeWeaponIdle = gpGlobals->time + .6;// idle pretty soon after shooting.

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_pPlayer->pev->punchangle.x -= 5;

}

void CCannon::SecondaryAttack()
{

}
void CCannon::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 6, CANNON_IDLE, 2.2 );
	else
		iResult = DefaultReload( 6, CANNON_IDLE, 2.2 );

	if (iResult)
	{
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/reloadcannon.wav", RANDOM_FLOAT(0.9, 1.0), ATTN_NORM);
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}
void CCannon::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = CANNON_IDLE;	
		break;
	
	default:
	case 1:
		iAnim = CANNON_IDLE1;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}

class CCannonAmmo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ||  CVAR_GET_FLOAT( "automatic_arena" )  == 2  )
	{
		
	}
	 else
	 {
		Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo9.mdl");
		CBasePlayerAmmo::Spawn( );
	 }
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo9.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		int bResult = (pOther->GiveAmmo( AMMO_CANNON_GIVE, "Shells", M203_GRENADE_MAX_CARRY ) != -1);

		if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
};
LINK_ENTITY_TO_CLASS( ammo_gaussclip, CCannonAmmo );


#endif