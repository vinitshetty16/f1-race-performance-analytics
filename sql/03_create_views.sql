-- analytics views - built on top of raw schema
-- these are what power bi connects to, not the raw tables directly

USE DATABASE f1_db;
USE SCHEMA analytics;
USE WAREHOUSE f1_wh;

-- ======================================================
-- view 1: master results
-- this is the main joined table everything else builds on
-- joins results + races + drivers + constructors + status
-- also handles the \N nulls and adds some derived columns
-- ======================================================

CREATE OR REPLACE VIEW analytics.v_master_results AS
SELECT
    res.resultid,
    r.raceid,
    r.year,
    r.round,
    r.name                                          AS race_name,
    d.driverid,
    d.forename || ' ' || d.surname                  AS driver_name,
    d.nationality                                   AS driver_nationality,
    c.constructorid,
    c.name                                          AS constructor_name,
    c.nationality                                   AS constructor_nationality,
    res.grid,
    res.positionorder                               AS finish_position,
    NULLIF(res.position, '\\N')::INT                AS finish_position_classified,
    res.points,
    res.laps,
    NULLIF(res.milliseconds, '\\N')::BIGINT         AS race_time_ms,
    NULLIF(res.fastestlaptime, '\\N')               AS fastest_lap_time,
    NULLIF(res.fastestlapspeed, '\\N')::FLOAT       AS fastest_lap_speed,
    s.status,

    -- finished = completed race or lapped, dnf = everything else
    CASE
        WHEN s.status = 'Finished'  THEN 'Finished'
        WHEN s.status LIKE '+%'     THEN 'Finished'
        WHEN s.status LIKE '%Lap%'  THEN 'Finished'
        ELSE 'DNF'
    END AS finish_status,

    -- breaking dnfs into mechanical vs accident vs other
    -- mechanical list probably not exhaustive but covers main ones
    CASE
        WHEN s.status IN (
            'Engine','Gearbox','Transmission','Clutch',
            'Hydraulics','Electrical','Suspension',
            'Brakes','Mechanical','Throttle','Oil pressure',
            'Turbo','CV joint','Wheel bearing'
        ) THEN 'Mechanical DNF'
        WHEN s.status IN ('Accident','Collision','Spun off')
            THEN 'Accident DNF'
        WHEN s.status = 'Finished' THEN 'Finished'
        WHEN s.status LIKE '+%'    THEN 'Finished'
        ELSE 'Other'
    END AS dnf_category,

    -- era buckets for filtering in power bi
    -- dates are approximate, based on regulation changes
    CASE
        WHEN r.year BETWEEN 1950 AND 1979 THEN 'Early era (1950-1979)'
        WHEN r.year BETWEEN 1980 AND 1999 THEN 'Turbo/Classic era (1980-1999)'
        WHEN r.year BETWEEN 2000 AND 2009 THEN 'Ferrari dominance (2000-2009)'
        WHEN r.year BETWEEN 2010 AND 2013 THEN 'Red Bull era (2010-2013)'
        WHEN r.year BETWEEN 2014 AND 2021 THEN 'Hybrid era (2014-2021)'
        WHEN r.year >= 2022             THEN 'Ground effect era (2022+)'
    END AS era

FROM raw.results res
JOIN raw.races        r ON res.raceid        = r.raceid
JOIN raw.drivers      d ON res.driverid      = d.driverid
JOIN raw.constructors c ON res.constructorid = c.constructorid
JOIN raw.status       s ON res.statusid      = s.statusid;


-- ======================================================
-- view 2: grid vs finish
-- answers q1 - does grid position predict race outcome?
-- aggregated by grid, era, year
-- ======================================================

