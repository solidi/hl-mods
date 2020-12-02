#include<VGUI_Panel.h>
#include<VGUI_TablePanel.h>
#include<VGUI_HeaderPanel.h>
#include<VGUI_TextGrid.h>
#include<VGUI_Label.h>

class CirHUD : public Panel
{
private:
	CImageLabel		*m_pHudLabel[10];
	BitmapTGA		*m_pHudImage[10];

	CImageLabel		*m_pHundredsLabel[8];
	CImageLabel		*m_pTensLabel[8];
	CImageLabel		*m_pOnesLabel[8];
	BitmapTGA		*m_pVGUINumbers[10];

public:
	CirHUD(int x,int y,int wide,int tall);
	virtual void setSize(int wide,int tall);

	void Update( void );
	void RebuildData( void );
	void Initialize( void );
	void Open( void )
	{
		RebuildData();
		setVisible(true);
	}

	void InitGuiLabels( int iType, char *szName, int x, int y );
	void InitGuiNumbers( int iType, int width, int height );	
	void DrawGuiNumber( int iType, int iNumber );
	void MakeGuiPackageVisible( int iType, bool visible );
};