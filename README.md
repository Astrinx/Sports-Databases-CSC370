# Sports-Databases-CSC370
A database of NHL seasons, the games played each season, the teams that played,
and the players on those teams, including their per-game stats.

## Repository layout
| Path | What it is |
|------|------------|
| `docs/ERD.png` | Entity Relationship Diagram |
| `docs/bcnf` | BCNF analysis |
| `sql/schema.sql` | SQL DDL (MySQL 8.0.16+) |
| `CHANGELOG.md` | Every design change and why |

## How to run
```
mysql -u <user> -p <database> < sql/schema.sql
```

---

## Sprint kick-off (done)
- Created the ERD
- Implemented it in SQL DDL
- Normalized it into BCNF

## Sprint 1 goals
- Check the ERD against the eight design criteria
- Compare our design in 3NF and 4NF
- Re-evaluate our weak entities
~~- Insert and delete data based on query predicates (SQL DML)~~ (moved to Sprint 2 goals)

---

## 1. Design criteria
| Criterion | What we changed or checked |
|-----------|----------------------------|
| Completeness | Covers seasons, games, teams, arenas, players, stints, and skater/goalie stats |
| Correctness | winner now points only to Teams (a team can win many seasons); stats split by player type |
| Minimality | Removed plays_for and played_in (both could be derived); derived attributes are dashed |
| Expressiveness | Skaters and Goalies are subsets of Players, so no columns sit empty |
| Readability | Consistent notation; derived = dashed, composite = yellow |
| Self-explanation | Relationship names read as sentences (Teams plays_at Arena) |
| Extensibility | New player types or stats can be added as new subsets or relationships |
| Normality | Arena split out of Teams because arena_name → city (see section 3) |

## 2. Weak entities
- **Stats (changed):** were weak entities, now many–many relationships between Skaters/Goalies and Games. A stat line is identified by (player_id, game_id), so it doesn't need to be a weak entity.
- **Player_History (kept weak):** it has no key of its own. Key = player_id + team_id + start_date. We kept it weak instead of making it a Players–Teams relationship because a relationship can only hold each (player, team) pair once, and a player can return to the same team twice.

## 3. Normal forms
Functional dependencies (FDs) for each table. Every left side is a key, so each table is in BCNF.

| Table | FDs |
|-------|-----|
| Arenas | arena_name → city |
| Teams | team_id → name, abbreviation, arena_name ; abbreviation → team_id ; name → team_id |
| Seasons | season_year_start → season_start_date, winning_team_id |
| Players | player_id → all ; (draft_year, draft_round, draft_pick) → player_id |
| Skaters | player_id → position, shoots |
| Goalies | player_id → catches |
| Player_History | (player_id, team_id, start_date) → end_date, jersey_number |
| Games | game_id → all ; (home_team_id, game_date) → game_id ; (away_team_id, game_date) → game_id |
| Skater_Game_Stats | (player_id, game_id) → goals, assists, plus_minus, pim |
| Goalie_Game_Stats | (player_id, game_id) → shots_against, saves, decision |

- **3NF:** every BCNF table is also in 3NF, so no table changes.
- **4NF:** no multivalued dependencies, because each player has one nationality and one position. If we later allow several, those move to their own tables (e.g. Player_Nationality).

## 4. Constraints the ERD can't show
- A player can't be both a Skater and a Goalie.
- A player's stints can't overlap.
- A player with stats in a game must have been on one of its two teams that day.
- A game's date falls inside its season.
- home_team_id ≠ away_team_id (CHECK in schema.sql).

---

## Next sprint
- Add game_type (regular / playoff) to Games
- Write queries over the stats
- Insert and delete data based on query predicates (SQL DML)
