
#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "monsters.h"
#include "weapons.h"
#include "nodes.h"
#include "player.h"
#include "gamerules.h"
#include "shake.h"

enum satchel_e {
	SATCHEL_IDLE1 = 0,
	SATCHEL_FIDGET1,
	SATCHEL_DRAW,
	SATCHEL_DROP
};

enum satchel_radio_e {
	SATCHEL_RADIO_IDLE1 = 0,
	SATCHEL_RADIO_FIDGET1,
	SATCHEL_RADIO_DRAW,
	SATCHEL_RADIO_FIRE,
	SATCHEL_RADIO_HOLSTER
};



class CMineCharge : public CGrenade
{
	void Spawn( void );
	void Precache( void );

	void EXPORT MineThink( void );

	int m_iLight;

public:
	void Deactivate( void );
};
LINK_ENTITY_TO_CLASS( monster_c4, CMineCharge );

//=========================================================
// Deactivate - do whatever it is we do to an orphaned 
// satchel when we don't want it in the world anymore.
//=========================================================
void CMineCharge::Deactivate( void )
{
	pev->solid = SOLID_NOT;
	UTIL_Remove( this );
}

void CMineCharge :: Precache( void )
{
	PRECACHE_SOUND("weapons/weap_c4place1.wav");
	PRECACHE_SOUND("weapons/weap_c4beep1.wav");

	m_iLight = PRECACHE_MODEL( "sprites/redflare2.spr" );
}

void CMineCharge :: Spawn( void )
{
	Precache( );
	// motor
	pev->movetype = MOVETYPE_FLY;
	pev->solid = SOLID_TRIGGER;

	SET_MODEL(ENT(pev), "models/w_satchel.mdl");
	UTIL_SetSize( pev, Vector( -8, -8, -8), Vector(8, 8, 8) );
	UTIL_SetOrigin( pev, pev->origin + gpGlobals->v_forward * 6 + gpGlobals->v_up * -6 );

//	SetTouch( MineTouch );
	SetUse( DetonateUse );
	SetThink( MineThink );

	EMIT_SOUND(ENT(pev), CHAN_VOICE, "weapons/weap_c4place1.wav", 1, ATTN_NORM);
	
	pev->nextthink = gpGlobals->time + .8;
	
	pev->dmg = gSkillData.plrDmgC4Mine;
}

void CMineCharge :: MineThink( void )
{
	StudioFrameAdvance( );
	pev->nextthink = gpGlobals->time + 0.4;
	pev->solid = SOLID_BBOX;

	EMIT_SOUND(ENT(pev), CHAN_VOICE, "weapons/weap_c4beep1.wav", .30, ATTN_NORM);

	Vector mVecDir;

	mVecDir = pev->origin + gpGlobals->v_forward * -2 + gpGlobals->v_up * 20;
					
	MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, mVecDir);
	WRITE_BYTE( TE_GLOWSPRITE );
	WRITE_COORD( mVecDir.x);	// pos
	WRITE_COORD( mVecDir.y);
	WRITE_COORD( mVecDir.z);
	WRITE_SHORT( m_iLight );		// model
	WRITE_BYTE( 1 );				// life * 10
	WRITE_BYTE( 2 );				// size * 10
	WRITE_BYTE( 200 );			// brightness
	MESSAGE_END();

	if (!IsInWorld())
	{
		UTIL_Remove( this );
		return;
	}
}


class CMineC4 : public CBasePlayerWeapon
{
public:
	int		Save( CSave &save );
	int		Restore( CRestore &restore );
	static	TYPEDESCRIPTION m_SaveData[];

	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 5; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );
	void PrimaryAttack( void );
	void SecondaryAttack( void );
	int AddDuplicate( CBasePlayerItem *pOriginal );
	BOOL CanDeploy( void );
	BOOL Deploy( void );
	BOOL IsUseable( void );
	
	void Holster( int skiplocal = 0 );
	void WeaponIdle( void );
	void Throw( void );
	int m_chargeReady;
};
LINK_ENTITY_TO_CLASS( weapon_c4, CMineC4 );

TYPEDESCRIPTION	CMineC4::m_SaveData[] = 
{
	DEFINE_FIELD( CMineC4, m_chargeReady, FIELD_INTEGER ),
};
IMPLEMENT_SAVERESTORE( CMineC4, CBasePlayerWeapon );

//=========================================================
// CALLED THROUGH the newly-touched weapon's instance. The existing player weapon is pOriginal
//=========================================================
int CMineC4::AddDuplicate( CBasePlayerItem *pOriginal )
{
	CMineC4 *pMine;

	if ( g_pGameRules->IsMultiplayer() )
	{
		pMine = (CMineC4 *)pOriginal;

		if ( pMine->m_chargeReady != 0 )
		{
			// player has some satchels deployed. Refuse to add more.
			return FALSE;
		}
	}

	return CBasePlayerWeapon::AddDuplicate ( pOriginal );
}

