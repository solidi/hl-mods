//=========== (C) Copyright 1999 Valve, L.L.C. All rights reserved. ===========
//
// The copyright to the contents herein is the property of Valve, L.L.C.
// The contents may be used and/or copied only with the written permission of
// Valve, L.L.C., or in accordance with the terms and conditions stipulated in
// the agreement/contract under which the contents have been supplied.
//
// Purpose: VGUI scoreboard
//
// $Workfile:     $
// $Date:         $
//
//-----------------------------------------------------------------------------
// $Log: $
//
// $NoKeywords: $
//=============================================================================


#include<VGUI_LineBorder.h>

#include "hud.h"
#include "cl_util.h"
#include "const.h"
#include "entity_state.h"
#include "cl_entity.h"
#include "vgui_TeamFortressViewport.h"
#include "vgui_ScorePanel.h"

hud_player_info_t	 g_PlayerInfoList[MAX_PLAYERS+1];	   // player info from the engine
extra_player_info_t  g_PlayerExtraInfo[MAX_PLAYERS+1];   // additional player info sent directly to the client dll
team_info_t			 g_TeamInfo[MAX_TEAMS+1];
int					 g_IsSpectator[MAX_PLAYERS+1];

int HUD_IsGame( const char *game );
int EV_TFC_IsAllyTeam( int iTeam1, int iTeam2 );

// Scoreboard dimensions
#define SBOARD_TITLE_SIZE_Y			YRES(24)
#define SBOARD_HEADER_SIZE_Y		YRES(40)
#define SBOARD_TABLE_X				XRES(16)
#define SBOARD_TABLE_Y				(SBOARD_TITLE_SIZE_Y + SBOARD_HEADER_SIZE_Y)

#define SBOARD_TEAM_CELL_SIZE_Y		YRES(20)
#define SBOARD_CELL_SIZE_Y			YRES(13)

// Column sizes
#define CSIZE_NAME				XRES(140)
#define CSIZE_CLASS				CSIZE_NAME + XRES(64)
#define CSIZE_KILLS				CSIZE_CLASS + XRES(60)
#define CSIZE_DEATHS			CSIZE_KILLS + XRES(64)

#define SMALL_CSIZE_NAME		XRES(124)					
#define SMALL_CSIZE_CLASS		SMALL_CSIZE_NAME + XRES(60)	
#define SMALL_CSIZE_KILLS		SMALL_CSIZE_CLASS + XRES(64)
#define SMALL_CSIZE_DEATHS		SMALL_CSIZE_KILLS + XRES(70)

#define TEAM_NO				0
#define TEAM_YES			1
#define TEAM_UNASSIGNED		2
#define TEAM_SPECTATORS		3

// Team Colors used in the scoreboard
int ScoreColorsBG[5][3] =
{
	{ 0, 0, 0 },
	{ 66, 114, 247 },
	{ 220, 51, 38 },
	{ 236, 212, 48 },
	{ 68, 199, 42 },
};

int ScoreColorsFG[5][3] =
{
	{ 255, 255, 255 },
	{ 170, 193, 251 },
	{ 215, 151, 146 },
	{ 227, 203, 46 },
	{ 143, 215, 142 },
};

//-----------------------------------------------------------------------------
// Purpose: Set different cell heights for Teams and Players
//-----------------------------------------------------------------------------
int ScoreTablePanel::getCellTall(int row)
{
	if ( m_iIsATeam[row] )
		return SBOARD_TEAM_CELL_SIZE_Y;

	return SBOARD_CELL_SIZE_Y;
}

