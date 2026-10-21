-- =============================================================
-- NHL Database: schema 
-- =============================================================

-- Drop old tables so this script can be re-run from scratch (otherwise CREATE TABLE fails with 'table already exists' error).
-- Order matters; tables with foreign keys are dropped before the tables they reference.


DROP TABLE IF EXISTS Played_In;
DROP TABLE IF EXISTS Goalie_Game_Stats;
DROP TABLE IF EXISTS Skater_Game_Stats;
DROP TABLE IF EXISTS Games;
DROP TABLE IF EXISTS Player_History;
DROP TABLE IF EXISTS Goalies;
DROP TABLE IF EXISTS Skaters;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Seasons;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Arenas;

-- -------------------------------------------------------------
-- Strong entity: Arenas (new). Split out of Teams because
-- arena_name -> city was a non-key FD inside Teams (Normality).
-- -------------------------------------------------------------
CREATE TABLE Arenas (
  arena_name  VARCHAR(80)  NOT NULL,
  city        VARCHAR(50)  NOT NULL,
  PRIMARY KEY (arena_name)
 );

-- -------------------------------------------------------------
-- Strong entity: Teams
-- plays_at: many-one Teams -> Arenas (city now lives on Arenas)
-- -------------------------------------------------------------
CREATE TABLE Teams (
  team_id       INT          NOT NULL,
  name          VARCHAR(50)  NOT NULL,
  abbreviation  CHAR(3)      NOT NULL,
  arena_name    VARCHAR(80)  NULL,          -- plays_at (at most one arena)
  PRIMARY KEY (team_id),
  UNIQUE (abbreviation),                    -- second candidate key
  UNIQUE (name),                            -- third candidate key
  FOREIGN KEY (arena_name) REFERENCES Arenas(arena_name)
);

-- -------------------------------------------------------------
-- Strong entity: Seasons
-- winner: many-one Seasons -> Teams (each season has <= 1 winner)
-- end_year is derived (dashed in ERD) -> generated column, not stored
-- -------------------------------------------------------------
CREATE TABLE Seasons (
  season_year_start  INT   NOT NULL,
  season_start_date  DATE  NOT NULL,
  end_year           INT   GENERATED ALWAYS AS (season_year_start + 1) VIRTUAL,
  winning_team_id     INT   NULL,              -- NULL until the season ends
  PRIMARY KEY (season_year_start),
  FOREIGN KEY (winning_team_id) REFERENCES Teams(team_id)
);

-- -------------------------------------------------------------
-- Strong entity: Players
-- name, physical, draft are composite attributes -> flattened
-- age is derived from birth_date -> not stored (compute in queries)
-- current team = the Player_History row with end_date IS NULL
-- -------------------------------------------------------------
CREATE TABLE Players (
  player_id        INT          NOT NULL,
  first_name       VARCHAR(40)  NOT NULL,
  last_name        VARCHAR(40)  NOT NULL,
  nickname         VARCHAR(40),
  height_cm        SMALLINT,
  weight_kg        SMALLINT,
  nationality      VARCHAR(40),
  birth_date       DATE,
  draft_year       SMALLINT,                  -- NULL = undrafted
  draft_round      TINYINT,
  draft_pick       SMALLINT,
  PRIMARY KEY (player_id),
  UNIQUE (draft_year, draft_round, draft_pick),   -- second key (NULLs allowed)
  CHECK (height_cm IS NULL OR height_cm > 0),
  CHECK (weight_kg IS NULL OR weight_kg > 0)
);

