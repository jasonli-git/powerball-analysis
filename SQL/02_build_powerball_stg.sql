-- ============================================================================
-- File:    02_build_powerball_stg.sql
-- Purpose: Create and populate the staging table (powerball_stg) from the
--          raw source table (powerball_src).
--
-- Assumptions:
--   - Database 'lottery' already exists.
--   - 01_load_powerball_src.sql has been run and powerball_src is populated.
--
-- Notes:
--   - Staging normalizes data types and parses the winning_numbers string
--     into separate columns before loading into the final analytics table.
-- ============================================================================

-- Use the target database explicitly for safety
USE lottery;

-- ============================================================================
-- Drop & Recreate staging table
-- ============================================================================

-- Rebuild the staging table from scratch
DROP TABLE IF EXISTS powerball_stg;

CREATE TABLE powerball_stg (
    draw_date  DATE,
    num1       TINYINT UNSIGNED,
    num2       TINYINT UNSIGNED,
    num3       TINYINT UNSIGNED,
    num4       TINYINT UNSIGNED,
    num5       TINYINT UNSIGNED,
    powerball  TINYINT UNSIGNED,
    power_play TINYINT UNSIGNED NULL   -- NULL = no Power Play listed / not applicable
);

-- ============================================================================
-- Populate staging table from source
-- ============================================================================

INSERT INTO powerball_stg (
    draw_date,
    num1, num2, num3, num4, num5, powerball,
    power_play
)
SELECT
    -- Convert draw date from string 'MM/DD/YYYY' to DATE
    STR_TO_DATE(draw_date, '%m/%d/%Y') AS draw_date_converted,

    -- Split the winning_numbers column into individual main numbers
    CAST(SUBSTRING_INDEX(winning_numbers, ' ', 1) AS UNSIGNED)                                        AS num1,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(winning_numbers, ' ', 2), ' ', -1) AS UNSIGNED)              AS num2,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(winning_numbers, ' ', 3), ' ', -1) AS UNSIGNED)              AS num3,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(winning_numbers, ' ', 4), ' ', -1) AS UNSIGNED)              AS num4,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(winning_numbers, ' ', 5), ' ', -1) AS UNSIGNED)              AS num5,
    CAST(SUBSTRING_INDEX(winning_numbers, ' ', -1) AS UNSIGNED)                                       AS powerball,

    -- Treat 0 in the CSV as "no Power Play" and store as NULL
    NULLIF(power_play, 0) AS power_play
FROM powerball_src;

-- ============================================================================
-- End of 02_build_powerball_stg.sql
-- ============================================================================