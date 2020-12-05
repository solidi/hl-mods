/***
*
*	Copyright (c) 1996-2002, Valve LLC. All rights reserved.
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
/*

===== globals.cpp ========================================================

  DLL-wide global variable definitions.
  They're all defined here, for convenient centralization.
  Source files that need them should "extern ..." declare each
  variable, to better document what globals they care about.

*/

#include "extdll.h"
#include "util.h"
#include "cbase.h"
#include "soundent.h"

DLL_GLOBAL ULONG		g_ulFrameCount;
DLL_GLOBAL ULONG		g_ulModelIndexEyes;
DLL_GLOBAL ULONG		g_ulModelIndexPlayer;
DLL_GLOBAL Vector		g_vecAttackDir;
DLL_GLOBAL int			g_iSkillLevel;
DLL_GLOBAL int			gDisplayTitle;
DLL_GLOBAL BOOL			g_fGameOver;
DLL_GLOBAL const Vector	g_vecZero = Vector(0,0,0);
DLL_GLOBAL int			g_Language;

//start hlpro2
DLL_GLOBAL int          g_flWeaponArena;
DLL_GLOBAL const char  *g_WeaponArenaName;
DLL_GLOBAL BOOL         g_bAntiCamper;
DLL_GLOBAL BOOL         g_bInstaGib;
DLL_GLOBAL BOOL         g_bFatBoy;
DLL_GLOBAL BOOL         g_bEarning;
DLL_GLOBAL BOOL         g_bStartFull;
DLL_GLOBAL BOOL         g_bMoreGore;
DLL_GLOBAL BOOL         g_bRunes;

DLL_GLOBAL int			g_GameMode;
DLL_GLOBAL const char  *g_GameModeName;

DLL_GLOBAL BOOL         g_VoteInProgress;
DLL_GLOBAL float        g_VoteTimer;
DLL_GLOBAL float        g_VoteExecute;
DLL_GLOBAL int			g_VotesYes;
DLL_GLOBAL int			g_VotesNo;
DLL_GLOBAL int			g_VoteType;
DLL_GLOBAL char			g_VoteMessage[256];
//end hlpro2
