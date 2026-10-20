## ERD
- Split Players into Skaters and Goalie 
- Split stats into Records Skater Stats and Records Goalie Stats
- Save %, Goals Against, Age, end_year marked as derived
- winner now points only to Teams (a team can win many seasons)
- Removed plays_for (duplicate: current team = Player_history row with no end_date)
- Removed played_in (duplicate: teams in a season can be found from Games)
- Added Arena (arena_name, City) with Plays_at; moved City off Teams (city depends on arena, not team)
- Removed made_of to Seasons

## Schema
- Added Arenas table
- Teams: removed city, arena_name now references Arenas, name is now UNIQUE
- Players: removed current_team_id
- Removed Played_In table
- Seasons: renamed winner_team_id to winning_team_id
- Goalie_Game_Stats: decision is NULL when a goalie played but wasn't the goalie of record
- Added DROP TABLE lines so the script can be re-run from scratch