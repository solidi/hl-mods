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
#include "weapons.h"
#include "monsters.h"
#include "player.h"
#include "gamerules.h"


enum mag60_e {
	MAG60_IDLE1 = 0,
	MAG60_IDLE2,
	MAG60_NULL,
    MAG60_RELOAD,
	MAG60_DRAW,
	MAG60_SHOOT,
	MAG60_SHOOT_EMPTY,
};

class CMag60 : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 2; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );
	void PrimaryAttack( void );
	void SecondaryAttack( void );
	void GlockFire( float flSpread, float flCycleTime, BOOL fUseAutoAim );
	BOOL Deploy( void );
	void Holster( void );
	void Reload( void );
	void WeaponIdle( void );
	float m_flSoundDelay;
	int m_iShell;

	BOOL m_fInZoom;// don't save this. 
};
LINK_ENTITY_TO_CLASS( weapon_mag60, CMag60 );

int CMag60::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "mags";
	p->iMaxAmmo1 = MAG60_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = M60_MAX_CLIP;
	p->iFlags = 0;
	p->iSlot = 0;
	p->iPosition = 4;
	p->iId = m_iId = WEAPON_PYTHON;
	p->iWeight = MAG60_WEIGHT;
	p->weaponName = "Mag-60 Automatic Handgun";        

	return 1;
}

int CMag60::AddToPlayer( CBasePlayer *pPlayer )
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

void CMag60::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2 )
	{
		return;
	}
	else
	{
	pev->classname = MAKE_STRING("weapon_mag60"); // hack to allow for old names
	Precache( );
	m_iId = WEAPON_PYTHON;
	SET_MODEL(ENT(pev), "models/wmodels/w_mag.mdl");

	m_iDefaultAmmo = MAG60_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
	}
}


void CMag60::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_mag.mdl");
	PRECACHE_MODEL("models/wmodels/w_mag.mdl");
	PRECACHE_MODEL("models/pmodels/p_mag.mdl");
	
	m_iShell = PRECACHE_MODEL ("models/shell.mdl");// brass shell

    PRECACHE_SOUND ("weapons/mag1.wav");
	PRECACHE_SOUND ("weapons/mag2.wav");
}

BOOL CMag60::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_mag.mdl", "models/pmodels/p_mag.mdl", MAG60_DRAW, "onehanded" );
}


void CMag60::Holster( )
{
	m_fInReload = FALSE;// cancel any reload in progress.

	if ( m_fInZoom )
	{
		SecondaryAttack();
	}
   // ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Switching Mag60 Handgun\n");
	m_pPlayer->m_flNextAttack = gpGlobals->time + .5;
	m_flTimeWeaponIdle = gpGlobals->time + 10 + RANDOM_FLOAT ( 0, 5 );
	
}

void CMag60::SecondaryAttack( void )
{
    GlockFire( 0.06, 0.15, TRUE );
}

void CMag60::PrimaryAttack( void )
{
    GlockFire( 0.12, 0.07, TRUE );

}

void CMag60::GlockFire( float flSpread , float flCycleTime, BOOL fUseAutoAim )
{
	if (m_iClip <= 0)
	{
		if (m_fFireOnEmpty)
		{
			//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Out of Mag60 ammo  Reload Weapon or Switch Weapon....\n");
			PlayEmptySound();
			m_flNextPrimaryAttack = gpGlobals->time + 0.2;
		}

		return;
	}

	m_iClip--;

	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	if (m_iClip != 0)
		SendWeaponAnim( MAG60_SHOOT );
	else
		SendWeaponAnim( MAG60_SHOOT );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(50,70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(100,150) 
							 + gpGlobals->v_forward * 25;
	EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 32 + gpGlobals->v_right * 6 , vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHELL ); 


	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;
	
	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/mag1.wav", RANDOM_FLOAT(0.92, 1.0), ATTN_NORM, 0, 98 + RANDOM_LONG(0,3));

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming;
	
	if ( fUseAutoAim )
	{
		vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_10DEGREES );
	}
	else
	{
		vecAiming = gpGlobals->v_forward;
	}

	m_pPlayer->FireBullets( 1, vecSrc, vecAiming, Vector( flSpread, flSpread, flSpread ), 8192, BULLET_PLAYER_9MM, 0 );
	m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + flCycleTime;

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );

	m_pPlayer->pev->punchangle.x -= .5;

}



void CMag60::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 22, MAG60_RELOAD, 1.5 );
	else
		iResult = DefaultReload( 22, MAG60_RELOAD, 1.5 );

	if (iResult)
	{
//		ShowSmart(m_pPlayer, 0x7, 2, 0, "--Reload--\n.38 ACP Clip" );
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}


void CMag60::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_10DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	// only idle if the slid isn't back
	if (m_iClip != 0)
	{
		int iAnim;
		float flRand = RANDOM_FLOAT(0, 1);
		if (flRand <= 0.3 + 0 * 0.75)
		{
			iAnim = MAG60_IDLE2;
			m_flTimeWeaponIdle = gpGlobals->time + 49.0 / 16;
		}
		else if (flRand <= 0.6 + 0 * 0.875)
		{
			iAnim = MAG60_IDLE1;
			m_flTimeWeaponIdle = gpGlobals->time + 60.0 / 16.0;
		}
		else
		{
			iAnim = MAG60_IDLE2;
			m_flTimeWeaponIdle = gpGlobals->time + 40.0 / 16.0;
		}
		SendWeaponAnim( iAnim );
	}
}
class CMag60Ammo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ||  CVAR_GET_FLOAT( "automatic_arena" )  == 2  )
	{
	
	}
	 else
	 {
		Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo5.mdl");
		CBasePlayerAmmo::Spawn( );
	 }
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo5.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		int bResult = (pOther->GiveAmmo( AMMO_MAG60_GIVE, "mags", MAG60_MAX_CARRY ) != -1);

		if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
};
LINK_ENTITY_TO_CLASS( ammo_357, CMag60Ammo );


#endif