//=========================================================
//=========================================================
int CMineC4::AddToPlayer( CBasePlayer *pPlayer )
{
	int bResult = CBasePlayerItem::AddToPlayer( pPlayer );

	pPlayer->pev->weapons |= (1<<m_iId);
	m_chargeReady = 0;// this satchel charge weapon now forgets that any satchels are deployed by it.

	if (bResult)
	{
		return AddWeapon( );
	}
	return FALSE;
}

void CMineC4::Spawn( )
{
	Precache( );
	m_iId = WEAPON_C4;
	SET_MODEL(ENT(pev), "models/w_satchel.mdl");

	m_iDefaultAmmo = C4_DEFAULT_GIVE;
		
	FallInit();// get ready to fall down.
}


void CMineC4::Precache( void )
{
	PRECACHE_MODEL("models/v_satchel.mdl");
	PRECACHE_MODEL("models/v_satchel_radio.mdl");
	PRECACHE_MODEL("models/w_satchel.mdl");
	PRECACHE_MODEL("models/p_satchel.mdl");
	PRECACHE_MODEL("models/p_satchel_radio.mdl");

	UTIL_PrecacheOther( "monster_c4" );
}


int CMineC4::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "Mine Charge";
	p->iMaxAmmo1 = C4_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = WEAPON_NOCLIP;
	p->iSlot = 4;
	p->iPosition = 0;
	p->iFlags = ITEM_FLAG_SELECTONEMPTY | ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
	p->iId = m_iId = WEAPON_C4;
	p->iWeight = C4_WEIGHT;

	return 1;
}

//=========================================================
//=========================================================
BOOL CMineC4::IsUseable( void )
{
	if ( m_pPlayer->m_rgAmmo[ PrimaryAmmoIndex() ] > 0 ) 
	{
		// player is carrying some satchels
		return TRUE;
	}

	if (m_chargeReady != 0)
	{
		// player isn't carrying any satchels, but has some out
		return TRUE;
	}

	return FALSE;
}

BOOL CMineC4::CanDeploy( void )
{
	if ( m_pPlayer->m_rgAmmo[ PrimaryAmmoIndex() ] > 0 ) 
	{
		// player is carrying some satchels
		return TRUE;
	}

	if (m_chargeReady != 0 )
	{
		// player isn't carrying any satchels, but has some out
		return TRUE;
	}

	return FALSE;
}

BOOL CMineC4::Deploy( )
{
	if (m_chargeReady)
	{
		m_pPlayer->pev->viewmodel = MAKE_STRING("models/v_satchel_radio.mdl");
		m_pPlayer->pev->weaponmodel = MAKE_STRING("models/p_satchel_radio.mdl");
		SendWeaponAnim( SATCHEL_RADIO_DRAW );
		// use hivehand animations
		strcpy( m_pPlayer->m_szAnimExtention, "hive" );
	}
	else
	{
		m_pPlayer->pev->viewmodel = MAKE_STRING("models/v_satchel.mdl");
		m_pPlayer->pev->weaponmodel = MAKE_STRING("models/p_satchel.mdl");
		SendWeaponAnim( SATCHEL_DRAW );
		// use tripmine animations
		strcpy( m_pPlayer->m_szAnimExtention, "trip" );
	}

	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 1.0;
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
	return TRUE;
}


void CMineC4::Holster( int skiplocal /* = 0 */ )
{
	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.5;
	
	if (m_chargeReady)
	{
		SendWeaponAnim( SATCHEL_RADIO_HOLSTER );
	}
	else
	{
		SendWeaponAnim( SATCHEL_DROP );
	}
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "common/null.wav", 1.0, ATTN_NORM);

	if ( !m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] && !m_chargeReady )
	{
		m_pPlayer->pev->weapons &= ~(1<<WEAPON_C4);
		SetThink( DestroyItem );
		pev->nextthink = gpGlobals->time + 0.1;
	}
}



