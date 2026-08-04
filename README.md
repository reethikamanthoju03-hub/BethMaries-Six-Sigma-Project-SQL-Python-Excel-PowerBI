## 🍦 Beth Marie's Ice Cream — Six Sigma DMAIC Project
A capstone project applying the Six Sigma DMAIC methodology to reduce customer wait times and order-fulfillment defects at Beth Marie's on the Square, a locally beloved ice cream shop in Denton, TX — covering process mapping, in-person time-study data collection, Monte Carlo simulation, and data-driven improvement recommendations.

## 📁 Repo Contents

| File / Folder | Description |
|---|---|
| [`data/Beth_Maries.xlsx`](data/Beth_Maries.xlsx) | Raw observation dataset — 42 customer service-time records (decision, scoop, checkout time by item type) |
| [`data/bethmaries_survey.xlsx`](data/bethmaries_survey.xlsx) | Customer perception survey responses (wait-time perception, flavor familiarity) |
| [`data/BethMaries_Simulated_5000-2.xlsx`](data/BethMaries_Simulated_5000-2.xlsx) | Monte Carlo–simulated dataset — 5,000 synthetic customer records generated from the original 42 (Python) |
| [`sql/Beth_Maries.sql`](sql/Beth_Maries.sql) | KPI, outlier-detection, and capacity queries — CTEs, window functions, z-scores |
| [`excel/BethMaries_Six_Sigma_Dashboard.xlsx`](excel/BethMaries_Six_Sigma_Dashboard.xlsx) | Excel dashboard — live formulas + charts |
| [`powerbi/BethMaries_Dashboard.pbix`](powerbi/BethMaries_Dashboard.pbix) | Power BI dashboard — interactive KPI report + slicers |
| [`reports/Final_Report_4700_Beth_Maries.pdf`](reports/Final_Report_4700_Beth_Maries.pdf) | Full DMAIC report — Define, Measure, Analyze & Improve phases, SIPOC, control plan |
| [`reports/BethMaries_Simulation_Report_docx.pdf`](reports/BethMaries_Simulation_Report_docx.pdf) | Monte Carlo simulation methodology & validation report |
| [`slides/BethMaries_Presentation.pptx`](slides/BethMaries_Presentation.pptx) | Project summary deck |

## 📊 Live Dashboard & Analysis Links
**Excel Dashboard:** [`excel/BethMaries_Six_Sigma_Dashboard.xlsx`](excel/BethMaries_Six_Sigma_Dashboard.xlsx)
**Power BI Dashboard:** [`powerbi/BethMaries_Dashboard.pbix`](powerbi/BethMaries_Dashboard.pbix)
**SQL Analysis:** [`sql/Beth_Maries.sql`](sql/Beth_Maries.sql)
**Full DMAIC Report:** [`reports/Final_Report_4700_Beth_Maries.pdf`](reports/Final_Report_4700_Beth_Maries.pdf)

## Project Overview
This project simulates the role of a Six Sigma process improvement team supporting a high-traffic, locally owned ice cream shop. The objective was to diagnose the root causes of long customer queues during peak periods and deliver actionable, evidence-based recommendations to store leadership.

**Dataset:** 42 in-person customer observations (decision time, scoop time, checkout time, item type) collected on-site at Beth Marie's on the Square, expanded via Monte Carlo simulation into a 5,000-customer dataset for reliable statistical analysis, plus a customer perception survey.

## Problem Statement
Beth Marie's experiences long customer queues at its Square location, particularly during two predictable daily rush windows. The store runs two structurally different order-fulfillment processes depending on volume — a single-staff model during slow periods and a split-role model (maker + cashier) during busy periods — with no standardized handoff between them. The busy-period process relies on a handwritten weight slip, which introduces legibility errors, incorrect charges, and checkout delays. This project applies a DMAIC framework and waiting-line (queuing) analysis to identify the primary bottleneck in the service process and recommend improvements to reduce wait time and improve accuracy.

## Analysis
Metrics calculated and evaluated (see `sql/Beth_Maries.sql`, `excel/BethMaries_Six_Sigma_Dashboard.xlsx`, and the two PDF reports):
- Service time broken into **Decision Time**, **Scoop Time**, and **Checkout Time**
- Descriptive statistics (mean, median, standard deviation, min/max) per service stage
- Service time distribution by **Item Type** (Cone, Cup, Shake, Split, Sundae)
- Outlier and variability analysis (coefficient of variance by stage and item; SQL z-score outlier detection)
- Peak-hour capacity analysis (arrival rate vs. service rate → minimum parallel service lines needed)
- Trend analysis of total service time across the observation window
- Monte Carlo simulation (Python — lognormal + multinomial distributions, n = 5,000) to validate patterns beyond the original 42-record sample
- Customer perception survey cross-referenced against observed wait times

## Six Sigma Findings & Improvement Opportunities

**1. Decision time is the biggest and most controllable delay.**
With a standard deviation of ~30s and a max of 173s (Customer 11), decision time is wildly inconsistent and is the single largest driver of service variability. The root cause is almost certainly customers not knowing what they want when they reach the counter.
> *Improvement:* Implement a visible menu board or order-ahead/kiosk system so customers arrive ready to decide. Even a 15-second reduction in average decision time would cut overall service time by roughly 30%.

