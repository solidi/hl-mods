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
#include "player.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "effects.h"
#include "customentity.h"
#include "gamerules.h"

#define	EGON_PRIMARY_VOLUME		450
#define EGON_BEAM_SPRITE		"sprites/XSpark1.spr"
#define EGON_FLARE_SPRITE		"sprites/XSpark1.spr"
#define EGON_SOUND_OFF			"weapons/egon_off1.wav"
#define EGON_SOUND_RUN			"weapons/egon_run3.wav"
#define EGON_SOUND_STARTUP		"weapons/egon_windup2.wav"

#define EGON_SWITCH_NARROW_TIME			0.75			// Time it takes to switch fire modes
#define EGON_SWITCH_WIDE_TIME			1.5


enum egon_e {
	EGON_IDLE1 = 0,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};


class CRaygun : public CBasePlayerWeapon
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

	void CreateEffect( void );
	void UpdateEffect( const Vector &startPoint, const Vector &endPoint, float timeBlend );
	void DestroyEffect( void );

	void EndAttack( void );
	void Attack( void );
	void PrimaryAttack( void );
	void WeaponIdle( void );
	static int g_fireAnims1[];
	static int g_fireAnims2[];

	int m_iBeam;

	float m_flAmmoUseTime;// since we use < 1 point of ammo per update, we subtract ammo on a timer.

	float GetPulseInterval( void );
	float GetDischargeInterval( void );

	void Fire( const Vector &vecOrigSrc, const Vector &vecDir );

	BOOL HasAmmo( void )
	{
		if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
			return FALSE;
		return TRUE;
	}

	void UseAmmo( int count )
	{
		if ( m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] >= count )
			m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] -= count;
		else
			m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] = 0;
	}

	enum EGON_FIRESTATE { FIRE_OFF, FIRE_CHARGE };
	enum EGON_FIREMODE { FIRE_NARROW, FIRE_WIDE};

private:
	float				m_shootTime;
	CBeam				*m_pBeam;
	CBeam				*m_pBeam1;
	CBeam				*m_pNoise;
	CSprite				*m_pSprite;
	EGON_FIRESTATE		m_fireState;
	EGON_FIREMODE		m_fireMode;
	float				m_shakeTime;
	BOOL				m_deployed;
};

LINK_ENTITY_TO_CLASS( weapon_raygun, CRaygun );

int CRaygun::g_fireAnims1[] = { EGON_FIRE1, EGON_FIRE2, EGON_FIRE3, EGON_FIRE4 };
int CRaygun::g_fireAnims2[] = { EGON_ALTFIRECYCLE };


TYPEDESCRIPTION	CRaygun::m_SaveData[] = 
{
	DEFINE_FIELD( CRaygun, m_pBeam, FIELD_CLASSPTR ),
	DEFINE_FIELD( CRaygun, m_pNoise, FIELD_CLASSPTR ),
	DEFINE_FIELD( CRaygun, m_pSprite, FIELD_CLASSPTR ),
	DEFINE_FIELD( CRaygun, m_shootTime, FIELD_TIME ),
	DEFINE_FIELD( CRaygun, m_fireState, FIELD_INTEGER ),
	DEFINE_FIELD( CRaygun, m_fireMode, FIELD_INTEGER ),
	DEFINE_FIELD( CRaygun, m_shakeTime, FIELD_TIME ),
	DEFINE_FIELD( CRaygun, m_flAmmoUseTime, FIELD_TIME ),
};
IMPLEMENT_SAVERESTORE( CRaygun, CBasePlayerWeapon );


void CRaygun::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_RAYGUN;
	SET_MODEL(ENT(pev), "models/w_egon.mdl");

	m_iDefaultAmmo = 3;

	FallInit();// get ready to fall down.
	}
}


void CRaygun::Precache( void )
{
	PRECACHE_MODEL("models/w_egon.mdl");
	PRECACHE_MODEL("models/v_egon.mdl");
	PRECACHE_MODEL("models/p_egon.mdl");

	PRECACHE_MODEL("models/w_9mmclip.mdl");
	PRECACHE_SOUND("items/9mmclip1.wav");

	m_iBeam = PRECACHE_MODEL( "sprites/smoke.spr" );

	PRECACHE_SOUND( EGON_SOUND_OFF );
	PRECACHE_SOUND( EGON_SOUND_RUN );
	PRECACHE_SOUND( EGON_SOUND_STARTUP );

	PRECACHE_MODEL( EGON_BEAM_SPRITE );
	PRECACHE_MODEL( EGON_FLARE_SPRITE );

	PRECACHE_SOUND ("weapons/357_cock1.wav");
}


