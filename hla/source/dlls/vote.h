
#ifndef VOTE_H
#define VOTE_H


void InitVote( edict_t *pVoter, int vote_type, const char *cmd, int ban_id  );
void CycleInitialPlayers ( const char *initializer, int vote_type, const char *cmd);
void CycleFinalPlayers ( int result );
int  CalculateVoteTotals ( void );
void ResetVote( void );
void TallyVote( void );
void ExecuteVote( void );		

#endif
