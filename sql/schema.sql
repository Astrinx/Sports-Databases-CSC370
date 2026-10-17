-- This schema is for a hockey database that tracks teams, seasons, games, players, and their statistics.

-- This table stores information about the teams in the league, including their name, abbreviation, city, and arena name.
CREATE TABLE Teams(
    team_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE, -- NOT NULL and UNIQUE to avoid duplicate team names
    abbreviation CHAR(3) NOT NULL UNIQUE, -- NOT NULL and UNIQUE to avoid duplicate abbreviations
    city VARCHAR(50),
    arena_name VARCHAR(50)
);

-- This table stores information about the seasons in the league, including the year the season started, the start date of the season, and the team that won the Presidents' Trophy for that season.
CREATE TABLE Seasons(
    season_year_start INT PRIMARY KEY,
    season_start_date DATE,
    winning_team INT NULL REFERENCES Teams(team_id) -- NULL until the season is decided
);

-- This table stores information about the games played in the league, including the date of the game, the scores for the home and away teams, and references to the teams that played in the game and the season in which the game was played.
CREATE TABLE Games(
    game_id INT PRIMARY KEY,
    game_date DATE,
    home_score INT,
    away_score INT,
    home_team_id INT NOT NULL,        -- Can't be null because every game must have a home team
    away_team_id INT NOT NULL,        -- Can't be null because every game must have an away team
    season_year_start INT NOT NULL,
    FOREIGN KEY (home_team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES Teams(team_id),
    FOREIGN KEY (season_year_start) REFERENCES Seasons(season_year_start),
    CHECK (home_team_id <> away_team_id)  -- Can't be the same team for home and away
);

-- This table stores information about the players in the league, including their name, nickname, birth date, height, weight, nationality, draft information, and the team they currently play for.
CREATE TABLE Players(
    player_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,     -- Last and first name cannot be null
    nickname VARCHAR(50),
    birth_date DATE,
    height INT,
    weight INT,
    nationality VARCHAR(50),
    draft_year INT,
    draft_round INT,
    draft_pick INT,
    current_team_id INT REFERENCES Teams(team_id) -- NULL if the player is a free agent
);

-- Adding skater and goalie subsets
-- Subset 1: Skaters
CREATE_TABLE Skaters (
    player_id INT PRIMARY KEY,
    position VARCHAR(5) NOT NULL,       -- ('C') for center, ('LW') for left wing, ('RW') for right wing, ('D') for defence       
    Shoots Char(1),                     -- ('L') for left, ('R') for right
    FOREIGN KEY (player_id) REFENCES Players(player_id),
    CHECK (position in ('C', 'LW', 'RW', 'D')),
    CHECK (shoots in ('L', 'R'))
)

-- Subset 2: Goalies
CREATE_TABLE Goalies (
    player_id INT PRIMARY KEY,
    catches CHAR (1),                   -- ('L') for left, ('R') for right
    FOREIGN KEY (player_id) REFERENCES Players(player_id),
    CHECK (catcehs IN ('L', 'R'))
)

-- This table stores information about the history of players in the league, including the teams they have played for, the dates they played for those teams, their position, and their jersey number.
CREATE TABLE Player_History(
    player_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    team_id INT NOT NULL, 
    jersey_number INT,
    -- position VARCHAR(20), -> moved to their own entities as player subsets
    PRIMARY KEY (player_id, start_date)
    FOREIGN KEY (player_id) REFERENCES Players(player_id)
    FOREIGN KEY (team_id) REFERENCES Players(player_id)
);

-- -- This table stores information about the statistics of players in the league, including the number of goals, assists, penalty minutes, and plus/minus rating for each player in each game they played.
-- CREATE TABLE Game_Stats(
--     game_id INT NOT NULL REFERENCES Games(game_id),
--     player_id INT NOT NULL REFERENCES Players(player_id),
--     goals INT DEFAULT 0,
--     assists INT DEFAULT 0,
--     pims INT DEFAULT 0,
--     plus_minus INT DEFAULT 0,
--     PRIMARY KEY (game_id, player_id)
-- );

-- Create two new tables for the many-to-many relationships between player subsets and games played
-- The Tables are relationships with attributes recording players stats from games played in


-- Relationship with attributes: Skaters stats
CREATE_TABLE Skater_Stats (
    game_id INT NOT NULL
    player_id INT NOT NULL
    goals INT DEFAULT 0,
    assists INT DEFAULT 0, 
    pim INT DEFAULT 0, 
    plus_minus INT DEFAULT 0, 
    PRIMARY KEY (game_id, player_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (player_id) REFERENCES Skaters(player_id)
)

-- Relationship with attributes: Goalie stats
CREATE_TABLE Skater_Stats (
    game_id INT NOT NULL
    player_id INT NOT NULL
    shots_against INT DEFAULT 0,
    saves INT DEFAULT 0, 
    goals_against INT DEFAULT 0, 
    wins INT DEFAULT 0, 
    PRIMARY KEY (game_id, player_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id),
    FOREIGN KEY (player_id) REFERENCES Skaters(player_id)
)

-- This table stores information about the teams that played in each season, including the team ID and the season year start.
CREATE TABLE Played_in(
    team_id INT NOT NULL REFERENCES Teams(team_id),
    season_year_start INT NOT NULL REFERENCES Seasons(season_year_start),
    PRIMARY KEY (team_id, season_year_start)
);