//-----------------------------------------------------------------------------
// Purpose: Render each of the cells in the Table
//-----------------------------------------------------------------------------
Panel* ScoreTablePanel::getCellRenderer(int column,int row,bool columnSelected,bool rowSelected,bool cellSelected)
{
	char sz[128];
	hud_player_info_t *pl_info = NULL;
	team_info_t *team_info = NULL;

	if ( m_iIsATeam[row] == TEAM_YES )
	{
		// Get the team's data
		team_info = &g_TeamInfo[ m_iSortedRows[row] ];

		// White text for team names
		m_pLabel->setFgColor(Scheme::sc_white);

		// Set background color
		m_pLabel->setBgColor( ScoreColorsBG[ team_info->teamnumber ][0], ScoreColorsBG[ team_info->teamnumber ][1], ScoreColorsBG[ team_info->teamnumber ][2], 128 );
	}
	else if ( m_iIsATeam[row] == TEAM_UNASSIGNED || m_iIsATeam[row] == TEAM_SPECTATORS )
	{
		// White text for team names
		m_pLabel->setFgColor(Scheme::sc_white);

		// Set background color
		m_pLabel->setBgColor( 0,0,0, 255 );
	}
	else
	{
		// Grey text for player names
		m_pLabel->setFgColor( ScoreColorsFG[ g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ][0], ScoreColorsFG[ g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ][1], ScoreColorsFG[ g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ][2], 128 );

		// Get the player's data
		pl_info = &g_PlayerInfoList[ m_iSortedRows[row] ];

		// Set background color
		if ( pl_info->thisplayer ) // if it is their name, draw it a different color
		{
			// Highlight this player
			m_pLabel->setFgColor(Scheme::sc_white);
			m_pLabel->setBgColor( ScoreColorsBG[ g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ][0], ScoreColorsBG[ g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ][1], ScoreColorsBG[ g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ][2], 196 );
		}
		else if ( m_iSortedRows[row] == m_iLastKilledBy && m_fLastKillTime && m_fLastKillTime > gHUD.m_flTime )
		{
			// Killer's name
			m_pLabel->setBgColor( 255,0,0, 255 - ((float)15 * (float)(m_fLastKillTime - gHUD.m_flTime)) );
		}
		else
		{
			m_pLabel->setBgColor( 0,0,0, 255 );
		}
	}

	// Align 
	if (column <= 1)
	{
		if ( m_iIsATeam[row] )
			m_pLabel->setContentAlignment( vgui::Label::a_southwest );
		else
			m_pLabel->setContentAlignment( vgui::Label::a_west );
	}
	else
	{
		if ( m_iIsATeam[row] )
			m_pLabel->setContentAlignment( vgui::Label::a_south );
		else
			m_pLabel->setContentAlignment( vgui::Label::a_center );
	}

	// Fill out with the correct data
	if ( m_iIsATeam[row] )
	{
		int i;
		char sz2[128];
		strcpy(sz, "");

		switch (column)
		{
		case 0:
			if ( m_iIsATeam[row] == TEAM_UNASSIGNED )
			{
				sprintf( sz2, CHudTextMessage::BufferedLocaliseTextString( "#Unassigned" ) );
			}
			else if ( m_iIsATeam[row] == TEAM_SPECTATORS )
			{
				sprintf( sz2, CHudTextMessage::BufferedLocaliseTextString( "#Spectators" ) );
			}
			else
			{
				sprintf( sz2, CHudTextMessage::BufferedLocaliseTextString( team_info->name ) );
			}

			// Uppercase it
			for (i = 0; i < (int)strlen(sz2); i++)
			{
				if ( *(sz2 + i) )
					sz[i] = toupper( *(sz2 + i) );
			}
			sz[i] = '\0';

			// Append the number of players
			if ( m_iIsATeam[row] == TEAM_YES )
			{
				if (team_info->players == 1)
					sprintf(sz, "%s (1 player)", sz );
				else
					sprintf(sz, "%s (%d players)", sz, team_info->players );
			}
			break;
		case 1:
			// No class for teams
			break;
		case 2:
			if ( m_iIsATeam[row] == TEAM_YES )
				sprintf(sz, "%d",  team_info->frags );
			break;
		case 3:
			if ( m_iIsATeam[row] == TEAM_YES )
				sprintf(sz, "%d",  team_info->deaths );
			break;
		case 4:
			if ( m_iIsATeam[row] == TEAM_YES )
				sprintf(sz, "%d", team_info->ping );
			break;
		default:
			break;
		}

		m_pLabel->setText(sz);
	}
	else
	{
		bool bShowClass = false;

		switch (column)
		{
		case 0:
			sprintf(sz, "  %s", pl_info->name);
			break;
		case 1:
			// No class for other team's members (unless allied or spectator)
			if ( gViewPort && EV_TFC_IsAllyTeam( g_iTeamNumber, g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber )  )
				bShowClass = true;
			// Don't show classes if this client hasnt picked a team yet
			if ( g_iTeamNumber == 0 )
				bShowClass = false;
			if ( g_iUser1 )
				bShowClass = true;

			if (bShowClass)
			{
				// Only print Civilian if this team are all civilians
				bool bNoClass = false;
				if ( g_PlayerExtraInfo[ m_iSortedRows[row] ].playerclass == 0 )
				{
					if ( gViewPort->GetValidClasses( g_PlayerExtraInfo[ m_iSortedRows[row] ].teamnumber ) != -1 )
						bNoClass = true;
				}

				if (bNoClass)
					sprintf(sz, "");
				else
					sprintf( sz, "%s", CHudTextMessage::BufferedLocaliseTextString( sLocalisedClasses[ g_PlayerExtraInfo[ m_iSortedRows[row] ].playerclass ] ) );
			}
			else
			{
				strcpy(sz, "");
			}
			break;
		case 2:
			sprintf(sz, "%d",  g_PlayerExtraInfo[ m_iSortedRows[row] ].frags );
			break;
		//start ice
		//case 3:
			//sprintf(sz, "%d",  g_PlayerExtraInfo[ m_iSortedRows[row] ].deaths );
		//	break;
		//end ice
		case 4:
			sprintf(sz, "%d", g_PlayerInfoList[ m_iSortedRows[row] ].ping );
			break;
		default:
			strcpy(sz, "");
		}

		m_pLabel->setText(sz);
	}

	return m_pLabel;
}


