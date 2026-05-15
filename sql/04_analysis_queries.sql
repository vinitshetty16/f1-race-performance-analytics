-- misc queries used during analysis and qa
-- not all of these ended up in the final dashboard
-- keeping them here for reference

USE DATABASE f1_db;
USE SCHEMA raw;

-- first thing i always run, just checking everything loaded properly
SELECT 'circuits' AS tbl, COUNT(*) FROM circuits
UNION ALL SELECT 'races', COUNT(*) FROM races
UNION ALL SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL SELECT 'constructors', COUNT(*) FROM constructors
UNION ALL SELECT 'status', COUNT(*) FROM status
UNION ALL SELECT 'results', COUNT(*) FROM results
UNION ALL SELECT 'driver_standings', COUNT(*) FROM driver_standings
UNION ALL SELECT 'constructor_standings', COUNT(*) FROM constructor_standings
UNION ALL SELECT 'constructor_results', COUNT(*) FROM constructor_results
UNION ALL SELECT 'qualifying', COUNT(*) FROM qualifying
UNION ALL SELECT 'lap_times', COUNT(*) FROM lap_times
UNION ALL SELECT 'pit_stops', COUNT(*) FROM pit_stops
UNION ALL SELECT 'sprint_results', COUNT(*) FROM sprint_results
UNION ALL SELECT 'seasons', COUNT(*) FROM seasons
ORDER BY tbl;

-- checking the \N null issue - how many are there in results
SELECT
    COUNT(CASE WHEN position = '\\N' THEN 1 END) AS null_positions,
    COUNT(CASE WHEN milliseconds = '\\N' THEN 1 END) AS null_ms,
    COUNT(CASE WHEN fastestlaptime = '\\N' THEN 1 END) AS null_fastestlap
FROM raw.results;

-- checking grid = 0 entries (pit lane starters)
-- decided to exclude these from analysis
SELECT grid, COUNT(*) FROM raw.results
WHERE grid = 0
GROUP BY grid;

-- q1 sanity check - pole to win conversion
-- should be around 40-45%
SELECT
    ROUND(
        COUNT(CASE WHEN grid = 1 AND positionorder = 1 THEN 1 END) * 100.0
        / COUNT(CASE WHEN grid = 1 THEN 1 END), 1
    ) AS pole_win_pct
FROM raw.results;

-- q2 - checking status breakdown, needed this to build the dnf categories
SELECT status, COUNT(*) AS cnt
FROM raw.status s
JOIN raw.results r ON s.statusid = r.statusid
GROUP BY status
ORDER BY cnt DESC;

-- q3 - checking jordan and minardi dnf rates
-- seemed high so wanted to verify
SELECT
    c.name,
    COUNT(*) AS entries,
    COUNT(CASE WHEN s.status NOT IN ('Finished') AND s.status NOT LIKE '+%' THEN 1 END) AS dnfs,
    ROUND(COUNT(CASE WHEN s.status NOT IN ('Finished') AND s.status NOT LIKE '+%' THEN 1 END) * 100.0
        / COUNT(*), 1) AS dnf_pct
FROM raw.results r
JOIN raw.constructors c ON r.constructorid = c.constructorid
JOIN raw.status s ON r.statusid = s.statusid
JOIN raw.races ra ON r.raceid = ra.raceid
WHERE ra.year >= 2000
AND c.name IN ('Jordan', 'Minardi')
GROUP BY c.name;

-- q4 - end of season championship gaps by year
-- used this to validate the power bi line chart
SELECT
    year,
    MAX(CASE WHEN position = 1 THEN points END) AS p1_pts,
    MAX(CASE WHEN position = 2 THEN points END) AS p2_pts,
    MAX(CASE WHEN position = 1 THEN points END) -
    MAX(CASE WHEN position = 2 THEN points END) AS gap
FROM analytics.v_championship_competitiveness
WHERE round = (
    SELECT MAX(round) FROM raw.races r2
    WHERE r2.year = v_championship_competitiveness.year
)
GROUP BY year
ORDER BY year DESC;
