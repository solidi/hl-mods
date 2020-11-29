/***************************************************

Grappling Hook (Grapple.cpp)

Adds a grappling hook to the player.

No Models / Custom Sounds are used in this code. 

This code can be used freely in any mod, 

but give credit to where it came from.

Phantasiere (nrich@iinet.net.au)

***************************************************/

#include "extdll.h" 

#include "decals.h" 

#include "util.h" 

#include "cbase.h" 

#include "monsters.h" 

#include "weapons.h" 

#include "nodes.h" 

#include "player.h" 

#include "soundent.h" 

#include "shake.h" 

#include "gamerules.h"

#define WEAPON_GRAPPLE 23

 


class CGrappleHook : public CBaseEntity

{ 

public: 

void Spawn( ); 

void Precache( ); 

void Move( ); 

void EXPORT Hit( CBaseEntity* ); 

void Killed(entvars_t *pev, int gib); //Removes grapple

static CGrappleHook* Create( Vector, Vector, CBasePlayer*);

int m_Chain; 

int m_iIsMoving; 

int m_iTrail_Length;

float m_flRemoveTime;

CBasePlayer *myowner;

};

LINK_ENTITY_TO_CLASS( proj_hook, CGrappleHook );


void CGrappleHook :: Spawn( ) 

{ 

Precache( ); 

SET_MODEL( ENT(pev), "models/shell.mdl" );

pev->movetype = MOVETYPE_FLY; 

pev->solid = SOLID_BBOX; 

pev->rendermode = kRenderNormal;

pev->renderamt = 0;

UTIL_SetSize( pev, Vector(0,0,0), Vector(0,0,0) ); 

UTIL_SetOrigin( pev, pev->origin ); 

pev->classname = MAKE_STRING( "proj_hook" );

SetThink( Move ); 

SetTouch( Hit );

UTIL_MakeVectors(pev->angles);

pev->velocity = gpGlobals->v_forward * 1500; 

pev->gravity = 0; 

pev->nextthink = gpGlobals->time + 0.13; 

pev->dmg = 0;

m_flRemoveTime = gpGlobals->time + 5.0; //Set max life of Grapple to 5 seconds 

}

void CGrappleHook :: Precache( ) 

{ 

m_Chain = PRECACHE_MODEL( "sprites/smoke.spr" ); 

PRECACHE_MODEL( "models/shell.mdl" ); 

}

void CGrappleHook :: Hit( CBaseEntity* Target ) 

{ 

TraceResult TResult; 

Vector StartPosition;

if(Target->pev->takedamage) //Hit something that can be damaged (ie another player) 

{

Target->TakeDamage(pev, myowner->pev, 5.0, 0); //Do a little damage

Killed(Target->pev, 0); //Remove the grapple 

return;

}

pev->velocity = pev->velocity.Normalize( );

myowner->m_afPhysicsFlags |= PFLAG_ON_GRAPPLE; //Set physics flag to "on grapple"

myowner->pev->movetype = MOVETYPE_FLY; //Remove gravity effect on player

}

void CGrappleHook :: Killed(entvars_t *pev, int gib)

{ 

myowner->pev->movetype = MOVETYPE_WALK; //Re-apply gravity

myowner->m_afPhysicsFlags &= ~PFLAG_ON_GRAPPLE; //Remove "on grapple" flag

myowner->m_iGrappleExists = 0;

SUB_Remove( ); 

}

CGrappleHook* CGrappleHook :: Create( Vector Pos, Vector Aim, CBasePlayer* Owner ) 

{ 

CGrappleHook* Hook = GetClassPtr( (CGrappleHook*)NULL ); 

UTIL_SetOrigin( Hook->pev, Pos ); 

Hook->pev->angles = Aim; 

Hook->Spawn( ); 

Hook->SetTouch( CGrappleHook :: Hit ); 

Hook->pev->owner = Owner->edict( );

Hook->myowner = Owner;

return Hook; 

}

void CGrappleHook :: Move( ) 

