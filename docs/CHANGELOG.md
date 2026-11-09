## ERD
### Sprint 1
- Split Players into Skaters and Goalie
- Split stats into Records Skater Stats and Records Goalie Stats
- Save %, Goals Against, Age, end_year marked as derived
- winner now points only to Teams (a team can win many seasons)
- Removed plays_for (duplicate: current team = Player_History row with no end_date)
- Removed played_in (duplicate: teams in a season can be found from Games)
- Added Arena (arena_name, City) with Plays_at; moved City off Teams (city depends on arena, not team)

### Sprint 2
- Added Game_Days entity (game_date -> season); Games are played_on a Game_Day
- Added game_type (regular / playoff) to Games
- Added constraint: every game is played on a Game_Day that belongs to a season

## Schema
### Sprint 1
- Added Arenas table
- Teams: removed city, arena_name now references Arenas, name is now UNIQUE
- Players: removed current_team_id
- Removed Played_In table
- Seasons: renamed winner_team_id to winning_team_id
- Goalie_Game_Stats: decision is NULL when a goalie played but wasn't the goalie of record
- Added DROP TABLE lines so the script can be re-run from scratch
- Added constraint on jersey #99

### Sprint 2
- Added Game_Days table to fix a BCNF violation in Games (game_date -> season_year_start, and game_date is not a key of Games)
- Added game_type (regular / playoff) to Games
- Added rule 6e; rules that used Games.season_year_start now reach the season through Game_Days
- dml.sql: added playoff games and stats for two EDM - VAN games

## SQL scripts
### Sprint 2 Goals
- queries.sql Q1: group by player_id only + HAVING, to show FD attributes (player_id -> name) and WHERE vs HAVING
- queries.sql Q3, Q4: Player_History join now matches the stint covering the game date, so a traded player's stats count only for the team he was on that day
- queries.sql Q7: added WHERE EXISTS (playoff skaters only), the existential condition on top of the average of averages
- queries.sql Q8: added player_id to SELECT DISTINCT, so two different players with the same name are not merged
- queries.sql Q9: LEFT JOIN keeps skaters with no playoff games (Matthews) with NULL playoff valuesTS and GROUP BY / HAVING, inside a transaction that is rolled back (teaching-team feedback from Sprint 1)
