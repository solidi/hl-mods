#include<VGUI_LineBorder.h>

#include "hud.h"
#include "cl_util.h"
#include "const.h"
#include "entity_state.h"
#include "cl_entity.h"
#include "vgui_TeamFortressViewport.h"
#include "vgui_Pong.h"

PongHud::PongHud(int x, int y, int wide, int tall) : Panel(x,y,wide,tall)
{
	setBgColor( 255,255,255,0 ); //white!

	m_pHLImage = LoadTGA( "hl" );
	m_pHLLabel = new CImageLabel( "hl", 128, 30 );
	m_pHLLabel->setVisible(true);
	m_pHLLabel->setParent(this);

	m_pDividerImage = LoadTGA( "divider" );
	m_pDividerLabel = new CImageLabel( "divider", 316, -4 );
	m_pDividerLabel->setVisible(true);
	m_pDividerLabel->setParent(this);

	m_pLogoImage = LoadTGA( "logo" );
	m_pLogoLabel = new CImageLabel( "logo", 20, ScreenHeight - 40 );
	m_pLogoLabel->setVisible(true);
	m_pLogoLabel->setParent(this);

	m_pBallImage = LoadTGA( "ball" );
	m_pBallLabel = new CImageLabel( "ball", ScreenWidth / 2, ScreenHeight / 2 );
	m_pBallLabel->setVisible(true);
	m_pBallLabel->setParent(this);

	m_pPodRightImage = LoadTGA( "pod_right" );
	m_pPodRightLabel = new CImageLabel( "pod_right", ScreenWidth - 40, m_PosRightPod );
	m_pPodRightLabel->setVisible(true);
	m_pPodRightLabel->setParent(this);

	m_pPodLeftImage = LoadTGA( "pod_left" );
	m_pPodLeftLabel = new CImageLabel( "pod_left", 6, m_PosLeftPod );
	m_pPodLeftLabel->setVisible(true);
	m_pPodLeftLabel->setParent(this);

	pLeftScore = new TextPanel( "", 100, ScreenHeight - 100, 100, 100);
	pLeftScore->setParent( this );
	pLeftScore->setFgColor( 0,0,0,0 );
	pLeftScore->setBgColor( 0,0,0,255 );
	pLeftScore->setText(" ");

	pRightScore = new TextPanel( "", ScreenWidth - 150, ScreenHeight - 100, 100, 100);
	pRightScore->setParent( this );
	pRightScore->setFgColor( 0,0,0,0 );
	pRightScore->setBgColor( 0,0,0,255 );
	pRightScore->setText(" ");


	Initialize();
}

//-----------------------------------------------------------------------------
// Purpose: Called each time a new level is started.
//-----------------------------------------------------------------------------
void PongHud::Initialize( void )
{
	ball_y = ball_x = 200;
	m_iRightScore = m_iLeftScore = 0;
}

void PongHud::setSize(int wide,int tall)
{
	Panel::setSize(wide,tall);
}

void PongHud::Update()
{
	m_pBallLabel->setPos(ball_x, ball_y);

	char sz[1024];
/*	strcpy(sz, " ");
	for ( int i = 1; i < MAX_PLAYERS; i++ )
	{
		if ( g_PlayerInfoList[i].name == NULL )
			continue; // empty player slot, skip
		else
			sprintf(sz, "%s %s\n", sz, g_PlayerInfoList[i].name);
	}*/

	sprintf(sz, "Score: %d", m_iLeftScore );
	pLeftScore->setText(sz);

	char sz2[1024];
	sprintf(sz2, "Score: %d", m_iRightScore );
	pRightScore->setText(sz2);

	//pod update
	m_pPodRightLabel->setPos(ScreenWidth - 40, m_PosRightPod );
	m_pPodLeftLabel->setPos(6, m_PosLeftPod );
}

void PongHud::RebuildData()
{
	Update();
}

