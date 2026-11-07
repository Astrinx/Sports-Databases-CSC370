## ERD
### Sprint 1
- Split Players into Skaters and Goalie 
- Split stats into Records Skater Stats and Records Goalie Stats
- Save %, Goals Against, Age, end_year marked as derived
- winner now points only to Teams (a team can win many seasons)
- Removed plays_for (duplicate: current team = Player_history row with no end_date)
- Removed played_in (duplicate: teams in a season can be found from Games)
- Added Arena (arena_name, City) with Plays_at; moved City off Teams (city depends on arena, not team)
### Sprint 2
- added Game_Days table
- added game types to Games
- Addded constraint ensuring every game played is played on a game_day that is contained in a season

## Schema
### Sprint 1
- Added Arenas table
- Teams: removed city, arena_name now references Arenas, name is now UNIQUE
- Players: removed current_team_id
- Removed Played_In table
- Seasons: renamed winner_team_id to winning_team_id
- Goalie_Game_Stats: decision is NULL when a goalie played but wasn't the goalie of record
- Added DROP TABLE lines so the script can be re-run from scratch
- Added Constraint on jersey #99

### Sprint 2
- added Game_days table to ensure 4nf on Games table
- added different game types (playoff/regular)