//-----------------------------------------------------------------------------
// Purpose: Create the ScoreBoard panel
//-----------------------------------------------------------------------------
ScorePanel::ScorePanel(int x,int y,int wide,int tall) : Panel(x,y,wide,tall)
{
	//start ice
	setBorder( new LineBorder( Color(0 * 0.7,115 * 0.7,230 * 0.7,0) ) );
	//end ice
	setBgColor( 0,0,0, 100 );

	//start ice
	m_pTitleLabel = new Label( "  Scores", 0,0, wide, SBOARD_TITLE_SIZE_Y );
	//end ice
	m_pTitleLabel->setBgColor( Scheme::sc_primary2 );
	m_pTitleLabel->setFgColor( Scheme::sc_primary1 );
	m_pTitleLabel->setContentAlignment( vgui::Label::a_west );
	m_pTitleLabel->setParent(this);

	_headerPanel = new HeaderPanel( SBOARD_TABLE_X, SBOARD_TITLE_SIZE_Y, wide - (SBOARD_TABLE_X * 2), SBOARD_HEADER_SIZE_Y);
	_headerPanel->setParent(this);

	// BUGBUG: This isn't working. gHUD.m_Teamplay hasn't been initialized yet.
	if ( gHUD.m_Teamplay )
		_headerPanel->addSectionPanel( new CLabelHeader( CHudTextMessage::BufferedLocaliseTextString( "#TEAMS" ), true) );
	else
		//start ice
		_headerPanel->addSectionPanel( new CLabelHeader( CHudTextMessage::BufferedLocaliseTextString( "Players" ), true) );
		//end ice

	if ( HUD_IsGame( "tfc" ) )
		_headerPanel->addSectionPanel( new CLabelHeader( CHudTextMessage::BufferedLocaliseTextString( "#CLASS" ), true) );
	else
		_headerPanel->addSectionPanel( new CLabelHeader("", true) );

	//start ice
	_headerPanel->addSectionPanel( new CLabelHeader( CHudTextMessage::BufferedLocaliseTextString( "Frags" )) );
	_headerPanel->addSectionPanel( new CLabelHeader( CHudTextMessage::BufferedLocaliseTextString( " ")) );
	_headerPanel->addSectionPanel( new CLabelHeader( CHudTextMessage::BufferedLocaliseTextString( "Latency")) );
	_headerPanel->setBgColor( 0,0,0, 255 );
	//end ice

	// Need to special case 400x300, because the titles just wont fit otherwise
	if ( ScreenWidth == 400 )
	{
		_headerPanel->setSliderPos( 0, SMALL_CSIZE_NAME );
		_headerPanel->setSliderPos( 1, SMALL_CSIZE_CLASS );
		_headerPanel->setSliderPos( 2, SMALL_CSIZE_KILLS );
		_headerPanel->setSliderPos( 3, SMALL_CSIZE_DEATHS );
		_headerPanel->setSliderPos( 4, wide - (SBOARD_TABLE_X * 2) - 1 );
	}
	else
	{
		_headerPanel->setSliderPos( 0, CSIZE_NAME );
		_headerPanel->setSliderPos( 1, CSIZE_CLASS );
		_headerPanel->setSliderPos( 2, CSIZE_KILLS );
		_headerPanel->setSliderPos( 3, CSIZE_DEATHS );
		_headerPanel->setSliderPos( 4, wide - (SBOARD_TABLE_X * 2) - 1 );
	}

	_tablePanel = new ScoreTablePanel(SBOARD_TABLE_X, SBOARD_TABLE_Y, wide - (SBOARD_TABLE_X * 2), tall - SBOARD_TABLE_Y, NUM_COLUMNS);
	_tablePanel->setParent(this);
	_tablePanel->setHeaderPanel(_headerPanel);
	_tablePanel->setBgColor( 0,0,0, 255 );

	Initialize();
}

