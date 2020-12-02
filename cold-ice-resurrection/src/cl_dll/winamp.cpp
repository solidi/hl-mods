#include "winamp.h"
#include "hud.h"
#include "cl_util.h"

int g_winamp;
/*
void ConsolePrint( const char *string )
{
	gEngfuncs.pfnConsolePrint( string );
}
*/
void winamptest()
{
	if (g_winamp == 0)
		return;
	
	HWND hwndWinamp;
	hwndWinamp = FindWindow("Winamp v1.x", NULL);
	
	if (g_winamp == CONTROL_WINAMP_PLAY) {
		ConsolePrint( "Playing.\n" );
		SendMessage(hwndWinamp, WM_COMMAND,WINAMP_BUTTON2,0);
	}
	if (g_winamp == CONTROL_WINAMP_STOP) {
		ConsolePrint( "Stopping.\n" );
		SendMessage(hwndWinamp, WM_COMMAND,WINAMP_BUTTON4,0);
	}
	
}