BOOL CRaygun::Deploy( void )
{
	m_deployed = FALSE;
	return DefaultDeploy( "models/v_egon.mdl", "models/p_egon.mdl", EGON_DRAW, "egon" );
}

int CRaygun::AddToPlayer( CBasePlayer *pPlayer )
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



void CRaygun::Holster( void )
{
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	// m_flTimeWeaponIdle = gpGlobals->time + UTIL_RandomFloat ( 10, 15 );
	SendWeaponAnim( EGON_HOLSTER );

	if ( m_fireState != FIRE_OFF )
		EndAttack();
}

int CRaygun::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "ARgrenades";
	p->iMaxAmmo1 = M203_GRENADE_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = WEAPON_NOCLIP;
	p->iSlot = 3;
	p->iPosition = 3;
	p->iId = m_iId = WEAPON_RAYGUN;
	p->iFlags = 0;
	p->iWeight = 0;

	return 1;
}


//#define EGON_PULSE_INTERVAL			0.25
//#define EGON_DISCHARGE_INTERVAL		0.5

#define EGON_PULSE_INTERVAL			0.1
#define EGON_DISCHARGE_INTERVAL		0.1

float CRaygun::GetPulseInterval( void )
{
	if ( g_pGameRules->IsMultiplayer() )
	{
		return 0.1;
	}

	return EGON_PULSE_INTERVAL;
}

float CRaygun::GetDischargeInterval( void )
{
	if ( g_pGameRules->IsMultiplayer() )
	{
		return 0.1;
	}

	return EGON_DISCHARGE_INTERVAL;
}

void CRaygun::Attack( void )
{
	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		if ( m_pBeam )
		{
			EndAttack();
		}
		else
		{
			PlayEmptySound( );
		}
		return;
	}

	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
	Vector vecAiming = gpGlobals->v_forward;
	Vector vecSrc	 = m_pPlayer->GetGunPosition( );

	switch( m_fireState )
	{
		case FIRE_OFF:
		{
			if ( !HasAmmo() )
			{
				m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + 0.25;
				PlayEmptySound( );
				return;
			}

			m_flAmmoUseTime = gpGlobals->time;// start using ammo ASAP.

			SendWeaponAnim( g_fireAnims1[ RANDOM_LONG(0,ARRAYSIZE(g_fireAnims1)-1) ] );
			m_shakeTime = 0;

			m_pPlayer->m_iWeaponVolume = EGON_PRIMARY_VOLUME;
			m_flTimeWeaponIdle = gpGlobals->time + 0.1;
			m_shootTime = gpGlobals->time + 2;

			if ( m_fireMode == FIRE_WIDE )
			{
				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, EGON_SOUND_STARTUP, 0.98, ATTN_NORM, 0, 125 );
			}
			else
			{
				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, EGON_SOUND_STARTUP, 0.9, ATTN_NORM, 0, 100 );
			}

			pev->dmgtime = gpGlobals->time + GetPulseInterval();
			m_fireState = FIRE_CHARGE;
		}
		break;

		case FIRE_CHARGE:
		{
			Fire( vecSrc, vecAiming );
			m_pPlayer->m_iWeaponVolume = EGON_PRIMARY_VOLUME;

			if ( m_shootTime != 0 && gpGlobals->time > m_shootTime )
			{
				if ( m_fireMode == FIRE_WIDE )
				{
					EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_STATIC, EGON_SOUND_RUN, 0.98, ATTN_NORM, 0, 125 );
				}
				else
				{
					EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_STATIC, EGON_SOUND_RUN, 0.9, ATTN_NORM, 0, 100 );
				}

				m_shootTime = 0;
			}
			if ( !HasAmmo() )
			{
				EndAttack();
				m_fireState = FIRE_OFF;
				m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + 1.0;
			}

		}
		break;
	}
}

void CRaygun::PrimaryAttack( void )
{
	m_fireMode = FIRE_WIDE;
	Attack();

}

