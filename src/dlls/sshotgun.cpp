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
#include "gamerules.h"


enum shotgun_e {
	SHOTGUN_FIRE,
	SHOTGUN_FIRE2,
	SHOTGUN_NULL,
	SHOTGUN_RELOAD,
	SHOTGUN_DRAW,
	SHOTGUN_HOLSTER,
    SHOTGUN_IDLE,
};

class CSshotgun : public CBasePlayerWeapon
{
public:

	void Spawn( void );
	void Precache( void );
	int iItemSlot( ) { return 3; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	BOOL Deploy( );
	void Holster( );
	void Reload( void );
	void WeaponIdle( void );
	int m_iShell;
};
LINK_ENTITY_TO_CLASS( weapon_sshotgun, CSshotgun );




void CSshotgun::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_SSHOTGUN;
	SET_MODEL(ENT(pev), "models/wmodels/w_sshotgun.mdl");

	m_iDefaultAmmo = SSHOTGUN_DEFAULT_GIVE;

	FallInit();// get ready to fall
	}
}


void CSshotgun::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_sshotgun.mdl");
	PRECACHE_MODEL("models/wmodels/w_sshotgun.mdl");
	PRECACHE_MODEL("models/pmodels/p_sshotgun.mdl");
	m_iShell = PRECACHE_MODEL ("models/shotgunshell.mdl");// shotgun shel
	PRECACHE_SOUND("items/9mmclip1.wav");              
	PRECACHE_SOUND ("weapons/sshotgun2.wav");
	PRECACHE_SOUND ("weapons/sshotgun1.wav");
	PRECACHE_SOUND ("weapons/reload1.wav");	
	PRECACHE_SOUND ("weapons/reload3.wav");	
	PRECACHE_SOUND ("weapons/357_cock1.wav"); 
	PRECACHE_SOUND ("weapons/scock1.wav");	
}

int CSshotgun::AddToPlayer( CBasePlayer *pPlayer )
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


int CSshotgun::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "buckshot";
	p->iMaxAmmo1 = BUCKSHOT_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = SSHOTGUN_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 5;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_SSHOTGUN;
	p->iWeight = SSHOTGUN_WEIGHT;
	p->weaponName = "12 gauge shotgun";        

	return 1;
}



BOOL CSshotgun::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_sshotgun.mdl", "models/pmodels/p_sshotgun.mdl", SHOTGUN_DRAW, "shotgun" );
}
void CSshotgun::Holster()
{
	
}

void CSshotgun::PrimaryAttack()
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextSecondaryAttack = gpGlobals->time + 0.03;
		return;
	}

	if (m_iClip == 0)
	{
		PlayEmptySound( );
	    m_flNextSecondaryAttack = gpGlobals->time + 0.6;
		return;
	}

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip--;
	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	SendWeaponAnim( SHOTGUN_FIRE );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );


	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/sshotgun1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 93 + RANDOM_LONG(0,0x1f));
	

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	m_pPlayer->FireBullets( 10, vecSrc, vecAiming, VECTOR_CONE_10DEGREES, 4096, BULLET_PLAYER_BUCKSHOT, 0 );

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_flNextPrimaryAttack = gpGlobals->time + 0.4;
	m_flNextSecondaryAttack = gpGlobals->time + 0.4;
	
	m_pPlayer->pev->punchangle.x -= 1;
}


void CSshotgun::SecondaryAttack( void )
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	if (m_iClip <= 1)
	{
		Reload( );
		PlayEmptySound( );
		m_flNextSecondaryAttack = gpGlobals->time + 0.6;
		return;
	}

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip -= 2;

	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	SendWeaponAnim( SHOTGUN_FIRE2 );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/sshotgun2.wav", RANDOM_FLOAT(0.98, 1.0), ATTN_NORM, 0, 85 + RANDOM_LONG(0,0x1f));
	
	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );
	
	m_pPlayer->FireBullets( 20, vecSrc, vecAiming, VECTOR_CONE_20DEGREES, 2048, BULLET_PLAYER_BUCKSHOT, 0 );

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_flNextPrimaryAttack = gpGlobals->time + 1.5;
	m_flNextSecondaryAttack = gpGlobals->time + 1.5;

	m_pPlayer->pev->punchangle.x -= 10;
}	



void CSshotgun::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 2, SHOTGUN_RELOAD, 3.0 );
	else
		iResult = DefaultReload( 2, SHOTGUN_RELOAD, 3.0 );

	if (iResult)
	{
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}
void CSshotgun::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = SHOTGUN_IDLE;	
		break;
	
	default:
	case 1:
		iAnim = SHOTGUN_IDLE;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}




