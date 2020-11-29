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
/*

Class Hierachy

CBaseEntity
	CBaseDelay
		CBaseToggle
			CBaseItem
			CBaseMonster
				CBaseCycler
				CBasePlayer
				CBaseGroup
*/

//This File was coded by [Wolfpac]SlimShady For Cold Ice!
//7/9/99


class CBaseClass {
public:
virtual int PlayerSpeed() { return 200; };
}

class CSpy : public CBaseClass {
public:
virtual int PlayerSpeed() { return 500; };
}

class CSloth : public CBaseClass {
public:
virtual int PlayerSpeed() { return 100; };
}



