# C3-Pipeline: Project Case Study

## Clinical Consult Communication & Care Analytics

### Author
**Mateo Osorio** — Data Analytics Portfolio Project

---

## The Problem

In hospital settings, bedside nurses serve as the de-facto communication hub between physicians and specialists. When a doctor orders a consult—say, "have Cardiology evaluate this patient"—the nurse is responsible for paging, calling, and messaging the specialist, often multiple times across fragmented channels: legacy pagers, secure chat apps, and voice badges.

This creates a **"telephone tag" bottleneck** that:
- Burns **45–60 minutes** of nurse time per shift on communication tasks alone
- Delays specialist consults, increasing patient **Length of Stay (LOS)**
- Contributes directly to **nurse burnout** and staff turnover

Hospital leadership—Chief Nursing Officers, Chief Medical Officers, and COOs—lack visibility into this friction. They know consults are slow but can't pinpoint *why*, *where*, or *how much it costs*.

---

## The Solution

I built **C3-Pipeline** (Clinical Consult Communication & Care Analytics), an end-to-end data analytics pipeline that:

1. **Generates** realistic synthetic hospital data simulating EHR and secure messaging platforms
2. **Processes** raw data through a PySpark ETL pipeline with feature engineering
3. **Analyzes** the data using DuckDB SQL queries answering 6 key business questions
4. **Visualizes** findings in a Tableau Public executive dashboard

The pipeline quantifies communication friction and identifies actionable bottlenecks for hospital leadership.

---

## Architecture

```
[Python Data Gen] → [Raw CSVs] → [PySpark ETL] → [Parquet + CSV] → [DuckDB SQL] → [Tableau Dashboard]
      ↓                                ↓                                  ↓
  10K encounters              Feature engineering              6 analytical queries
  30K consults               2 aggregated tables              Executive KPIs
  82K messages               Bottleneck validation            Specialist rankings
  25K completions            Dual format output               Cost estimation
```

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

## Skills Demonstrated

| Skill | Application |
|:---|:---|
| **Python** | Synthetic data generation with Faker, Pandas, NumPy |
| **PySpark** | ETL pipeline: cleaning, feature engineering, aggregation |
| **SQL** | Advanced DuckDB queries: CTEs, window functions, percentiles |
| **Data Modeling** | Star schema design, fact/dimension tables, FK relationships |
| **Data Visualization** | Tableau Public dashboard design with executive focus |
| **Healthcare Domain** | EHR/messaging data patterns, consult workflows, clinical terminology |
| **Statistical Analysis** | Correlation analysis, distribution-based data generation |
| **Version Control** | Git/GitHub repository management |

---

## Recommendations for Hospital Leadership

Based on the analysis, I recommend:

1. **Migrate from Legacy Pagers to Secure App Chat** — Potential 68% reduction in response lag
2. **Add weekend specialist coverage** for Cardiology and Psychiatry — 2.5 hour delay reduction
3. **Implement escalation workflows** — Auto-escalate consults after 4 hours without response
4. **Track friction scores** as a nursing quality metric — Target < 2 messages per consult
5. **Set specialty-specific SLAs** — Current data shows one-size-fits-all is unrealistic

---

## Future Enhancements

1. **ML-based SLA prediction** — Train a model to predict which consults will breach the 4-hour SLA based on specialty, time of day, and channel
2. **Nurse satisfaction correlation** — Integrate survey data to quantify the link between communication friction and burnout
3. **Real-time streaming** — Simulate a Kafka-based streaming pipeline for real-time consult tracking
4. **Natural Language Processing** — Analyze message text for sentiment and urgency classification