void CRaygun::Fire( const Vector &vecOrigSrc, const Vector &vecDir )
{
	Vector vecDest = vecOrigSrc + vecDir * 2048;
	edict_t		*pentIgnore;
	TraceResult tr;

	pentIgnore = m_pPlayer->edict();
	Vector tmpSrc = vecOrigSrc + gpGlobals->v_up * -8 + gpGlobals->v_right * 3;

	// ALERT( at_console, "." );
	
	UTIL_TraceLine( vecOrigSrc, vecDest, dont_ignore_monsters, pentIgnore, &tr );

	if (tr.fAllSolid)
		return;

	CBaseEntity *pEntity = CBaseEntity::Instance(tr.pHit);

	if (pEntity == NULL)
		return;

	if ( g_pGameRules->IsMultiplayer() )
	{
		if ( m_pSprite && pEntity->pev->takedamage )
		{
			m_pSprite->pev->effects &= ~EF_NODRAW;
		}
		else if ( m_pSprite )
		{
			m_pSprite->pev->effects |= EF_NODRAW;
		}
	}

	float timedist;

	switch ( m_fireMode )
	{
	case FIRE_NARROW:
		if ( pev->dmgtime < gpGlobals->time )
		{
			// Narrow mode only does damage to the entity it hits
			ClearMultiDamage();
			if (pEntity->pev->takedamage)
			{
				pEntity->TraceAttack( m_pPlayer->pev, gSkillData.plrDmgEgonNarrow, vecDir, &tr, DMG_ENERGYBEAM );
			}
			ApplyMultiDamage(m_pPlayer->pev, m_pPlayer->pev);

			if ( g_pGameRules->IsMultiplayer() )
			{
				// multiplayer uses 1 ammo every 1/10th second
				if ( gpGlobals->time >= m_flAmmoUseTime )
				{
					UseAmmo( 1 );
					m_flAmmoUseTime = gpGlobals->time + 0.1;
				}
			}
			else
			{
				// single player, use 3 ammo/second
				if ( gpGlobals->time >= m_flAmmoUseTime )
				{
					UseAmmo( 1 );
					m_flAmmoUseTime = gpGlobals->time + 0.166;
				}
			}

			pev->dmgtime = gpGlobals->time + GetPulseInterval();
		}
		timedist = ( pev->dmgtime - gpGlobals->time ) / GetPulseInterval();
		break;
	
	case FIRE_WIDE:
		if ( pev->dmgtime < gpGlobals->time )
		{
			// wide mode does damage to the ent, and radius damage
			ClearMultiDamage();
			if (pEntity->pev->takedamage)
			{
				pEntity->TraceAttack( m_pPlayer->pev, gSkillData.plrDmgEgonWide, vecDir, &tr, DMG_ENERGYBEAM | DMG_ALWAYSGIB);
			}
			ApplyMultiDamage(m_pPlayer->pev, m_pPlayer->pev);

			if ( g_pGameRules->IsMultiplayer() )
			{
				// radius damage a little more potent in multiplayer.
				::RadiusDamage( tr.vecEndPos, pev, m_pPlayer->pev, gSkillData.plrDmgEgonWide/4, 128, CLASS_NONE, DMG_ENERGYBEAM | DMG_BLAST | DMG_ALWAYSGIB );
			}

			if ( !m_pPlayer->IsAlive() )
				return;

			if ( g_pGameRules->IsMultiplayer() )
			{
				//multiplayer uses 5 ammo/second
				if ( gpGlobals->time >= m_flAmmoUseTime )
				{
					UseAmmo( 1 );
					m_flAmmoUseTime = gpGlobals->time + 0.2;
				}
			}
			else
			{
				// Wide mode uses 10 charges per second in single player
				if ( gpGlobals->time >= m_flAmmoUseTime )
				{
					UseAmmo( 1 );
					m_flAmmoUseTime = gpGlobals->time + 0.1;
				}
			}

			pev->dmgtime = gpGlobals->time + GetDischargeInterval();
			if ( m_shakeTime < gpGlobals->time )
			{
				UTIL_ScreenShake( tr.vecEndPos, 5.0, 150.0, 0.75, 250.0 );
				m_shakeTime = gpGlobals->time + 1.5;
			}
		}
		timedist = ( pev->dmgtime - gpGlobals->time ) / GetDischargeInterval();
		break;
	}

	if ( timedist < 0 )
		timedist = 0;
	else if ( timedist > 1 )
		timedist = 1;
	timedist = 1-timedist;

	UpdateEffect( tmpSrc, tr.vecEndPos, timedist );
}


void CRaygun::UpdateEffect( const Vector &startPoint, const Vector &endPoint, float timeBlend )
{
	if ( !m_pBeam )
	{
		CreateEffect();
	}

	m_pBeam->SetStartPos( endPoint );
	m_pBeam->SetBrightness( 255 - (timeBlend*180) );
	m_pBeam->SetWidth( 4 );

	m_pBeam1->SetStartPos( endPoint );
	m_pBeam1->SetBrightness( 255 - (timeBlend*180) );
	m_pBeam1->SetWidth( 4 );

	/*
	if ( m_fireMode == FIRE_WIDE )
		m_pBeam->SetColor( 30 + (25*timeBlend), 30 + (30*timeBlend), 64 + 80*fabs(sin(gpGlobals->time*10)) );
	else
		m_pBeam->SetColor( 60 + (25*timeBlend), 120 + (30*timeBlend), 64 + 80*fabs(sin(gpGlobals->time*10)) );
*/

	UTIL_SetOrigin( m_pSprite->pev, endPoint );
	m_pSprite->pev->frame += 8 * gpGlobals->frametime;
	if ( m_pSprite->pev->frame > m_pSprite->Frames() )
		m_pSprite->pev->frame = 0;

	m_pNoise->SetStartPos( endPoint );
}