//-----------------------------------------------------------------------------
// Purpose: Called each time a new level is started.
//-----------------------------------------------------------------------------
void ScorePanel::Initialize( void )
{
	// Clear out scoreboard data
	_tablePanel->m_iLastKilledBy = 0;
	_tablePanel->m_fLastKillTime = 0;
	m_iPlayerNum = 0;
	m_iNumTeams = 0;
	memset( g_PlayerExtraInfo, 0, sizeof g_PlayerExtraInfo );
	memset( g_TeamInfo, 0, sizeof g_TeamInfo );
}

//-----------------------------------------------------------------------------
// Purpose: Set the size of the header and table when this panel's size changes
//-----------------------------------------------------------------------------
void ScorePanel::setSize(int wide,int tall)
{
	Panel::setSize(wide,tall);

	_headerPanel->setBounds(0,0,wide,SBOARD_HEADER_SIZE_Y);
	_tablePanel->setBounds(0,20,wide,tall - SBOARD_HEADER_SIZE_Y);
}

//-----------------------------------------------------------------------------
// Purpose: Recalculate the internal scoreboard data
//-----------------------------------------------------------------------------
void ScorePanel::Update()
{
	// Set the title
	if (gViewPort->m_szServerName)
	{
		char sz[MAX_SERVERNAME_LENGTH + 16];
		//start ice
		sprintf(sz, "  Scores: %s", gViewPort->m_szServerName );
		//end ice
		m_pTitleLabel->setText(sz);
	}

	_tablePanel->m_iRows = 0;
	gViewPort->GetAllPlayersInfo();

	// Clear out sorts
	for (int i = 0; i < MAX_PLAYERS; i++)
	{
		_tablePanel->m_iSortedRows[i] = 0;
		_tablePanel->m_iIsATeam[i] = TEAM_NO;
		_tablePanel->m_bHasBeenSorted[i] = false;
	}

	// If it's not teamplay, sort all the players. Otherwise, sort the teams.
	if ( !gHUD.m_Teamplay )
		SortPlayers( 0, NULL );
	else
		SortTeams();
}