**2. Scoop time drives the worst outliers.**
All three extreme outlier customers (19, 26, 39) were flagged primarily due to abnormal scoop times — 106.7s, 70.4s, and 86.4s respectively, versus a normal average of ~30s. Shakes in particular averaged 61.4s to scoop — double any other item. This points to a process or equipment issue (blenders, frozen product handling, or staff inexperience with specific items) rather than a random fluke.
> *Improvement:* A DMAIC root-cause analysis on the scooping step — especially for shakes and complex items — is warranted before broader process changes are made.

**3. Shakes are a hidden bottleneck.**
Only 2 shake customers appear in the sample, but their average scoop time (61.4s) is more than double that of cones or splits. At peak volume (134–164 customers/hour on Saturday evenings), even a small share of shake orders could create significant queue backups.
> *Improvement:* Consider a dedicated shake station or pre-blending during slower hours to decouple shake prep from the main scooping line.

**4. Checkout is already near-optimal and consistent.**
With a standard deviation of only 3.8s and a max of 29.5s, the checkout/payment step is already well-controlled statistically. This is the best-performing step in the process and does not require major intervention.

**5. Peak volume creates capacity risk.**
Saturday 8–11pm averages 164 customers/hour — roughly one customer every 22 seconds. With a mean total service time of 50.4 seconds, this strongly implies the shop needs at least 2–3 parallel service lines during peak hours to avoid queue buildup. This is a classic capacity/throughput problem that Six Sigma process mapping surfaces clearly.

**6. Small sample size is a project limitation.**
With only 50 raw observations across 5 item types (some with only 2–3 data points), results for shakes, splits, and sundaes are not yet statistically reliable on their own — which is why the dataset was expanded via Monte Carlo simulation to 5,000 records. A larger real-world sample (100–200 customers, stratified by item type and time of day) is recommended to strengthen the Measure phase in future iterations.

## Project Phases
**1. Define** — Established the project charter, problem statement, SIPOC diagram, and stakeholder map through a general manager interview at Beth Marie's on the Square.

**2. Measure** — Designed and executed an in-person observation plan capturing decision, scoop, and checkout time per customer, alongside a customer perception survey, across 42 real customer records.

**3. Simulate & Validate (Python)** — Expanded the 42-record dataset to 5,000 simulated customers via lognormal (continuous) and multinomial (categorical) Monte Carlo simulation in Python (NumPy/pandas), validating that simulated means fell within 1% of the original observed means.

**4. SQL Analysis** — Loaded the simulated dataset into a relational table and used SQL (CTEs, window functions, z-score outlier detection, `RANK`/`PERCENT_RANK`) to quantify KPIs, flag statistical outliers, and model a peak-hour capacity scenario (see `sql/Beth_Maries.sql`).

**5. Excel Dashboard** — Built an interactive workbook (`excel/BethMaries_Six_Sigma_Dashboard.xlsx`) with a Raw Data sheet feeding a Dashboard sheet driven entirely by live `AVERAGEIF`/`COUNTIF`/`STDEV` formulas — KPI cards, service-time-by-item and variability tables, a peak-capacity table, and bar charts.

**6. Analyze** — Used the dashboard, descriptive statistics, and SQL outlier queries to isolate decision time as the primary bottleneck and identify scoop time as the driver of extreme outliers, particularly for shakes.

**7. Improve** — Recommended a visible/digital menu system to reduce decision time, a dedicated shake station, elimination of the handwritten weight slip, and standardized busy-period staff roles.

**8. Control** — Proposed a control plan including standardized peak/slow-period procedures, ongoing tracking of service-time KPIs, staff training, periodic process audits, and continued customer feedback collection.

## Tech Stack
Python (NumPy, pandas, openpyxl) for Monte Carlo simulation · SQL (CTEs, window functions, statistical outlier detection) · Microsoft Excel (live-formula dashboard, PivotChart-style KPI cards) · Power BI (interactive KPI dashboard) · Google Forms (customer survey) · Six Sigma DMAIC methodology

## Getting Started
```
git clone https://github.com/reethikamanthoju03-hub/BethMaries-Six-Sigma-Project-SQL-Python-Excel-PowerBI.git
cd BethMaries-Six-Sigma-Project-SQL-Python-Excel-PowerBI
```
- Open [`excel/BethMaries_Six_Sigma_Dashboard.xlsx`](excel/BethMaries_Six_Sigma_Dashboard.xlsx) to explore the live KPI dashboard, service-time-by-item breakdown, and peak-capacity model
- Run the queries in [`sql/Beth_Maries.sql`](sql/Beth_Maries.sql) against the "Simulated Data (5000)" sheet loaded into MySQL/SQL Server/Postgres
- Open [`reports/Final_Report_4700_Beth_Maries.pdf`](reports/Final_Report_4700_Beth_Maries.pdf) for the full DMAIC write-up (Define, Measure, Analyze, Improve, Control)
- Open [`data/BethMaries_Simulated_5000-2.xlsx`](data/BethMaries_Simulated_5000-2.xlsx) to explore the raw 42-record dataset, the 5,000-record simulation, and side-by-side summary statistics
- Review [`reports/BethMaries_Simulation_Report_docx.pdf`](reports/BethMaries_Simulation_Report_docx.pdf) for the Monte Carlo simulation methodology and validation

## Conclusion
This project demonstrates end-to-end Six Sigma analytics skills — from in-person time-study data collection and root-cause analysis to statistical simulation and stakeholder-ready improvement recommendations. The findings show that customer decision-making, not employee performance, is the dominant driver of service delay, and that targeted, low-cost process changes (menu visibility, a dedicated shake station, and a standardized busy-period handoff) could meaningfully reduce wait times and improve the guest experience at Beth Marie's.
