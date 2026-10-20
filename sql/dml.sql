-- =============================================================
-- NHL Database: ddl (run after schema.sql)
-- Sample data: names are real, stats are made up.
-- =============================================================

INSERT INTO Arenas (arena_name, city) VALUES
  ('Rogers Arena',     'Vancouver'),
  ('Rogers Place',     'Edmonton'),
  ('Scotiabank Arena', 'Toronto');

INSERT INTO Teams (team_id, name, abbreviation, arena_name) VALUES
  (1, 'Vancouver Canucks',   'VAN', 'Rogers Arena'),
  (2, 'Edmonton Oilers',     'EDM', 'Rogers Place'),
  (3, 'Toronto Maple Leafs', 'TOR', 'Scotiabank Arena');

INSERT INTO Seasons (season_year_start, season_start_date) VALUES
  (2024, '2024-10-04');

INSERT INTO Players (player_id, first_name, last_name) VALUES
  (1, 'Quinn',    'Hughes'),
  (2, 'Elias',    'Pettersson'),
  (3, 'Connor',   'McDavid'),
  (4, 'Thatcher', 'Demko'),
  (5, 'Stuart',   'Skinner'),
  (6, 'Auston',   'Matthews');

INSERT INTO Skaters (player_id, position, shoots) VALUES
  (1, 'D', 'L'), (2, 'C', 'L'), (3, 'C', 'L'), (6, 'C', 'L');

INSERT INTO Goalies (player_id, catches) VALUES
  (4, 'L'), (5, 'L');

INSERT INTO Player_History (player_id, team_id, start_date) VALUES
  (1, 1, '2018-10-01'),
  (2, 1, '2018-10-01'),
  (3, 2, '2015-10-01'),
  (4, 1, '2014-10-01'),
  (5, 2, '2019-10-01'),
  (6, 3, '2016-10-01');

-- Game 3 has not been played yet (scores are NULL)
INSERT INTO Games (game_id, game_date, home_team_id, away_team_id, home_score, away_score, season_year_start) VALUES
  (1, '2024-10-10', 1, 2, 3, 2, 2024),
  (2, '2024-10-12', 2, 3, 4, 1, 2024),
  (3, '2024-10-14', 3, 1, NULL, NULL, 2024);

INSERT INTO Skater_Game_Stats (player_id, game_id, goals, assists, plus_minus, pim) VALUES
  (1, 1, 1, 1,  1, 0),
  (2, 1, 1, 0,  1, 0),
  (3, 1, 1, 1, -1, 0),
  (3, 2, 2, 1,  2, 0),
  (6, 2, 1, 0, -1, 0);

INSERT INTO Goalie_Game_Stats (player_id, game_id, shots_against, saves, decision) VALUES
  (4, 1, 30, 28, 'W'),
  (5, 1, 28, 25, 'L'),
  (5, 2, 20, 19, 'W');



ROLLBACK;