void CMineC4::PrimaryAttack()
{
	switch (m_chargeReady)
	{
	case 0:
		{
		Throw( );
		}
		break;
	case 1:
		{
		SendWeaponAnim( SATCHEL_RADIO_FIRE );

		edict_t *pPlayer = m_pPlayer->edict( );

		CBaseEntity *pSatchel = NULL;

		while ((pSatchel = UTIL_FindEntityInSphere( pSatchel, m_pPlayer->pev->origin, 4096 )) != NULL)
		{
			if (FClassnameIs( pSatchel->pev, "monster_c4"))
			{
				if (pSatchel->pev->owner == pPlayer)
				{
					pSatchel->Use( m_pPlayer, m_pPlayer, USE_ON, 0 );
					UTIL_ScreenShake( pSatchel->pev->origin, 10.0, 150.0, 0.75, 250.0 );
					m_chargeReady = 2;
				}
			}
		}

		if (m_chargeReady == 1)
		{
			// play buzzer sound
		}
		else
		{
			// play click sound
		}

		m_chargeReady = 2;
		
		if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
			m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + .25;
		else
			m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + .5;

		m_flTimeWeaponIdle = gpGlobals->time + 0.5;
		break;
		}

	case 2:
		// we're reloading, don't allow fire
		{
		}
		break;
	}
}


void CMineC4::SecondaryAttack( void )
{
	if (m_chargeReady != 2)
	{
		Throw( );
	}
}


void CMineC4::Throw( void )
{
	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
	{
		UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle );
		Vector vecSrc	 = m_pPlayer->GetGunPosition( );
		Vector vecAiming = gpGlobals->v_forward;

		TraceResult tr;

		UTIL_TraceLine( vecSrc, vecSrc + vecAiming * 128, dont_ignore_monsters, ENT( m_pPlayer->pev ), &tr );

		if (tr.flFraction < 1.0)
		{
			CBaseEntity *pEntity = CBaseEntity::Instance( tr.pHit );
			if (pEntity && !(pEntity->pev->flags & FL_CONVEYOR) && !pEntity->IsPlayer())
			{
				Vector angles = UTIL_VecToAngles( tr.vecPlaneNormal );

				Vector vecThrow = gpGlobals->v_forward * 274 + m_pPlayer->pev->velocity;

				CBaseEntity *pEnt = CBaseEntity::Create( "monster_c4", tr.vecEndPos + tr.vecPlaneNormal * 8, angles, m_pPlayer->edict() );
				
				if ( m_pPlayer->m_fHasRune == RUNE_STRENGTH )
				{
					pEnt->pev->renderfx = kRenderFxGlowShell;
					pEnt->pev->renderamt = 2;
					pEnt->pev->rendercolor.x = 200;
					pEnt->pev->rendercolor.y = 200;
					pEnt->pev->rendercolor.z = 0;
				}

				m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType]--;

				m_pPlayer->pev->viewmodel = MAKE_STRING("models/v_satchel_radio.mdl");
				m_pPlayer->pev->weaponmodel = MAKE_STRING("models/p_satchel_radio.mdl");
				SendWeaponAnim( SATCHEL_RADIO_DRAW );

				// player "shoot" animation
				m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

				m_chargeReady = 1;
			}
		}
	}

	if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
		m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + .5;
	else
		m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + 1.0;

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}


void CMineC4::WeaponIdle( void )
{
	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	switch( m_chargeReady )
	{
	case 0:
		SendWeaponAnim( SATCHEL_FIDGET1 );
		// use tripmine animations
		strcpy( m_pPlayer->m_szAnimExtention, "trip" );
		break;
	case 1:
		SendWeaponAnim( SATCHEL_RADIO_FIDGET1 );
		// use hivehand animations
		strcpy( m_pPlayer->m_szAnimExtention, "hive" );
		break;
	case 2:
		if ( !m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] )
		{
			m_chargeReady = 0;
			RetireWeapon();
			return;
		}

		m_pPlayer->pev->viewmodel = MAKE_STRING("models/v_satchel.mdl");
		m_pPlayer->pev->weaponmodel = MAKE_STRING("models/p_satchel.mdl");
		SendWeaponAnim( SATCHEL_DRAW );

		// use tripmine animations
		strcpy( m_pPlayer->m_szAnimExtention, "trip" );


		if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
			m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + .25;
		else
			m_flNextPrimaryAttack = m_flNextSecondaryAttack = gpGlobals->time + .5;

		m_chargeReady = 0;
		break;
	}
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}

//=========================================================
// DeactivateMines - removes all satchels owned by
// the provided player. Should only be used upon death.
//
// Made this global on purpose.
//=========================================================
void DeactivateMines( CBasePlayer *pOwner )
{
	edict_t *pFind; 

	pFind = FIND_ENTITY_BY_CLASSNAME( NULL, "monster_c4" );

	while ( !FNullEnt( pFind ) )
	{
		CBaseEntity *pEnt = CBaseEntity::Instance( pFind );
		CMineCharge *pSatchel = (CMineCharge *)pEnt;

		if ( pSatchel )
		{
			if ( pSatchel->pev->owner == pOwner->edict() )
			{
				pSatchel->Deactivate();
			}
		}

		pFind = FIND_ENTITY_BY_CLASSNAME( pFind, "monster_c4" );
	}
}
