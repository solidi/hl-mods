
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

class CBlasterBeam : public CBaseEntity
{
	void Spawn( void );
	void Precache( void );
	int  Classify ( void );
	void EXPORT BubbleThink( void );
	void EXPORT PulseTouch( CBaseEntity *pOther );

    CBeam *m_pBeam;
	int m_iGlow;
	int m_iTrail;
	int m_iBalls;
	Vector beamendpos;

public:
	static CBlasterBeam *Fire( void );
};
LINK_ENTITY_TO_CLASS( blaster_beam, CBlasterBeam );

CBlasterBeam *CBlasterBeam::Fire( void )
{
	CBlasterBeam *pPulse = GetClassPtr( (CBlasterBeam *)NULL );
	pPulse->pev->classname = MAKE_STRING("blaster_beam");
	pPulse->Spawn();
	return pPulse;
}

void CBlasterBeam::Spawn( )
{
	Precache( );
	pev->movetype = MOVETYPE_FLY;
	pev->solid    = SOLID_BBOX;
	pev->gravity = 0.3;

	SET_MODEL(ENT(pev), "sprites/blueflare2.spr");
	pev->rendermode = kRenderGlow;
	pev->renderfx = kRenderFxNoDissipation;
	pev->renderamt = 400;
	UTIL_SetOrigin( pev, pev->origin );
	UTIL_SetSize( pev, Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) );

	SetTouch( PulseTouch );
	SetThink( BubbleThink );
	pev->nextthink = gpGlobals->time + 0.1;
}


void CBlasterBeam::Precache( )
{
	PRECACHE_MODEL ("sprites/blueflare2.spr");

	PRECACHE_SOUND("weapons/xbow_hitbod1.wav");
	PRECACHE_SOUND("weapons/xbow_hitbod2.wav");
	PRECACHE_SOUND("weapons/xbow_fly1.wav");

	PRECACHE_SOUND("fvox/beep.wav");

	m_iGlow = PRECACHE_MODEL( "sprites/blueflare1.spr" );
	m_iBalls = PRECACHE_MODEL( "sprites/blueflare1.spr" );
	m_iTrail = PRECACHE_MODEL( "sprites/streak.spr" );
}


int	CBlasterBeam :: Classify ( void )
{
	return	CLASS_NONE;
}

void CBlasterBeam::PulseTouch( CBaseEntity *pOther )
{
	SetTouch( NULL );
	SetThink( NULL );

	if (pOther->pev->takedamage)
	{
		TraceResult tr = UTIL_GetGlobalTrace( );
		entvars_t	*pevOwner;

		pevOwner = VARS( pev->owner );

		ClearMultiDamage( );

		if ( pOther->IsPlayer() )
		{
			pOther->TraceAttack(pevOwner, 20, pev->velocity.Normalize(), &tr, DMG_BLAST|DMG_ALWAYSGIB); 
		}
		else
		{
			pOther->TraceAttack(pevOwner, 20, pev->velocity.Normalize(), &tr, DMG_BULLET | DMG_NEVERGIB ); 
		}

		ApplyMultiDamage( pev, pevOwner );

		pev->velocity = Vector( 0, 0, 0 );

		//EMIT_SOUND(ENT(pev), CHAN_WEAPON, "weapons/hblaster_hit.wav", 1, ATTN_NORM); 
		
		Killed( pev, GIB_NEVER );
	}
	else
	{
		//EMIT_SOUND_DYN(ENT(pev), CHAN_WEAPON, "weapons/hblaster_hit.wav", RANDOM_FLOAT(0.95, 1.0), ATTN_NORM, 0, 98 + RANDOM_LONG(0,7));

		SetThink( SUB_Remove );
		pev->nextthink = gpGlobals->time;

		if ( FClassnameIs( pOther->pev, "worldspawn" ) )	
		{
			
			MESSAGE_BEGIN( MSG_PAS, SVC_TEMPENTITY, pev->origin );
			WRITE_BYTE( TE_GLOWSPRITE );
			WRITE_COORD( pev->origin.x );					// pos
			WRITE_COORD( pev->origin.y );
			WRITE_COORD( pev->origin.z );
			WRITE_SHORT( m_iGlow );							// model
			WRITE_BYTE( 4 );								// life * 10
			WRITE_BYTE( RANDOM_LONG( 1, 4 ) );				// size * 10
			WRITE_BYTE( 150 );								// brightness
			MESSAGE_END();

			MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, pev->origin );
			WRITE_BYTE( TE_SPRITETRAIL );
			WRITE_COORD( pev->origin.x );
			WRITE_COORD( pev->origin.y );
			WRITE_COORD( pev->origin.z );
			WRITE_COORD( pev->origin.x );
			WRITE_COORD( pev->origin.y );
			WRITE_COORD( pev->origin.z );
			WRITE_SHORT( m_iBalls );				// model
			WRITE_BYTE( 4 );						// count
			WRITE_BYTE( .5 );						// life * 10
			WRITE_BYTE( RANDOM_LONG( 1, 3 ) );		// size * 10
			WRITE_BYTE( 10 );						// amplitude * 0.1
			WRITE_BYTE( 20 );						// speed * 100
			MESSAGE_END();	

		}

		Killed(pev,GIB_NEVER);			
	}

}

