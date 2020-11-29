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
#include "effects.h"
#include "gamerules.h"

enum kamakaze_e {
	SATCHEL_RADIO_IDLE1 = 0,
	SATCHEL_RADIO_FIDGET1,
	SATCHEL_RADIO_DRAW,
	SATCHEL_RADIO_FIRE,
	SATCHEL_RADIO_HOLSTER
};

class CKamikaze : public CBasePlayerWeapon
{
public:
	void Spawn( void );
	void Precache( void );
	int iItemSlot( void ) { return 5; }
	int GetItemInfo(ItemInfo *p);
	void PrimaryAttack( void );
	BOOL Deploy( void );
	void Holster( void );
	void WeaponIdle( void );
	int m_iSpriteTexture;//initiallize the sprite for disc
    int m_iExplode;//initiallize the sprite for explosion
    int m_iGlow;//initiallize the sprite for afterglow
    int m_iBalls;
};
LINK_ENTITY_TO_CLASS( weapon_tnt, CKamikaze );


void CKamikaze::Spawn( )
{
		if ( CVAR_GET_FLOAT( "rocket_arena" ) == 2 ||  CVAR_GET_FLOAT( "automatic_arena" ) == 2 )	
	{
	
	}
	 else
	 {
	Precache( );
	m_iId = WEAPON_TRIPMINE;
	SET_MODEL(ENT(pev), "models/wmodels/w_tnt.mdl");

	FallInit();// get ready to fall down

	m_iDefaultAmmo = TNT_DEFAULT_GIVE;
	 }
}

void CKamikaze::Precache( void )
{
	PRECACHE_MODEL ("models/vmodels/v_kamikaze.mdl");
	PRECACHE_MODEL ("models/pmodels/p_tnt.mdl");
	PRECACHE_MODEL ("models/wmodels/w_tnt.mdl");
	PRECACHE_SOUND ("weapons/tnt1.wav");
	PRECACHE_SOUND ("items/tntvest.wav");
	m_iSpriteTexture = PRECACHE_MODEL( "sprites/white.spr" );//precache the sprite for disc
    m_iExplode = PRECACHE_MODEL( "sprites/fexplo.spr" );//precache the sprite for explosion
    m_iGlow = PRECACHE_MODEL( "sprites/hotglow.spr" );//precache the sprite for afterglow
	m_iBalls = PRECACHE_MODEL( "sprites/blueflare2.spr" );

}

int CKamikaze::GetItemInfo(ItemInfo *p)
{
	p->pszName = STRING(pev->classname);
	p->pszAmmo1 = "Trip Mine";
	p->iMaxAmmo1 = TNT_MAX_CARRY;
	p->pszAmmo2 = NULL;
	p->iMaxAmmo2 = -1;
	p->iMaxClip = WEAPON_NOCLIP;
	p->iSlot = 4;
	p->iPosition = 3;
	p->iId = m_iId = WEAPON_TRIPMINE;
	p->iWeight = TNT_WEIGHT;
	p->iFlags = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
	p->weaponName = "Kamikaze Dynamite Vest";        

	return 1;
}

BOOL CKamikaze::Deploy( )
{
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "items/tntvest.wav", RANDOM_FLOAT(0.9, 1.0), ATTN_NORM);
	return DefaultDeploy( "models/vmodels/v_kamikaze.mdl", "models/pmodels/p_tnt.mdl", SATCHEL_RADIO_DRAW, "hive" );
}


void CKamikaze::Holster( )
{

	m_pPlayer->m_flNextAttack = gpGlobals->time + 0.5;

	if (!m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType])
	{
		// out of mines
		m_pPlayer->pev->weapons &= ~(1<<WEAPON_TRIPMINE);
		SetThink( DestroyItem );
		
		pev->nextthink = gpGlobals->time + 0.1;
	}

	SendWeaponAnim( SATCHEL_RADIO_HOLSTER );
	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_WEAPON, "common/null.wav", 1.0, ATTN_NORM);
}

