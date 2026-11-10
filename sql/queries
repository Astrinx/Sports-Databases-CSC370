-- =============================================================
-- NHL Database: stats queries (run after schema.sql and dml.sql,
-- and before modify.sql, which changes the data)
-- =============================================================

-- -------------------------------------------------------------
-- Q1: Scoring leaders for the season (regular-season games only)
-- Multi-table JOIN + GROUP BY. first_name and last_name can go in the
-- SELECT because player_id determines them (player_id -> name).
-- points = goals + assists; ties broken by goals, then last name.
-- -------------------------------------------------------------
SELECT p.first_name, p.last_name,
       COUNT(*)                  AS games_played,
       SUM(s.goals)              AS goals,
       SUM(s.assists)            AS assists,
       SUM(s.goals + s.assists)  AS points
FROM Skater_Game_Stats AS s
JOIN Players AS p ON (p.player_id = s.player_id)
JOIN Games   AS g ON (g.game_id   = s.game_id)
JOIN Game_Days AS d ON (d.game_date = g.game_date)
WHERE d.season_year_start = 2024
  AND g.game_type = 'regular'
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY points DESC, goals DESC, p.last_name;

-- -------------------------------------------------------------
-- Q2: Goalie save percentage for the season (regular season only)
-- Season save % = total saves / total shots against.
-- WHERE filters rows before grouping; HAVING filters groups after.
-- -------------------------------------------------------------
SELECT p.first_name, p.last_name,
       COUNT(*)                                       AS games_played,
       SUM(gs.shots_against)                          AS shots_against,
       SUM(gs.saves)                                  AS saves,
       SUM(gs.goals_against)                          AS goals_against,
       SUM(gs.saves) / SUM(gs.shots_against)          AS season_save_pct
FROM Goalie_Game_Stats AS gs
JOIN Players AS p ON (p.player_id = gs.player_id)
JOIN Games   AS g ON (g.game_id   = gs.game_id)
JOIN Game_Days AS d ON (d.game_date = g.game_date)
WHERE d.season_year_start = 2024
  AND g.game_type = 'regular'
GROUP BY p.player_id, p.first_name, p.last_name
HAVING SUM(gs.shots_against) > 0
ORDER BY season_save_pct DESC;

-- -------------------------------------------------------------
-- Q3: Regular-season point leader on each team.
-- Only regular-season games count
-- The subquery lists every skater's point total on the
-- same team; >= ALL keeps the skater whose total is at least as big as
-- all of them. Ties return every tied skater.
-- -------------------------------------------------------------
SELECT t.abbreviation, p.last_name, SUM(s.goals + s.assists) AS points
FROM Skater_Game_Stats AS s
JOIN Players AS p ON (p.player_id = s.player_id)
JOIN Games AS g ON (g.game_id = s.game_id)
JOIN Player_History AS ph ON (ph.player_id = s.player_id)
JOIN Teams AS t ON (t.team_id = ph.team_id)
WHERE g.game_type = 'regular'
GROUP BY t.team_id, t.abbreviation, p.player_id, p.last_name
HAVING SUM(s.goals + s.assists) >= ALL (
  SELECT SUM(s2.goals + s2.assists)
  FROM Skater_Game_Stats AS s2
  JOIN Games AS g2 ON (g2.game_id = s2.game_id)
  JOIN Player_History AS ph2 ON (ph2.player_id = s2.player_id)
  WHERE ph2.team_id = t.team_id
    AND g2.game_type = 'regular'
  GROUP BY s2.player_id
)
ORDER BY t.abbreviation;

-- -------------------------------------------------------------
-- Q4: Team scoring summary (regular season).
-- Goals, different goal scorers and games with a goal, per team.
-- COUNT(DISTINCT s.player_id) counts each scorer once, however many games
-- he scored in. COUNT(DISTINCT s.game_id) counts each game once, however
-- many players scored in it.
-- -------------------------------------------------------------
SELECT t.abbreviation,
       SUM(s.goals)                 AS goals,
       COUNT(DISTINCT s.player_id)  AS different_scorers,
       COUNT(DISTINCT s.game_id)    AS games_with_a_goal
FROM Skater_Game_Stats AS s
JOIN Games AS g ON (g.game_id = s.game_id)
JOIN Player_History AS ph ON (ph.player_id = s.player_id)
JOIN Teams AS t ON (t.team_id = ph.team_id)
WHERE s.goals > 0
  AND g.game_type = 'regular'