-- -------------------------------------------------------------
-- Subsets of Players (isa): PK is also the FK to the parent
-- -------------------------------------------------------------
CREATE TABLE Skaters (
  player_id  INT      NOT NULL,
  position   ENUM('C','LW','RW','D') NOT NULL,
  shoots     ENUM('L','R'),
  PRIMARY KEY (player_id),
  FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

CREATE TABLE Goalies (
  player_id  INT      NOT NULL,
  catches    ENUM('L','R'),
  PRIMARY KEY (player_id),
  FOREIGN KEY (player_id) REFERENCES Players(player_id)
);

-- -------------------------------------------------------------
-- Weak entity: Player_History
-- Supported by Has (-> Players) AND stint_with (-> Teams), both
-- double diamonds, so its key = player_id + team_id + start_date
-- -------------------------------------------------------------
CREATE TABLE Player_History (
  player_id      INT      NOT NULL,
  team_id        INT      NOT NULL,
  start_date     DATE     NOT NULL,           -- partial key
  end_date       DATE     NULL,               -- NULL = current stint
  jersey_number  TINYINT,
  PRIMARY KEY (player_id, team_id, start_date),
  FOREIGN KEY (player_id) REFERENCES Players(player_id),
  FOREIGN KEY (team_id)   REFERENCES Teams(team_id),
  CHECK (end_date IS NULL OR end_date >= start_date),
  CHECK (jersey_number IS NULL OR jersey_number BETWEEN 0 AND 99),
  CHECK (jersey_number <> 99 OR start_date <= '2000-02-06')       -- No player can wear #99 after Greztky's number is retired
);

-- -------------------------------------------------------------
-- Strong entity: Games
-- Hosts / Visits: two many-one relationships to Teams (two roles)
-- made_of: many-one Games -> Seasons
-- Score is a composite attribute -> home_score, away_score
-- -------------------------------------------------------------
CREATE TABLE Games (
  game_id            INT   NOT NULL,
  game_date          DATE  NOT NULL,
  home_team_id       INT   NOT NULL,
  away_team_id       INT   NOT NULL,
  home_score         INT,                 -- NULL = not played yet
  away_score         INT,
  season_year_start  INT   NOT NULL,
  PRIMARY KEY (game_id),
  UNIQUE (home_team_id, game_date),           -- a team hosts <= 1 game per day
  UNIQUE (away_team_id, game_date),           -- a team visits <= 1 game per day
  FOREIGN KEY (home_team_id)      REFERENCES Teams(team_id),
  FOREIGN KEY (away_team_id)      REFERENCES Teams(team_id),
  FOREIGN KEY (season_year_start) REFERENCES Seasons(season_year_start),
  CHECK (home_team_id <> away_team_id),
  CHECK (home_score IS NULL OR home_score >= 0),
  CHECK (away_score IS NULL OR away_score >= 0)
);

-- -------------------------------------------------------------
-- Many-many: Records Skater Stats (Skaters x Games)
-- -------------------------------------------------------------
CREATE TABLE Skater_Game_Stats (
  player_id   INT      NOT NULL,
  game_id     INT      NOT NULL,
  goals       TINYINT  NOT NULL DEFAULT 0,
  assists     TINYINT  NOT NULL DEFAULT 0,
  plus_minus  TINYINT  NOT NULL DEFAULT 0,    -- can be negative
  pim         SMALLINT NOT NULL DEFAULT 0,    -- penalty minutes
  PRIMARY KEY (player_id, game_id),
  FOREIGN KEY (player_id) REFERENCES Skaters(player_id),
  FOREIGN KEY (game_id)   REFERENCES Games(game_id),
  CHECK (goals >= 0 AND assists >= 0 AND pim >= 0)
);

-- -------------------------------------------------------------
-- Many-many: Records Goalie Stats (Goalies x Games)
-- goals_against and save_pct are derived (dashed) -> generated
-- decision (Win/Loss on the ERD) is stored: deriving it would need
-- the goalie's team, which the stats row doesn't have
-- -------------------------------------------------------------
CREATE TABLE Goalie_Game_Stats (
  player_id      INT       NOT NULL,
  game_id        INT       NOT NULL,
  shots_against  SMALLINT  NOT NULL DEFAULT 0,
  saves          SMALLINT  NOT NULL DEFAULT 0,
  decision       ENUM('W','L','OTL') NULL,    -- NULL = played but not the goalie of record
  goals_against  SMALLINT  GENERATED ALWAYS AS (shots_against - saves) VIRTUAL,
  save_pct       DECIMAL(4,3) GENERATED ALWAYS AS
                   (CASE WHEN shots_against = 0 THEN NULL
                         ELSE saves / shots_against END) VIRTUAL,
  PRIMARY KEY (player_id, game_id),
  FOREIGN KEY (player_id) REFERENCES Goalies(player_id),
  FOREIGN KEY (game_id)   REFERENCES Games(game_id),
  CHECK (saves >= 0 AND shots_against >= 0 AND saves <= shots_against)
);
