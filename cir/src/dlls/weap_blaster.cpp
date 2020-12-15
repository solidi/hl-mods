
#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"
#include "soundent.h"
#include "gamerules.h"
#include "effects.h"

enum blaser_e
{
	BLASER_IDLE1 = 0,
	BLASER_SHOOT,
	BLASER_SHOOT_EMPTY,
	BLASER_RELOAD,
	BLASER_DRAW,
	BLASER_HOLSTER,
};


class CBlaser : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 4; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	BOOL Deploy( void );
	void Holster( int skiplocal /* = 0 */ );
	void Reload( void );
	void WeaponIdle( void );
	void UpdateSpot( void );
	void ReloadClip( void );
	void EjectShell( void );
	float m_flNextAnimTime;

	float m_fEjectShellTime;
	int m_fInZoom;

	int Shell;
private:
	unsigned short m_usBlaser;
};
LINK_ENTITY_TO_CLASS( weapon_blaser, CBlaser );

//=========================================================
//=========================================================

void CBlaser::Spawn( )
{
	Precache( );
	SET_MODEL(ENT(pev), "models/w_smg.mdl");
	m_iId = WEAPON_BLASTER;

	m_iDefaultAmmo = BLASTER_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
}


void CBlaser::Precache( void )
{
	PRECACHE_MODEL("models/v_blaser.mdl");
	PRECACHE_MODEL("models/w_smg.mdl");
	PRECACHE_MODEL("models/p_smg.mdl");
	Shell = PRECACHE_MODEL("models/w_smgclip.mdl");

	PRECACHE_MODEL ("models/env_762mmshell.mdl");// brass shellTE_MODEL

	PRECACHE_SOUND ("weapons/weap_blaser1.wav");
	PRECACHE_SOUND ("weapons/weap_pullbolt1.wav");
	PRECACHE_SOUND ("weapons/weap_zoom1.wav");
	PRECACHE_SOUND ("weapons/weap_blaserreload1.wav");
	PRECACHE_SOUND ("weapons/weap_blaserreload2.wav");

	Shell = PRECACHE_MODEL ("models/env_762mmshell.mdl");// shotgun shell

	m_usBlaser = PRECACHE_EVENT( 1, "events/blaser.sc" );
}

int CBlaser::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "762mm";
	p->iMaxAmmo1 = BLASTER_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = BLASTER_MAX_CLIP;
	p->iSlot = 3;
	p->iPosition = 0;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_BLASTER;
	p->iWeight = BLASTER_WEIGHT;

	return 1;
}

int CBlaser::AddToPlayer( CBasePlayer *pPlayer )
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

BOOL CBlaser::Deploy( )
{
	return DefaultDeploy( "models/v_blaser.mdl", "models/p_smg.mdl", BLASER_DRAW, "rpg" );
}

void CBlaser::Holster( int skiplocal /* = 0 */)
{
	m_fInReload = FALSE;
	m_flDropClipTime = 0;

	if ( m_fInZoom )
	{
		SecondaryAttack( );
	}

	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.5;

	SendWeaponAnim( BLASER_HOLSTER );
}


void CBlaser::PrimaryAttack()
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

	PLAYBACK_EVENT_FULL( 0, m_pPlayer->edict(), m_usBlaser, 0.0, (float *)&g_vecZero, (float *)&g_vecZero, 0.0, 0.0, 0, 0, ( m_iClip == 1 ) ? 1 : 0, 0 );

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip--;

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );
	
	if ( g_pGameRules->IsDeathmatch() )
	{
		// optimized multiplayer. Widened to make it easier to hit a moving player
		m_pPlayer->FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_MP5, 2 );
	}
	else
	{
		// single player spread
		m_pPlayer->FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_3DEGREES, 8192, BULLET_PLAYER_MP5, 2 );
	}
	
	if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
		m_flNextPrimaryAttack = gpGlobals->time + 1.4;
	else
		m_flNextPrimaryAttack = gpGlobals->time + 1.2;

	m_fEjectShellTime = gpGlobals->time + .8;
	m_flNextSecondaryAttack = gpGlobals->time + 1.0;

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}

void CBlaser::SecondaryAttack( void )
{
	if (m_fInZoom)
	{
		m_pPlayer->m_iFOV = 0; // 0 means reset to default fov
		m_fInZoom = 0;
	}
	else
	{
		m_pPlayer->m_iFOV = 20;
		m_fInZoom = 1;
	}

	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_zoom1.wav", 1, ATTN_NORM);

	m_flNextPrimaryAttack = gpGlobals->time + .25;
	m_flNextSecondaryAttack = gpGlobals->time + .25;
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}

void CBlaser::Reload( void )
{
	int iResult;

	if ( m_fInZoom )
	{
		SecondaryAttack( );
	}

	iResult = DefaultReload( BLASTER_MAX_CLIP, BLASER_RELOAD, 1.6 );

	if ( iResult )
	{
		m_flDropClipTime = gpGlobals->time + 0.5;
	}
}

void CBlaser::ReloadClip( void )
{
	if ( m_flDropClipTime != 0 && m_flDropClipTime < gpGlobals->time )
	{
		UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
/*		
		Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(-50,-70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(-10,-15) 
							 + gpGlobals->v_forward * 25;
		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -20 + gpGlobals->v_forward * 32 + gpGlobals->v_right * -6 , vecShellVelocity, pev->angles.y, Shell, 0 ); 
*/
		m_flDropClipTime = 0;
	}

	if ( m_fEjectShellTime && m_fEjectShellTime < gpGlobals->time )
	{
		EjectShell();
		m_fEjectShellTime = 0;
	}
}

void CBlaser::EjectShell( void )
{	
	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
	Vector	vecShellVelocity = m_pPlayer->pev->velocity 
						 + gpGlobals->v_right * RANDOM_FLOAT(-150,-200) 
						 + gpGlobals->v_up * RANDOM_FLOAT(-10,-15) 
						 + gpGlobals->v_forward * 25;
	EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 32 + gpGlobals->v_right * 4, vecShellVelocity, pev->angles.y, Shell, TE_BOUNCE_SHELL ); 

	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/weap_pullbolt1.wav", 1, ATTN_NORM);
}

void CBlaser::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = BLASER_IDLE1;	
		break;
	
	default:
	case 1:
		iAnim = BLASER_IDLE1;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}
