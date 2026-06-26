
# Clinical Consult Communication Pipeline - Project Case Study

---

## The Problem

In hospital settings, bedside nurses serve as the main communication hub between physicians and specialists. When a doctor orders a consult, say "have Cardiology evaluate this patient," the nurse is responsible for calling the specialist, often multiple times across channels like chat apps, and voice badges.

This creates a **bottleneck** that:
- Burns **45–60 minutes** of nurse time per shift on communication tasks alone
- Delays specialist consults, increasing patient **Length of Stay (LOS)**
- Contributes directly to **nurse burnout** 

Hospital leadership—Chief Nursing Officers, Chief Medical Officers, and COOs—lack visibility into this friction. They know consults are slow but can't pinpoint *why*, *where*, or *how much it costs*.

---

## The Solution

I built **C3-Pipeline** (Clinical Consult Communication), an end-to-end data analytics pipeline that:

1. **Generates** realistic synthetic hospital data simulating EHR and messaging platforms
2. **Processes** raw data through a PySpark ETL pipeline with feature engineering
3. **Analyzes** the data using DuckDB SQL queries answering 6 key business questions
4. **Visualizes** findings in a Tableau Public executive dashboard



---

## Key Findings

### 1. Specialty Bottlenecks
- **Psychiatry** consults averaged **7.9 hours** to bedside—nearly **2x the 4-hour SLA target**
- **Cardiology** averaged **7.5 hours**, **87% above** the SLA target
- **Gastroenterology** was fastest at **4.3 hours**, just above the target
- Only the fastest specialties come close to meeting a 4-hour SLA

### 2. Channel Effectiveness
- **Vocera Badge Call** (real-time voice): **3.1 minute** average response
- **Secure App Chat**: **8.2 minute** average response
- **Legacy Pager**: **25.3 minute** average response—**8x slower** than Vocera
- **Phone Call to Office**: **40.3 minute** average—**13x slower** than Vocera
- Switching from Legacy Pager to Secure App Chat would reduce response lag by **68%**

### 3. Weekend Staffing Gap
- **Weekend Night Shift**: 7.67 hours average time-to-bedside
- **Weekday Day Shift**: 5.03 hours average
- Weekend consults are **2.5 hours slower** on average, indicating a significant staffing gap

### 4. Financial Impact
- **Total estimated excess bed cost: $14.8M** across 2 years of data
- MedSurg units bear the highest cost burden ($3.5–3.7M per unit)
- Average of **1.17 excess bed-days** per encounter with delays
- At $2,500/bed-day (Florida average), even modest improvements yield significant savings

### 5. Communication Friction
- Average **2.8 nurse messages per consult** (target: < 2.0)
- **88.6% message read rate** (target: > 90%)
- Legacy Pager has a **19.3% unread rate**—nearly 1 in 5 pages are never seen

---

## Technical Implementation

### Data Generation (Python + Faker)
- Generated 4 synthetic tables totaling ~147,000 rows
- Injected intentional bottlenecks to simulate real-world patterns
- Maintained referential integrity across all tables

### ETL Pipeline (PySpark)
- Timestamp parsing and validation
- Deduplication and referential integrity checks
- Feature engineering: response lag, turnaround times, friction scores
- Two aggregated analytical tables
- Dual output: Parquet (portfolio showcase) + CSV (Tableau upload)

### SQL Analytics (DuckDB)
- 7 standalone SQL files covering turnaround, channel effectiveness, friction, weekday/weekend, cost estimation, and specialist rankings
- Advanced SQL: CTEs, window functions, percentile calculations, conditional aggregation

### Dashboard (Tableau Public)
- 4 KPI scorecards with conditional color logic
- Specialty bottleneck horizontal bar chart
- Channel effectiveness comparison
- Day/hour friction heatmap
- Friction vs. delay scatter plot with trendline
- Interactive filters: date range, specialty, unit, priority


---



## 📁 Repository Structure

```
C3-Pipeline/
├── README.md                          # This file
├── requirements.txt                   # Python dependencies
├── .gitignore
│
├── notebooks/
│   ├── 01_data_generation.ipynb       # Synthetic data generator
│   ├── 02_pyspark_etl.ipynb           # PySpark ETL pipeline
│   └── 03_sql_analytics.ipynb         # DuckDB analytics with commentary
│
├── sql/
│   ├── 01_schema_creation.sql         # DDL for all 6 tables
│   ├── 02_consult_turnaround.sql      # Turnaround by specialty
│   ├── 03_channel_effectiveness.sql   # Channel response comparison
│   ├── 04_friction_analysis.sql       # Message count vs. delay
│   ├── 05_weekend_vs_weekday.sql      # Temporal analysis
│   ├── 06_excess_bed_day_cost.sql     # Financial impact
│   └── 07_specialist_leaderboard.sql  # Individual specialist ranking
│
├── data/
│   ├── raw/                           # Raw generated CSVs (gitignored)
│   ├── processed/                     # PySpark output (gitignored)
│   │   ├── parquet/
│   │   └── csv/
│   └── sample/                        # Small samples committed for demo
│
├── dashboard/
│   ├── tableau_step_by_step.md        # Dashboard build guide
│   └── tableau_public_link.md         # Live dashboard link
│
└── docs/
    ├── data_dictionary.md             # Column-level documentation
    └── project_writeup.md             # Portfolio case study
```

---

## 🚀 How to Run

### Prerequisites
- Python 3.9+
- Java 11+ (required for PySpark)

### Step 1: Clone and Setup
```bash
git clone https://github.com/mmosoriov/nurse-pipeline.git
cd nurse-pipeline
pip install -r requirements.txt
```

### Step 2: Generate Data
Run the data generation notebook (`notebooks/01_data_generation.ipynb`) in Google Colab or locally:
```bash
# Or run directly:
jupyter nbconvert --to notebook --execute notebooks/01_data_generation.ipynb
```
This creates ~147K rows of synthetic hospital data in `data/raw/`.

### Step 3: Run ETL Pipeline
Run `notebooks/02_pyspark_etl.ipynb`:
- Cleans and validates all data
- Engineers features (response lag, turnaround times, friction scores)
- Creates 2 aggregated tables
- Outputs to `data/processed/` in both Parquet and CSV formats

### Step 4: Run SQL Analytics
Run `notebooks/03_sql_analytics.ipynb`:
- Loads processed data into DuckDB
- Executes 7 analytical queries
- Produces executive summary with KPIs

### Step 5: Build Tableau Dashboard
Follow the detailed guide in `dashboard/tableau_step_by_step.md` to build the dashboard in Tableau Public.

---

## Data Schema

Full documentation: [Data Dictionary](docs/data_dictionary.md)

---
