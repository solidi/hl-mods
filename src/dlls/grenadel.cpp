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
#include "player.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "effects.h"
#include "customentity.h"
#include "gamerules.h"


enum grenadelauncher_e {
	GL_IDLE1 = 0,
	GL_IDLE2,
	GL_FIRE1,
	GL_FIRE2,
	GL_RELOAD1,
	GL_RELOAD2,
	GL_RELOAD3,
	GL_RELOAD4,
	GL_DRAW,
	GL_DRAW1,
	GL_HOLSTER,

};


class CGrenadelauncher : public CBasePlayerWeapon
{
public:
	int		Save( CSave &save );
	int		Restore( CRestore &restore );
	static	TYPEDESCRIPTION m_SaveData[];

	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 4; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	BOOL Deploy( void );
	void Holster( void );

	void PrimaryAttack( void );
	void WeaponIdle( void );
	void SecondaryAttack( void );
	float m_flNextAnimTime;
	void Reload( void );
	int m_fInReload;
	float m_flNextReload;
	int m_iShell;
	float m_flPumpTime;
};
LINK_ENTITY_TO_CLASS( weapon_grenadel, CGrenadelauncher );

TYPEDESCRIPTION	CGrenadelauncher::m_SaveData[] = 
{
	DEFINE_FIELD( CGrenadelauncher, m_flNextReload, FIELD_TIME ),
	DEFINE_FIELD( CGrenadelauncher, m_fInReload, FIELD_INTEGER ),
	DEFINE_FIELD( CGrenadelauncher, m_flNextReload, FIELD_TIME ),
	DEFINE_FIELD( CGrenadelauncher, m_flPumpTime, FIELD_TIME ),
};
IMPLEMENT_SAVERESTORE( CGrenadelauncher, CBasePlayerWeapon );

void CGrenadelauncher::Spawn( )
{
	    if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ||  CVAR_GET_FLOAT( "automatic_arena" )  == 2  )	
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_EGON;

	SET_MODEL(ENT(pev), "models/wmodels/w_grenadel.mdl");

	m_iDefaultAmmo = GL_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
	}
}


void CGrenadelauncher::Precache( void )
{
	PRECACHE_MODEL("models/wmodels/w_grenadel.mdl");
	PRECACHE_MODEL("models/vmodels/v_grenadel.mdl");
	PRECACHE_MODEL("models/pmodels/p_grenadel.mdl");
	PRECACHE_SOUND ("weapons/357_cock1.wav"); //empty?
	PRECACHE_SOUND("weapons/glauncher.wav");
	PRECACHE_SOUND("weapons/glauncher2.wav");
	PRECACHE_SOUND("weapons/cannoncock.wav");
	PRECACHE_SOUND("weapons/reloadcannon1.wav");
}


BOOL CGrenadelauncher::Deploy( void )
{
	return DefaultDeploy( "models/vmodels/v_grenadel.mdl", "models/pmodels/p_grenadel.mdl", GL_DRAW, "egon" );
}

int CGrenadelauncher::AddToPlayer( CBasePlayer *pPlayer )
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



void CGrenadelauncher::Holster( void )
{
	//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Switching Grenade Launcher\n");
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	SendWeaponAnim( GL_HOLSTER );
}

