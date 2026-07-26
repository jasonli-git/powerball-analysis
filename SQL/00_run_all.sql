-- ============================================================================
-- File:    00_run_all.sql
-- Purpose: Master script that rebuilds the entire `lottery` database from the
--          raw CSV by running each pipeline step in order.
--
-- IMPORTANT: Run this with the `mysql` command-line client only.
--            SOURCE is a client built-in command, not SQL, so this script
--            will NOT run inside MySQL Workbench. In Workbench, open and
--            execute 01 -> 04 individually instead.
--
-- Run from: the repository root (the folder containing /Data and /SQL).
--           01_load_powerball_src.sql loads the CSV using the relative path
--           './Data/...', which resolves against the client's working
--           directory, so running from inside /SQL will not find the file.
--
-- Usage:
--     mysql -u root -p --local-infile=1 < SQL/00_run_all.sql
--
-- Requirements:
--   - The raw CSV must be present at:
--       ./Data/Lottery_Powerball_Winning_Numbers__Beginning_2010.csv
--     (CSVs are gitignored, so download it from the data.gov link in 01.)
--   - LOCAL INFILE must be enabled on both ends. Either pass
--     --local-infile=1 to the client, or set it once in my.cnf:
--       [mysqld]   local_infile=1
--       [client]   local_infile=1
--
-- Notes:
--   - Step 01 DROPS and recreates the entire `lottery` database.
--   - Every step is idempotent, so the full rebuild is safe to re-run.
--   - SOURCE lines intentionally have no trailing semicolon: the client
--     treats the rest of the line as the filename, and a ';' would be
--     read as part of it.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Load the raw CSV into the source table (powerball_src)
-- ----------------------------------------------------------------------------
SOURCE SQL/01_load_powerball_src.sql


-- ----------------------------------------------------------------------------
-- 2. Clean and normalize into the staging table (powerball_stg)
-- ----------------------------------------------------------------------------
SOURCE SQL/02_build_powerball_stg.sql


-- ----------------------------------------------------------------------------
-- 3. Build the final analytical fact table (powerball_final)
-- ----------------------------------------------------------------------------
SOURCE SQL/03_build_powerball_final.sql


-- ----------------------------------------------------------------------------
-- 4. Create the pivoted view used for frequency / position analysis
-- ----------------------------------------------------------------------------
SOURCE SQL/04_build_powerball_pivot_view.sql


-- ----------------------------------------------------------------------------
-- 5. (Optional) Post-build QA checks - leave commented out for reference
-- ----------------------------------------------------------------------------

-- USE lottery;

-- -- Row counts should be identical across the pipeline
-- SELECT
--     (SELECT COUNT(*) FROM powerball_src)   AS src_rows,
--     (SELECT COUNT(*) FROM powerball_stg)   AS stg_rows,
--     (SELECT COUNT(*) FROM powerball_final) AS final_rows;

-- -- The pivoted view should hold exactly 5 rows per draw
-- SELECT COUNT(*) AS pivoted_rows
-- FROM powerball_pivoted;

-- -- Confirm the full date range loaded as expected
-- SELECT
--     MIN(draw_date) AS first_draw,
--     MAX(draw_date) AS last_draw
-- FROM powerball_final;


-- ============================================================================
-- End of 00_run_all.sql
-- ============================================================================
