-- setting up snowflake for f1 project
-- run these one at a time dont run all at once

USE ROLE ACCOUNTADMIN;

-- warehouse for running queries, x-small is fine for this size of data
-- auto suspend so it doesnt eat credits when im not using it
CREATE WAREHOUSE f1_wh
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;

CREATE DATABASE f1_db;

USE DATABASE f1_db;

-- two schemas - raw is source data (dont touch), analytics is where i build views
CREATE SCHEMA raw;
CREATE SCHEMA analytics;

-- file format for loading the csvs
-- null_if handles the \N values that ergast uses instead of proper nulls
-- took me a while to figure this out
CREATE FILE FORMAT f1_db.raw.csv_format
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('\\N', 'NULL', '')
    EMPTY_FIELD_AS_NULL = TRUE;
