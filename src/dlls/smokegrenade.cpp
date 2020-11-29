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

#define SMOKETIME 8 // 8 seconds for smoke

#define SMOKE_SLOTNUMBER 0 // The slot it is in ( 0 is crowbar area, 1 is pistol area, etc… )
#define SMOKE_POSITION 3 // Position Is what column the weapon is in, for example - in slot 1, the pistol is position 1, the magnum is 2, and so forth. Try not to put the same position number as another weapon, or it might cause problems.

enum handgrenade_e {
HANDGRENADE_IDLE = 0,
HANDGRENADE_FIDGET,
HANDGRENADE_PINPULL,
HANDGRENADE_THROW1, // toss
HANDGRENADE_THROW2, // medium
HANDGRENADE_THROW3, // hard
HANDGRENADE_HOLSTER,
HANDGRENADE_DRAW
};

 

class CSmokeGrenade : public CBasePlayerWeapon
{
public:
void Spawn( void );
void Precache( void );
int iItemSlot( void ) { return 5; }
int GetItemInfo(ItemInfo *p);

void PrimaryAttack( void );
BOOL Deploy( void );
BOOL CanHolster( void );
void Holster( void );
void WeaponIdle( void );
void SmokeThink( void );
float m_flStartThrow;
float m_flReleaseThrow;
};
LINK_ENTITY_TO_CLASS( weapon_smokegrenade, CSmokeGrenade );

 

void CSmokeGrenade::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
		return;
	}
	else
	{
Precache( );
m_iId = WEAPON_SMOKEGRENADE;
SET_MODEL(ENT(pev), "models/w_grenade.mdl");

pev->dmg = gSkillData.plrDmgHandGrenade;
m_iDefaultAmmo = 5;
FallInit();// get ready to fall down.
	}
}

 

 

void CSmokeGrenade::Precache( void )
{
PRECACHE_MODEL("models/w_grenade.mdl");
PRECACHE_MODEL("models/v_grenade.mdl");
PRECACHE_MODEL("models/p_grenade.mdl");
PRECACHE_SOUND ("weapons/xbow_fly1.wav");
PRECACHE_SOUND ("common/null.wav");
}

 

int CSmokeGrenade::GetItemInfo(ItemInfo *p)
{
p->pszName = STRING(pev->classname);
p->pszAmmo1 = "Smoke Grenade";
p->iMaxAmmo1 = 5;
p->pszAmmo2 = NULL;
p->iMaxAmmo2 = -1;
p->iMaxClip = WEAPON_NOCLIP;
p->iSlot = 4;
p->iPosition = 2;
p->iId = m_iId = WEAPON_SMOKEGRENADE;
p->iWeight = 20;
p->iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;

return 1;
}

 

 

BOOL CSmokeGrenade::Deploy( )
{
m_flReleaseThrow = -1;
return DefaultDeploy( "models/v_grenade.mdl", "models/p_grenade.mdl", HANDGRENADE_DRAW, "crowbar" );
}

 

BOOL CSmokeGrenade::CanHolster( void )
{
// can only holster hand grenades when not primed!
return ( m_flStartThrow == 0 );
}

 

void CSmokeGrenade::Holster( )
{
m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;
if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
{
SendWeaponAnim( HANDGRENADE_HOLSTER );
}
else
{
// no more grenades!
m_pPlayer->pev->weapons &= ~(1<<WEAPON_SMOKEGRENADE);
SetThink( DestroyItem );
pev->nextthink = gpGlobals->time + 0.1;
}

EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "common/null.wav", 1.0, ATTN_NORM);
}

 

 

 

void CSmokeGrenade::PrimaryAttack()
{
if (!m_flStartThrow && m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] > 0)
{
m_flStartThrow = gpGlobals->time;
m_flReleaseThrow = 0;

SendWeaponAnim( HANDGRENADE_PINPULL );
m_flTimeWeaponIdle = gpGlobals->time + 0.5;
}
}

 

 

