
#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"
#include "gamerules.h"


#define	PIPE_BODYHIT_VOLUME 128
#define	PIPE_WALLHIT_VOLUME 512

class CPipe : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 1; }
	void EXPORT SwingAgain( void );
	void EXPORT Smack( void );
	int GetItemInfo(ItemInfo *p);

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	int Swing( int fFirst, BOOL fSmash );
	BOOL Deploy( void );
	void Holster( int skiplocal = 0 );
	void WeaponIdle( void );
	int m_iSwing;
	TraceResult m_trHit;
};
LINK_ENTITY_TO_CLASS( weapon_steelpipe, CPipe );



enum pipe_e {
	PIPE_IDLE1 = 0,
	PIPE_IDLE2,
	PIPE_IDLE3,
	PIPE_HIT1,
	PIPE_HIT2,
	PIPE_MISS1,
	PIPE_MISS2,
	PIPE_SMASH,
	PIPE_DRAW,
	PIPE_HOLSTER,
};


void CPipe::Spawn( )
{
	Precache( );
	m_iId = WEAPON_PIPE;
	SET_MODEL(ENT(pev), "models/w_steelpipe.mdl");
	m_iClip = -1;

	FallInit();// get ready to fall down.
}


void CPipe::Precache( void )
{
	PRECACHE_MODEL("models/v_steelpipe.mdl");
	PRECACHE_MODEL("models/w_steelpipe.mdl");
	PRECACHE_MODEL("models/p_steelpipe.mdl");
	PRECACHE_SOUND("weapons/weap_pipe_hit1.wav");
	PRECACHE_SOUND("weapons/weap_pipe_hit2.wav");
	PRECACHE_SOUND("weapons/weap_pipe_hitbod1.wav");
	PRECACHE_SOUND("weapons/weap_pipe_hitbod2.wav");
	PRECACHE_SOUND("weapons/weap_pipe_hitbod3.wav");
	PRECACHE_SOUND("weapons/weap_pipe_miss1.wav");
	PRECACHE_SOUND("weapons/weap_pipe_miss2.wav");
}

int CPipe::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = NULL;
	p->iMaxAmmo1 = -1;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = WEAPON_NOCLIP;
	p->iSlot = 0;
	p->iPosition = 0;
	p->iId = WEAPON_PIPE;
	p->iWeight = PIPE_WEIGHT;
	return 1;
}



BOOL CPipe::Deploy( )
{
	return DefaultDeploy( "models/v_steelpipe.mdl", "models/p_steelpipe.mdl", PIPE_DRAW, "crowbar" );
}

void CPipe::Holster( int skiplocal /* = 0 */ )
{
	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.5;
	SendWeaponAnim( PIPE_HOLSTER );
}


void FindHullIntersection( const Vector &vecSrc, TraceResult &tr, float *mins, float *maxs, edict_t *pEntity )
{
	int			i, j, k;
	float		distance;
	float		*minmaxs[2] = {mins, maxs};
	TraceResult tmpTrace;
	Vector		vecHullEnd = tr.vecEndPos;
	Vector		vecEnd;

	distance = 1e6f;

	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc)*2);
	UTIL_TraceLine( vecSrc, vecHullEnd, dont_ignore_monsters, pEntity, &tmpTrace );
	if ( tmpTrace.flFraction < 1.0 )
	{
		tr = tmpTrace;
		return;
	}

	for ( i = 0; i < 2; i++ )
	{
		for ( j = 0; j < 2; j++ )
		{
			for ( k = 0; k < 2; k++ )
			{
				vecEnd.x = vecHullEnd.x + minmaxs[i][0];
				vecEnd.y = vecHullEnd.y + minmaxs[j][1];
				vecEnd.z = vecHullEnd.z + minmaxs[k][2];

				UTIL_TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pEntity, &tmpTrace );
				if ( tmpTrace.flFraction < 1.0 )
				{
					float thisDistance = (tmpTrace.vecEndPos - vecSrc).Length();
					if ( thisDistance < distance )
					{
						tr = tmpTrace;
						distance = thisDistance;
					}
				}
			}
		}
	}
}


void CPipe::PrimaryAttack()
{
	if (! Swing( 1, 0 ))
	{
		SetThink( SwingAgain );
		pev->nextthink = gpGlobals->time + 0.1;
	}
}

