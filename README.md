# Sports-Databases-CSC370
A database of NHL seasons, the games played each season, the teams that played,
and the players on those teams, including their per-game stats.

## Repository layout
| Path | What it is |
|------|------------|
| `docs/ERD_NHL_database.png` | Entity Relationship Diagram |
| `docs/bcnf` | BCNF analysis |
| `docs/constraints` | Relational Algebra Constraint rule list |
| `docs/CHANGELOG.md` | Every design change and why |
| `sql/schema.sql` | SQL DDL (MySQL 8.0.16+) |
| `sql/dml.sql` | Sample data |
| `sql/queries.sql` | Queries over the stats |
| `sql/modify.sql` | Query-driven INSERT / DELETE (in a rolled-back transaction) |

How to run:

Run in this order:
```
mysql -u <user> -p <database> < sql/schema.sql
mysql -u <user> -p <database> < sql/dml.sql
mysql -u <user> -p -t <database> < sql/queries.sql
mysql -u <user> -p -t <database> < sql/modify.sql
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
| Normality | Arena split out of Teams because arena_name → city; Game_Days split out of Games because game_date → season_year_start (see section 3) |

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
| Game_Days | game_date → season_year_start |
| Skater_Game_Stats | (player_id, game_id) → goals, assists, plus_minus, pim |
| Goalie_Game_Stats | (player_id, game_id) → shots_against, saves, decision |

- **3NF:** every BCNF table is also in 3NF, so no table changes.
- **BCNF fix (Sprint 2):** Games was not in BCNF, because game_date → season_year_start and game_date is not a key of Games (many games share a date). We moved the pair into Game_Days(game_date, season_year_start), and Games now points to it through game_date. Every table is now in BCNF.
- **4NF:** no multivalued dependencies, because each player has one nationality and one position. If we later allow several, those move to their own tables (e.g. Player_Nationality).

## 4. Constraints the ERD can't show
 - See docs/constraints for full list

---

## Sprint 2 goals (this sprint)
| Goal | Success criterion | Status | Evidence |
|------|-------------------|--------|----------|
| Add game_type (regular / playoff) to Games | `DESCRIBE Games` shows it; any other value is rejected | Done | schema.sql |
| Write queries over the stats | Each query returns the hand-checked result on our sample data | Done | queries.sql (Q1–Q9) |
| Insert and delete data based on query predicates | Each block's count changes as commented (0→3, 5→4, 5→4, 11→10) and is restored after ROLLBACK | Done | modify.sql |
| Teaching-team feedback: query-driven DML was missing | Same as above | Done | modify.sql |
| Teaching-team feedback: written normal forms didn't match the video | Games violation fixed with Game_Days; remaining exception stated | Done | docs/bcnf, section 3 |

How the queries cover this module's competencies:
- **Aggregation with FD attributes, WHERE and HAVING:** Q1 (groups by player_id only; names allowed since player_id → name)
- **Subquery aggregating aggregations with an existential condition:** Q7 (average of averages + EXISTS)
- **DML with complex predicates:** modify.sql (INSERT … SELECT, DELETE with IN, NOT EXISTS, GROUP BY / HAVING)

---

## Sprint 3 plan
Covers ACID Transactions, Basic Security and Analysing Query Algorithms. Each goal has an objective measure we can check at the end of the sprint.

| # | Goal | Competencies covered | Current limitation | Objective measure |
|---|------|----------------------|--------------------|-------------------|
| 1 | Record a game safely: one transaction, with triggers enforcing our written rules | Atomicity, Consistency, Triggers | A failure midway leaves half a game; rules 3a, 3b, 4a exist only in relational algebra | Forced error → row counts unchanged after ROLLBACK; 3 of 3 violating inserts rejected |
| 2 | User roles and a public view | Manages access, Creates views | Every user can change everything, and fans can see private data (birth dates) | fan's INSERT fails with error 1142; fan can read the view but not Players; a row inserted through the view appears in Players |
| 3 | Index player lookups and analyse the B+-tree | External memory model, Index design | Looking up a player by last name scans the whole table | EXPLAIN goes from type ALL (~5,000 rows) to ref (1 row); lookup, range and insert I/Os calculated and compared |
| 4 | Analyse and simplify our query plans | SQL to plans, Pushing selections, Simplifies queries | Q1 and Q7 have no plan analysis; Q7 uses a correlated subquery | 3 equivalent plans for Q1 return identical rows; row counts before/after pushing the selection; Q7 rewritten as a join with identical output |
| 5 | (stretch) Concurrency and recovery tests | Isolation, Durability | No tests of concurrent updates or data recovery | Anomaly appears at READ COMMITTED and not at REPEATABLE READ; row counts after log replay equal the counts before the drop |
| 6 | Move game_type to Game_Days | Normal forms (carry-over) | game_date → game_type still holds in Games | Every table's FDs have a key on the left side |
---

## Use of AI
We used Claude (Anthropic) to review our ERD and queries and to explain our errors. Our team made every design decision (Game_Days, game_type, which queries to write), and we ran and checked all SQL ourselves.
