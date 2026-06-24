# 🏥 C3-Pipeline: Clinical Consult Communication & Care Analytics

**An end-to-end data analytics pipeline that quantifies communication friction in hospital specialist consult workflows and identifies actionable bottlenecks for hospital leadership.**

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat-square&logo=python&logoColor=white)
![PySpark](https://img.shields.io/badge/PySpark-3.5+-E25A1C?style=flat-square&logo=apache-spark&logoColor=white)
![DuckDB](https://img.shields.io/badge/DuckDB-0.10+-FFF000?style=flat-square&logo=duckdb&logoColor=black)
![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat-square&logo=tableau&logoColor=white)
![Healthcare](https://img.shields.io/badge/Domain-Healthcare%20Analytics-27AE60?style=flat-square)

---

## 📋 Overview

In hospital settings, bedside nurses act as the de-facto communication hub between physicians and specialists. When a doctor orders a consult, the nurse pages, calls, and messages the specialist—often multiple times across fragmented channels. This "telephone tag" bottleneck **burns 45–60 minutes of nurse time per shift**, delays specialist consults, and contributes to nurse burnout.

**C3-Pipeline** simulates a hospital's EHR and secure messaging platform data, processes it through a PySpark ETL pipeline, loads it into DuckDB for SQL analytics, and produces outputs for a Tableau Public dashboard—all designed to **quantify communication friction** and identify actionable bottlenecks.

### Target Audience
| Stakeholder | Key Question |
|:---|:---|
| **Chief Nursing Officer (CNO)** | How can we reduce nurse communication burden? |
| **Chief Medical Officer (CMO)** | Which specialties are missing consult SLA targets? |
| **Hospital COO** | What's the financial cost of consult-related delays? |

---

## 🏗️ Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Python     │    │   PySpark    │    │   DuckDB     │    │   Tableau    │
│  Data Gen    │───▶│   ETL        │───▶│   SQL        │───▶│  Dashboard   │
│              │    │  Pipeline    │    │  Analytics   │    │              │
│ 4 tables     │    │ Cleaning     │    │ 7 queries    │    │ 5 visuals    │
│ ~147K rows   │    │ Features     │    │ KPIs         │    │ 4 filters    │
│ Faker+NumPy  │    │ Aggregation  │    │ Percentiles  │    │ Interactive  │
└──────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
       │                   │                    │
       ▼                   ▼                    ▼
   data/raw/         data/processed/      c3_pipeline.duckdb
   (CSV)             (Parquet + CSV)
```

---

## 🔑 Key Findings

> **📊 Based on analysis of ~10,000 encounters, ~30,000 consults, and ~82,000 communication attempts**

### 🔴 Specialty Bottlenecks
- **Psychiatry** consults averaged **7.9 hours** to bedside—nearly **2× the 4-hour SLA target**
- **Cardiology** averaged **7.5 hours**, **87% above** the SLA target
- P90 turnaround for Psychiatry: **12.9 hours**—over half a day

### 📱 Channel Effectiveness
- Switching from **Legacy Pager → Secure App Chat** reduces response lag by **68%**
- **Vocera Badge Call**: 3.1 min avg response (fastest)
- **Legacy Pager**: 25.3 min avg response with **19.3% unread rate**

### 📅 Weekend Staffing Gap
- Weekend consults took **2.5 hours longer** on average (7.5h vs. 5.0h)
- Weekend Night Shift was the worst: **7.67 hours** average time-to-bedside

### 💰 Financial Impact
- **Estimated excess bed cost: $14.8M** over 2 years
- Average **1.17 excess bed-days** per delayed encounter
- At $2,500/bed-day (Florida average), this represents significant recoverable cost

---

## 🛠️ Tech Stack

| Layer | Tool | Purpose |
|:---|:---|:---|
| Data Generation | Python 3.10+, Faker, NumPy | Synthetic hospital data with injected bottlenecks |
| Data Engineering | PySpark 3.5+ | ETL: cleaning, feature engineering, aggregation |
| Analytical Database | DuckDB 0.10+ | In-process SQL analytics engine |
| SQL Authoring | Standalone `.sql` files | 7 advanced queries with CTEs and window functions |
| Visualization | Tableau Public | Executive dashboard with interactive filters |
| Output Formats | CSV + Parquet | Dual output for Tableau and portfolio showcase |

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

## 📊 Data Schema

| Table | Rows | Source | Description |
|:---|:---|:---|:---|
| `dim_encounters` | ~10,000 | EHR | Patient hospital stays |
| `fact_consult_orders` | ~30,000 | EHR | Specialist consult requests |
| `fact_communication_logs` | ~82,000 | Messaging | Nurse-to-specialist messages |
| `fact_consult_completions` | ~25,000 | EHR | Completed specialist consults |
| `agg_consult_friction` | ~30,000 | ETL | Per-consult friction metrics |
| `agg_encounter_summary` | ~6,000 | ETL | Per-encounter summary stats |

Full documentation: [Data Dictionary](docs/data_dictionary.md)

---

## 🔮 Future Enhancements

- 🤖 **ML-based SLA prediction** — Predict which consults will breach the 4-hour target
- 📋 **Nurse satisfaction correlation** — Link survey data to communication friction metrics
- 🌊 **Real-time streaming** — Kafka-based pipeline for live consult tracking
- 💬 **NLP on messages** — Sentiment and urgency classification on communication text

---

## 📄 Documentation

- [Data Dictionary](docs/data_dictionary.md) — Column-level documentation for all tables
- [Project Case Study](docs/project_writeup.md) — Detailed narrative and findings
- [Tableau Build Guide](dashboard/tableau_step_by_step.md) — Step-by-step dashboard instructions