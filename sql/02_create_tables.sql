-- creating all 14 raw tables
-- keeping everything as varchar where im not sure of the data type
-- better to be safe than get load errors

USE DATABASE f1_db;
USE SCHEMA raw;
USE WAREHOUSE f1_wh;

-- circuits - 77 rows, all f1 tracks ever used
CREATE TABLE circuits (
    circuitId INT,
    circuitRef VARCHAR,
    name VARCHAR,
    location VARCHAR,
    country VARCHAR,
    lat FLOAT,
    lng FLOAT,
    alt VARCHAR, -- keeping as varchar, some nulls in here
    url VARCHAR
);

-- races - 1125 rows, one row per race 1950 to 2024
CREATE TABLE races (
    raceId INT,
    year INT,
    round INT,
    circuitId INT,
    name VARCHAR,
    date VARCHAR, -- varchar not date, had issues with format
    time VARCHAR,
    url VARCHAR,
    fp1_date VARCHAR,
    fp1_time VARCHAR,
    fp2_date VARCHAR,
    fp2_time VARCHAR,
    fp3_date VARCHAR,
    fp3_time VARCHAR,
    quali_date VARCHAR,
    quali_time VARCHAR,
    sprint_date VARCHAR,
    sprint_time VARCHAR
);

-- drivers - 861 rows
-- dob kept as varchar because of inconsistent date formats in source
CREATE TABLE drivers (
    driverId INT,
    driverRef VARCHAR,
    number VARCHAR, -- varchar because some drivers have no number
    code VARCHAR,
    forename VARCHAR,
    surname VARCHAR,
    dob VARCHAR,
    nationality VARCHAR,
    url VARCHAR
);

-- constructors - 212 rows
-- note: lotus appears twice as two completely different teams, known issue
CREATE TABLE constructors (
    constructorId INT,
    constructorRef VARCHAR,
    name VARCHAR,
    nationality VARCHAR,
    url VARCHAR
);

-- status lookup table - 139 rows
-- maps statusId to actual reason like Engine, Finished, Accident etc
CREATE TABLE status (
    statusId INT,
    status VARCHAR
);

-- results - biggest table, 26759 rows
-- position column has nulls for dnfs, use positionOrder instead
-- milliseconds and fastestlap columns are mostly null pre-2004
CREATE TABLE results (
    resultId INT,
    raceId INT,
    driverId INT,
    constructorId INT,
    number VARCHAR,
    grid INT,
    position VARCHAR, -- nullable, dnfs have no position
    positionText VARCHAR,
    positionOrder INT, -- use this one, always populated
    points FLOAT,
    laps INT,
    time VARCHAR,
    milliseconds VARCHAR, -- varchar because of nulls
    fastestLap VARCHAR,
    rank VARCHAR,
    fastestLapTime VARCHAR,
    fastestLapSpeed VARCHAR,
    statusId INT
);

-- driver standings after each race
-- 34863 rows
CREATE TABLE driver_standings (
    driverStandingsId INT,
    raceId INT,
    driverId INT,
    points FLOAT,
    position INT,
    positionText VARCHAR,
    wins INT
);

-- constructor standings after each race
-- 13391 rows
CREATE TABLE constructor_standings (
    constructorStandingsId INT,
    raceId INT,
    constructorId INT,
    points FLOAT,
    position INT,
    positionText VARCHAR,
    wins INT
);

-- points per constructor per race
-- slightly different from standings, used for cross checking
CREATE TABLE constructor_results (
    constructorResultsId INT,
    raceId INT,
    constructorId INT,
    points FLOAT,
    status VARCHAR
);

-- qualifying times - 10494 rows
-- q2 and q3 are null if driver was eliminated in q1/q2
CREATE TABLE qualifying (
    qualifyId INT,
    raceId INT,
    driverId INT,
    constructorId INT,
    number INT,
    position INT,
    q1 VARCHAR,
    q2 VARCHAR, -- null if knocked out in q1
    q3 VARCHAR  -- null if knocked out in q2
);

-- lap by lap times - 589081 rows
-- only goes back to 1996, nothing before that
-- this is the biggest table, takes longest to load
CREATE TABLE lap_times (
    raceId INT,
    driverId INT,
    lap INT,
    position INT,
    time VARCHAR,
    milliseconds INT
);

-- pit stops - 11371 rows
-- only available from 2011 onwards, not in earlier data
CREATE TABLE pit_stops (
    raceId INT,
    driverId INT,
    stop INT,
    lap INT,
    time VARCHAR,
    duration VARCHAR,
    milliseconds INT
);

-- sprint race results - only 360 rows
-- sprints only started in 2021, too few for trend analysis
CREATE TABLE sprint_results (
    resultId INT,
    raceId INT,
    driverId INT,
    constructorId INT,
    number INT,
    grid INT,
    position VARCHAR,
    positionText VARCHAR,
    positionOrder INT,
    points FLOAT,
    laps INT,
    time VARCHAR,
    milliseconds VARCHAR,
    fastestLap VARCHAR,
    fastestLapTime VARCHAR,
    statusId INT
);

-- seasons list, just year and wikipedia url basically
CREATE TABLE seasons (
    year INT,
    url VARCHAR
);