void CRaygun::CreateEffect( void )
{
	DestroyEffect();

	m_pBeam = CBeam::BeamCreate( EGON_BEAM_SPRITE, 2 );
	m_pBeam->PointEntInit( pev->origin, m_pPlayer->entindex() );
	m_pBeam->SetFlags( BEAM_FSINE );
	m_pBeam->SetEndAttachment( 1 );
	m_pBeam->pev->spawnflags |= SF_BEAM_TEMPORARY;	// Flag these to be destroyed on save/restore or level transition

	m_pBeam1 = CBeam::BeamCreate( EGON_BEAM_SPRITE, 4 );
	m_pBeam1->PointEntInit( pev->origin, m_pPlayer->entindex() );
	m_pBeam1->SetFlags( BEAM_FSINE );
	m_pBeam1->SetEndAttachment( 1 );
	m_pBeam1->pev->spawnflags |= SF_BEAM_TEMPORARY;	// Flag these to be destroyed on save/restore or level transition

	m_pNoise = CBeam::BeamCreate( EGON_BEAM_SPRITE, 40 );
	m_pNoise->PointEntInit( pev->origin, m_pPlayer->entindex() );
	m_pNoise->SetScrollRate( 25 );
	m_pNoise->SetBrightness( 400 );
	m_pNoise->SetEndAttachment( 1 );
	m_pNoise->pev->spawnflags |= SF_BEAM_TEMPORARY;

	m_pSprite = CSprite::SpriteCreate( EGON_FLARE_SPRITE, pev->origin, FALSE );
	m_pSprite->pev->scale = 1.0;
	m_pSprite->SetTransparency( kRenderGlow, 255, 0, 0, 255, kRenderFxNoDissipation );
	m_pSprite->pev->spawnflags |= SF_SPRITE_TEMPORARY;

	if ( m_fireMode == FIRE_WIDE )
	{
		m_pBeam->SetScrollRate( 400 );
		m_pBeam->SetNoise( 10 );
		m_pBeam1->SetScrollRate( 400 );
		m_pBeam->SetColor( 255, 0 , 113 );
		m_pBeam1->SetNoise( 15 );
		m_pNoise->SetColor( 0, 113, 230 );
		m_pNoise->SetNoise( 0 );
	}
	else
	{
		m_pBeam->SetScrollRate( 300 );
		m_pBeam->SetNoise( 10 );
		m_pBeam1->SetScrollRate( 400 );
		m_pBeam1->SetNoise( 15 );
		m_pBeam->SetColor( 255, 0 , 113 );
		m_pNoise->SetColor( 0, 113, 230 );
		m_pNoise->SetNoise( 0 );
	}
}


void CRaygun::DestroyEffect( void )
{
	if ( m_pBeam )
	{
		UTIL_Remove( m_pBeam );
		m_pBeam = NULL;
	}
	if ( m_pBeam1 )
	{
		UTIL_Remove( m_pBeam1 );
		m_pBeam1 = NULL;
	}
	if ( m_pNoise )
	{
		UTIL_Remove( m_pNoise );
		m_pNoise = NULL;
	}
	if ( m_pSprite )
	{
		if ( m_fireMode == FIRE_WIDE )
			m_pSprite->Expand( 10, 5 );
	}
}


void CRaygun::WeaponIdle( void )
{
	ResetEmptySound( );

	if ( m_flTimeWeaponIdle > gpGlobals->time )
		return;

	if ( m_fireState != FIRE_OFF )
		EndAttack();


	int iAnim;

	float flRand = RANDOM_FLOAT(0,1);

	if ( flRand <= 0.5 )
	{
		iAnim = EGON_IDLE1;
		m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT(10,15);
	}
	else 
	{
		iAnim = EGON_FIDGET1;
		m_flTimeWeaponIdle = gpGlobals->time + 3;
	}

	SendWeaponAnim( iAnim );
	m_deployed = TRUE;
}



void CRaygun::EndAttack( void )
{
	STOP_SOUND( ENT(m_pPlayer->pev), CHAN_STATIC, EGON_SOUND_RUN );
	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, EGON_SOUND_OFF, 0.98, ATTN_NORM, 0, 100); 
	m_fireState = FIRE_OFF;
	m_flTimeWeaponIdle = gpGlobals->time + 2.0;
	m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + 0.5;
	DestroyEffect();
}

