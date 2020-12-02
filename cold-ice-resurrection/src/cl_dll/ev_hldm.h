#if !defined ( EV_HLDMH )
#define EV_HLDMH

// bullet types
typedef	enum
{
	//start ice
	BULLET_NONE = 0,
	BULLET_PLAYER_9MM, // glock
	BULLET_PLAYER_MP5, // mp5
	BULLET_PLAYER_DEAGLE, // python
	BULLET_PLAYER_BUCKSHOT, // shotgun
	BULLET_PLAYER_CROWBAR, // crowbar swipe

	BULLET_MONSTER_9MM,
	BULLET_MONSTER_MP5,
	BULLET_MONSTER_12MM,
	//end ice
} Bullet;

enum glock_e {
	GLOCK_IDLE1 = 0,
	GLOCK_IDLE2,
	GLOCK_IDLE3,
	GLOCK_SHOOT,
	GLOCK_SHOOT_EMPTY,
	GLOCK_RELOAD,
	GLOCK_RELOAD_NOT_EMPTY,
	GLOCK_DRAW,
	GLOCK_HOLSTER,
	GLOCK_ADD_SILENCER
};

//start ice
enum sawedoff_e {
	SAWED_IDLE1 = 0,
	SAWED_IDLE2,
	SAWED_FIRE_LEFT,
	SAWED_FIRE_RIGHT,
	SAWED_FIRE_BOTH,
	SAWED_RELOAD,
	SAWED_DRAW,
};

enum deagle_e {
	DEAGLE_IDLE1 = 0,
	DEAGLE_IDLE2,
	DEAGLE_IDLE_EMPTY,
	DEAGLE_SHOOT,
	DEAGLE_SHOOT_EMPTY,
	DEAGLE_RELOAD,
	DEAGLE_RELOAD_EMPTY,
	DEAGLE_DRAW,
	DEAGLE_HOLSTER,
	DEAGLE_HOLSTER_EMPTY,
};

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
//end ice

#define	GAUSS_PRIMARY_CHARGE_VOLUME	256// how loud gauss is while charging
#define GAUSS_PRIMARY_FIRE_VOLUME	450// how loud gauss is when discharged

enum gauss_e {
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

void EV_HLDM_GunshotDecalTrace( pmtrace_t *pTrace, char *decalName );
void EV_HLDM_DecalGunshot( pmtrace_t *pTrace, int iBulletType );
int EV_HLDM_CheckTracer( int idx, float *vecSrc, float *end, float *forward, float *right, int iBulletType, int iTracerFreq, int *tracerCount );
void EV_HLDM_FireBullets( int idx, float *forward, float *right, float *up, int cShots, float *vecSrc, float *vecDirShooting, float *vecSpread, float flDistance, int iBulletType, int iTracerFreq, int *tracerCount );

#endif // EV_HLDMH