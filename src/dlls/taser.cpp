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
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"
#include "soundent.h"
#include "shake.h"
#include "gamerules.h"


#define	TASER_PRIMARY_CHARGE_VOLUME	256// how loud gauss is while charging
#define TASER_PRIMARY_FIRE_VOLUME	450// how loud gauss is when discharged

enum taser_e {
	GAUSS_IDLE = 0,
	GAUSS_IDLE2,
	GAUSS_FIDGET,
	GAUSS_SPINUP,
	GAUSS_SPIN,
	GAUSS_FIRE,
	GAUSS_FIRE2,
	GAUSS_HOLSTER,
	GAUSS_DRAW
};

class CTaser : public CBasePlayerWeapon
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
	void SecondaryAttack( void );
	void WeaponIdle( void );

	int m_fInAttack;
	float m_flStartCharge;
	float m_flPlayAftershock;
	void StartFire( void );
	void Fire( Vector vecOrigSrc, Vector vecDirShooting, float flDamage );
	float GetFullChargeTime( void );
	int m_iBalls;
	int m_iGlow;
	int m_iBeam;
	int m_iSoundState; // don't save this

	float m_flNextAmmoBurn;// while charging, when to absorb another unit of player's ammo?

	// was this weapon just fired primary or secondary?
	// we need to know so we can pick the right set of effects. 
	BOOL m_fPrimaryFire;
};
LINK_ENTITY_TO_CLASS( weapon_taser, CTaser );


TYPEDESCRIPTION	CTaser::m_SaveData[] = 
{
	DEFINE_FIELD( CTaser, m_fInAttack, FIELD_INTEGER ),
	DEFINE_FIELD( CTaser, m_flStartCharge, FIELD_TIME ),
	DEFINE_FIELD( CTaser, m_flPlayAftershock, FIELD_TIME ),
	DEFINE_FIELD( CTaser, m_flNextAmmoBurn, FIELD_TIME ),
	DEFINE_FIELD( CTaser, m_fPrimaryFire, FIELD_BOOLEAN ),
};
IMPLEMENT_SAVERESTORE( CTaser, CBasePlayerWeapon );


float CTaser::GetFullChargeTime( void )
{
	if ( g_pGameRules->IsMultiplayer() )
	{
		return 1.5;
	}

	return 4;
}

void CTaser::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
	Precache( );
	m_iId = WEAPON_TASER;
	SET_MODEL(ENT(pev), "models/wmodels/w_taser.mdl");

	m_iDefaultAmmo = 3;

	FallInit();// get ready to fall down.
	}
}


void CTaser::Precache( void )
{
	PRECACHE_MODEL("models/wmodels/w_taser.mdl");
	PRECACHE_MODEL("models/vmodels/v_taser.mdl");
	PRECACHE_MODEL("models/pmodels/p_taser.mdl");

	PRECACHE_SOUND("items/9mmclip1.wav");

	PRECACHE_SOUND("weapons/gauss2.wav");
	PRECACHE_SOUND("weapons/electro4.wav");
	PRECACHE_SOUND("weapons/electro5.wav");
	PRECACHE_SOUND("weapons/electro6.wav");
	PRECACHE_SOUND("ambience/pulsemachine.wav");
	
	m_iGlow = PRECACHE_MODEL( "sprites/hotglow.spr" );
	m_iBalls = PRECACHE_MODEL( "sprites/hotglow.spr" );
	m_iBeam = PRECACHE_MODEL( "sprites/smoke.spr" );
}

int CTaser::AddToPlayer( CBasePlayer *pPlayer )
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

int CTaser::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = NULL;
	p->iMaxAmmo1 = -1;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = WEAPON_NOCLIP;
	p->iSlot = 4;
	p->iPosition = 1;
	p->iId = m_iId = WEAPON_TASER;
	p->iFlags = 0;
	p->iWeight = -1;
	p->weaponName = "Taser";

	return 1;
}