void CBlasterBeam::BubbleThink( void )
{
	pev->nextthink = gpGlobals->time + 0.1;

	if (pev->waterlevel == 0)
	{
		MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY );
		WRITE_BYTE( TE_BEAMFOLLOW );
		WRITE_SHORT(entindex());	// entity
		WRITE_SHORT( m_iTrail );	// model
		WRITE_BYTE( 3 );            // life
		WRITE_BYTE( 1 );			// width
		WRITE_BYTE( 0 );			// r, g, b
		WRITE_BYTE( 115 );			// r, g, b
		WRITE_BYTE( 230 );			// r, g, b
		WRITE_BYTE( 200 );			// brightness
		MESSAGE_END();
		return;
	}

	UTIL_BubbleTrail( pev->origin - pev->velocity * 0.1, pev->origin, 1 );
}

enum pulsegun_e
{
	SMG_IDLE1 = 0,
	SMG_IDLE2,
	SMG_SWITCH,
	SMG_SHOOT,
	SMG_RELOAD,
	SMG_DRAW,
	SMG_HOLSTER,
};

class CPulseGun : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 2; }
	int GetItemInfo(ItemInfo *p);
	int AddToPlayer( CBasePlayer *pPlayer );

	void PrimaryAttack( void );
	void SecondaryAttack( void );
	BOOL Deploy( void );
	void Holster( int skiplocal /* = 0 */ );
	void Reload( void );
	void WeaponIdle( void );
	void ReloadClip( void );
	float m_flNextAnimTime;

	int Shell;
	CBeam *m_pBeam;
};
LINK_ENTITY_TO_CLASS( weapon_pulsegun, CPulseGun );

//=========================================================
//=========================================================

void CPulseGun::Spawn( )
{
	Precache( );
	SET_MODEL(ENT(pev), "models/w_smg.mdl");
	m_iId = WEAPON_PULSEGUN;

	m_iDefaultAmmo = PULSEGUN_DEFAULT_GIVE;

	FallInit();// get ready to fall down.
}


void CPulseGun::Precache( void )
{
	PRECACHE_MODEL("models/v_pulsegun.mdl");
	PRECACHE_MODEL("models/w_smg.mdl");
	PRECACHE_MODEL("models/p_smg.mdl");

	Shell = PRECACHE_MODEL("models/w_smgclip.mdl");

	PRECACHE_SOUND ("weapons/weap_pulsegun1.wav");
	PRECACHE_SOUND ("weapons/357_cock1.wav");
	PRECACHE_SOUND ("weapons/weap_smgreload1.wav");
	PRECACHE_SOUND ("weapons/weap_smgreload2.wav");

	UTIL_PrecacheOther( "blaster_beam" );
}

int CPulseGun::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "9mm";
	p->iMaxAmmo1 = PULSEGUN_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = PULSEGUN_MAX_CLIP;
	p->iSlot = 1;
	p->iPosition = 0;
	p->iFlags = 0;
	p->iId = m_iId = WEAPON_PULSEGUN;
	p->iWeight = PULSEGUN_WEIGHT;

	return 1;
}

int CPulseGun::AddToPlayer( CBasePlayer *pPlayer )
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

BOOL CPulseGun::Deploy( )
{
	return DefaultDeploy( "models/v_pulsegun.mdl", "models/p_smg.mdl", SMG_DRAW, "onehanded" );
}

void CPulseGun::Holster( int skiplocal /* = 0 */)
{
	m_fInReload = FALSE;
	m_flDropClipTime = 0;

	m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.5;

	SendWeaponAnim( SMG_HOLSTER );
}


void CPulseGun::PrimaryAttack()
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

	m_pPlayer->m_iWeaponVolume = NORMAL_GUN_VOLUME;
	m_pPlayer->m_iWeaponFlash = NORMAL_GUN_FLASH;

	m_iClip--;

	// player "shoot" animation
	SendWeaponAnim( SMG_SWITCH );
	m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

	Vector vecSrc	 = m_pPlayer->GetGunPosition( );
	Vector vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_5DEGREES );

	CBlasterBeam  *m_pBeam = CBlasterBeam::Fire();
	m_pBeam->pev->origin = vecSrc + gpGlobals->v_forward * 32 + gpGlobals->v_right * RANDOM_FLOAT(-10,10)  + gpGlobals->v_up * RANDOM_FLOAT(-10, 10);
	m_pBeam->pev->owner = m_pPlayer->edict();
	m_pBeam->pev->velocity = gpGlobals->v_forward * 2000;
	m_pBeam->pev->angles = UTIL_VecToAngles( m_pBeam->pev->velocity ); 

	EMIT_SOUND_DYN(ENT(m_pPlayer->pev), CHAN_WEAPON, "weapons/weap_pulsegun1.wav", RANDOM_FLOAT(0.92, 1.0), ATTN_NORM, 0, 98 + RANDOM_LONG(0,3));

	if ( m_pPlayer->m_fHasRune == RUNE_HASTE )
		m_flNextPrimaryAttack = gpGlobals->time + 0.09;
	else
		m_flNextPrimaryAttack = gpGlobals->time + 0.12;

	m_flNextSecondaryAttack = gpGlobals->time + .1;

	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}

void CPulseGun::SecondaryAttack( void )
{

}

void CPulseGun::Reload( void )
{
	int iResult;
	iResult = DefaultReload( PULSEGUN_MAX_CLIP, SMG_RELOAD, 1.4 );

	if ( iResult )
	{
		m_flDropClipTime = gpGlobals->time + 0.5;
	}
}

void CPulseGun::ReloadClip( void )
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

void CPulseGun::WeaponIdle( void )
{
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

