{ 

if( !myowner->IsAlive( ) ) //if owner is dead is

{

Killed(pev, 0); //Remove grapple

return;

}

if(m_flRemoveTime < gpGlobals->time) //if grapple has outlived it's lifespan

{

Killed(pev, 0); //Remove grapple

return;

}


if(!(myowner->pev->button & (IN_ATTACK|IN_ATTACK2) )) //If owner is not pushing attack buttons

{

Killed(pev, 0); //Remove grapple

return;

}


MESSAGE_BEGIN( MSG_BROADCAST, SVC_TEMPENTITY ); //Draw 'chain'

WRITE_BYTE( TE_BEAMENTPOINT ); 

WRITE_SHORT( myowner->entindex() );

WRITE_COORD( pev->origin.x );

WRITE_COORD( pev->origin.y );

WRITE_COORD( pev->origin.z );

WRITE_SHORT( m_Chain ); 

WRITE_BYTE( 1 ); //start frame

WRITE_BYTE( 0 ); 

WRITE_BYTE( 1 ); 

WRITE_BYTE( 2 ); //width 

WRITE_BYTE( 2); 

WRITE_BYTE( 255 ); //r

WRITE_BYTE( 255 ); //g

WRITE_BYTE( 255 ); //b

WRITE_BYTE( 255);

WRITE_BYTE( 10);

MESSAGE_END( );

pev->nextthink = gpGlobals->time + 0.13;

}

 


class CGrapple : public CBasePlayerWeapon 

{ 

public: 

void Spawn( ); 

void Precache( ); 

int iItemSlot( ); 

int GetItemInfo( ItemInfo* ); 

BOOL Deploy( ); 

void PrimaryAttack( ); 

void WeaponIdle( );

void SecondaryAttack( );

}; 

LINK_ENTITY_TO_CLASS( weapon_grapple, CGrapple );



void CGrapple :: Spawn( ) 

{ 

pev->classname = MAKE_STRING( "weapon_grapple" ); 

Precache( ); 

m_iId = WEAPON_GRAPPLE; 

m_iDefaultAmmo = 1; 

FallInit( ); 

}

void CGrapple :: Precache( ) 

{ 

//TODO: Precache models/sounds here

}

int CGrapple :: iItemSlot( ) 

{ 

return 0; 

}

int CGrapple :: GetItemInfo( ItemInfo* Info ) 

{ 

Info->pszName = STRING( pev->classname ); 

Info->pszAmmo1 = NULL; 

Info->iMaxAmmo1 = -1; 

Info->pszAmmo2 = NULL; 

Info->iMaxAmmo2 = -1; 

Info->iMaxClip = 1; 

Info->iSlot = 0; 

Info->iPosition = 1; 

Info->iFlags = 0; 

Info->iId = WEAPON_GRAPPLE; 

Info->iWeight = 27;

return 1; 

}

BOOL CGrapple :: Deploy( ) 

{ 

return DefaultDeploy( NULL, 

NULL, 

NULL, 

"onehanded" ); 

}

void CGrapple :: PrimaryAttack( ) 

{ 

if( m_pPlayer->m_iGrappleExists ) //if player already has a grapple

{

return;

}

if(m_flNextPrimaryAttack > gpGlobals->time)

{

return;

}


m_pPlayer->m_iGrappleExists = 1;

m_pPlayer->SetAnimation( PLAYER_ATTACK1 ); 

UTIL_MakeVectors( m_pPlayer->pev->v_angle + m_pPlayer->pev->punchangle ); 

Vector AimingDir = gpGlobals->v_forward; 

Vector GunPosition = m_pPlayer->GetGunPosition( ); 

GunPosition = GunPosition + gpGlobals->v_up * -4 + gpGlobals->v_right * 3 + gpGlobals->v_forward * 16;

m_pPlayer->m_MyGrapple = CGrappleHook :: Create( GunPosition, 

m_pPlayer->pev->v_angle, 

m_pPlayer 

);


//TODO: add grapple deploy sound here

m_flNextPrimaryAttack = gpGlobals->time + 0.1; 

m_flTimeWeaponIdle = gpGlobals->time + 0.6;

}

void CGrapple :: SecondaryAttack( ) 

{ 

//TODO: add in a secondary fire 

}

 

void CGrapple :: WeaponIdle( ) 

{

//TODO: add in idle animations

}