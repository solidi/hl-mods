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

// special deathmatch shotgun spreads
#define VECTOR_CONE_DM_SHOTGUN	Vector( 0.11365, 0.4362, 0.00  )// 10 degrees by 5 degrees
#define VECTOR_CONE_DM_DOUBLESHOTGUN Vector( 0.17365, 0.04362, 0.00 ) // 20 degrees by 5 degrees

enum shotgun_e {
	SHOTGUN_IDLE = 0,
	SHOTGUN_FIRE,
	SHOTGUN_FIRE2,
	SHOTGUN_RELOAD,
	SHOTGUN_PUMP,
	SHOTGUN_START_RELOAD,
	SHOTGUN_DRAW,
	SHOTGUN_HOLSTER,
	SHOTGUN_IDLE4,
	SHOTGUN_IDLE_DEEP
};

class CShotgun : public CBasePlayerWeapon
{
public:
	int		Save( CSave &save );
	int		Restore( CRestore &restore );
	static	TYPEDESCRIPTION m_SaveData[];

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
	int m_fInReload;
	float m_flNextReload;
	int m_iShell;
	float m_flPumpTime;
};
LINK_ENTITY_TO_CLASS( weapon_ashotgun, CShotgun );


TYPEDESCRIPTION	CShotgun::m_SaveData[] = 
{
	DEFINE_FIELD( CShotgun, m_flNextReload, FIELD_TIME ),
	DEFINE_FIELD( CShotgun, m_fInReload, FIELD_INTEGER ),
	DEFINE_FIELD( CShotgun, m_flNextReload, FIELD_TIME ),
	DEFINE_FIELD( CShotgun, m_flPumpTime, FIELD_TIME ),
};
IMPLEMENT_SAVERESTORE( CShotgun, CBasePlayerWeapon );



void CShotgun::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_SHOTGUN;
	SET_MODEL(ENT(pev), "models/wmodels/w_ashotgun.mdl");

	m_iDefaultAmmo = SHOTGUN_DEFAULT_GIVE;

	FallInit();// get ready to fall
	}
}


void CShotgun::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_ashotgun.mdl");
	PRECACHE_MODEL("models/wmodels/w_ashotgun.mdl");
	PRECACHE_MODEL("models/pmodels/p_ashotgun.mdl");

	m_iShell = PRECACHE_MODEL ("models/shotgunshell.mdl");// shotgun shell

	PRECACHE_SOUND("items/9mmclip1.wav");              

	PRECACHE_SOUND ("weapons/ashotgun1.wav");//shotgun

	PRECACHE_SOUND ("weapons/reload1.wav");	// shotgun reload
	PRECACHE_SOUND ("weapons/reload3.wav");	// shotgun reload
	
	PRECACHE_SOUND ("weapons/357_cock1.wav"); // gun empty sound
	PRECACHE_SOUND ("weapons/scock1.wav");	// cock gun
}

int CShotgun::AddToPlayer( CBasePlayer *pPlayer )
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


int CShotgun::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "buckshot";
	p->iMaxAmmo1 = BUCKSHOT_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = SHOTGUN_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 6;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_SHOTGUN;
	p->iWeight = SHOTGUN_WEIGHT;
	p->weaponName = "Assault Shotgun";        

	return 1;
}



BOOL CShotgun::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_ashotgun.mdl", "models/pmodels/p_ashotgun.mdl", SHOTGUN_DRAW, "shotgun" );
}
void CShotgun::Holster()
{

}