void CSmokeGrenade::SmokeThink( void )
{
pev->velocity = pev->velocity * 0.4;
pev->sequence = RANDOM_LONG( 1, 1 );

if (pev->dmgtime < gpGlobals->time){
EMIT_SOUND(ENT(pev), CHAN_WEAPON, "common/null.wav", 1 , ATTN_NORM);
pev->velocity = Vector( 0, 0, 0 );
UTIL_Remove( this );
return;
} else {

EMIT_SOUND(ENT(pev), CHAN_WEAPON, "weapons/xbow_fly1.wav", .3 , ATTN_NORM);
}

 

// Make some smoke
MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, pev->origin );
WRITE_BYTE( TE_SMOKE );
WRITE_COORD( pev->origin.x );
WRITE_COORD( pev->origin.y );
WRITE_COORD( pev->origin.z );
WRITE_SHORT( g_sModelIndexSmoke );
WRITE_BYTE( (pev->dmg - 50) * 0.80 ); // scale * 10
WRITE_BYTE( 12 ); // framerate
MESSAGE_END();

 

m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
m_flReleaseThrow = -1;
pev->nextthink = gpGlobals->time + 0.3;
}

 

void CSmokeGrenade::WeaponIdle( void )
{
if (m_flReleaseThrow == 0)
m_flReleaseThrow = gpGlobals->time;

if (m_flTimeWeaponIdle > gpGlobals->time)
return;

if (m_flStartThrow)
{
Vector angThrow = m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle;

if (angThrow.x < 0)
angThrow.x = -10 + angThrow.x * ((90 - 10) / 90.0);
else
angThrow.x = -10 + angThrow.x * ((90 + 10) / 90.0);

float flVel = (90 - angThrow.x) * 4;
if (flVel > 500)
flVel = 500;

UTIL_MakeVectors( angThrow );

Vector vecSrc = m_pPlayer->pev->origin + m_pPlayer->pev->view_ofs + gpGlobals->v_forward * 16;

Vector vecThrow = gpGlobals->v_forward * flVel + m_pPlayer->pev->velocity;

 

// alway explode 3 seconds after the pin was pulled

CGrenade *pGrenade = GetClassPtr( (CGrenade *)NULL );
pGrenade->Spawn();
UTIL_SetOrigin( pGrenade->pev, vecSrc );
pGrenade->pev->velocity = vecThrow;
pGrenade->pev->angles = UTIL_VecToAngles(pGrenade->pev->velocity);
pGrenade->pev->owner = ENT(m_pPlayer->pev);
pGrenade->pev->dmgtime = gpGlobals->time + SMOKETIME;

pGrenade->SetThink( SmokeThink );
pGrenade->pev->nextthink = gpGlobals->time + 0.1;
SET_MODEL(ENT(pGrenade->pev), "models/w_grenade.mdl");

 

if (flVel < 500)
{
SendWeaponAnim( HANDGRENADE_THROW1 );
}
else if (flVel < 1000)
{
SendWeaponAnim( HANDGRENADE_THROW2 );
}
else
{
SendWeaponAnim( HANDGRENADE_THROW3 );
}

 

// player "shoot" animation
m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

m_flStartThrow = 0;
m_flNextPrimaryAttack = gpGlobals->time + 0.5;
m_flTimeWeaponIdle = gpGlobals->time + 0.5;

m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType]--;

if ( !m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] )
{
// just threw last grenade
// set attack times in the future, and weapon idle in the future so we can see the whole throw
// animation, weapon idle will automatically retire the weapon for us.
m_flTimeWeaponIdle = m_flNextSecondaryAttack = m_flNextPrimaryAttack = gpGlobals->time + 0.5;// ensure that the animation can finish playing
}
return;
}
else if (m_flReleaseThrow > 0)
{
// we've finished the throw, restart.
m_flStartThrow = 0;

if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
{
SendWeaponAnim( HANDGRENADE_DRAW );
}
else
{
RetireWeapon();
return;
}

return;
}

 

if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
{
int iAnim;
float flRand = RANDOM_FLOAT(0, 1);
if (flRand <= 0.75)
{
iAnim = HANDGRENADE_IDLE;
m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );// how long till we do this again.
}
else
{
iAnim = HANDGRENADE_FIDGET;
m_flTimeWeaponIdle = gpGlobals->time + 75.0 / 30.0;
}

SendWeaponAnim( iAnim );
}
}