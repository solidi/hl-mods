
#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"
#include "gamerules.h"

// special deathmatch shotgun spreads
#define VECTOR_CONE_DM_SHOTGUN	Vector( 0.08716, 0.04362, 0.00  )// 10 degrees by 5 degrees
#define VECTOR_CONE_DM_DOUBLESHOTGUN Vector( 0.17365, 0.04362, 0.00 ) // 20 degrees by 5 degrees

enum sawedoff_e {
	SAWED_IDLE1 = 0,
	SAWED_IDLE2,
	SAWED_FIRE_LEFT,
	SAWED_FIRE_RIGHT,
	SAWED_FIRE_BOTH,
	SAWED_RELOAD,
	SAWED_DRAW,
	SAWED_HOLSTER,
};

class CSawedOff : public CBasePlayerWeapon
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
	void Holster( int skiplocal /* = 0 */ );
	void Reload( void );
	void WeaponIdle( void );
	void ReloadClip( void );
	int Shell;
private:
	unsigned short m_usSawed1;
	unsigned short m_usSawed2;
};
LINK_ENTITY_TO_CLASS( weapon_sawedoff, CSawedOff );


void CSawedOff::Spawn( )
{
	Precache( );
	m_iId = WEAPON_SAWEDOFF;
	SET_MODEL(ENT(pev), "models/w_sawedoff.mdl");

	m_iDefaultAmmo = SAWEDOFF_DEFAULT_GIVE;

	FallInit();// get ready to fall
}


void CSawedOff::Precache( void )
{
	PRECACHE_MODEL("models/v_sawedoff.mdl");
	PRECACHE_MODEL("models/w_sawedoff.mdl");
	PRECACHE_MODEL("models/p_sawedoff.mdl");

	Shell = PRECACHE_MODEL ("models/env_12gshell.mdl");// shotgun shell

	PRECACHE_SOUND("items/9mmclip1.wav");              

	PRECACHE_SOUND ("weapons/weap_sawed1.wav");
	PRECACHE_SOUND ("weapons/weap_sawed2.wav");
	PRECACHE_SOUND ("weapons/sshell2.wav");
	PRECACHE_SOUND ("weapons/sshell3.wav");
	PRECACHE_SOUND ("weapons/reload1.wav");

	PRECACHE_SOUND ("weapons/weap_cock3.wav");
	
	PRECACHE_SOUND ("weapons/357_cock1.wav"); // gun empty sound

	m_usSawed1 = PRECACHE_EVENT( 1, "events/sawedoff1.sc" );
	m_usSawed2 = PRECACHE_EVENT( 1, "events/sawedoff2.sc" );
}

int CSawedOff::AddToPlayer( CBasePlayer *pPlayer )
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


int CSawedOff::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "buckshot";
	p->iMaxAmmo1 = BUCKSHOT_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = SAWEDOFF_MAX_CLIP;
	p->iSlot = 2;
	p->iPosition = 0;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_SAWEDOFF;
	p->iWeight = SAWEDOFF_WEIGHT;

	return 1;
}



BOOL CSawedOff::Deploy( )
{
	return DefaultDeploy( "models/v_sawedoff.mdl", "models/p_sawedoff.mdl", SAWED_DRAW, "shotgun" );
}

void CSawedOff::Holster( int skiplocal /* = 0 */ )
{
	m_fInReload = FALSE;
	m_flDropClipTime = 0;

	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.5;
	SendWeaponAnim( SAWED_HOLSTER );
}

void CSawedOff::PrimaryAttack()
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
		Reload( );
		if (m_iClip == 0)
			PlayEmptySound( );
		return;
	}

	PLAYBACK_EVENT( 0, m_pPlayer->edict(), m_usSawed1 );

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip--;

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if ( g_pGameRules->IsDeathmatch() )
	{
		// altered deathmatch spread
		m_pPlayer->FireBullets( 4, vecSrc, vecAiming, VECTOR_CONE_DM_SHOTGUN, 2048, BULLET_PLAYER_BUCKSHOT, 0 );
	}
	else
	{
		// regular old, untouched spread. 
		m_pPlayer->FireBullets( 6, vecSrc, vecAiming, VECTOR_CONE_10DEGREES, 2048, BULLET_PLAYER_BUCKSHOT, 0 );
	}

	if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
	{
		m_flNextPrimaryAttack = gpGlobals->time + 0.5;
		m_flNextSecondaryAttack = gpGlobals->time + 0.5;
	}
	else
	{
		m_flNextPrimaryAttack = gpGlobals->time + 0.75;
		m_flNextSecondaryAttack = gpGlobals->time + 0.75;
	}

	m_flTimeWeaponIdle = gpGlobals->time + 5.0;
}


