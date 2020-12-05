#include<VGUI_Panel.h>
#include<VGUI_TablePanel.h>
#include<VGUI_HeaderPanel.h>
#include<VGUI_TextGrid.h>
#include<VGUI_Label.h>

class PongHud : public Panel
{
private:

	CImageLabel		*m_pPodRightLabel;
	BitmapTGA		*m_pPodRightImage;
	
	CImageLabel		*m_pPodLeftLabel;
	BitmapTGA		*m_pPodLeftImage;

	CImageLabel     *m_pBallLabel;
	BitmapTGA       *m_pBallImage;

	//static images
	CImageLabel     *m_pDividerLabel;
	BitmapTGA       *m_pDividerImage;
	CImageLabel     *m_pLogoLabel;
	BitmapTGA       *m_pLogoImage;
	CImageLabel     *m_pHLLabel;
	BitmapTGA       *m_pHLImage;

	TextPanel       *pLeftScore;
	TextPanel       *pRightScore;

public:
	PongHud(int x,int y,int wide,int tall);
	virtual void setSize(int wide,int tall);

	void Update( void );
	void RebuildData( void );
	void Initialize( void );

	char szRController[128];
	char szLController[128];
	int m_PosRightPod;
	int m_PosLeftPod;

	int ball_x;
	int ball_y;
	int m_iLeftScore;
	int m_iRightScore;
	
	void Open( void )
	{
		RebuildData();
		setVisible(true);
	}
};
