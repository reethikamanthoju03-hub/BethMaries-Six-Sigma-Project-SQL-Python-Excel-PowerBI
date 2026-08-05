-- =====================================================================
-- Beth Marie's Ice Cream — Six Sigma Service Time Analysis
-- SQL queries supporting the Measure & Analyze phases of the DMAIC project
-- Run against the Simulated Data (5,000-customer Excel-generated Monte
-- Carlo dataset)
-- Compatible with PostgreSQL / SQL Server / MySQL (minor syntax notes below)
--
-- TERMINOLOGY (kept consistent across Excel, SQL, and both reports):
--   Service Time        = Scoop Time + Checkout Time
--   Total Customer Time  = Decision Time + Scoop Time + Checkout Time
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. TABLE SETUP
-- Load "Simulation" data from Beth_Maries_Simulation.xlsx (Excel-based
-- Monte Carlo simulation, LOGNORM.INV / RAND) into this table, or point
-- your BI tool / SQL import wizard at the same sheet.
-- ---------------------------------------------------------------------
CREATE TABLE service_observations (
    customer_id      INT PRIMARY KEY,
    decision_time_s   DECIMAL(6,2) NOT NULL,   -- seconds
    scoop_time_s       DECIMAL(6,2) NOT NULL,   -- seconds
    checkout_time_s    DECIMAL(6,2) NOT NULL,   -- seconds
    total_service_time_s DECIMAL(6,2) NOT NULL, -- Service Time: scoop_time_s + checkout_time_s (does NOT include decision_time_s)
    item_selected     VARCHAR(20) NOT NULL      -- Cone, Cup, Shake, Split, Sundae
);

-- Optional: peak-volume reference table captured from on-site observation
CREATE TABLE peak_volume (
    day_of_week   VARCHAR(10),
    time_window   VARCHAR(20),
    avg_customers_per_hour DECIMAL(6,2)
);

-- =====================================================================
-- 1. OVERALL KPI SUMMARY
-- =====================================================================
SELECT
    ROUND(AVG(decision_time_s), 2)          AS avg_decision_time,
    ROUND(STDDEV(decision_time_s), 2)       AS stddev_decision_time,
    ROUND(AVG(scoop_time_s), 2)             AS avg_scoop_time,
    ROUND(STDDEV(scoop_time_s), 2)          AS stddev_scoop_time,
    ROUND(AVG(checkout_time_s), 2)          AS avg_checkout_time,
    ROUND(STDDEV(checkout_time_s), 2)       AS stddev_checkout_time,
    ROUND(AVG(total_service_time_s), 2)     AS avg_service_time,
    ROUND(STDDEV(total_service_time_s), 2)  AS stddev_service_time,
    ROUND(AVG(total_service_time_s + decision_time_s), 2) AS avg_total_customer_time,
    COUNT(*)                                AS n_customers
FROM service_observations;