GROUP BY t.team_id, t.abbreviation
ORDER BY goals DESC;

-- -------------------------------------------------------------
-- Q5: Rematches: pairs of games between the same two teams.
-- Games is joined to itself (a = the earlier game, b = the later one).
-- The same two teams can be home/away in either order, so the join
-- accepts both. a.game_date < b.game_date lists each pair once.
-- -------------------------------------------------------------
SELECT h.abbreviation AS team_1, v.abbreviation AS team_2,
       a.game_date AS first_game, b.game_date AS second_game
FROM Games AS a
JOIN Games AS b ON (a.game_date < b.game_date
               AND ((a.home_team_id = b.home_team_id AND a.away_team_id = b.away_team_id)
                 OR (a.home_team_id = b.away_team_id AND a.away_team_id = b.home_team_id)))
JOIN Teams AS h ON (h.team_id = a.home_team_id)
JOIN Teams AS v ON (v.team_id = a.away_team_id)
ORDER BY a.game_date, b.game_date;

-- -------------------------------------------------------------
-- Q6: Points per game for each skater over a span of games.
-- AVG(goals + assists) per player, only for games between the two dates.
-- WHERE filters the games first, then GROUP BY averages per player.
-- To look at another span, change the two dates.
-- -------------------------------------------------------------
SELECT p.first_name, p.last_name,
       COUNT(*)                    AS games,
       AVG(s.goals + s.assists)    AS points_per_game
FROM Skater_Game_Stats AS s
JOIN Players AS p ON (p.player_id = s.player_id)
JOIN Games   AS g ON (g.game_id   = s.game_id)
WHERE g.game_date >= '2024-10-10'
  AND g.game_date <= '2024-10-12'
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY points_per_game DESC, p.last_name;

-- -------------------------------------------------------------
-- Q7: Skaters whose points per game beat the average skater's points per game.
-- The inner query (subquery in FROM) gives one average per skater; the
-- scalar subquery averages those averages.
-- -------------------------------------------------------------
SELECT p.first_name, p.last_name, AVG(s.goals + s.assists) AS points_per_game
FROM Skater_Game_Stats AS s
JOIN Players AS p ON (p.player_id = s.player_id)
GROUP BY p.player_id, p.first_name, p.last_name
HAVING AVG(s.goals + s.assists) > (
  SELECT AVG(t.points_per_game)
  FROM (
    SELECT AVG(s2.goals + s2.assists) AS points_per_game
    FROM Skater_Game_Stats AS s2
    GROUP BY s2.player_id
  ) AS t
)
ORDER BY points_per_game DESC;

-- -------------------------------------------------------------
-- Q8: Which skaters have scored a goal this regular season?
-- McDavid scored in two games, so he has two matching stat lines.
-- Without DISTINCT he appears twice; with DISTINCT, once per player.
-- -------------------------------------------------------------
SELECT DISTINCT p.first_name, p.last_name
FROM Skater_Game_Stats AS s
JOIN Players AS p ON (p.player_id = s.player_id)
JOIN Games AS g ON (g.game_id = s.game_id)
WHERE s.goals > 0
  AND g.game_type = 'regular'
ORDER BY p.last_name;

-- -------------------------------------------------------------
-- Q9: Regular season vs playoffs.
-- Each subquery in FROM is one skater's points per game for one game_type;
-- the two are joined on player_id so each skater appears once, with both
-- numbers side by side. Skaters with no playoff games (Matthews) drop out.
-- -------------------------------------------------------------
SELECT r.last_name,
       r.points_per_game                      AS regular_ppg,
       po.points_per_game                     AS playoff_ppg,
       po.points_per_game - r.points_per_game AS change_in_playoffs
FROM (
  SELECT s.player_id, p.last_name, AVG(s.goals + s.assists) AS points_per_game
  FROM Skater_Game_Stats AS s
  JOIN Players AS p ON (p.player_id = s.player_id)
  JOIN Games   AS g ON (g.game_id   = s.game_id)
  WHERE g.game_type = 'regular'
  GROUP BY s.player_id, p.last_name
) AS r
JOIN (
  SELECT s.player_id, AVG(s.goals + s.assists) AS points_per_game
  FROM Skater_Game_Stats AS s
  JOIN Games AS g ON (g.game_id = s.game_id)
  WHERE g.game_type = 'playoff'
  GROUP BY s.player_id
) AS po ON (po.player_id = r.player_id)
ORDER BY change_in_playoffs DESC;