void CPipe::SecondaryAttack()
{
	Swing( 1, 1 );
}

void CPipe::Smack( )
{
	DecalGunshot( &m_trHit, BULLET_PLAYER_CROWBAR );
	m_flTimeWeaponIdle = gpGlobals->time + 5.0;
}


void CPipe::SwingAgain( void )
{
	Swing( 0, 0 );
}


int CPipe::Swing( int fFirst, BOOL fSmash )
{
	int fDidHit = FALSE;

	TraceResult tr;

	UTIL_MakeVectors (m_pPlayer->pev->v_angle);
	Vector vecSrc	= m_pPlayer->GetGunPosition( );
	Vector vecEnd	= vecSrc + gpGlobals->v_forward * 32;

	UTIL_TraceLine( vecSrc, vecEnd, dont_ignore_monsters, ENT( m_pPlayer->pev ), &tr );

	if ( tr.flFraction >= 1.0 )
	{
		UTIL_TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, ENT( m_pPlayer->pev ), &tr );
		if ( tr.flFraction < 1.0 )
		{
			// Calculate the point of intersection of the line (or hull) and the object we hit
			// This is and approximation of the "best" intersection
			CBaseEntity *pHit = CBaseEntity::Instance( tr.pHit );
			if ( !pHit || pHit->IsBSPModel() )
				FindHullIntersection( vecSrc, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer->edict() );
			vecEnd = tr.vecEndPos;	// This is the point on the actual surface (the hull could have hit space)
		}
	}

	if ( tr.flFraction >= 1.0 )
	{
		if (fFirst)
		{
			// miss
			if ( !fSmash )
			{
				switch( (m_iSwing++) % 3 )
				{
				case 0:
					SendWeaponAnim( PIPE_MISS1 ); break;
				case 1:
					SendWeaponAnim( PIPE_MISS2 ); break;
				case 2:
					SendWeaponAnim( PIPE_MISS1 ); break;
				}
			}
			else
				SendWeaponAnim( PIPE_SMASH );

			if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
				m_flNextPrimaryAttack = gpGlobals->time + 0.25;
			else
				m_flNextPrimaryAttack = gpGlobals->time + 0.5;

	
			// play wiff or swish sound
			if ( !fSmash )
			{
				if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
					m_flNextSecondaryAttack = gpGlobals->time + 0.5;
				else
					m_flNextSecondaryAttack = gpGlobals->time + 0.25;

				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_pipe_miss1.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xF));
			}
			else
			{
				if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
					m_flNextSecondaryAttack = gpGlobals->time + 1.25;
				else
					m_flNextSecondaryAttack = gpGlobals->time + 1.0;

				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_pipe_miss2.wav", 1, ATTN_NORM, 0, 94 + RANDOM_LONG(0,0xF));
			}

			// player "shoot" animation
			m_pPlayer->SetAnimation( PLAYER_ATTACK1 );
		}
	}
	else
	{
		// hit
		fDidHit = TRUE;

		CBaseEntity *pEntity = CBaseEntity::Instance(tr.pHit);

		if ( !fSmash )
		{
			switch( ((m_iSwing++) % 2) + 1 )
			{
			case 0:
				SendWeaponAnim( PIPE_HIT1 ); break;
			case 1:
				SendWeaponAnim( PIPE_HIT2 ); break;
			case 2:
				SendWeaponAnim( PIPE_HIT1 ); break;
			}
		}
		else
			SendWeaponAnim( PIPE_SMASH );

		// player "shoot" animation
		m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

		ClearMultiDamage( );
		if ( (m_flNextPrimaryAttack + 1 < gpGlobals->time) || g_pGameRules->IsMultiplayer() )
		{
			// first swing does full damage
			if ( fSmash )
				pEntity->TraceAttack(m_pPlayer->pev, gSkillData.plrDmgPipe * 2, gpGlobals->v_forward, &tr, DMG_CLUB ); 
			else
				pEntity->TraceAttack(m_pPlayer->pev, gSkillData.plrDmgPipe, gpGlobals->v_forward, &tr, DMG_CLUB ); 
		}
		else
		{
			// subsequent swings do half
			if ( fSmash )
				pEntity->TraceAttack(m_pPlayer->pev, gSkillData.plrDmgPipe, gpGlobals->v_forward, &tr, DMG_CLUB ); 
			else
				pEntity->TraceAttack(m_pPlayer->pev, gSkillData.plrDmgPipe / 2, gpGlobals->v_forward, &tr, DMG_CLUB ); 	
		}	
		ApplyMultiDamage( m_pPlayer->pev, m_pPlayer->pev );

		if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
			m_flNextPrimaryAttack = gpGlobals->time + .15;
		else
			m_flNextPrimaryAttack = gpGlobals->time + .25;

		if ( !fSmash )
		{
			if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
				m_flNextSecondaryAttack = gpGlobals->time + .15;
			else
				m_flNextSecondaryAttack = gpGlobals->time + .25;
		}
		else
		{
			if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
				m_flNextSecondaryAttack = gpGlobals->time + .5;
			else
				m_flNextSecondaryAttack = gpGlobals->time + .75;
		}

		// play thwack, smack, or dong sound
		float flVol = 1.0;
		int fHitWorld = TRUE;

		if (pEntity)
		{
			if (pEntity->Classify() != CLASS_NONE && pEntity->Classify() != CLASS_MACHINE)
			{
				// play thwack or smack sound
				switch( RANDOM_LONG(0,2) )
				{
				case 0:
					EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_pipe_hitbod1.wav", 1, ATTN_NORM); break;
				case 1:
					EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_pipe_hitbod2.wav", 1, ATTN_NORM); break;
				case 2:
					EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_pipe_hitbod3.wav", 1, ATTN_NORM); break;
				}
				m_pPlayer->m_iWeaponVolume = PIPE_BODYHIT_VOLUME;
				if (!pEntity->IsAlive() )
					return TRUE;
				else
					flVol = 0.1;

				fHitWorld = FALSE;
			}
		}

		// play texture hit sound
		// UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

		if (fHitWorld)
		{
			float fvolbar = TEXTURETYPE_PlaySound(&tr, vecSrc, vecSrc + (vecEnd-vecSrc)*2, BULLET_PLAYER_CROWBAR);

			if ( g_pGameRules->IsMultiplayer() )
			{
				// override the volume here, cause we don't play texture sounds in multiplayer, 
				// and fvolbar is going to be 0 from the above call.

				fvolbar = 1;
			}

			// also play crowbar strike
			switch( RANDOM_LONG(0,1) )
			{
			case 0:
				//UTIL_EmitAmbientSound(ENT(0), ptr->vecEndPos, "weapons/cbar_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + RANDOM_LONG(0,3));
				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/weap_pipe_hit1.wav", fvolbar, ATTN_NORM, 0, 98 + RANDOM_LONG(0,3)); 
				break;
			case 1:
				//UTIL_EmitAmbientSound(ENT(0), ptr->vecEndPos, "weapons/cbar_hit2.wav", fvolbar, ATTN_NORM, 0, 98 + RANDOM_LONG(0,3));
				EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_ITEM, "weapons/weap_pipe_hit2.wav", fvolbar, ATTN_NORM, 0, 98 + RANDOM_LONG(0,3)); 
				break;
			}
		}

		// delay the decal a bit
		m_trHit = tr;
		SetThink( Smack );
		pev->nextthink = gpGlobals->time + 0.2;

		m_pPlayer->m_iWeaponVolume = flVol * PIPE_WALLHIT_VOLUME;
	}
	return fDidHit;
}

void CPipe::WeaponIdle( void )
{
	ResetEmptySound( );

	m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	if (m_flTimeWeaponIdle < gpGlobals->time)
	{
		int iAnim;
		float flRand = RANDOM_FLOAT(0, 1);
		if (flRand <= 0.8)
		{
			iAnim = PIPE_IDLE1;
			m_flTimeWeaponIdle = gpGlobals->time + (60.0/12.0);// * RANDOM_LONG(2, 5);
		}
		else if (flRand <= 0.95)
		{
			iAnim = PIPE_IDLE2;
			m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
		}
		else
		{
			iAnim = PIPE_IDLE3;
			m_flTimeWeaponIdle = gpGlobals->time + (20.0/9.0);
		}
		SendWeaponAnim( iAnim );
	}
}




