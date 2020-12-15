
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

enum smg_e
{
	SMG_IDLE1 = 0,
	SMG_IDLE2,
	SMG_SWITCH,
	SMG_SHOOT,
	SMG_RELOAD,
	SMG_DRAW,
	SMG_HOLSTER,
};

class CLaserSpot : public CBaseEntity
{
	void Spawn( void );
	void Precache( void );

	int	ObjectCaps( void ) { return FCAP_DONT_SAVE; }

public:
	void Suspend( float flSuspendTime );
	void EXPORT Revive( void );
	
	static CLaserSpot *CreateSpot( void );
};
LINK_ENTITY_TO_CLASS( laser_spot, CLaserSpot );

//=========================================================
//=========================================================
CLaserSpot *CLaserSpot::CreateSpot( void )
{
	CLaserSpot *pSpot = GetClassPtr( (CLaserSpot *)NULL );
	pSpot->Spawn();

	pSpot->pev->classname = MAKE_STRING("laser_spot");

	return pSpot;
}

//=========================================================
//=========================================================
void CLaserSpot::Spawn( void )
{
	Precache( );
	pev->movetype = MOVETYPE_NONE;
	pev->solid = SOLID_NOT;

	pev->rendermode = kRenderGlow;
	pev->renderfx = kRenderFxNoDissipation;
	pev->renderamt = 255;
	pev->scale = .3;

	SET_MODEL(ENT(pev), "sprites/laserdot.spr");
	UTIL_SetOrigin( pev, pev->origin );
};

//=========================================================
// Suspend- make the laser sight invisible. 
//=========================================================
void CLaserSpot::Suspend( float flSuspendTime )
{
	pev->effects |= EF_NODRAW;
	
	SetThink( Revive );
	pev->nextthink = gpGlobals->time + flSuspendTime;
}

//=========================================================
// Revive - bring a suspended laser sight back.
//=========================================================
void CLaserSpot::Revive( void )
{
	pev->effects &= ~EF_NODRAW;

	SetThink( NULL );
}

void CLaserSpot::Precache( void )
{
	PRECACHE_MODEL("sprites/laserdot.spr");
};



class CSmg : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 3; }
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
	float m_flNextAnimTime;
	float m_fShowLaser;
	int Shell;
	int m_iFireMode;
	int m_iBurstCount;

	CBeam *m_pBeam;

	CLaserSpot *m_pSpot;
	int m_fSpotActive;
private:
	unsigned short m_usSmg;
};
LINK_ENTITY_TO_CLASS( weapon_smg, CSmg );

//=========================================================
//=========================================================

void CSmg::Spawn( )
{
	Precache( );
	SET_MODEL(ENT(pev), "models/w_smg.mdl");
	m_iId = WEAPON_SMG;

	m_fSpotActive = 1;

	m_iDefaultAmmo = SMG_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
}


void CSmg::Precache( void )
{
	PRECACHE_MODEL("models/v_smg.mdl");
	PRECACHE_MODEL("models/w_smg.mdl");
	PRECACHE_MODEL("models/p_smg.mdl");
	Shell = PRECACHE_MODEL("models/w_smgclip.mdl");

	PRECACHE_MODEL ("models/env_9mmshell_si.mdl");// brass shellTE_MODEL

	PRECACHE_SOUND ("weapons/weap_smg1.wav");
	PRECACHE_SOUND ("weapons/weap_select1.wav");
	PRECACHE_SOUND ("weapons/357_cock1.wav");
	PRECACHE_SOUND ("weapons/weap_smgreload1.wav");
	PRECACHE_SOUND ("weapons/weap_smgreload2.wav");

	UTIL_PrecacheOther( "laser_spot" );
	UTIL_PrecacheOther( "blaster_beam" );

	m_usSmg = PRECACHE_EVENT( 1, "events/smg.sc" );
}

int CSmg::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "9mm";
	p->iMaxAmmo1 = SMG_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = SMG_MAX_CLIP;
	p->iSlot = 2;
	p->iPosition = 1;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_SMG;
	p->iWeight = SMG_WEIGHT;

	return 1;
}

int CSmg::AddToPlayer( CBasePlayer *pPlayer )
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

BOOL CSmg::Deploy( )
{
	m_iBurstCount = 0;
	return DefaultDeploy( "models/v_smg.mdl", "models/p_smg.mdl", SMG_DRAW, "onehanded" );
}

void CSmg::Holster( int skiplocal /* = 0 */)
{
	m_fInReload = FALSE;
	m_flDropClipTime = 0;

	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.5;

	if (m_pSpot)
	{
		m_pSpot->Killed( NULL, GIB_NEVER );
		m_pSpot = NULL;
	}
/*
	if ( m_pBeam )
	{
		UTIL_Remove( m_pBeam );
		m_pBeam = NULL;
	}
*/
	SendWeaponAnim( SMG_HOLSTER );
}


