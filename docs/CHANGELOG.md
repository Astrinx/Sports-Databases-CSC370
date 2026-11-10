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
### Sprint 2
- queries.sql (Q1–Q9): scoring leaders, goalie save percentage, regular-season point leader per team, team scoring summary (COUNT DISTINCT), rematches (self-join of Games), points per game over a span of games, average of averages (double aggregation), DISTINCT, regular season vs playoffs
- modify.sql (M1–M4): INSERT ... SELECT with a join predicate, DELETE with a subquery, DELETE with NOT EXISTS, and DELETE with a GROUP BY / HAVING subquery, all inside a transaction that is rolled back (teaching-team feedback from Sprint 1)
- Known query issues (Q1, Q3, Q4, Q7, Q8, Q9) are listed in the README with planned Sprint 3 fixes