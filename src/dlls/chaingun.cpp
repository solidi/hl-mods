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
#include "soundent.h"
#include "gamerules.h"

enum chaingun_e
{
    CHAINGUN_IDLE = 0,
	CHAINGUN_IDLE1,
	CHAINGUN_SPINUP,
	CHAINGUN_SPINDOWN,
	CHAINGUN_FIRE,
	CHAINGUN_DRAW,
	CHAINGUN_HOLSTER,
};


class CChaingun : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 3; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	int SecondaryAmmoIndex( void );
	BOOL Deploy( void );
	void Reload( void );
	void Holster( );
	void WeaponIdle( void );
	float m_flNextAnimTime;
	int m_iShell;
	int m_iShell2; //secondary fire shell
};
LINK_ENTITY_TO_CLASS( weapon_chaingun, CChaingun );


//=========================================================
//=========================================================
int CChaingun::SecondaryAmmoIndex( void )
{
	return m_iSecondaryAmmoType;
}

void CChaingun::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2 )
	{
		return;
	}
	else
	{
	pev->classname = MAKE_STRING("weapon_chaingun"); // hack to allow for old names
	Precache( );
	SET_MODEL(ENT(pev), "models/wmodels/w_mini.mdl");
	m_iId = WEAPON_MP5;

	m_iDefaultAmmo = CHAIN_MAX_CLIP;

	FallInit();// get ready to fall down.
	}
}


void CChaingun::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_mini.mdl");
	PRECACHE_MODEL("models/wmodels/w_mini.mdl");
	PRECACHE_MODEL("models/pmodels/p_mini.mdl");

	m_iShell = PRECACHE_MODEL ("models/shell.mdl");// brass shell
	m_iShell2 = PRECACHE_MODEL ("models/shotgunshell.mdl");// shotgunshell for blast

	PRECACHE_MODEL("models/w_9mmARclip.mdl");
	PRECACHE_SOUND("items/9mmclip1.wav");              

	PRECACHE_SOUND ("weapons/chaingun1.wav");
	PRECACHE_SOUND ("weapons/chaingun2.wav");
    PRECACHE_SOUND ("weapons/reloadchaingun.wav");

}

int CChaingun::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "chain";
	p->iMaxAmmo1 = CHAIN_MAX_CARRY;
	p->pszAmmo2 = "buckshot";
	p->iMaxAmmo2 = BUCKSHOT_MAX_CARRY;
	p->iMaxClip = CHAIN_MAX_CLIP;
	p->iSlot = 0;
	p->iPosition = 9;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_MP5;
	p->iWeight = CHAIN_WEIGHT;
	p->weaponName = "25 Inch Chaingun";        

	return 1;
}

int CChaingun::AddToPlayer( CBasePlayer *pPlayer )
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

BOOL CChaingun::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_mini.mdl", "models/pmodels/p_mini.mdl", CHAINGUN_DRAW, "mp5" );
}

void CChaingun::Holster( )
{
	m_fInReload = FALSE;// cancel any reload in progress.
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	SendWeaponAnim( CHAINGUN_HOLSTER );

}


void CChaingun::PrimaryAttack()
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)	
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.3;
		return;
	}

	if (m_iClip <= 0)
	{
		//ClientPrint(m_pPlayer->pev, HUD_PRINTTALK, "Out of 9mm ammo  Reload Weapon or Switch Weapon....\n");
		SendWeaponAnim( CHAINGUN_IDLE );
		PlayEmptySound();
		m_flNextPrimaryAttack = gpGlobals->time + 0.3;
		return;
	}

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip--;

	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;
	
	SendWeaponAnim( CHAINGUN_FIRE );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	switch( RANDOM_LONG(0,1) )
	{
	case 0: EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/chaingun1.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xf)); break;
	case 1: EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/chaingun1.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xf)); break;
	}

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(100,100) 
							 + gpGlobals->v_up * RANDOM_FLOAT(100,150) 
							 + gpGlobals->v_forward * 25;
	EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs
					+ gpGlobals->v_up * -12 
					+ gpGlobals->v_forward * 25 
					+ gpGlobals->v_right * 6, vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHELL); 
	
	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	m_pPlayer->FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_10DEGREES, 8192, 	BULLET_PLAYER_MINI, 0 );

	if (!m_iClip && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_flNextPrimaryAttack = m_flNextPrimaryAttack + .07;
	if (m_flNextPrimaryAttack < gpGlobals->time)
		m_flNextPrimaryAttack = gpGlobals->time + .07; 

	m_flTimeWeaponIdle = gpGlobals->time + .6;

	m_pPlayer->pev->punchangle.x = RANDOM_FLOAT( 1, 1 );
}



