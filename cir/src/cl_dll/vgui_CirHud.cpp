#include "hud.h"
#include "ammo.h"
#include "parsemsg.h"

#include <string.h>
#include <stdio.h>

#include "cl_util.h"
#include "const.h"
#include "entity_state.h"
#include "cl_entity.h"
#include "vgui_TeamFortressViewport.h"
#include "vgui_ScorePanel.h"
#include "vgui_CirHud.h"

#include "ammo.h"
#include "ammohistory.h"

#define  LABEL_FRAGS   1
#define  LABEL_CLIP    2
#define  LABEL_RESERVE 3
#define  LABEL_XHAIR   4

char *sGuiNumbers[] = 
{
	"num_0",
	"num_1",
	"num_2",
	"num_3",
	"num_4",
	"num_5",
	"num_6",
	"num_7",
	"num_8",
	"num_9",
	"num_10",
};

//-----------------------------------------------------------------------------
// Purpose: Construct the vgui Hud.
//-----------------------------------------------------------------------------
CirHUD::CirHUD(int x, int y, int wide, int tall) : Panel(x,y,wide,tall)
{
	setBgColor( 0, 0, 0, 255 ); // We don''t want a dark screen with a hud!

	for ( int i = 0; i < 10; i++ )
	{
		m_pVGUINumbers[i] = LoadTGA( sGuiNumbers[i] );
	}

	//create ammo labels
	InitGuiLabels( LABEL_CLIP, "clip", ScreenWidth - 132, ScreenHeight - 90 );
	InitGuiLabels( LABEL_RESERVE, "reserve", ScreenWidth - 132, ScreenHeight - 44 );	
	InitGuiLabels( LABEL_FRAGS, "frags", -10, 4 );

	//create ammo numbers
	InitGuiNumbers( LABEL_FRAGS, 12, 8 ); //48, 39
	InitGuiNumbers( LABEL_CLIP, ScreenWidth - 80, ScreenHeight - 86 ); //-120, 95
	InitGuiNumbers( LABEL_RESERVE, ScreenWidth - 80, ScreenHeight - 40 ); //120, 49

	//create special xhair. (invisible)
	InitGuiLabels( LABEL_XHAIR, "zoomxhair", ( ScreenWidth / 2 ) - 133, ( ScreenHeight / 2 ) - 133 );

	Initialize();
}

//-----------------------------------------------------------------------------
// Purpose: Called each time a new level is started.
//-----------------------------------------------------------------------------
void CirHUD::Initialize( void )
{

// TODO: Clear out all the values here

}

void CirHUD::setSize(int wide,int tall)
{
	Panel::setSize(wide,tall);
}

void CirHUD::Update()
{	
	if ( gHUD.m_fPlayerDead )
		return;

	WEAPON *pw = gHUD.m_Ammo.m_pWeapon;

	if ( pw )
	{
		//draw ammo clip
		if ( pw->iClip >= 0 )
		{
			DrawGuiNumber(LABEL_CLIP, pw->iClip );
			MakeGuiPackageVisible( LABEL_CLIP, true );
		}
		else
		{
			MakeGuiPackageVisible( LABEL_CLIP, false );
		}

		//draw ammo reserve
		if ( gWR.CountAmmo(pw->iAmmoType) >= 0 )
		{
			//draw only if its not a pipe or chainsaw
			if ( pw->iId > 2 )
			{
				DrawGuiNumber(LABEL_RESERVE, gWR.CountAmmo(pw->iAmmoType) );
				MakeGuiPackageVisible( LABEL_RESERVE, true );
			}
			else
				MakeGuiPackageVisible( LABEL_RESERVE, false );

		}
		else
		{
			MakeGuiPackageVisible( LABEL_RESERVE, false );
		}

		//determine if we need zoomed in crosshair
		if ( gHUD.m_iFOV < 90 )
			m_pHudLabel[LABEL_XHAIR]->setVisible(true);
		else
			m_pHudLabel[LABEL_XHAIR]->setVisible(false);
	}

	//draw frags
	DrawGuiNumber(LABEL_FRAGS, gHUD.m_iMyFrags );
}

//-----------------------------------------------------------------------------
// Purpose: Create defined vgui label.
//-----------------------------------------------------------------------------
void CirHUD::InitGuiLabels( int iType, char *szName, int x, int y )
{
	m_pHudImage[iType] = LoadTGA( szName );
	m_pHudLabel[iType] = new CImageLabel( szName, x, y );
	m_pHudLabel[iType]->setVisible(true);
	m_pHudLabel[iType]->setParent(this);
}

//-----------------------------------------------------------------------------
// Purpose: Create defined vgui label (static). (100)
//-----------------------------------------------------------------------------
void CirHUD::InitGuiNumbers( int iType, int width, int height )
{
	m_pHundredsLabel[iType] = new CImageLabel(sGuiNumbers[0], width, height);
	m_pHundredsLabel[iType]->setParent(this);

	width += 20;

	m_pTensLabel[iType] = new CImageLabel(sGuiNumbers[0], width, height );
	m_pTensLabel[iType]->setParent(this);

	width += 20;

	m_pOnesLabel[iType] = new CImageLabel(sGuiNumbers[0], width, height );
	m_pOnesLabel[iType]->setParent(this);
}

//-----------------------------------------------------------------------------
// Purpose: Update defined vgui number (active). (100)
//-----------------------------------------------------------------------------
void CirHUD::DrawGuiNumber( int iType, int iNumber )
{
	int k;

	//crash if negative!!!
	if ( iNumber < 0 )
		return;

	//draw 100's
	k = iNumber / 100;
	
	if ( iNumber > 99 )
	{
		m_pHundredsLabel[iType]->m_pTGA = m_pVGUINumbers[k];
		m_pHundredsLabel[iType]->setImage( m_pHundredsLabel[iType]->m_pTGA );
		m_pHundredsLabel[iType]->setVisible(true);
	}
	else
		m_pHundredsLabel[iType]->setImage(false);

	//draw 10's
	k = (iNumber % 100) / 10;
	
	if ( iNumber > 9 )
	{
		m_pTensLabel[iType]->m_pTGA = m_pVGUINumbers[k];
		m_pTensLabel[iType]->setImage( m_pTensLabel[iType]->m_pTGA );
		m_pTensLabel[iType]->setVisible(true);
	}
	else
		m_pTensLabel[iType]->setImage(false);

	//draw 1's
	k = iNumber % 10;
	
	m_pOnesLabel[iType]->m_pTGA = m_pVGUINumbers[k];
	m_pOnesLabel[iType]->setImage( m_pOnesLabel[iType]->m_pTGA );
	m_pOnesLabel[iType]->setVisible(true);
}

//-----------------------------------------------------------------------------
// Purpose: Make Gui Image Package (Numbers & Label)  Visible / Unvisible
//-----------------------------------------------------------------------------
void CirHUD::MakeGuiPackageVisible( int iType, bool visible )
{
	m_pHudLabel[iType]->setVisible(false);
	m_pOnesLabel[iType]->setVisible(visible);
	m_pTensLabel[iType]->setVisible(visible);
	m_pHundredsLabel[iType]->setVisible(visible);
}

void CirHUD::RebuildData()
{
	Update();
}
