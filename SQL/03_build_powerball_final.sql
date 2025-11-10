-- ============================================================================
-- File:    03_build_powerball_final.sql
-- Purpose: Build the final analytical table (powerball_final) used for
--          reporting and Tableau visualizations.
--
-- Notes:
--   - Depends on powerball_stg being fully populated.
--   - Adds derived metrics (sum of main numbers, even/odd counts, etc.)
--     to make downstream analysis and visualization easier.
-- ============================================================================

-- Use the target database explicitly for safety
USE lottery;

-- ----------------------------------------------------------------------------
-- 1. Drop and recreate the final analytical table
-- ----------------------------------------------------------------------------

-- Drop final table if it already exists (idempotent rebuild)
DROP TABLE IF EXISTS powerball_final;

-- Final, analysis-ready fact table
CREATE TABLE powerball_final (
    draw_id          INT AUTO_INCREMENT PRIMARY KEY,  -- surrogate key
    draw_date        DATE,                            -- actual draw date

    -- Main drawn numbers
    num1             TINYINT UNSIGNED,
    num2             TINYINT UNSIGNED,
    num3             TINYINT UNSIGNED,
    num4             TINYINT UNSIGNED,
    num5             TINYINT UNSIGNED,

    -- Powerball and Power Play
    powerball        TINYINT UNSIGNED,
    power_play       TINYINT UNSIGNED NULL,           -- NULL when Power Play not offered

    -- Derived metrics for deeper analysis
    sum_main_numbers SMALLINT UNSIGNED,               -- num1 + ... + num5
    count_even       TINYINT UNSIGNED,                -- number of even main balls
    count_odd        TINYINT UNSIGNED,                -- number of odd main balls
    highest_number   TINYINT UNSIGNED,                -- max of main balls
    lowest_number    TINYINT UNSIGNED                 -- min of main balls
);


-- ----------------------------------------------------------------------------
-- 2. Populate the final table from the staging table
-- ----------------------------------------------------------------------------

INSERT INTO powerball_final (
    draw_date,
    num1, num2, num3, num4, num5, powerball,
    power_play,
    sum_main_numbers,
    count_even,
    count_odd,
    highest_number,
    lowest_number
)
SELECT
    draw_date,
    num1, num2, num3, num4, num5, powerball,
    power_play,

    -- Sum of main balls
    (num1 + num2 + num3 + num4 + num5) AS sum_main_numbers,

    -- Count of even main numbers (TRUE = 1, FALSE = 0 in MySQL)
    (
        (num1 % 2 = 0) +
        (num2 % 2 = 0) +
        (num3 % 2 = 0) +
        (num4 % 2 = 0) +
        (num5 % 2 = 0)
    ) AS count_even,

    -- Count of odd main numbers
    (
        (num1 % 2 = 1) +
        (num2 % 2 = 1) +
        (num3 % 2 = 1) +
        (num4 % 2 = 1) +
        (num5 % 2 = 1)
    ) AS count_odd,

    -- Highest and lowest main numbers
    GREATEST(num1, num2, num3, num4, num5) AS highest_number,
    LEAST(num1, num2, num3, num4, num5)    AS lowest_number

FROM powerball_stg;


-- ============================================================================
-- End of 03_build_powerball_final.sql
-- ============================================================================