# Source Tables

All tables loaded into Snowflake `F1_DB.RAW` schema.
Data source: Ergast Motor Racing Database via Kaggle.

| Table | Rows | Description |
|---|---|---|
| circuits | 77 | All F1 circuits ever used |
| races | 1,125 | Every race 1950–2024 |
| drivers | 861 | All drivers in F1 history |
| constructors | 212 | All constructor entries |
| results | 26,759 | Race result per driver per race |
| status | 139 | Finish status lookup |
| driver_standings | 34,863 | Championship standings after each race |
| constructor_standings | 13,391 | Constructor standings after each race |
| constructor_results | 12,625 | Points per constructor per race |
| qualifying | 10,494 | Qualifying session times Q1/Q2/Q3 |
| lap_times | 589,081 | Individual lap times from 1996 |
| pit_stops | 11,371 | Pit stop records from 2011 |
| sprint_results | 360 | Sprint race results from 2021 |
| seasons | 75 | Season list 1950–2024 |

## Known Data Issues

- `\N` string nulls throughout raw data — handled via NULLIF() in views
- Pit stop data only from 2011 — excluded from main analysis scope
- Lap time data only from 1996 — not 1950
- Grid = 0 entries exist — pit lane starters, excluded from analysis
- Constructor name "Lotus" refers to two completely unrelated teams
- `results.position` is NULL for all DNF entries — use `positionOrder` instead
