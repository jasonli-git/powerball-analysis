-- ============================================================================
-- File:    01_load_powerball_src.sql
-- Purpose: Create the `lottery` database and load the raw Powerball CSV
--          into a source table (`powerball_src`) for downstream transformation.
--
-- Data Source:
--   Lottery Powerball Winning Numbers (Beginning 2010)
--   https://catalog.data.gov/dataset/lottery-powerball-winning-numbers-beginning-2010
--
-- Data Last Retrieved: 2025-11-09      -- <-- update whenever you refresh the CSV
-- Data Publisher:      State of New York
--
-- Notes:
--   - This script DROPS and recreates the entire `lottery` database.
--   - The original CSV structure is preserved at this stage to maintain traceability.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Recreate the database
-- ----------------------------------------------------------------------------
DROP DATABASE IF EXISTS lottery;
CREATE DATABASE lottery;

USE lottery;


-- ----------------------------------------------------------------------------
-- 2. Create and load the raw source table
-- ----------------------------------------------------------------------------

-- Drop the source table if it already exists (idempotent rebuild)
DROP TABLE IF EXISTS powerball_src;

-- Raw source table matching the CSV file structure
CREATE TABLE powerball_src (
    draw_date       VARCHAR(10),        -- e.g. '09/26/2020'
    winning_numbers VARCHAR(25),        -- e.g. '11 21 27 36 62 24'
    power_play      TINYINT UNSIGNED    -- e.g. 2, 3, 4, 5; may be 0 or blank
);

-- Load the CSV into the source table
-- NOTE: Update the LOCAL INFILE path if your project folder changes.
LOAD DATA LOCAL INFILE
    './Data/Lottery_Powerball_Winning_Numbers__Beginning_2010.csv'
INTO TABLE powerball_src
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

-- CSV downloaded from:
--   https://catalog.data.gov/dataset/lottery-powerball-winning-numbers-beginning-2010


-- ----------------------------------------------------------------------------
-- 3. (Optional) QA checks — leave commented out for reference
-- ----------------------------------------------------------------------------

-- -- View first 10 records to confirm structure and formatting
-- SELECT *
-- FROM powerball_src
-- LIMIT 10;

-- -- Confirm total row count matches the CSV file
-- SELECT COUNT(*) AS row_count
-- FROM powerball_src;

-- -- Inspect maximum length of winning_numbers field
-- SELECT
--     winning_numbers,
--     LENGTH(winning_numbers) AS length_value
-- FROM powerball_src
-- ORDER BY length_value DESC
-- LIMIT 10;


-- ============================================================================
-- End of 01_load_powerball_src.sql
-- ============================================================================