void CKamikaze::PrimaryAttack( void )
{
	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] <= 0)
		return;

	EMIT_SOUND(ENT(m_pPlayer->pev), CHAN_AUTO, "weapons/tnt1.wav", 1.0, ATTN_NORM);

    pev->nextthink = gpGlobals->time + 20.0;

	SendWeaponAnim( SATCHEL_RADIO_FIRE );

	//initialize a vector that finds the center of the RPG models hitbox
	Vector vecSpot = pev->origin + (pev->mins + pev->maxs) * 0.5;
	/* Make a Big Fireball
	In MESSAGE_BEGIN--there are some cryptic looking things--I'll explain them
	in more detail in the next tutorial. Those of you who know what these parameters
	mean, I'm using MSG_PVS to be more network-friendly--sending the message only to people
	who can see it.*/
	MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, vecSpot );
	WRITE_BYTE( TE_SPRITE );//additive sprite plays though once
	WRITE_COORD( vecSpot.x );//where to make the sprite appear on x axis
	WRITE_COORD( vecSpot.y );//where to make the sprite appear on y axis
	WRITE_COORD( vecSpot.z + 128 );//Creates sprite 128 units above model's center
	WRITE_SHORT( m_iExplode );//Name of the sprite to use, as defined at begining of tut
	WRITE_BYTE( 400 ); // scale in .1 units --by comparison the player is 72 units tall 
	WRITE_BYTE( 255 ); // brightness (this is as bright as it gets)
	MESSAGE_END();

	// Big Plume of Smoke
	MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, vecSpot );
	WRITE_BYTE( TE_SMOKE );//alphablended sprite
	WRITE_COORD( vecSpot.x );
	WRITE_COORD( vecSpot.y );
	WRITE_COORD( vecSpot.z + 256 );
	WRITE_SHORT( g_sModelIndexSmoke );//This is Defined in weapons.cpp and weapons.h
	WRITE_BYTE( 125 ); //scale in .1 units
	WRITE_BYTE( 5 ); // framerate to playback sprite
	MESSAGE_END();

	// blast circle "The Infamous Disc of Death"
	MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, pev->origin );
	WRITE_BYTE( TE_BEAMCYLINDER );
	WRITE_COORD( pev->origin.x);//center of effect on x axis
	WRITE_COORD( pev->origin.y);//center of effect on y axis
	WRITE_COORD( pev->origin.z);//center of effect on z axis
	WRITE_COORD( pev->origin.x);//axis of effect on x axis
	WRITE_COORD( pev->origin.y);//axis of effect on y axis
	WRITE_COORD( pev->origin.z + 1000 ); // z axis and Radius of effect
	WRITE_SHORT( m_iSpriteTexture );//Name of the sprite to use, as defined at begining of tut
	WRITE_BYTE( 0 ); // startframe
	WRITE_BYTE( 0 ); //framerate in 0.1's
	WRITE_BYTE( 40 ); //Life in 0.1's
	WRITE_BYTE( 32 ); //Line Width in .1 units
	WRITE_BYTE( 0 ); //Noise Amplitude in 0.01's
	WRITE_BYTE( 255 ); // Red Color Value
	WRITE_BYTE( 255 ); // Green Color Value
	WRITE_BYTE( 192 ); // Blue Color Value
	WRITE_BYTE( 128 ); // brightness
	WRITE_BYTE( 0 ); // speed
	MESSAGE_END();

	MESSAGE_BEGIN( MSG_PVS, SVC_TEMPENTITY, pev->origin );
	WRITE_BYTE( TE_SPRITETRAIL );// TE_RAILTRAIL);
	WRITE_COORD( pev->origin.x);//center of effect on x axis
	WRITE_COORD( pev->origin.y);//center of effect on y axis
	WRITE_COORD( pev->origin.z);//center of effect on z axis
	WRITE_COORD( pev->origin.x);//axis of effect on x axis
	WRITE_COORD( pev->origin.y);//axis of effect on y axis
	WRITE_COORD( pev->origin.z);
	WRITE_SHORT( m_iBalls );		// model
	WRITE_BYTE( 10 );				// count
	WRITE_BYTE( 100 );				// life * 10
	WRITE_BYTE( 4 );				// size * 10
	WRITE_BYTE( 5 );				// amplitude * 0.1
	WRITE_BYTE( 20 );				// speed * 100
    MESSAGE_END();

	/*Big Booming Sound
	The first parameter says what entity is giving off the sound. The second parameter
	says that the sound isn't dynamic. The third says the name of the sound file. The fourth
	is the volume and the last one tells us attenuation( or falloff ) of the audio file being played*/
	EMIT_SOUND(ENT(pev), CHAN_STATIC, "weapons/mortarhit.wav", 1.0, 0.3);

	/*Big Shake
	The first parameter is the center of where the shaking radiates from. The second parameter is
	the amplitude( or intensity ) of the shaking. The third parameter is the Frequency( or Speed )
	of our tremor. The fourth parameter is the Duration in seconds, and the last one is the radius of the
	shake in units.*/
	UTIL_ScreenShake( pev->origin, 50.0, 400.0, 1.0, 1080 );
	
	entvars_t	*pevOwner;
	
	if ( pev->owner )
		pevOwner = VARS( pev->owner );
	else
		pevOwner = NULL;

	pev->owner = NULL; // can't traceline attack owner if this is set

	/*Big Damage 
	The first parameter is the center of where the damage radiates from. The second is the inflictor
	( or what caused it ). The third is the attacker (or what caused this ). The fourth parameter is the
	damage to inflict, the fifth is the class to ignore ( or what entity not apply damage to ). The final
	parameter is the damage type--(with multiple damage types delineated by a | ).*/
	RadiusDamage( pev->origin, pev, pevOwner, 400, 200, CLASS_NONE, DMG_BLAST | DMG_BURN ); 


	pev->effects |= EF_NODRAW;//stop showing the model!!
	pev->velocity = g_vecZero;//set velocity to "0"
	/*now we set the think to go to our AfterGlow function
	which will leave a Glowing Residue ;) */ 


    m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType]--;

			// player "shoot" animation
			m_pPlayer->SetAnimation( PLAYER_ATTACK1 );

			if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] == 0)
				
				RetireWeapon();
				return;

	m_flNextPrimaryAttack = gpGlobals->time + 2.0;
	m_flTimeWeaponIdle = gpGlobals->time + RANDOM_FLOAT ( 10, 15 );
}
void CKamikaze::WeaponIdle( void )
{
	if (m_flTimeWeaponIdle > gpGlobals->time)
		return;

	if (m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType] > 0)
	{
		SendWeaponAnim( SATCHEL_RADIO_DRAW );
	}
	else
	{
		RetireWeapon(); 
		return;
	}

	int iAnim;
	float flRand = RANDOM_FLOAT(0, 1);
	if (flRand <= 0.25)
	{
		iAnim = SATCHEL_RADIO_IDLE1;
		m_flTimeWeaponIdle = gpGlobals->time + 90.0 / 30.0;
	}
	else if (flRand <= 0.75)
	{
		iAnim = SATCHEL_RADIO_IDLE1;
		m_flTimeWeaponIdle = gpGlobals->time + 60.0 / 30.0;
	}
	else
	{
		iAnim = SATCHEL_RADIO_IDLE1;
		m_flTimeWeaponIdle = gpGlobals->time + 100.0 / 30.0;
	}

	SendWeaponAnim( iAnim );
	
}




