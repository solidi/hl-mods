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

enum uzi_e
{
	M16_IDLE = 0,
	M16_IDLE1,
	M16_IDLE3,
	M16_RIGHTSHOT,
	M16_LEFTSHOT,
	M16_NULL,
	M16_NULL2,
	M16_RELOAD,
	M16_NULL3,
	M16_DEPLOY,

};


class CDoubleUzi : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 3; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	void PrimaryAttack( void );
	int m_iShotCount; 
	void SecondaryAttack( void );
	int SecondaryAmmoIndex( void );
	BOOL Deploy( void );
	void Holster( );
	void Reload( void );
	void WeaponIdle( void );
	float m_flNextAnimTime;
	int m_iShell;
	int m_fInZoom;
	int m_iSideCount;
};
LINK_ENTITY_TO_CLASS( weapon_doubleuzi, CDoubleUzi );



//=========================================================
//=========================================================
int CDoubleUzi::SecondaryAmmoIndex( void )
{
	return m_iSecondaryAmmoType;
}

void CDoubleUzi::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" )  == 2 )
	{
		return;
	}
	else
	{
	pev->classname = MAKE_STRING("weapon_doubleuzi"); // hack to allow for old names
	Precache( );
	SET_MODEL(ENT(pev), "models/wmodels/w_uzi.mdl");
	m_iId = WEAPON_DOUBLEUZI;

	m_iDefaultAmmo = 50;

	FallInit();// get ready to fall down.
	}
}


void CDoubleUzi::Precache( void )
{
	PRECACHE_MODEL("models/vmodels/v_doubleuzi.mdl");
	PRECACHE_MODEL("models/wmodels/w_uzi.mdl");
	PRECACHE_MODEL("models/pmodels/p_uzi.mdl");
	m_iShell = PRECACHE_MODEL ("models/shell.mdl");// brass shellTE_MODEL
	PRECACHE_MODEL("models/w_9mmARclip.mdl");
	PRECACHE_SOUND("items/9mmclip1.wav");              
	PRECACHE_SOUND("items/clipinsert1.wav");
	PRECACHE_SOUND("items/cliprelease1.wav");
	PRECACHE_SOUND ("weapons/uzi1.wav"); //1 shot
    PRECACHE_SOUND ("weapons/357_cock1.wav");
}

int CDoubleUzi::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "5.56mm";
	p->iMaxAmmo1 = 250;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = 32;
	p->iSlot = 0;
	p->iPosition = 15;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_DOUBLEUZI;
	p->iWeight = DOUBLEUZI_WEIGHT;
	p->weaponName = "Double Uzis";

	return 1;
}

int CDoubleUzi::AddToPlayer( CBasePlayer *pPlayer )
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

BOOL CDoubleUzi::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_doubleuzi.mdl", "models/pmodels/p_uzi.mdl", M16_DEPLOY, "onehanded" );
}

void CDoubleUzi::Holster( )
{
	m_fInReload = FALSE;// cancel any reload in progress.

	if ( m_fInZoom )
	{
		SecondaryAttack( );
	}
	m_pPlayer->m_iFOV = 0;
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
}


void CDoubleUzi::PrimaryAttack()
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	if (m_iClip <= 0)
	{
		PlayEmptySound();
	    m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;

	m_iClip--;
	m_iSideCount++;
	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	if (m_iSideCount == 1)
    {
		SendWeaponAnim( M16_RIGHTSHOT );
			
		m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

        EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/uzi1.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xf)); 

	    UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	    Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(100,150) 
							 + gpGlobals->v_up * RANDOM_FLOAT(100,150) //x,y values? 
							 + gpGlobals->v_forward * 35;
			
		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs
					+ gpGlobals->v_up * -12 
					+ gpGlobals->v_forward * 35 
					+ gpGlobals->v_right * 6, vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHELL);
		
	    Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	    Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	    m_pPlayer->FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_MP5, 0 );
	

	}
	if (m_iSideCount == 2)
	{
		
		SendWeaponAnim( M16_LEFTSHOT );
			
		m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

        EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/uzi1.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xf)); 

	    UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	    Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(100,150) 
							 + gpGlobals->v_up * RANDOM_FLOAT(100,150) //x,y values? 
							 + gpGlobals->v_forward * 35;

		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs
					+ gpGlobals->v_up * -12 
					+ gpGlobals->v_forward * 35 
					+ gpGlobals->v_right * -6, vecShellVelocity, pev->angles.y, m_iShell, TE_BOUNCE_SHELL); 
	
	    Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	    Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	    m_pPlayer->FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_MP5, 0 );
	
	}

	if (m_iSideCount == 2)
	  	m_iSideCount = 0;
		

	m_flNextPrimaryAttack = gpGlobals->time + 0.08;
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	m_pPlayer->pev->punchangle.x = RANDOM_FLOAT( -2, 2 );
}
void CDoubleUzi::SecondaryAttack( void )
{
	
}
void CDoubleUzi::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 32, M16_RELOAD, 1.5 );
	else
		iResult = DefaultReload( 32, M16_RELOAD, 1.5 );

	if (iResult)
	{
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	}
}
void CDoubleUzi::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = M16_IDLE;	
		break;
	
	default:
	case 1:
		iAnim = M16_IDLE3;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}


