void CSawedOff::SecondaryAttack( void )
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
		return;
	}

	PLAYBACK_EVENT( 0, m_pPlayer->edict(), m_usSawed2 );

	m_pPlayer->m_iWeaponVolume = LOUD_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip -= 2;

	// player "shoot" animation
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );
	
	if ( g_pGameRules->IsDeathmatch() )
	{
		// tuned for deathmatch
		m_pPlayer->FireBullets( 8, vecSrc, vecAiming, VECTOR_CONE_DM_DOUBLESHOTGUN, 2048, BULLET_PLAYER_BUCKSHOT, 0 );
	}
	else
	{
		// untouched default single player
		m_pPlayer->FireBullets( 12, vecSrc, vecAiming, VECTOR_CONE_10DEGREES, 2048, BULLET_PLAYER_BUCKSHOT, 0 );
	}

	if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
	{
		m_flNextPrimaryAttack = gpGlobals->time + 1.25;
		m_flNextSecondaryAttack = gpGlobals->time + 1.25;
	}
	else
	{
		m_flNextPrimaryAttack = gpGlobals->time + 1.5;
		m_flNextSecondaryAttack = gpGlobals->time + 1.5;
	}

	m_flTimeWeaponIdle = gpGlobals->time + 6.0;
}


void CSawedOff::Reload( void )
{
	int iResult;

	iResult = DefaultReload( SAWEDOFF_MAX_CLIP, SAWED_RELOAD, 2.2 );

	if ( iResult )
		m_flDropClipTime = gpGlobals->time + 1.1;
}

void CSawedOff::ReloadClip( void )
{
	if ( m_flDropClipTime != 0 && m_flDropClipTime < gpGlobals->time )
	{
		UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
		Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(-50,-70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(-10,-15) 
							 + gpGlobals->v_forward * 25;
		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 32 + gpGlobals->v_right * -6 , vecShellVelocity, pev->angles.y, Shell, TE_BOUNCE_SHOTSHELL ); 

		vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(50,70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(-10,-15) 
							 + gpGlobals->v_forward * 25;
		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -12 + gpGlobals->v_forward * 32 + gpGlobals->v_right * 12 , vecShellVelocity, pev->angles.y, Shell, TE_BOUNCE_SHOTSHELL ); 

		
		m_flDropClipTime = 0;
	}
}


void CSawedOff::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle < gpGlobals->time)
	{
		int iAnim;
		float flRand = RANDOM_FLOAT(0, 1);
		if (flRand <= 0.8)
		{
			iAnim = SAWED_IDLE1;
			m_flTimeWeaponIdle = gpGlobals->time + (60.0/12.0);// * RANDOM_LONG(2, 5);
		}
		else if (flRand <= 0.95)
		{
			iAnim = SAWED_IDLE2;
			m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
		}
		else
		{
			iAnim = SAWED_IDLE1;
			m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
		}
		SendWeaponAnim( iAnim );
	}
}

class CBuckShotAmmo : public CBasePlayerAmmo
{
	void Spawn( void )
	{ 
		Precache( );
		SET_MODEL(ENT(pev), "models/w_slugbox.mdl");
		CBasePlayerAmmo::Spawn( );
	}
	void Precache( void )
	{
		PRECACHE_MODEL ("models/w_slugbox.mdl");
		PRECACHE_SOUND("items/9mmclip1.wav");
	}
	BOOL AddAmmo( CBaseEntity *pOther ) 
	{ 
		if (pOther->GiveAmmo( AMMO_BUCKSHOTBOX_GIVE, "buckshot", BUCKSHOT_MAX_CARRY ) != -1)
		{
			EMIT_SOUND(ENT(pev), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM);
			return TRUE;
		}
		return FALSE;
	}
};
LINK_ENTITY_TO_CLASS( ammo_slugbox, CBuckShotAmmo );
