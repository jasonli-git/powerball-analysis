# Powerball Winning Numbers Analysis (2010–2025)

End-to-end analytics project using **MySQL** and **Tableau** to explore historical Powerball results from 2010 onward.  

The pipeline:
1. Load raw CSV into MySQL.
2. Clean and normalize into an analysis-ready schema.
3. Build a pivoted view for number frequency analysis.
4. Visualize patterns in Tableau (desktop + public).

---

## Data Source

- **Source:** Lottery Powerball Winning Numbers (Beginning 2010)  
  https://catalog.data.gov/dataset/lottery-powerball-winning-numbers-beginning-2010  
- **Last downloaded:** *November 10, 2025* 

---

## Repository Structure

```text
/dashboard
  powerball_analysis.twbx   # Packaged Tableau workbook (includes extract)

/data
  .gitkeep                  # Placeholder; CSV is not tracked in Git

/sql
  00_run_all.sql
  01_load_powerball_src.sql
  02_build_powerball_stg.sql
  03_build_powerball_final.sql
  04_build_powerball_pivot_view.sql
```

### MySQL pipeline

All SQL scripts live in the [`sql/`](sql/) folder and are designed to be idempotent (safe to re-run).

1. **`01_load_powerball_src.sql`**  
   - Recreates the `lottery` database.  
   - Creates the raw source table `powerball_src`.  
   - Loads the CSV into `powerball_src` via `LOAD DATA LOCAL INFILE`.  

2. **`02_build_powerball_stg.sql`**  
   - Creates a staging table `powerball_stg`.  
   - Converts the draw date from string (`MM/DD/YYYY`) to `DATE`.  
   - Splits `winning_numbers` into `num1`–`num5` and `powerball`.  
   - Normalizes `power_play` (treats 0 as `NULL` when Power Play is not applicable).

3. **`03_build_powerball_final.sql`**  
   - Builds the final analytical fact table `powerball_final`.  
   - Adds derived metrics such as:
     - `sum_main_numbers` (sum of `num1`–`num5`)  
     - `count_even` / `count_odd` (parity counts for main balls)  
     - `highest_number` / `lowest_number`  

4. **`04_build_powerball_pivot_view.sql`**  
   - Creates the view `powerball_pivoted` (one row per main number).  
   - Unpivots `num1`–`num5` into:
     - `main_number_position` (1–5)  
     - `main_number` (actual ball value)  
   - This view is used for position-based and frequency analysis in Tableau.

5. **`00_run_all.sql`**  
   - Master script that runs all of the above in order.  
   - Usage (from the `sql/` folder):  
     ```bash
     mysql -u root -p < 00_run_all.sql

### Tableau dashboard

The Tableau workbook (`dashboard/powerball_analysis.twbx`) connects to the MySQL `lottery` database and uses **two logical data sources**:

1. **`powerball_final` (main draws)**  
   - Used for:
     - Draw count over time  
     - Powerball frequency  
     - Power Play usage over time  
     - Even vs odd patterns  
     - Average main number by position  

2. **`powerball_pivoted` (unpivoted main numbers)**  
   - Used for:
     - Main number frequency across the full history  
     - Position-based analysis (which positions tend to hold higher/lower numbers)  

**Key dashboard elements:**

- **Date range filter** (slider): lets viewers zoom into specific time periods (e.g., recent years vs full history).
- **Power Play bar chart**: acts as both a summary and an interactive filter (click a bar to focus on a specific multiplier).
- **Frequency charts**: show how often each main number and Powerball have appeared.
- **Distribution views**: average / distribution of main numbers by position, plus even/odd mix for each draw.

A published, interactive version of the dashboard is available on Tableau Public:  
https://public.tableau.com/views/powerball_analysis/PowerballDashboard?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link
