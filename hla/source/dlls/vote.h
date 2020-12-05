
#ifndef VOTE_H
#define VOTE_H

#define VOTE_MAP		1
#define VOTE_GAME		2
#define VOTE_KICK		3
#define VOTE_BAN		4
#define VOTE_EXTEND		5
#define VOTE_MUTATOR	6


void InitVote( CBasePlayer *pPlayer, int vote_type, const char *cmd, int ban_id  );
void CycleInitialPlayers ( const char *initializer, int vote_type, const char *cmd);
void CycleFinalPlayers ( int result );
int  CalculateVoteTotals ( void );
void ResetVote( void );
void TallyVote( void );
void ExecuteVote( void );

void Vote( CBasePlayer *pPlayer, BOOL vote );		
void VoteMap( CBasePlayer *pPlayer, const char *szMap );
void VoteGame( CBasePlayer *pPlayer, const char *szGameMode );
void VoteKick( CBasePlayer *pPlayer, const char *szClient, BOOL BanMe );
void VoteExtend( CBasePlayer *pPlayer, const char *szMap );
void VoteMutator( CBasePlayer *pPlayer, const char *szMutator );

#endif
