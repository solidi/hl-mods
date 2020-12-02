
#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "weapons.h"
#include "monsters.h"
#include "player.h"
#include "gamerules.h"


enum deagle_e {
	DEAGLE_IDLE1 = 0,
	DEAGLE_IDLE2,
	DEAGLE_IDLE_EMPTY,
	DEAGLE_SHOOT,
	DEAGLE_SHOOT_EMPTY,
	DEAGLE_RELOAD,
	DEAGLE_RELOAD_EMPTY,
	DEAGLE_DRAW,
	DEAGLE_HOLSTER,
	DEAGLE_HOLSTER_EMPTY,
};

class CDeagle : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 2; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );
	void PrimaryAttack( void );
	BOOL Deploy( void );
	void Holster( int skiplocal = 0 );
	void Reload( void );
	void WeaponIdle( void );
	void ReloadClip( void );

	int Shell;
	int Smoke;

private:
	unsigned short m_usFireDeagle;
};
LINK_ENTITY_TO_CLASS( weapon_deagle, CDeagle );

int CDeagle::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = ".50mm";
	p->iMaxAmmo1 = _50MM_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = DEAGLE_MAX_CLIP;
	p->iFlags = 0;
	p->iSlot = 1;
	p->iPosition = 1;
	p->iId = m_iId = WEAPON_DEAGLE;
	p->iWeight = DEAGLE_WEIGHT;

	return 1;
}

int CDeagle::AddToPlayer( CBasePlayer *pPlayer )
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

void CDeagle::Spawn( )
{
	Precache( );
	m_iId = WEAPON_DEAGLE;
	SET_MODEL(ENT(pev), "models/w_deagle.mdl");

	m_iDefaultAmmo = DEAGLE_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
}


void CDeagle::Precache( void )
{
	PRECACHE_MODEL("models/v_deagle.mdl");
	PRECACHE_MODEL("models/w_deagle.mdl");
	PRECACHE_MODEL("models/p_deagle.mdl");
	Shell = PRECACHE_MODEL("models/w_deagleclip.mdl");
	PRECACHE_MODEL("models/env_9mmshell.mdl");

	PRECACHE_SOUND("items/9mmclip1.wav");              

	PRECACHE_SOUND ("weapons/357_cock1.wav");
	PRECACHE_SOUND ("weapons/weap_deagle1.wav");
	PRECACHE_SOUND ("weapons/weap_deagledeploy1.wav");
	PRECACHE_SOUND ("weapons/weap_deaglereload1.wav");
	PRECACHE_SOUND ("weapons/weap_deaglereload2.wav");
	PRECACHE_SOUND ("weapons/weap_deaglereload3.wav");

	Smoke = PRECACHE_MODEL("models/w_deagle.mdl");

	m_usFireDeagle = PRECACHE_EVENT( 1, "events/deagle.sc" );
}

BOOL CDeagle::Deploy( )
{
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_deagledeploy1.wav", 0.8, ATTN_NORM);		
	return DefaultDeploy( "models/v_deagle.mdl", "models/p_deagle.mdl", DEAGLE_DRAW, "python" );
}


void CDeagle::Holster( int skiplocal /* = 0 */ )
{
	m_fInReload = FALSE;
	m_flDropClipTime = 0;

	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + .5;
	m_flTimeWeaponIdle = gpGlobals->time + 10 + RANDOM_FLOAT ( 0, 5 );
	
	if ( m_iClip > 0 )
		SendWeaponAnim( DEAGLE_HOLSTER );
	else
		SendWeaponAnim( DEAGLE_HOLSTER_EMPTY );
}

void CDeagle::PrimaryAttack()
{
	if(! ( m_pPlayer->m_afButtonPressed & IN_ATTACK ) )
		return;

	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	if (m_iClip <= 0)
	{
		if (!m_fFireOnEmpty)
			Reload( );
		else
		{
			EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/357_cock1.wav", 0.8, ATTN_NORM);
			m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		}

		return;
	}

	PLAYBACK_EVENT_FULL( 0, m_pPlayer->edict(), m_usFireDeagle, 0.0, (float *)&g_vecZero, (float *)&g_vecZero, 0.0, 0.0, 0, 0, ( m_iClip == 1 ) ? 1 : 0, 0 );

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = BRIGHT_GUN_FLASH;

	m_iClip--;
/*
	Vector vecFinal = pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * 0 + gpGlobals->v_forward * 32 + gpGlobals->v_right * 0;
	MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, m_pPlayer->pev->origin );
		WRITE_BYTE( TE_SMOKE );
		WRITE_COORD( vecFinal.x );
		WRITE_COORD( vecFinal.y );
		WRITE_COORD( vecFinal.z );
		WRITE_SHORT( g_sModelIndexSmoke );
		WRITE_BYTE( 4 ); 
		WRITE_BYTE( 12  ); 
	MESSAGE_END();
*/

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	m_pPlayer->pev->effects = (int)(m_pPlayer->pev->effects) | EF_MUZZLEFLASH;

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_10DEGREES );
	m_pPlayer->FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_1DEGREES, 8192, BULLET_PLAYER_DEAGLE, 0 );

	//m_flNextPrimaryAttack = gpGlobals->time + 0.5;
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );

}


void CDeagle::Reload( void )
{
	int iResult;

	if (m_iClip == 0)
		iResult = DefaultReload( 7, DEAGLE_RELOAD_EMPTY, 1.8 );
	else
		iResult = DefaultReload( 7, DEAGLE_RELOAD, 1.8 );	
	
	if ( iResult )
		m_flDropClipTime = gpGlobals->time + .5;
}

void CDeagle::ReloadClip( void )
{
	if ( m_flDropClipTime != 0 && m_flDropClipTime < gpGlobals->time )
	{
		UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
		Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(-50,-70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(-10,-15) 
							 + gpGlobals->v_forward * 25;
		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 32 + gpGlobals->v_right * -6 , vecShellVelocity, pev->angles.y, Shell, 0 ); 

		m_flDropClipTime = 0;
	}
}

void CDeagle::WeaponIdle( void )
{
	ResetEmptySound( );
	m_pPlayer->GetAutoaimVector( AUTOAIM_10DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	float flRand = RANDOM_FLOAT(0, 1);
	if (flRand <= 0.5)
	{
		iAnim = DEAGLE_IDLE1;
		m_flTimeWeaponIdle = gpGlobals->time + (70.0/30.0);
	}
	else if (flRand <= 0.7)
	{
		iAnim = DEAGLE_IDLE2;
		m_flTimeWeaponIdle = gpGlobals->time + (60.0/30.0);
	}
	else if (flRand <= 0.9)
	{
		iAnim = DEAGLE_IDLE1;
		m_flTimeWeaponIdle = gpGlobals->time + (88.0/30.0);
	}
	else
	{
		iAnim = DEAGLE_IDLE2;
		m_flTimeWeaponIdle = gpGlobals->time + (170.0/30.0);
	}
	SendWeaponAnim( iAnim );
}

class CDeagleAmmo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_deaglebox.mdl");
		CBasePlayerAmmo::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_deaglebox.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		if (pOther->GiveAmmo( AMMO_DEAGLEBOX_GIVE, ".50mm", _50MM_MAX_CARRY ) != -1)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
			return TRUE;
		}
		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( ammo_deaglebox, CDeagleAmmo );