//-----------------------------------------------------------------------------
// Purpose: Sort all the teams
//-----------------------------------------------------------------------------
void ScorePanel::SortTeams()
{
	// clear out team scores
	for ( int i = 1; i <= m_iNumTeams; i++ )
	{
		if ( !g_TeamInfo[i].scores_overriden )
			g_TeamInfo[i].frags = g_TeamInfo[i].deaths = 0;
		g_TeamInfo[i].ping = g_TeamInfo[i].packetloss = 0;
	}

	// recalc the team scores, then draw them
	for ( i = 1; i < MAX_PLAYERS; i++ )
	{
		if ( g_PlayerInfoList[i].name == NULL )
			continue; // empty player slot, skip

		if ( g_PlayerExtraInfo[i].teamname[0] == 0 )
			continue; // skip over players who are not in a team

		// find what team this player is in
		for ( int j = 1; j <= m_iNumTeams; j++ )
		{
			if ( !stricmp( g_PlayerExtraInfo[i].teamname, g_TeamInfo[j].name ) )
				break;
		}
		if ( j > m_iNumTeams )  // player is not in a team, skip to the next guy
			continue;

		if ( !g_TeamInfo[j].scores_overriden )
		{
			g_TeamInfo[j].frags += g_PlayerExtraInfo[i].frags;
			g_TeamInfo[j].deaths += g_PlayerExtraInfo[i].deaths;
		}

		g_TeamInfo[j].ping += g_PlayerInfoList[i].ping;
		g_TeamInfo[j].packetloss += g_PlayerInfoList[i].packetloss;

		if ( g_PlayerInfoList[i].thisplayer )
			g_TeamInfo[j].ownteam = TRUE;
		else
			g_TeamInfo[j].ownteam = FALSE;

		// Set the team's number (used for team colors)
		g_TeamInfo[j].teamnumber = g_PlayerExtraInfo[i].teamnumber;
	}

	// find team ping/packetloss averages
	for ( i = 1; i <= m_iNumTeams; i++ )
	{
		g_TeamInfo[i].already_drawn = FALSE;

		if ( g_TeamInfo[i].players > 0 )
		{
			g_TeamInfo[i].ping /= g_TeamInfo[i].players;  // use the average ping of all the players in the team as the teams ping
			g_TeamInfo[i].packetloss /= g_TeamInfo[i].players;  // use the average ping of all the players in the team as the teams ping
		}
	}

	// Draw the teams
	while ( 1 )
	{
		int highest_frags = -99999; int lowest_deaths = 99999;
		int best_team = 0;

		for ( i = 1; i <= m_iNumTeams; i++ )
		{
			if ( g_TeamInfo[i].players < 1 )
				continue;

			if ( !g_TeamInfo[i].already_drawn && g_TeamInfo[i].frags >= highest_frags )
			{
				if ( g_TeamInfo[i].frags > highest_frags || g_TeamInfo[i].deaths < lowest_deaths )
				{
					best_team = i;
					lowest_deaths = g_TeamInfo[i].deaths;
					highest_frags = g_TeamInfo[i].frags;
				}
			}
		}

		// draw the best team on the scoreboard
		if ( !best_team )
			break;

		// Put this team in the sorted list
		_tablePanel->m_iSortedRows[ _tablePanel->m_iRows ] = best_team;
		_tablePanel->m_iIsATeam[ _tablePanel->m_iRows ] = TEAM_YES;
		g_TeamInfo[best_team].already_drawn = TRUE;  // set the already_drawn to be TRUE, so this team won't get sorted again
		_tablePanel->m_iRows++;

		// Now sort all the players on this team
		SortPlayers( 0, g_TeamInfo[best_team].name );
	}

	// Now add all the spectators
	SortPlayers( TEAM_SPECTATORS, NULL );

	// Now add all the players who aren't in a team yet
	SortPlayers( TEAM_UNASSIGNED, NULL );
}