void CShotgun::PrimaryAttack()
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.03;
		return;
	}

	if (m_iClip <= 0)
	{
		Reload( );
		if (m_iClip == 0)
			//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Out of Buckshots  Reload Weapon or Switch Weapon.....\n");
			m_flNextPrimaryAttack = gpGlobals->time + 0.2;
		    PlayEmptySound( );
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

	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/ashotgun1.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 93 + RANDOM_LONG(0,0x1f));

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	m_pPlayer->FireBullets( 8, vecSrc, vecAiming, VECTOR_CONE_15DEGREES, 4096, BULLET_PLAYER_BUCKSHOT, 0 );

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	if (m_iClip != 0)
		m_flPumpTime = gpGlobals->time - 0.03;

	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(50,70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(100,150) 
							 + gpGlobals->v_forward * 20;

	EjectBrass ( m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 20 + gpGlobals->v_right * 4 , vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHOTSHELL); 

	m_flNextPrimaryAttack = gpGlobals->time + 0.6
	;m_flNextSecondaryAttack = gpGlobals->time + 0.6;
	if (m_iClip != 0)
		m_flTimeWeaponIdle = gpGlobals->time + 5.0;
	else
		m_flTimeWeaponIdle = 0.05;
	m_fInReload = 0;

	m_pPlayer->pev->punchangle.x -= 1;
}


void CShotgun::SecondaryAttack( void )
{

}	

void CShotgun::Reload( void )
{
	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0 || m_iClip == SHOTGUN_MAX_CLIP)
		return;

	if (m_flNextReload > gpGlobals->time)
		return;

	// don't reload until recoil is done
	if (m_flNextPrimaryAttack > gpGlobals->time)
		return;

	// check to see if we're ready to reload
	if (m_fInReload == 0)
	{
		SendWeaponAnim( SHOTGUN_START_RELOAD );
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
			EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/reload1.wav", 1, ATTN_NORM, 0, 85 + RANDOM_LONG(0,0x1f));
		else
			EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/reload3.wav", 1, ATTN_NORM, 0, 85 + RANDOM_LONG(0,0x1f));

		SendWeaponAnim( SHOTGUN_RELOAD );
//		ShowSmart (m_pPlayer, 0x7, 2, 0, "--Reload--\nBuckshot Loaded" );

		m_flNextReload = gpGlobals->time + 0.2;
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


void CShotgun::WeaponIdle( void )
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
			if (m_iClip != 8 && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
			{
				Reload( );
			}
			else
			{
				// reload debounce has timed out
				SendWeaponAnim( SHOTGUN_PUMP );
				
				// play cocking sound
				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/scock1.wav", 1, ATTN_NORM, 0, 95 + RANDOM_LONG(0,0x1f));
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
				iAnim = SHOTGUN_IDLE_DEEP;
				m_flTimeWeaponIdle = gpGlobals->time + (60.0/12.0);// * RANDOM_LONG(2, 5);
			}
			else if (flRand <= 0.95)
			{
				iAnim = SHOTGUN_IDLE;
				m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
			}
			else
			{
				iAnim = SHOTGUN_IDLE4;
				m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
			}
			SendWeaponAnim( iAnim );
		}
	}
}



class CShotgunAmmo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
	
	}
	 else
	 {
		Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo3.mdl");
		CBasePlayerAmmo::Spawn( );
	 }
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo3.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		
		int bResult = (pOther->GiveAmmo( AMMO_BUCKSHOTBOX_GIVE, "buckshot", BUCKSHOT_MAX_CARRY ) != 0);
		              (pOther->GiveAmmo( USAS_MAX_CLIP, "slugs", USAS_MAX_CARRY) != -1);
		
		 if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
	
};
LINK_ENTITY_TO_CLASS( ammo_buckshot, CShotgunAmmo );

class CUnusedAmmo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
	/*	Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo3.mdl");
		CBasePlayerAmmo::Spawn( );*/
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo3.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		
		int bResult = (pOther->GiveAmmo( AMMO_BUCKSHOTBOX_GIVE, "buckshot", BUCKSHOT_MAX_CARRY ) != 0);
		              (pOther->GiveAmmo( USAS_MAX_CLIP, "slugs", USAS_MAX_CARRY) != -1);
		
		 if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
	
};

LINK_ENTITY_TO_CLASS( weapon_shotgun, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_9mmhandgun, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_9mmAR, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_357, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_gauss, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_rpg, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_egon, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_tripmine, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_satchel, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_handgrenade, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_snark, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_hornetgun, CUnusedAmmo );
LINK_ENTITY_TO_CLASS( weapon_crossbow, CUnusedAmmo );


