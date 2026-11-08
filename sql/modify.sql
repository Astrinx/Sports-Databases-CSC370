-- =============================================================
-- NHL Database: query-driven DML (run after schema.sql, dml.sql
-- and queries.sql)
-- Every INSERT/DELETE below picks its rows with a query predicate
-- (join, subquery, aggregate, NOT EXISTS), not hand-typed values.
-- Everything runs in ONE transaction that is rolled back at the end,
-- so the sample data is unchanged afterwards (change ROLLBACK to
-- COMMIT to keep the changes).
-- Demo: run each block with the SELECT before and after it.
-- =============================================================

START TRANSACTION;

-- -------------------------------------------------------------
-- M1. INSERT ... SELECT with a join predicate
-- Create empty stat lines for game 3 (TOR vs VAN, 2024-10-14), but
-- only for skaters whose stint covers the game date on either team.
-- end_date IS NULL = current stint (= NULL would never be true).
-- Expected: 0 -> 3 (Hughes, Pettersson for VAN; Matthews for TOR)
-- -------------------------------------------------------------
SELECT COUNT(*) AS lines_game_3 FROM Skater_Game_Stats WHERE game_id = 3;

INSERT INTO Skater_Game_Stats (player_id, game_id)
SELECT ph.player_id, g.game_id
FROM Games AS g
JOIN Player_History AS ph
  ON ph.team_id IN (g.home_team_id, g.away_team_id)
 AND ph.start_date <= g.game_date
 AND (ph.end_date IS NULL OR ph.end_date >= g.game_date)
JOIN Skaters AS sk ON (sk.player_id = ph.player_id)
WHERE g.game_id = 3;

SELECT COUNT(*) AS lines_game_3 FROM Skater_Game_Stats WHERE game_id = 3;

-- -------------------------------------------------------------
-- M2. DELETE with a subquery predicate
-- Game 3 was cancelled: remove every game that was never played
-- (NULL score). Stats first, then the game, because of the FKs.
-- Expected games: 5 -> 4
-- -------------------------------------------------------------
SELECT COUNT(*) AS games FROM Games;

DELETE FROM Skater_Game_Stats
WHERE game_id IN (SELECT game_id FROM Games WHERE home_score IS NULL);

DELETE FROM Goalie_Game_Stats
WHERE game_id IN (SELECT game_id FROM Games WHERE home_score IS NULL);

DELETE FROM Games WHERE home_score IS NULL;

SELECT COUNT(*) AS games FROM Games;

-- -------------------------------------------------------------
-- M3. DELETE with NOT EXISTS
-- After M2, 2024-10-14 is a game day with no games. Remove every
-- Game_Days row that no game is played on.
-- Expected game days: 5 -> 4
-- -------------------------------------------------------------
SELECT COUNT(*) AS game_days FROM Game_Days;

DELETE FROM Game_Days
WHERE NOT EXISTS (SELECT 1 FROM Games AS g
                  WHERE g.game_date = Game_Days.game_date);

SELECT COUNT(*) AS game_days FROM Game_Days;

-- -------------------------------------------------------------
-- M4. DELETE with an aggregate (GROUP BY / HAVING) subquery
-- Remove the stat lines of skaters with fewer than 2 total points.
-- MySQL error 1093 blocks a DELETE whose subquery reads the same
-- table, so the subquery is wrapped in a derived table (AS low).
-- Expected: removes Matthews' 1 line (1 point); 11 -> 10
-- -------------------------------------------------------------
SELECT COUNT(*) AS skater_lines FROM Skater_Game_Stats;

DELETE FROM Skater_Game_Stats
WHERE player_id IN (SELECT player_id
                    FROM (SELECT player_id
                          FROM Skater_Game_Stats
                          GROUP BY player_id
                          HAVING SUM(goals + assists) < 2) AS low);

SELECT COUNT(*) AS skater_lines FROM Skater_Game_Stats;

ROLLBACK;

-- After ROLLBACK everything is undone. Expected: 5 games, 5 game days, 11 lines
SELECT COUNT(*) AS games        FROM Games;
SELECT COUNT(*) AS game_days    FROM Game_Days;
SELECT COUNT(*) AS skater_lines FROM Skater_Game_Stats;