BOOL CTaser::Deploy( )
{
	return DefaultDeploy( "models/vmodels/v_taser.mdl", "models/pmodels/p_taser.mdl", GAUSS_DRAW, "gauss" );
}


void CTaser::Holster( )
{
	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
	SendWeaponAnim( GAUSS_HOLSTER );
	m_fInAttack = 0;
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "common/null.wav", 1.0, ATTN_NORM);
}


void CTaser::PrimaryAttack()
{
	if (m_pPlayer->pev->armorvalue <= 3)
	{
//		ShowSmart (m_pPlayer, 0x7, 4, 0, "--Low Power--\nYou cannot use Taser due\n to low battery power" );
      	PlayEmptySound( );
		m_pPlayer->m_flNextAttack = gpGlobals->time + .5;
		return;
	}
	else
	{
		m_pPlayer->pev->armorvalue -= 2; //takes more battery power to turn on than off
	}

	// don't fire underwater
	if (m_pPlayer->pev->waterlevel == 3)
	{
		PlayEmptySound( );
		m_flNextSecondaryAttack = m_flNextPrimaryAttack = gpGlobals->time + 0.15;
		return;
	}

	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] < 2)
	{
		PlayEmptySound( );
		m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
		return;
	}

	m_pPlayer->m_iWeaponVolume = TASER_PRIMARY_FIRE_VOLUME;

	m_fPrimaryFire = TRUE;

	StartFire();
	m_fInAttack = 0;
	m_flTimeWeaponIdle = gpGlobals->time + 1.0;
	m_pPlayer->m_flNextAttack = gpGlobals->time + 1.0;
}

void CTaser::SecondaryAttack()
{

}

//=========================================================
// StartFire- since all of this code has to run and then 
// call Fire(), it was easier at this point to rip it out 
// of weaponidle() and make its own function then to try to
// merge this into Fire(), which has some identical variable names 
//=========================================================
void CTaser::StartFire( void )
{
	float flDamage;
	
	UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
	Vector vecAiming = gpGlobals->v_forward;
	Vector vecSrc = m_pPlayer->GetGunPosition( ); // + gpGlobals->v_up * -8 + gpGlobals->v_right * 8;
	
	if (gpGlobals->time - m_flStartCharge > GetFullChargeTime())
	{
		flDamage = 200;
	}
	else
	{
		flDamage = 200 * ((gpGlobals->time - m_flStartCharge) / GetFullChargeTime() );
	}

	if ( m_fPrimaryFire )
	{
		// fixed damage on primary attack
		flDamage = gSkillData.plrDmgGauss;
		m_pPlayer->pev->punchangle.x = -2;// punch now, after building aim vector
	}

	if (m_fInAttack != 3)
	{
		//ALERT ( at_console, "Time:%f Damage:%f\n", gpGlobals->time - m_flStartCharge, flDamage );

		float flZVel = m_pPlayer->pev->velocity.z;

		if ( !m_fPrimaryFire )
		{
			m_pPlayer->pev->velocity = m_pPlayer->pev->velocity - gpGlobals->v_forward * flDamage * 5;
		}

		if ( !g_pGameRules->IsDeathmatch() )
		{
			// in deathmatch, gauss can pop you up into the air. Not in single play.
			m_pPlayer->pev->velocity.z = flZVel;
		}

		SendWeaponAnim( GAUSS_FIRE2 );

		// player "shoot" animation
		m_pPlayer->SetAnimation( PLAYER_ATTACK1 );
	}
	STOP_SOUND( ENT(m_pPlayer->pev), CHAN_WEAPON, "ambience/pulsemachine.wav" );
	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/gauss2.wav", 0.5 + flDamage * (1.0 / 400.0), ATTN_NORM, 0, 85 + RANDOM_LONG(0,0x1f)); 
	// time until aftershock 'static discharge' sound
	m_flPlayAftershock = gpGlobals->time + RANDOM_FLOAT(0.3, 0.8);

	Fire( vecSrc, vecAiming, flDamage );
}

