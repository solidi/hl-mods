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
#include "hornet.h"
#include "gamerules.h"


enum usas_e {
	USAS_IDLE = 0,
	USAS_IDLE1,
	USAS_NULL,
	USAS_RELOAD,
	USAS_DEPOLY,
	USAS_SHOOT,

};

class CUsas : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 4; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	void Holster( );
	BOOL Deploy( void );
	BOOL IsUseable( void );
	void Reload( void );
	void WeaponIdle( void );
	float m_flNextAnimTime;
	int m_iShell;
};
LINK_ENTITY_TO_CLASS( weapon_usas, CUsas );

BOOL CUsas::IsUseable( void )
{
	return TRUE;
}

void CUsas::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 )
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_HORNETGUN;
	SET_MODEL(ENT(pev), "models/wmodels/w_usas.mdl");

	m_iDefaultAmmo = USAS_DEFAULT_GIVE;


	FallInit();// get ready to fall down.
	}
}


void CUsas::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_usas.mdl");
	PRECACHE_MODEL("models/wmodels/w_usas.mdl");
	PRECACHE_MODEL("models/pmodels/p_usas.mdl");
	
	m_iShell = PRECACHE_MODEL ("models/shotgunshell.mdl");// shell            

    PRECACHE_SOUND ("weapons/usas1.wav");
	PRECACHE_SOUND ("weapons/reloadusas.wav");

}

int CUsas::AddToPlayer( CBasePlayer *pPlayer )
{
	if ( CBasePlayerWeapon::AddToPlayer( pPlayer ) )
	{
		if ( g_pGameRules->IsMultiplayer() )
		{
			// in multiplayer, all hivehands come full. 
			pPlayer->m_rgAmmo[ PrimaryAmmoIndex() ] = USAS_MAX_CLIP;
		}

		MESSAGE_BEGIN( MSG_ONE, gmsgWeapPickup, NULL, pPlayer->pev );
			WRITE_BYTE( m_iId );
		MESSAGE_END();
		return TRUE;
	}
	return FALSE;
}

int CUsas::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "slugs";
	p->iMaxAmmo1 = USAS_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = USAS_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 12;
	p->iId = m_iId = WEAPON_HORNETGUN;
	p->iFlags = 0;
	p->iWeight = USAS_WEIGHT;
    p->weaponName = "USAS-12 Automatic Shotgun";        


	return 1;
}


BOOL CUsas::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_usas.mdl", "models/pmodels/p_usas.mdl", USAS_DEPOLY, "mp5" );
}
void CUsas::Holster( )
{
	m_fInReload = FALSE;// cancel any reload in progress.  
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	SendWeaponAnim( USAS_IDLE );

}
void CUsas::PrimaryAttack()
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.03;
		return;
	}

	if (m_iClip == 0)
	{
			//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Out of Buckshots  Reload Weapon or Switch Weapon.....\n");
			m_flNextPrimaryAttack = gpGlobals->time + 0.2;
		    PlayEmptySound( );
		return;
	}

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;

	m_iClip--;
	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	SendWeaponAnim( USAS_SHOOT );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/usas1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 93 + RANDOM_LONG(0,0x1f));

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	m_pPlayer->FireBullets( 2, vecSrc, vecAiming, VECTOR_CONE_15DEGREES, 4096, BULLET_PLAYER_BUCKSHOT, 0 );
	
	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(300,300) 
							 + gpGlobals->v_up * RANDOM_FLOAT(-200,-200) 
							 + gpGlobals->v_forward * 14;

	EjectBrass ( m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 20 + gpGlobals->v_right * 4 , vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHOTSHELL); 

	m_flNextPrimaryAttack = gpGlobals->time + 0.09;

	if (m_iClip != 0)
		m_flTimeWeaponIdle = gpGlobals->time + 5.0;
	else
		m_flTimeWeaponIdle = 0.05;
	m_fInReload = 0;

	m_pPlayer->pev->punchangle.x -= .01;
}
void CUsas::SecondaryAttack( void )
{
	
}

void CUsas::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 40, USAS_RELOAD, 2.4 );
	else
		iResult = DefaultReload( 40, USAS_RELOAD, 2.4 );

	if (iResult)
	{
//	    ShowSmart (m_pPlayer, 0x7, 2, 0, "--Reload--\nSlugs" );
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/reloadusas.wav", RANDOM_FLOAT(0.9, 1.0), ATTN_NORM);
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}

void CUsas::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = USAS_IDLE;	
		break;
	
	default:
	case 1:
		iAnim = USAS_IDLE;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}

#endif