CREATE OR REPLACE VIEW analytics.v_grid_vs_finish AS
SELECT
    grid,
    era,
    year,
    COUNT(*)                                                    AS total_races,
    SUM(CASE WHEN finish_position = 1 THEN 1 ELSE 0 END)       AS wins,
    SUM(CASE WHEN finish_position <= 3 THEN 1 ELSE 0 END)      AS podiums,
    SUM(CASE WHEN finish_position <= 10 THEN 1 ELSE 0 END)     AS points_finishes,
    ROUND(AVG(finish_position), 2)                             AS avg_finish_position,

    -- win conversion = wins / total races from that grid slot
    ROUND(
        SUM(CASE WHEN finish_position = 1 THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2)                                   AS win_conversion_pct,

    ROUND(
        SUM(CASE WHEN finish_position <= 3 THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2)                                   AS podium_conversion_pct

FROM analytics.v_master_results
WHERE grid > 0 -- removing pit lane starters
AND finish_position IS NOT NULL
GROUP BY grid, era, year
ORDER BY year, grid;


-- ======================================================
-- view 3: dnf analysis
-- answers q2 - which constructors are most unreliable?
-- filtered to modern era in power bi (2000+)
-- ======================================================

CREATE OR REPLACE VIEW analytics.v_dnf_analysis AS
SELECT
    constructor_name,
    constructor_nationality,
    era,
    year,
    COUNT(*)                                                        AS total_entries,
    SUM(CASE WHEN finish_status = 'DNF' THEN 1 ELSE 0 END)         AS total_dnfs,
    SUM(CASE WHEN dnf_category = 'Mechanical DNF' THEN 1 ELSE 0 END) AS mechanical_dnfs,
    SUM(CASE WHEN dnf_category = 'Accident DNF' THEN 1 ELSE 0 END)   AS accident_dnfs,
    SUM(CASE WHEN finish_status = 'Finished' THEN 1 ELSE 0 END)    AS total_finishes,

    ROUND(
        SUM(CASE WHEN finish_status = 'DNF' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2)                                       AS dnf_rate_pct,

    ROUND(
        SUM(CASE WHEN dnf_category = 'Mechanical DNF' THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2)                                       AS mechanical_dnf_rate_pct

FROM analytics.v_master_results
GROUP BY constructor_name, constructor_nationality, era, year
ORDER BY year, dnf_rate_pct DESC;


-- ======================================================
-- view 4: driver overperformance
-- answers q3 - who gains the most positions on race day?
-- positive avg_positions_gained = finishing better than starting
-- ======================================================

CREATE OR REPLACE VIEW analytics.v_driver_overperformance AS
SELECT
    driver_name,
    driver_nationality,
    constructor_name,
    era,
    year,
    COUNT(*)                                AS total_races,
    ROUND(AVG(grid), 2)                     AS avg_grid_position,
    ROUND(AVG(finish_position), 2)          AS avg_finish_position,

    -- positive = gaining positions, negative = losing positions
    ROUND(AVG(grid) - AVG(finish_position), 2) AS avg_positions_gained,

    SUM(CASE WHEN finish_position < grid THEN 1 ELSE 0 END) AS races_gained_positions,
    SUM(CASE WHEN finish_position = 1 THEN 1 ELSE 0 END)    AS wins,

    ROUND(
        SUM(CASE WHEN finish_position < grid THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2)               AS pct_races_gained

FROM analytics.v_master_results
WHERE grid > 0
AND finish_position IS NOT NULL
AND finish_status = 'Finished' -- only counting finishers, dnfs skew this badly
GROUP BY driver_name, driver_nationality, constructor_name, era, year
ORDER BY avg_positions_gained DESC;


-- ======================================================
-- view 5: championship competitiveness
-- answers q4 - how dominant were teams each season?
-- use max round per year to get end of season standings
-- points system changed in 2010 so pre/post not directly comparable
-- ======================================================

CREATE OR REPLACE VIEW analytics.v_championship_competitiveness AS
SELECT
    cs.raceid,
    r.year,
    r.round,
    r.name                              AS race_name,
    c.name                              AS constructor_name,
    cs.points,
    cs.position,
    cs.wins,
    CASE
        WHEN r.year BETWEEN 1950 AND 1979 THEN 'Early era (1950-1979)'
        WHEN r.year BETWEEN 1980 AND 1999 THEN 'Turbo/Classic era (1980-1999)'
        WHEN r.year BETWEEN 2000 AND 2009 THEN 'Ferrari dominance (2000-2009)'
        WHEN r.year BETWEEN 2010 AND 2013 THEN 'Red Bull era (2010-2013)'
        WHEN r.year BETWEEN 2014 AND 2021 THEN 'Hybrid era (2014-2021)'
        WHEN r.year >= 2022             THEN 'Ground effect era (2022+)'
    END AS era
FROM raw.constructor_standings cs
JOIN raw.races        r ON cs.raceid        = r.raceid
JOIN raw.constructors c ON cs.constructorid = c.constructorid
ORDER BY r.year, r.round, cs.position;