void CTaser::Fire( Vector vecOrigSrc, Vector vecDir, float flDamage )
{
	m_pPlayer->m_iWeaponVolume = TASER_PRIMARY_FIRE_VOLUME;

	Vector vecSrc = vecOrigSrc;
	Vector vecDest = vecSrc + vecDir * 8192;
	edict_t		*pentIgnore;
	TraceResult tr, beam_tr;
	float flMaxFrac = 1.0;
	int	nTotal = 0;
	int fHasPunched = 0;
	int fFirstBeam = 1;
	int	nMaxHits = 10;

	pentIgnore = ENT( m_pPlayer->pev );

	while (flDamage > 10 && nMaxHits > 0)
	{
		nMaxHits--;

		// ALERT( at_console, "." );
		UTIL_TraceLine(vecSrc, vecDest, dont_ignore_monsters, pentIgnore, &tr);

		if (tr.fAllSolid)
			break;

		CBaseEntity *pEntity = CBaseEntity::Instance(tr.pHit);

		if (pEntity == NULL)
			break;

		if (fFirstBeam)
		{
			m_pPlayer->pev->effects |= EF_MUZZLEFLASH;
			fFirstBeam = 0;

			Vector tmpSrc = vecSrc + gpGlobals->v_up * -8 + gpGlobals->v_right * -2;

			// don't draw beam until the damn thing looks like it's coming out of the barrel
			// draw beam
			MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, tr.vecEndPos );
				WRITE_BYTE( TE_BEAMENTPOINT );
				WRITE_SHORT( m_pPlayer->entindex() + 0x1000 );
				WRITE_COORD( tr.vecEndPos.x);
				WRITE_COORD( tr.vecEndPos.y);
				WRITE_COORD( tr.vecEndPos.z);
				WRITE_SHORT( m_iBeam );
				WRITE_BYTE( 0 ); // startframe
				WRITE_BYTE( 0 ); // framerate
				WRITE_BYTE( 1 ); // life

				if ( m_fPrimaryFire )
				{
					WRITE_BYTE( 10 );  // width
				}
				else
				{
					WRITE_BYTE( 25 );  // width
				}

				WRITE_BYTE( 0 );   // noise

				if ( m_fPrimaryFire )
				{
					WRITE_BYTE( 0 );   // r, g, b
					WRITE_BYTE( 113 );   // r, g, b
					WRITE_BYTE( 230 );   // r, g, b

					WRITE_BYTE( 200 );	// brightness
				}
				else
				{
					// secondary shot is always white, and intensity based on charge
					WRITE_BYTE( 255 );   // r, g, b
					WRITE_BYTE( 255 );   // r, g, b
					WRITE_BYTE( 255 );   // r, g, b
				
					WRITE_BYTE( flDamage );	// brightness
				}

				WRITE_BYTE( 0 );		// speed
			MESSAGE_END();

			nTotal += 26;
		}
		else
		{
			// draw beam
			MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, vecSrc );
				WRITE_BYTE( TE_BEAMPOINTS);
				WRITE_COORD( vecSrc.x);
				WRITE_COORD( vecSrc.y);
				WRITE_COORD( vecSrc.z);
				WRITE_COORD( tr.vecEndPos.x);
				WRITE_COORD( tr.vecEndPos.y);
				WRITE_COORD( tr.vecEndPos.z);
				WRITE_SHORT( m_iBeam );
				WRITE_BYTE( 0 ); // startframe
				WRITE_BYTE( 0 ); // framerate
				WRITE_BYTE( 1 ); // life

				if ( m_fPrimaryFire )
				{
					WRITE_BYTE( 5 );  // width
				}
				else
				{
					WRITE_BYTE( 25 );  // width
				}

				WRITE_BYTE( 0 );   // noise

				if ( m_fPrimaryFire )
				{
					// primary shot always looks full intensity
					WRITE_BYTE( 0 );   // r, g, b
					WRITE_BYTE( 113 );   // r, g, b
					WRITE_BYTE( 230 );   // r, g, b

					WRITE_BYTE( 200 );	// brightness
				}
				else
				{
					// secondary shot is always white, and intensity based on charge
					WRITE_BYTE( 255 );   // r, g, b
					WRITE_BYTE( 255 );   // r, g, b
					WRITE_BYTE( 255 );   // r, g, b
				
					WRITE_BYTE( flDamage );	// brightness
				}

				WRITE_BYTE( 0 );		// speed
			MESSAGE_END();
			nTotal += 26;
		}

		if (pEntity->pev->takedamage)
		{
			ClearMultiDamage();
			pEntity->TraceAttack( m_pPlayer->pev, flDamage, vecDir, &tr, DMG_BULLET );
			ApplyMultiDamage(m_pPlayer->pev, m_pPlayer->pev);
		}


		if ( pEntity->ReflectGauss() )
		{
			float n;

			pentIgnore = NULL;

			n = -DotProduct(tr.vecPlaneNormal, vecDir);

			if (n < 0.5) // 60 degrees
			{
	
				Vector r;
			
				r = 2.0 * tr.vecPlaneNormal * n + vecDir;
				flMaxFrac = flMaxFrac - tr.flFraction;
				vecDir = r;
				vecSrc = tr.vecEndPos + vecDir * 8;
				vecDest = vecSrc + vecDir * 8192;

				// explode a bit
				m_pPlayer->RadiusDamage( tr.vecEndPos, pev, m_pPlayer->pev, flDamage * n, CLASS_NONE, DMG_BLAST );

				// bounce wall glow
				MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, tr.vecEndPos );
					WRITE_BYTE( TE_GLOWSPRITE );
					WRITE_COORD( tr.vecEndPos.x);		// pos
					WRITE_COORD( tr.vecEndPos.y);
					WRITE_COORD( tr.vecEndPos.z);
					WRITE_SHORT( m_iGlow );				// model
					WRITE_BYTE( flDamage * n * 0.5 );	// life * 10
					WRITE_BYTE( 2 );					// size * 10
					WRITE_BYTE( flDamage * n );			// brightness
				MESSAGE_END();

				nTotal += 13;

				// balls
				MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, tr.vecEndPos );
					WRITE_BYTE( TE_SPRITETRAIL );// TE_RAILTRAIL);
					WRITE_COORD( tr.vecEndPos.x );
					WRITE_COORD( tr.vecEndPos.y );
					WRITE_COORD( tr.vecEndPos.z );
					WRITE_COORD( tr.vecEndPos.x + tr.vecPlaneNormal.x );
					WRITE_COORD( tr.vecEndPos.y + tr.vecPlaneNormal.y );
					WRITE_COORD( tr.vecEndPos.z + tr.vecPlaneNormal.z );
					WRITE_SHORT( m_iBalls );		// model
					WRITE_BYTE( n * flDamage * 0.3 );				// count
					WRITE_BYTE( 10 );				// life * 10
					WRITE_BYTE( RANDOM_LONG( 1, 2 ) );				// size * 10
					WRITE_BYTE( 10 );				// amplitude * 0.1
					WRITE_BYTE( 20 );				// speed * 100
				MESSAGE_END();

				nTotal += 21;

				// lose energy
				if (n == 0) n = 0.1;
				flDamage = flDamage * (1 - n);
			}
			else
			{
				// tunnel
				DecalGunshot( &tr, BULLET_MONSTER_12MM );

				// entry wall glow
				MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, tr.vecEndPos );
					WRITE_BYTE( TE_GLOWSPRITE );
					WRITE_COORD( tr.vecEndPos.x);	// pos
					WRITE_COORD( tr.vecEndPos.y);
					WRITE_COORD( tr.vecEndPos.z);
					WRITE_SHORT( m_iGlow );		// model
					WRITE_BYTE( 60 );				// life * 10
					WRITE_BYTE( 10 );				// size * 10
					WRITE_BYTE( flDamage );			// brightness
				MESSAGE_END();
				nTotal += 13;

				// limit it to one hole punch
				if (fHasPunched)
					break;
				fHasPunched = 1;

				// try punching through wall if secondary attack (primary is incapable of breaking through)
				if ( !m_fPrimaryFire )
				{
					UTIL_TraceLine( tr.vecEndPos + vecDir * 8, vecDest, dont_ignore_monsters, pentIgnore, &beam_tr);
					if (!beam_tr.fAllSolid)
					{
						// trace backwards to find exit point
						UTIL_TraceLine( beam_tr.vecEndPos, tr.vecEndPos, dont_ignore_monsters, pentIgnore, &beam_tr);

						float n = (beam_tr.vecEndPos - tr.vecEndPos).Length( );

						if (n < flDamage)
						{
							if (n == 0) n = 1;
							flDamage -= n;

							// ALERT( at_console, "punch %f\n", n );

							// absorption balls
							MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, tr.vecEndPos );
								WRITE_BYTE( TE_SPRITETRAIL );// TE_RAILTRAIL);
								WRITE_COORD( tr.vecEndPos.x );
								WRITE_COORD( tr.vecEndPos.y );
								WRITE_COORD( tr.vecEndPos.z );
								WRITE_COORD( tr.vecEndPos.x - vecDir.x );
								WRITE_COORD( tr.vecEndPos.y - vecDir.y );
								WRITE_COORD( tr.vecEndPos.z - vecDir.z );
								WRITE_SHORT( m_iBalls );		// model
								WRITE_BYTE( 3 );				// count
								WRITE_BYTE( 10 );				// life * 10
								WRITE_BYTE( RANDOM_LONG( 1, 2 ) );				// size * 10
								WRITE_BYTE( 10 );				// amplitude * 0.1
								WRITE_BYTE( 1 );				// speed * 100
							MESSAGE_END();
							nTotal += 21;

							// exit blast damage
							m_pPlayer->RadiusDamage( beam_tr.vecEndPos + vecDir * 8, pev, m_pPlayer->pev, flDamage, CLASS_NONE, DMG_BLAST );
							CSoundEnt::InsertSound ( bits_SOUND_COMBAT, pev->origin, NORMAL_EXPLOSION_VOLUME, 3.0 );

							DecalGunshot( &beam_tr, BULLET_MONSTER_12MM );
							nTotal += 19;

							// exit wall glow
							MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, beam_tr.vecEndPos );
								WRITE_BYTE( TE_GLOWSPRITE );
								WRITE_COORD( beam_tr.vecEndPos.x);	// pos
								WRITE_COORD( beam_tr.vecEndPos.y);
								WRITE_COORD( beam_tr.vecEndPos.z);
								WRITE_SHORT( m_iGlow );		// model
								WRITE_BYTE( 60 );				// life * 10
								WRITE_BYTE( 10 );				// size * 10
								WRITE_BYTE( flDamage );			// brightness
							MESSAGE_END();
							nTotal += 13;

							// balls
							MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, beam_tr.vecEndPos );
								WRITE_BYTE( TE_SPRITETRAIL );// TE_RAILTRAIL);
								WRITE_COORD( beam_tr.vecEndPos.x );
								WRITE_COORD( beam_tr.vecEndPos.y );
								WRITE_COORD( beam_tr.vecEndPos.z );
								WRITE_COORD( beam_tr.vecEndPos.x + vecDir.x );
								WRITE_COORD( beam_tr.vecEndPos.y + vecDir.y );
								WRITE_COORD( beam_tr.vecEndPos.z + vecDir.z );
								WRITE_SHORT( m_iBalls );		// model
								WRITE_BYTE( flDamage * 0.3 );				// count
								WRITE_BYTE( 10 );				// life * 10
								WRITE_BYTE( RANDOM_LONG( 1, 2 ) );				// size * 10
								WRITE_BYTE( 20 );				// amplitude * 0.1
								WRITE_BYTE( 40 );				// speed * 100
							MESSAGE_END();
							nTotal += 21;

							vecSrc = beam_tr.vecEndPos + vecDir;
						}
					}
					else
					{
						 //ALERT( at_console, "blocked %f\n", n );
						flDamage = 0;
					}
				}
				else
				{
					//ALERT( at_console, "blocked solid\n" );
					
					if ( m_fPrimaryFire )
					{
						// slug doesn't punch through ever with primary 
						// fire, so leave a little glowy bit and make some balls
						MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, tr.vecEndPos );
							WRITE_BYTE( TE_GLOWSPRITE );
							WRITE_COORD( tr.vecEndPos.x);	// pos
							WRITE_COORD( tr.vecEndPos.y);
							WRITE_COORD( tr.vecEndPos.z);
							WRITE_SHORT( m_iGlow );		// model
							WRITE_BYTE( 20 );				// life * 10
							WRITE_BYTE( 3 );				// size * 10
							WRITE_BYTE( 200 );			// brightness
						MESSAGE_END();


						MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, tr.vecEndPos );
							WRITE_BYTE( TE_SPRITETRAIL );// TE_RAILTRAIL);
							WRITE_COORD( tr.vecEndPos.x );
							WRITE_COORD( tr.vecEndPos.y );
							WRITE_COORD( tr.vecEndPos.z );
							WRITE_COORD( tr.vecEndPos.x + tr.vecPlaneNormal.x );
							WRITE_COORD( tr.vecEndPos.y + tr.vecPlaneNormal.y );
							WRITE_COORD( tr.vecEndPos.z + tr.vecPlaneNormal.z );
							WRITE_SHORT( m_iBalls );		// model
							WRITE_BYTE( 8 );				// count
							WRITE_BYTE( 6 );				// life * 10
							WRITE_BYTE( RANDOM_LONG( 1, 2 ) );	// size * 10
							WRITE_BYTE( 10 );				// amplitude * 0.1
							WRITE_BYTE( 20 );				// speed * 100
						MESSAGE_END();
					}

					flDamage = 0;
				}

			}
		}
		else
		{
			vecSrc = tr.vecEndPos + vecDir;
			pentIgnore = ENT( pEntity->pev );
		}
	}
	// ALERT( at_console, "%d bytes\n", nTotal );
}