int CGrenadelauncher::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "ARgrenades";
	p->iMaxAmmo1 = M203_GRENADE_MAX_CARRY;
	p->pszAmmo2 = "Timed";
	p->iMaxAmmo2 = TIMED_MAX_CARRY;
	p->iMaxClip = GL_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 14;
	p->iId = m_iId = WEAPON_EGON;
	p->iFlags = 0;
	p->iWeight = GL_WEIGHT;
	p->weaponName = "120 Pound Automatic Grenade Launcher";        

	return 1;
}
void CGrenadelauncher::PrimaryAttack( void )
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
		m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	if (m_iClip == 0)
	{
		Reload( );
	    SendWeaponAnim( GL_IDLE1 );
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
		m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;
			
	m_iClip--;

	
	  SendWeaponAnim( GL_FIRE1 );


	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	if ( RANDOM_LONG(0,1) )
	{
		// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/glauncher.wav", 0.8, ATTN_NORM);
	}
	else
	{
		// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/glauncher2.wav", 0.8, ATTN_NORM);
	}
 
	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	// Shoot an Contact Grenade. When touch surface, EXPLODE!
	CGrenade::ShootContact ( m_pPlayer->pev, 
							m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_forward * 10, 
							gpGlobals->v_forward * 1000 );
	
	m_flNextPrimaryAttack = gpGlobals->time + 1.0;
	m_flNextSecondaryAttack = gpGlobals->time + 1.0;
	m_flTimeWeaponIdle = gpGlobals->time + .6;// idle pretty soon after shooting.

	if (!m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_pPlayer->pev->punchangle.x -= 5;

}
void CGrenadelauncher::SecondaryAttack( void )
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
		m_flNextSecondaryAttack = gpGlobals->time + 0.15;
		return;
	}

	if (m_pPlayer->m_rgAmmo[m_iSecondaryAmmoType] == 0)
	{
	    SendWeaponAnim( GL_IDLE1 );
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
		m_flNextSecondaryAttack = gpGlobals->time + 0.15;
		return;
	}

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;
			
	m_pPlayer->m_rgAmmo[m_iSecondaryAmmoType]--;

	SendWeaponAnim( GL_FIRE2 );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );


	if ( RANDOM_LONG(0,1) )
	{
		// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/glauncher.wav", 0.8, ATTN_NORM);
	}
	else
	{
		// play this sound through BODY channel so we can hear it if player didn't stop firing MP3
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/glauncher2.wav", 0.8, ATTN_NORM);
	}
 
	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	//Shoot the Time  Grenade. Give the bitch a blast in 3.0 seconds.
	CGrenade::ShootTimed  ( m_pPlayer->pev, 
							m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_forward * 10, 
							gpGlobals->v_forward * 1000, 3.0 );
	
	
	m_flNextPrimaryAttack = gpGlobals->time + 1.2;
	m_flNextSecondaryAttack = gpGlobals->time + 1.2;
	
	if (m_iClip != 0)
		m_flTimeWeaponIdle = gpGlobals->time + .6;
	else
		m_flTimeWeaponIdle = 1.5;

	m_fInReload = 0;

	if (!m_pPlayer->m_rgAmmo[m_iSecondaryAmmoType])
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_pPlayer->pev->punchangle.x -= 10;

}
void CGrenadelauncher::Reload( void )
{
	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0 || m_iClip == GL_MAX_CLIP)
		return;

	if (m_flNextReload > gpGlobals->time)
		return;

	// don't reload until recoil is done
	if (m_flNextPrimaryAttack > gpGlobals->time)
		return;

	// check to see if we're ready to reload
	if (m_fInReload == 0)
	{
		SendWeaponAnim( GL_RELOAD1 );
//		ShowSmart (m_pPlayer, 0x7, 2, 0, "--Reload--\nContact Grenade" );
		m_fInReload = 1;
		m_pPlayer->m_flNextAttack = gpGlobals->time + 0.1;
		m_flTimeWeaponIdle = gpGlobals->time + 0.1;
		m_flNextPrimaryAttack = gpGlobals->time + .3;
		m_flNextSecondaryAttack = gpGlobals->time + .3;
		return;
	}
	else if (m_fInReload == 1)
	{
		if (m_flTimeWeaponIdle > gpGlobals->time)
			return;
		// was waiting for gun to move to side
		m_fInReload = 2;

		if (RANDOM_LONG(0,1))
			EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/reloadcannon1.wav", 1, ATTN_NORM, 0, 85 + RANDOM_LONG(0,0x1f));
		else
			EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/reloadcannon1.wav", 1, ATTN_NORM, 0, 85 + RANDOM_LONG(0,0x1f));

		SendWeaponAnim( GL_RELOAD2 );

		m_flNextReload = gpGlobals->time + .8;
		m_flTimeWeaponIdle = gpGlobals->time + 0.2;
	}
	else
	{
		// Add them to the clip
		m_iClip += 1;
		m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] -= 1;
		m_fInReload = 1;
	}
}
void CGrenadelauncher::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flPumpTime && m_flPumpTime < gpGlobals->time)
	{
		// play pumping sound
		EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/scock1.wav", 1, ATTN_NORM, 0, 95 + RANDOM_LONG(0,0x1f));
		m_flPumpTime = 0;
	}

	if (m_flTimeWeaponIdle < gpGlobals->time)
	{
		if (m_iClip == 0 && m_fInReload == 0 && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
		{
			Reload( );
		}
		else if (m_fInReload != 0)
		{
			if (m_iClip != 6 && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
			{
				Reload( );
			}
			else
			{
				// reload debounce has timed out
				SendWeaponAnim( GL_IDLE1 );
				
				// play cocking sound
				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/cannoncock.wav", 1, ATTN_NORM, 0, 95 + RANDOM_LONG(0,0x1f));
				m_fInReload = 0;
				m_flTimeWeaponIdle = gpGlobals->time + 1.5;
			}
		}
		else
		{
			int iAnim;
			float flRand = RANDOM_FLOAT(0, 1);
			if (flRand <= 0.8)
			{
				iAnim = GL_IDLE2;
				m_flTimeWeaponIdle = gpGlobals->time + (60.0/12.0);// * RANDOM_LONG(2, 5);
			}
			else if (flRand <= 0.95)
			{
				iAnim = GL_IDLE1;
				m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
			}
			else
			{
				iAnim = GL_IDLE2;
				m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
			}
			SendWeaponAnim( iAnim );
		}
	}
}
	

class CGrenadelauncherAmmo : public CBasePlayerAmmo
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
LINK_ENTITY_TO_CLASS( ammo_egonclip, CGrenadelauncherAmmo );

#endif
