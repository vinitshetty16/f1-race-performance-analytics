# Data Dictionary

Detailed column descriptions for all 14 source tables.
All tables live in Snowflake `F1_DB.RAW` schema.

---

## results (26,759 rows)
Core table — one row per driver per race.

| Column | Type | Description |
|---|---|---|
| resultId | INT | Primary key |
| raceId | INT | Foreign key → races |
| driverId | INT | Foreign key → drivers |
| constructorId | INT | Foreign key → constructors |
| grid | INT | Starting grid position. 0 = pit lane start |
| position | VARCHAR | Finish position. NULL for DNFs — use positionOrder |
| positionOrder | INT | Always populated. Use this for analysis |
| points | FLOAT | Championship points scored |
| laps | INT | Laps completed |
| milliseconds | VARCHAR | Total race time in ms. NULL for DNFs and pre-2004 |
| fastestLapTime | VARCHAR | Driver fastest lap. Sparse before 2004 |
| statusId | INT | Foreign key → status |

---

## races (1,125 rows)
One row per race weekend.

| Column | Type | Description |
|---|---|---|
| raceId | INT | Primary key |
| year | INT | Season year |
| round | INT | Race number within season |
| circuitId | INT | Foreign key → circuits |
| name | VARCHAR | Official race name |
| date | VARCHAR | Race date |

---

## drivers (861 rows)
All drivers who have competed in F1.

| Column | Type | Description |
|---|---|---|
| driverId | INT | Primary key |
| driverRef | VARCHAR | URL-safe name slug |
| number | VARCHAR | Permanent driver number. NULL for older drivers |
| code | VARCHAR | 3-letter code e.g. HAM, VER |
| forename | VARCHAR | First name |
| surname | VARCHAR | Last name |
| dob | VARCHAR | Date of birth |
| nationality | VARCHAR | Driver nationality |

---

## constructors (212 rows)
All constructor/team entries.

| Column | Type | Description |
|---|---|---|
| constructorId | INT | Primary key |
| name | VARCHAR | Constructor name |
| nationality | VARCHAR | Team nationality |

Note: Lotus appears twice — two completely unrelated teams.

---

## status (139 rows)
Lookup table mapping statusId to finish reason.

| Column | Type | Description |
|---|---|---|
| statusId | INT | Primary key |
| status | VARCHAR | e.g. Finished, Engine, Accident, +1 Lap |

---

## lap_times (589,081 rows)
Individual lap times per driver per race.
Only available from 1996 onwards.

| Column | Type | Description |
|---|---|---|
| raceId | INT | Foreign key → races |
| driverId | INT | Foreign key → drivers |
| lap | INT | Lap number |
| position | INT | Track position on that lap |
| time | VARCHAR | Lap time as string e.g. 1:32.456 |
| milliseconds | INT | Lap time in milliseconds |

---

## pit_stops (11,371 rows)
Pit stop records. Only available from 2011 onwards.

| Column | Type | Description |
|---|---|---|
| raceId | INT | Foreign key → races |
| driverId | INT | Foreign key → drivers |
| stop | INT | Stop number within race (1st stop, 2nd stop etc) |
| lap | INT | Lap on which pit stop occurred |
| duration | VARCHAR | Pit stop duration as string |
| milliseconds | INT | Pit stop duration in milliseconds |

---

## qualifying (10,494 rows)
Qualifying session lap times.

| Column | Type | Description |
|---|---|---|
| qualifyId | INT | Primary key |
| raceId | INT | Foreign key → races |
| driverId | INT | Foreign key → drivers |
| position | INT | Qualifying classification |
| q1 | VARCHAR | Q1 lap time. NULL if no time set |
| q2 | VARCHAR | Q2 lap time. NULL if knocked out in Q1 |
| q3 | VARCHAR | Q3 lap time. NULL if knocked out in Q2 |

---

## Full documentation

For full project documentation including EDA findings,
SQL query log and AI insight log see:

[Notion Project Documentation →](https://www.notion.so/F1-Analytics-Project-327cd3d3755e803784b9fa14aee1429a)