-- =====================================================================
-- 2. SERVICE TIME BY ITEM TYPE (Finding #2 & #3: scoop time / shake bottleneck)
-- =====================================================================
SELECT
    item_selected,
    COUNT(*)                            AS n_orders,
    ROUND(AVG(scoop_time_s), 2)         AS avg_scoop_time,
    ROUND(STDDEV(scoop_time_s), 2)      AS stddev_scoop_time,
    ROUND(AVG(total_service_time_s), 2) AS avg_service_time,
    ROUND(AVG(total_service_time_s + decision_time_s), 2) AS avg_total_customer_time,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders
FROM service_observations
GROUP BY item_selected
ORDER BY avg_scoop_time DESC;

-- =====================================================================
-- 3. COEFFICIENT OF VARIANCE BY STAGE
-- =====================================================================
SELECT
    'Decision Time' AS stage,
    ROUND(AVG(decision_time_s), 2) AS avg_time,
    ROUND(STDDEV(decision_time_s), 2) AS stddev_time,
    ROUND(STDDEV(decision_time_s) / AVG(decision_time_s) * 100, 1) AS coefficient_of_variance_pct
FROM service_observations
UNION ALL
SELECT
    'Scoop Time',
    ROUND(AVG(scoop_time_s), 2),
    ROUND(STDDEV(scoop_time_s), 2),
    ROUND(STDDEV(scoop_time_s) / AVG(scoop_time_s) * 100, 1)
FROM service_observations
UNION ALL
SELECT
    'Checkout Time',
    ROUND(AVG(checkout_time_s), 2),
    ROUND(STDDEV(checkout_time_s), 2),
    ROUND(STDDEV(checkout_time_s) / AVG(checkout_time_s) * 100, 1)
FROM service_observations
ORDER BY coefficient_of_variance_pct DESC;

-- =====================================================================
-- 4. OUTLIER DETECTION — Z-SCORE (Finding #2: worst outliers driven by scoop time)
-- =====================================================================
WITH stats AS (
    SELECT
        AVG(scoop_time_s) OVER ()    AS mean_scoop,
        STDDEV(scoop_time_s) OVER () AS sd_scoop,
        customer_id,
        scoop_time_s,
        item_selected,
        total_service_time_s
    FROM service_observations
)
SELECT
    customer_id,
    item_selected,
    scoop_time_s,
    total_service_time_s,
    ROUND((scoop_time_s - mean_scoop) / sd_scoop, 2) AS scoop_time_zscore
FROM stats
WHERE (scoop_time_s - mean_scoop) / sd_scoop >= 2
ORDER BY scoop_time_zscore DESC;

-- =====================================================================
-- 5. TOP-N SLOWEST SERVICE TIMES (RANK / percentile window functions)
-- =====================================================================
SELECT
    customer_id,
    item_selected,
    total_service_time_s,
    RANK() OVER (ORDER BY total_service_time_s DESC)              AS slowest_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_service_time_s) * 100, 1) AS percentile
FROM service_observations
ORDER BY slowest_rank
LIMIT 20;

-- =====================================================================
-- 6. DECISION TIME IMPACT SIMULATION (Finding #1)
-- =====================================================================
SELECT
    ROUND(AVG(total_service_time_s + decision_time_s), 2)                AS current_avg_total_customer_time,
    ROUND(AVG(GREATEST(decision_time_s - 15, 0) + total_service_time_s), 2) AS projected_avg_total_customer_time,
    ROUND(
        100.0 * (
            AVG(total_service_time_s + decision_time_s)
            - AVG(GREATEST(decision_time_s - 15, 0) + total_service_time_s)
        ) / AVG(total_service_time_s + decision_time_s)
    , 1) AS pct_reduction
FROM service_observations;

-- =====================================================================
-- 7. PEAK-HOUR CAPACITY CHECK (Finding #5: throughput vs. arrival rate)
-- =====================================================================
SELECT
    day_of_week,
    time_window,
    avg_customers_per_hour,
    ROUND(3600.0 / avg_customers_per_hour, 1)              AS seconds_between_arrivals,
    (SELECT ROUND(AVG(total_service_time_s + decision_time_s), 1) FROM service_observations) AS avg_total_customer_time_s,
    CEIL(
        (SELECT AVG(total_service_time_s + decision_time_s) FROM service_observations)
        / (3600.0 / avg_customers_per_hour)
    ) AS min_parallel_lines_needed
FROM peak_volume
ORDER BY avg_customers_per_hour DESC;

-- =====================================================================
-- 8. SAMPLE SIZE / DATA RELIABILITY CHECK (Finding #6)
-- =====================================================================
SELECT
    item_selected,
    COUNT(*) AS n_orders,
    CASE WHEN COUNT(*) < 30 THEN 'LOW — flag for larger sample' ELSE 'OK' END AS sample_reliability
FROM service_observations
GROUP BY item_selected
ORDER BY n_orders ASC;

-- Note: syntax notes —
-- STDDEV() is native in PostgreSQL/MySQL; SQL Server uses STDEV().
-- PERCENT_RANK()/RANK() are ANSI-standard window functions, supported by all three.
-- CEIL() is CEILING() in SQL Server.