void CTaser::WeaponIdle( void )
{
	ResetEmptySound( );

	// play aftershock static discharge
	if (m_flPlayAftershock && m_flPlayAftershock < gpGlobals->time)
	{
		switch (RANDOM_LONG(0,3))
		{
		case 0:	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/electro4.wav", RANDOM_FLOAT(0.7, 0.8), ATTN_NORM); break;
		case 1:	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/electro5.wav", RANDOM_FLOAT(0.7, 0.8), ATTN_NORM); break;
		case 2:	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/electro6.wav", RANDOM_FLOAT(0.7, 0.8), ATTN_NORM); break;
		case 3:	break; // no sound
		}
		m_flPlayAftershock = 0.0;
	}

	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	if (m_fInAttack != 0)
	{
		StartFire();
		m_fInAttack = 0;
		m_flTimeWeaponIdle = gpGlobals->time + 2.0;
	}
	else
	{
		int iAnim;
		float flRand = RANDOM_FLOAT(0, 1);
		if (flRand <= 0.5)
		{
			iAnim = GAUSS_IDLE;
			m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
		}
		else if (flRand <= 0.75)
		{
			iAnim = GAUSS_IDLE2;
			m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
		}
		else
		{
			iAnim = GAUSS_FIDGET;
			m_flTimeWeaponIdle = gpGlobals->time + 3;
		}

		return;
		SendWeaponAnim( iAnim );
		
	}
}



#endif