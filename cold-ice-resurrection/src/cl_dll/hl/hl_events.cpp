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
#include "../hud.h"
#include "../cl_util.h"
#include "event_api.h"

extern "C"
{
// HLDM
//start ice
void EV_FireSawed1( struct event_args_s *args  );
void EV_FireSawed2( struct event_args_s *args  );
void EV_FireDeagle( struct event_args_s *args  );
void EV_FireSmg( struct event_args_s *args  );
void EV_FireBlaster( struct event_args_s *args  );
//end ice
void EV_FireGlock1( struct event_args_s *args  );
void EV_FireGlock2( struct event_args_s *args  );
void EV_FireGauss( struct event_args_s *args  );
void EV_SpinGauss( struct event_args_s *args  );
void EV_TrainPitchAdjust( struct event_args_s *args );
}

/*
======================
Game_HookEvents

Associate script file name with callback functions.  Callback's must be extern "C" so
 the engine doesn't get confused about name mangling stuff.  Note that the format is
 always the same.  Of course, a clever mod team could actually embed parameters, behavior
 into the actual .sc files and create a .sc file parser and hook their functionality through
 that.. i.e., a scripting system.

That was what we were going to do, but we ran out of time...oh well.
======================
*/
void Game_HookEvents( void )
{
	//start ice
	gEngfuncs.pfnHookEvent( "events/sawedoff1.sc",				EV_FireSawed1 );
	gEngfuncs.pfnHookEvent( "events/sawedoff2.sc",				EV_FireSawed2 );
	gEngfuncs.pfnHookEvent( "events/deagle.sc",					EV_FireDeagle );
	gEngfuncs.pfnHookEvent( "events/smg.sc",					EV_FireSmg );
	gEngfuncs.pfnHookEvent( "events/blaser.sc",				EV_FireBlaster );
	//end ice
	gEngfuncs.pfnHookEvent( "events/glock1.sc",					EV_FireGlock1 );
	gEngfuncs.pfnHookEvent( "events/glock2.sc",					EV_FireGlock2 );
	gEngfuncs.pfnHookEvent( "events/gauss.sc",					EV_FireGauss );
	gEngfuncs.pfnHookEvent( "events/gaussspin.sc",				EV_SpinGauss );
	gEngfuncs.pfnHookEvent( "events/train.sc",					EV_TrainPitchAdjust );
}