//-----------------------------------------------------------------------------
// Purpose: Sort a list of players
//-----------------------------------------------------------------------------
void ScorePanel::SortPlayers( int iTeam, char *team )
{
	bool bCreatedTeam = false;

	// draw the players, in order,  and restricted to team if set
	while ( 1 )
	{
		// Find the top ranking player
		int highest_frags = -99999;	int lowest_deaths = 99999;
		int best_player;
		best_player = 0;

		for ( int i = 1; i < MAX_PLAYERS; i++ )
		{
			if ( _tablePanel->m_bHasBeenSorted[i] == false && g_PlayerInfoList[i].name && g_PlayerExtraInfo[i].frags >= highest_frags )
			{
				cl_entity_t *ent = gEngfuncs.GetEntityByIndex( i );

				if ( ent && ((iTeam == TEAM_SPECTATORS && g_IsSpectator[i] != 0) || (iTeam != TEAM_SPECTATORS && !(team && stricmp(g_PlayerExtraInfo[i].teamname, team)))) )  
				{
					extra_player_info_t *pl_info = &g_PlayerExtraInfo[i];
					if ( pl_info->frags > highest_frags || pl_info->deaths < lowest_deaths )
					{
						best_player = i;
						lowest_deaths = pl_info->deaths;
						highest_frags = pl_info->frags;
					}
				}
			}
		}

		if ( !best_player )
			break;

		// If we haven't created the Team yet, do it first
		if (!bCreatedTeam && iTeam)
		{
			_tablePanel->m_iIsATeam[ _tablePanel->m_iRows ] = iTeam;
			_tablePanel->m_iRows++;

			bCreatedTeam = true;
		}

		// Put this player in the sorted list
		_tablePanel->m_iSortedRows[ _tablePanel->m_iRows ] = best_player;
		_tablePanel->m_bHasBeenSorted[ best_player ] = true;
		_tablePanel->m_iRows++;
	}
}

//-----------------------------------------------------------------------------
// Purpose: Recalculate the existing teams in the match
//-----------------------------------------------------------------------------
void ScorePanel::RebuildTeams()
{
	// clear out player counts from teams
	for ( int i = 1; i <= m_iNumTeams; i++ )
	{
		g_TeamInfo[i].players = 0;
	}

	// rebuild the team list
	gViewPort->GetAllPlayersInfo();
	m_iNumTeams = 0;
	for ( i = 1; i < MAX_PLAYERS; i++ )
	{
		if ( g_PlayerInfoList[i].name == NULL )
			continue;

		if ( g_PlayerExtraInfo[i].teamname[0] == 0 )
			continue; // skip over players who are not in a team

		// is this player in an existing team?
		for ( int j = 1; j <= m_iNumTeams; j++ )
		{
			if ( g_TeamInfo[j].name[0] == '\0' )
				break;

			if ( !stricmp( g_PlayerExtraInfo[i].teamname, g_TeamInfo[j].name ) )
				break;
		}

		if ( j > m_iNumTeams )
		{ // they aren't in a listed team, so make a new one
			// search through for an empty team slot
			for ( int j = 1; j <= m_iNumTeams; j++ )
			{
				if ( g_TeamInfo[j].name[0] == '\0' )
					break;
			}
			m_iNumTeams = max( j, m_iNumTeams );

			strncpy( g_TeamInfo[j].name, g_PlayerExtraInfo[i].teamname, MAX_TEAM_NAME );
			g_TeamInfo[j].players = 0;
		}

		g_TeamInfo[j].players++;
	}

	// clear out any empty teams
	for ( i = 1; i <= m_iNumTeams; i++ )
	{
		if ( g_TeamInfo[i].players < 1 )
			memset( &g_TeamInfo[i], 0, sizeof(team_info_t) );
	}

	// Update the scoreboard
	Update();
}

//-----------------------------------------------------------------------------
// Purpose: Setup highlights for player names in scoreboard
//-----------------------------------------------------------------------------
void ScorePanel::DeathMsg( int killer, int victim )
{
	// if we were the one killed,  or the world killed us, set the scoreboard to indicate suicide
	if ( victim == m_iPlayerNum || killer == 0 )
	{
		_tablePanel->m_iLastKilledBy = killer ? killer : m_iPlayerNum;
		_tablePanel->m_fLastKillTime = gHUD.m_flTime + 10;	// display who we were killed by for 10 seconds

		if ( killer == m_iPlayerNum )
			_tablePanel->m_iLastKilledBy = m_iPlayerNum;
	}
}