void CSmg::PrimaryAttack()
{
//	UpdateSpot();

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

	PLAYBACK_EVENT( 0, m_pPlayer->edict(), m_usSmg );

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip--;
	m_iBurstCount++;

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
/*
	if ( m_iBurstCount >= 3 && m_iFireMode )
	{
		m_flNextPrimaryAttack = gpGlobals->time + .50;
		m_iBurstCount = 0;
	}
	else
*/
	
	if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
		m_flNextPrimaryAttack = gpGlobals->time + 0.05;
	else
		m_flNextPrimaryAttack = gpGlobals->time + 0.07;

	m_flNextSecondaryAttack = gpGlobals->time + .1;

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}

void CSmg::SecondaryAttack( void )
{/*
	if ( m_iFireMode )
		m_iFireMode = 0;
	else
	{
		m_iBurstCount = 0;
		m_iFireMode = 1;
	}

	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/weap_select1.wav", 1, ATTN_NORM);

	m_flNextPrimaryAttack = gpGlobals->time + .50;
	m_flNextSecondaryAttack = gpGlobals->time + .50;
*/
	m_fShowLaser = gpGlobals->time + .6;

	SendWeaponAnim( SMG_SWITCH );

	m_flNextPrimaryAttack = gpGlobals->time + 1.0;
	m_flNextSecondaryAttack = gpGlobals->time + 1.0;
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}

void CSmg::Reload( void )
{
	int iResult;
	iResult = DefaultReload( SMG_MAX_CLIP, SMG_RELOAD, 1.4 );

	if ( iResult )
	{
		if (m_pSpot && m_fSpotActive)
			m_pSpot->Suspend( 1.4 );
/*
		if ( m_pBeam )
		{
			UTIL_Remove( m_pBeam );
			m_pBeam = NULL;
		}
*/
		m_flDropClipTime = gpGlobals->time + 0.5;
	}
}

void CSmg::ReloadClip( void )
{
	if ( m_flDropClipTime != 0 && m_flDropClipTime < gpGlobals->time )
	{
		UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		
		Vector	vecShellVelocity = m_pPlayer->pev->velocity 
							 + gpGlobals->v_right * RANDOM_FLOAT(-50,-70) 
							 + gpGlobals->v_up * RANDOM_FLOAT(-10,-15) 
							 + gpGlobals->v_forward * 25;
		EjectBrass ( pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_up * -20 + gpGlobals->v_forward * 32 + gpGlobals->v_right * -6 , vecShellVelocity, pev->angles.y, Shell, 0 ); 

		m_flDropClipTime = 0;
	}
}

void CSmg::WeaponIdle( void )
{
	if ( m_fShowLaser )
	{
		if ( m_fShowLaser < gpGlobals->time )
		{
			m_fSpotActive = ! m_fSpotActive;

			if (!m_fSpotActive && m_pSpot)
			{
				m_pSpot->Killed( NULL, GIB_NORMAL );
				m_pSpot = NULL;
			}
/*
			if ( m_pBeam )
			{
				UTIL_Remove( m_pBeam );
				m_pBeam = NULL;
			}
*/
			m_fShowLaser = 0;
		}

		UpdateSpot( );
		return;
	}

	UpdateSpot( );
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	int iAnim;
	switch ( RANDOM_LONG( 0, 1 ) )
	{
	case 0:	
		iAnim = SMG_IDLE1;	
		break;
	
	default:
	case 1:
		iAnim = SMG_IDLE2;
		break;
	}

	SendWeaponAnim( iAnim );

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}


void CSmg::UpdateSpot( void )
{
	if (m_fSpotActive)
	{
		if (!m_pSpot)
		{
			m_pSpot = CLaserSpot::CreateSpot();
		}

		UTIL_MakeVectors( m_pPlayer->pev->v_angle );
		Vector vecSrc = m_pPlayer->GetGunPosition( );;
		Vector vecAiming = gpGlobals->v_forward;

		TraceResult tr;
		UTIL_TraceLine ( vecSrc, vecSrc + vecAiming * 8192, dont_ignore_monsters, ENT(m_pPlayer->pev), &tr );
		UTIL_SetOrigin( m_pSpot->pev, tr.vecEndPos );
/*
		//make actual distance laser
		UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		vecSrc	 = m_pPlayer->GetGunPosition( );
		vecAiming = gpGlobals->v_forward;

		Vector vecTmpEnd = vecSrc + vecAiming * 2048;

		if ( !m_pBeam )
			m_pBeam = CBeam::BeamCreate( g_pModelNameLaser, 5 );

		//m_pBeam->SetStartPos( vecTmpEnd );
		m_pBeam->PointsInit( vecSrc +  gpGlobals->v_up * -7 + gpGlobals->v_forward * 28 + gpGlobals->v_right * 3,vecTmpEnd );
		//m_pBeam->PointEntInit( vecTmpEnd, m_pPlayer->entindex() );
		m_pBeam->SetColor( 255, 0, 0 );
		m_pBeam->SetScrollRate( 255 );
		m_pBeam->SetBrightness( 128 );
*/
	}
}


















