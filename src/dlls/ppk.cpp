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

enum ppk_e {
	GLOCK_IDLE1 = 0,
	GLOCK_IDLE2,
	GLOCK_IDLE3,
	GLOCK_SHOOT,
	GLOCK_SHOOT_EMPTY,
	GLOCK_RELOAD,
	GLOCK_RELOAD_NOT_EMPTY,
	GLOCK_DRAW,
	GLOCK_HOLSTER,
	GLOCK_ADD_SILENCER
};

class CPpk : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 2; }
	int GetItemInfo(ItemInfo *p);

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	void Holster( );
	void AddSilencer( void );
	void GlockFire( float flSpread, float flCycleTime, BOOL fUseAutoAim );
	BOOL Deploy( void );
	void Reload( void );
	void WeaponIdle( void );
	int m_iShell;
};
LINK_ENTITY_TO_CLASS( weapon_ppk, CPpk );


void CPpk::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
	pev->classname = MAKE_STRING("weapon_ppk"); // hack to allow for old names
	Precache( );
	m_iId = WEAPON_GLOCK;
	SET_MODEL(ENT(pev), "models/wmodels/w_silenced.mdl");

	m_iDefaultAmmo = PPK_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
	}
}


void CPpk::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_ppk.mdl");
	PRECACHE_MODEL("models/wmodels/w_silenced.mdl");
	PRECACHE_MODEL("models/p_9mmhandgun.mdl");

	m_iShell = PRECACHE_MODEL ("models/shell.mdl");// brass shell

	PRECACHE_SOUND("items/9mmclip1.wav");
	PRECACHE_SOUND("items/9mmclip2.wav");

	PRECACHE_SOUND ("weapons/ppk2.wav");//silenced handgun
	PRECACHE_SOUND ("weapons/ppk1.wav");//handgun
	PRECACHE_SOUND ("weapons/ppkbond.wav");
}

int CPpk::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "ppk";
	p->iMaxAmmo1 = PPK_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = PPK_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 3;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_GLOCK;
	p->iWeight = PPK_WEIGHT;
	p->weaponName = "Silenced PPK {Bond Style}";

	return 1;
}

BOOL CPpk::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_ppk.mdl", "models/p_9mmhandgun.mdl", GLOCK_DRAW, "onehanded" );
}
void CPpk::Holster ( )
{
	//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Switching PPK\n");
}
void CPpk::SecondaryAttack( void )
{
    m_flTimeWeaponIdle = gpGlobals->time + 2.0f;
    m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + 2.0f;
    SetThink( AddSilencer );
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_AUTO, "weapons/ppkbond.wav", RANDOM_FLOAT(0.9, 1.0), ATTN_NORM);
    pev->nextthink = gpGlobals->time + 1.0f;
    SendWeaponAnim( GLOCK_HOLSTER );
}
void CPpk::AddSilencer( void )
{
    if(pev->body == 1)
        pev->body = 0;
    else
        pev->body = 1;
    SendWeaponAnim( GLOCK_DRAW );
}

void CPpk::PrimaryAttack( void )
{
	GlockFire( 0.01, 0.3, TRUE );
}

void CPpk::GlockFire( float flSpread , float flCycleTime, BOOL fUseAutoAim )
{
	if (m_iClip <= 0)
	{
		if (m_fFireOnEmpty)
		{
			//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Out of 9mm ammo  Reload Weapon or Switch Weapon.....\n");
			PlayEmptySound();
			m_flNextPrimaryAttack = gpGlobals->time + 0.2;
		}

		return;
	}

	m_iClip--;

	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	if (m_iClip != 0)
		SendWeaponAnim( GLOCK_SHOOT );
	else
		SendWeaponAnim( GLOCK_SHOOT_EMPTY );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(50,70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(100,150) 
							 + gpGlobals->v_forward * 25;
	EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 32 + gpGlobals->v_right * 6 , vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHELL ); 

	// silenced
	if (pev->body == 1)
	{
		m_pPlayer->m_iWeaponVolume = QUIET_GUN_VOLUME;
		m_pPlayer->m_iWeaponFlash = DIM_GUN_FLASH;

		switch(RANDOM_LONG(0,1))
		{
		case 0:
			EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/ppk2.wav", RANDOM_FLOAT(0.4, .2), ATTN_NORM);
			break;
		case 1:
			EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/ppk2.wav", RANDOM_FLOAT(0.4, .2), ATTN_NORM);
			break;
		}
	}
	else
	{
		// non-silenced
		m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;
		EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/ppk1.wav", RANDOM_FLOAT(0.92, 1.0), ATTN_NORM, 0, 98 + RANDOM_LONG(0,3));
	}

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

	m_pPlayer->pev->punchangle.x -= 2;
}


void CPpk::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 8, GLOCK_RELOAD, 1.5 );
	else
		iResult = DefaultReload( 8, GLOCK_RELOAD_NOT_EMPTY, 1.5 );

	if (iResult)
	{
//		ShowSmart (m_pPlayer, 0x7, 2, 0, "--Reload--\n.32 ACP Clip" );
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}



void CPpk::WeaponIdle( void )
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
			iAnim = GLOCK_IDLE3;
			m_flTimeWeaponIdle = gpGlobals->time + 49.0 / 16;
		}
		else if (flRand <= 0.6 + 0 * 0.875)
		{
			iAnim = GLOCK_IDLE1;
			m_flTimeWeaponIdle = gpGlobals->time + 60.0 / 16.0;
		}
		else
		{
			iAnim = GLOCK_IDLE2;
			m_flTimeWeaponIdle = gpGlobals->time + 40.0 / 16.0;
		}
		SendWeaponAnim( iAnim );
	}
}
class CPpkAmmo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	

	{
	
	}
	 else
	 {
		Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo7.mdl");
		CBasePlayerAmmo::Spawn( );
	 }
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo7.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		int cResult = (pOther->GiveAmmo( 24, "ppk", PPK_MAX_CARRY) != -1);
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
			return TRUE;
		}
		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( ammo_glockclip, CPpkAmmo );
LINK_ENTITY_TO_CLASS( ammo_9mmclip, CPpkAmmo );