void CChaingun::SecondaryAttack( void )
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)	
	{
		PlayEmptySound( );
		m_flNextSecondaryAttack = gpGlobals->time + 0.3;
		return;
	}

	if (m_pPlayer->m_rgAmmo[m_iSecondaryAmmoType] == 0)
	{
		SendWeaponAnim( CHAINGUN_IDLE );
		PlayEmptySound();
		m_flNextSecondaryAttack = gpGlobals->time + 0.3;
		return;
	}

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_pPlayer->m_rgAmmo[m_iSecondaryAmmoType]--;

	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;
		
	SendWeaponAnim( CHAINGUN_FIRE );

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	switch( RANDOM_LONG(0,1) )
	{
	case 0: EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/chaingun2.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xf)); break;
	case 1: EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/chaingun2.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xf)); break;
	}

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(300,100) 
							 + gpGlobals->v_up * RANDOM_FLOAT(300,150) 
							 + gpGlobals->v_forward * 25;
	EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs
					+ gpGlobals->v_up * -12 
					+ gpGlobals->v_forward * 25 
					+ gpGlobals->v_right * 6, vecShellVelocity, pev->angles.y, m_iShell2, TE_BOUNCE_SHELL); 
	
	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

    m_pPlayer->FireBullets( 18, vecSrc, vecAiming, VECTOR_CONE_20DEGREES, 4096, BULLET_PLAYER_BUCKSHOT, 0 );

     if (!m_pPlayer->m_rgAmmo[m_iSecondaryAmmoType])
		// HEV suit - indicate out of ammo condition
		m_pPlayer->SetSuitUpdate("!HEV_AMO0", FALSE, 0);

	m_flNextPrimaryAttack = m_flNextSecondaryAttack + 0.8;
	if (m_flNextSecondaryAttack < gpGlobals->time)
		m_flNextSecondaryAttack = gpGlobals->time + 0.8;

	m_flTimeWeaponIdle = gpGlobals->time + .6;

	m_pPlayer->pev->punchangle.x = RANDOM_FLOAT( 1, 1 );
}

void CChaingun::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 60, CHAINGUN_IDLE, 2.6 );
	else
		iResult = DefaultReload( 60, CHAINGUN_IDLE, 2.6 );

	if (iResult)
	{
		EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/reloadchaingun.wav", RANDOM_FLOAT(0.9, 1.0), ATTN_NORM);
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}
void CChaingun::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = CHAINGUN_IDLE;	
		break;
	
	default:
	case 1:
		iAnim = CHAINGUN_IDLE1;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}



class CChaingunAmmoClip : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ||  CVAR_GET_FLOAT( "automatic_arena" )  == 2  )
				
	{
	
	}
	 else
	 {
		Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo4.mdl");
		CBasePlayerAmmo::Spawn( );
	 }
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo4.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		int bResult = (pOther->GiveAmmo( 60, "chain", CHAIN_MAX_CARRY) != 0);
		              (pOther->GiveAmmo( 30, "5.56mm", _556MM_MAX_CARRY) != -1);
		if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
};
LINK_ENTITY_TO_CLASS( ammo_mp5clip, CChaingunAmmoClip );
LINK_ENTITY_TO_CLASS( ammo_9mmAR, CChaingunAmmoClip );



class CChaingunChainammo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_chainammo.mdl");
		CBasePlayerAmmo::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_chainammo.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		int bResult = (pOther->GiveAmmo( AMMO_CHAINBOX_GIVE, "chain", CHAIN_MAX_CARRY) != -1);
		if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
};
LINK_ENTITY_TO_CLASS( ammo_9mmbox, CChaingunChainammo );


class CGrenadeLauncherAmmoGrenade : public CBasePlayerAmmo
{
	void Spawn( void )
	{
	   if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2  ||  CVAR_GET_FLOAT( "automatic_arena" ) > 0 )	
	{
	
	}
	 else
	 {
		Precache( );
		SET_MODEL(ENT(pev), "models/ammo/w_ammo8.mdl");
		CBasePlayerAmmo::Spawn( );
	 }

	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/ammo/w_ammo8.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 

		int bResult = (pOther->GiveAmmo( AMMO_M203BOX_GIVE, "ARgrenades", M203_GRENADE_MAX_CARRY ) != 0);
                      (pOther->GiveAmmo( AMMO_TIMED_GIVE, "Timed", TIMED_MAX_CARRY ) != -1);
		
		if (bResult)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
		}
		return bResult;
	}
};
LINK_ENTITY_TO_CLASS( ammo_mp5grenades, CGrenadeLauncherAmmoGrenade );
LINK_ENTITY_TO_CLASS( ammo_ARgrenades, CGrenadeLauncherAmmoGrenade );


















