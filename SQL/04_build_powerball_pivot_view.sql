-- ============================================================================
-- File:    04_build_powerball_pivot_view.sql
-- Purpose: Create a pivoted view (one row per main number) to support
--          frequency and position-based analysis in Tableau.
--
-- Notes:
--   - Reads from: powerball_final
--   - Creates:    powerball_pivoted (VIEW, not a physical table)
--   - Each draw produces 5 rows in this view (one per main number).
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Make sure we are in the correct database
-- ----------------------------------------------------------------------------
USE lottery;

-- ----------------------------------------------------------------------------
-- 2. Create / replace the pivoted view
--
--    For each draw, we unpivot Num1–Num5 into separate rows:
--      - main_number_position = 1–5 (original position in the draw)
--      - main_number          = the actual main ball value
--
--    UNION ALL is used (instead of UNION) to preserve all occurrences and
--    avoid de-duplicating numbers across positions.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW powerball_pivoted AS
SELECT
    draw_date,
    power_play,
    1 AS main_number_position,
    Num1 AS main_number
FROM powerball_final
UNION ALL
SELECT
    draw_date,
    power_play,
    2 AS main_number_position,
    Num2 AS main_number
FROM powerball_final
UNION ALL
SELECT
    draw_date,
    power_play,
    3 AS main_number_position,
    Num3 AS main_number
FROM powerball_final
UNION ALL
SELECT
    draw_date,
    power_play,
    4 AS main_number_position,
    Num4 AS main_number
FROM powerball_final
UNION ALL
SELECT
    draw_date,
    power_play,
    5 AS main_number_position,
    Num5 AS main_number
FROM powerball_final;

-- ============================================================================
-- End of 04_build_powerball_pivot_view.sql
-- ============================================================================