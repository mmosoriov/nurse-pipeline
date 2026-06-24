# 📊 Tableau Public Dashboard: Step-by-Step Build Guide

## C3 Clinical Command Center: Consult Turnaround & Communication Friction

This guide walks you through building the executive dashboard in Tableau Public (web editor).

---

## Prerequisites

1. **Tableau Public Account**: Sign up free at [public.tableau.com](https://public.tableau.com)
2. **Processed CSV Files**: From the `data/processed/csv/` directory, you'll need:
   - `fact_consult_completions` (contains `time_to_bedside_hours`, `time_to_note_signed_hours`)
   - `fact_communication_logs` (contains `response_lag_minutes`, `channel`, `message_outcome`)
   - `fact_consult_orders` (contains `target_specialty`, `priority`, `order_timestamp`)
   - `agg_consult_friction` (contains `friction_score`, `dominant_channel`)
   - `agg_encounter_summary` (contains `estimated_excess_bed_days`, `total_nurse_messages_sent`)
   - `dim_encounters` (contains `admitting_unit`, `admit_timestamp`)

> **Note**: Spark outputs CSV files as `part-00000-*.csv` inside subdirectories. You may want to rename them for clarity before uploading (e.g., `fact_consult_completions.csv`).

---

## Step 1: Connect to Data

1. Go to [Tableau Public Web Editor](https://public.tableau.com/app/discover)
2. Click **Create** → **Web Authoring**
3. Click **Connect to Data** → **Upload from Computer**
4. Upload all 6 CSV files one at a time
5. After uploading, go to the **Data Source** tab:
   - Drag `fact_consult_orders` to the canvas
   - **Join** `fact_consult_completions` on `consult_order_id` (Inner Join)
   - **Join** `agg_consult_friction` on `consult_order_id` (Left Join)
   - **Join** `dim_encounters` on `encounter_id` (from `fact_consult_orders`) (Left Join)
   - **Join** `agg_encounter_summary` on `encounter_id` (Left Join)
6. Create a separate data source for `fact_communication_logs` (used for channel analysis)

### Data Relationship Diagram
```
fact_consult_orders (center)
  ├── fact_consult_completions  (on consult_order_id)
  ├── agg_consult_friction      (on consult_order_id)
  ├── dim_encounters            (on encounter_id)
  └── agg_encounter_summary     (on encounter_id)
```

---

## Step 2: Color Palette Setup

Before building visuals, set up the healthcare color palette:

| Color Name | Hex Code | Usage |
|:---|:---|:---|
| Deep Navy | `#1B4F72` | Primary / headers |
| Medium Blue | `#2E86C1` | Secondary elements |
| Green (Good) | `#27AE60` | On-target KPIs |
| Amber (Warning) | `#F39C12` | Warning KPIs |
| Red (Critical) | `#E74C3C` | Critical KPIs |
| Off-White (BG) | `#FDFEFE` | Dashboard background |

To apply custom colors in Tableau:
1. Right-click on color legend → **Edit Colors**
2. Click on each item → **Custom** → Enter hex code

---

## Step 3: Section 1 — KPI Scorecard (Top Row)

Create 4 individual sheets, each displaying one KPI as a large number.

### KPI 1: Avg. Time to Bedside (hrs)
1. New Worksheet → Rename to "KPI - Avg Time to Bedside"
2. Drag `time_to_bedside_hours` to **Text** on the Marks card
3. Change aggregation to **AVG**
4. Format: Number → 1 decimal place
5. **Color logic**:
   - Create a calculated field called `Bedside KPI Color`:
     ```
     IF AVG([Time To Bedside Hours]) < 4 THEN "Green"
     ELSEIF AVG([Time To Bedside Hours]) <= 6 THEN "Yellow"
     ELSE "Red"
     END
     ```
   - Drag this to **Color** on the Marks card
   - Assign: Green → `#27AE60`, Yellow → `#F39C12`, Red → `#E74C3C`
6. Set font size to 36pt bold
7. Add a subtitle: "Target: < 4.0 hours"

### KPI 2: Avg. Nurse Messages per Consult
1. New Worksheet → "KPI - Avg Messages"
2. Drag `friction_score` → **Text**, aggregation = **AVG**
3. Color logic (calculated field `Messages KPI Color`):
   ```
   IF AVG([Friction Score]) < 2 THEN "Green"
   ELSEIF AVG([Friction Score]) <= 4 THEN "Yellow"
   ELSE "Red"
   END
   ```
4. Format same as KPI 1

### KPI 3: Message Read Rate (%)
1. New Worksheet → "KPI - Read Rate"
2. Create calculated field `Read Rate`:
   ```
   SUM(IF NOT ISNULL([Message Read Timestamp]) THEN 1 ELSE 0 END) / COUNT([Message Id]) * 100
   ```
3. Drag to **Text**, format as percentage with 1 decimal
4. Color logic:
   ```
   IF [Read Rate] > 90 THEN "Green"
   ELSEIF [Read Rate] >= 80 THEN "Yellow"
   ELSE "Red"
   END
   ```

### KPI 4: Estimated Annual Excess Bed Cost ($)
1. New Worksheet → "KPI - Excess Cost"
2. Create calculated field: `Excess Cost = [Estimated Excess Bed Days] * 2500`
3. Drag SUM of `Excess Cost` to **Text**
4. Format as Currency, 0 decimal places
5. Always color `#E74C3C` (red) for urgency

---

## Step 4: Section 2 — Specialty Bottleneck Chart

1. New Worksheet → "Specialty Turnaround"
2. **Columns**: `AVG(time_to_bedside_hours)`
3. **Rows**: `target_specialty` (sorted descending by the measure)
4. **Chart Type**: Horizontal bar chart (swap rows/columns if needed)
5. **Color**:
   - Drag `AVG(time_to_bedside_hours)` to **Color**
   - Edit color: Diverging palette → Green-Red
   - Set center at 4.0 (the SLA target)
6. **Tooltip**: Add the following to the tooltip:
   ```
   Specialty: <target_specialty>
   Avg Time to Bedside: <AVG(time_to_bedside_hours)> hours
   Total Consults: <COUNT(consult_order_id)>
   ```
7. Add a **Reference Line** at 4.0 hours (dashed red) labeled "SLA Target"
8. Format axis labels with 1 decimal place

---

## Step 5: Section 3 — Communication Channel Effectiveness

1. New Worksheet → "Channel Effectiveness"
2. Use the `fact_communication_logs` data source
3. **Columns**: `channel`
4. **Rows**: `AVG(response_lag_minutes)` (Axis 1)
5. **Dual Axis**: Add `Read Rate %` (calculated field) as the second axis
   - Right-click → Dual Axis → Synchronize Axes
6. **Marks**:
   - First axis: Bar chart (response lag), color = `#2E86C1`
   - Second axis: Circle/line (read rate), color = `#E74C3C`
7. **Sort** channels by `AVG(response_lag_minutes)` ascending
8. Add reference labels showing the exact values

### Alternative: Grouped Bar Chart
If dual-axis is complex, create two side-by-side bars:
- Bar 1: Avg Response Lag (minutes) per channel
- Bar 2: Read Rate (%) per channel
- Color-code bars: Blue for lag, Green for read rate

---

## Step 6: Section 4 — Friction Heatmap

1. New Worksheet → "Friction Heatmap"
2. You'll need to create calculated fields from `message_sent_timestamp`:
   ```
   Day of Week = DATENAME('weekday', [Message Sent Timestamp])
   Hour Block = STR(DATEPART('hour', [Message Sent Timestamp]))
   ```
3. **Columns**: `Day of Week` (order: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
4. **Rows**: `Hour Block` (or group into 4-hour blocks: 0-3, 4-7, 8-11, 12-15, 16-19, 20-23)
5. **Color**: `AVG(response_lag_minutes)` on the Color card
   - Palette: Sequential → Orange-Red (darker = longer delays)
   - Adjust range: min = 0, max = ~50 minutes
6. **Mark Type**: Square
7. **Size**: Set to fill the cells completely
8. **Tooltip**:
   ```
   Day: <Day of Week>
   Hour: <Hour Block>
   Avg Response Lag: <AVG(response_lag_minutes)> min
   Message Count: <COUNT(message_id)>
   ```
9. **Expected pattern**: Friday evening through Sunday should show as the darkest "red zone"

---

## Step 7: Section 5 — Friction vs. Delay Scatter Plot

1. New Worksheet → "Friction vs Delay"
2. **Columns**: `friction_score` (from `agg_consult_friction`)
3. **Rows**: `time_to_bedside_hours` (from `fact_consult_completions`)
4. **Detail**: `consult_order_id` (to get individual dots)
5. **Color**: `target_specialty`
   - Use a categorical palette with 10 distinct colors
6. **Mark Type**: Circle, reduce size and opacity (~30% opacity) for dense areas
7. **Trend Line**:
   - Right-click in the chart → **Trend Lines** → **Show Trend Lines**
   - Select Linear trend line
   - This should show a positive correlation (more messages = longer delay)
8. **Tooltip**:
   ```
   Consult: <consult_order_id>
   Specialty: <target_specialty>
   Friction Score: <friction_score> messages
   Time to Bedside: <time_to_bedside_hours> hours
   ```

---

## Step 8: Add Interactive Filters

1. Go to your Dashboard (see Step 9)
2. Add the following filters (drag to the Filters shelf on the relevant sheets, then show filter):

### Date Range Selector
- Drag `admit_timestamp` (from `dim_encounters`) to Filters
- Select **Range of Dates**
- Show Filter → **Slider** style

### Specialty Dropdown
- Drag `target_specialty` to Filters
- Show Filter → **Single Value (Dropdown)**

### Unit Filter
- Drag `admitting_unit` to Filters
- Show Filter → **Multiple Values (Checkboxes)**

### Priority Filter
- Drag `priority` to Filters
- Show Filter → **Single Value (Dropdown)**

3. **Apply to All Worksheets Using This Data Source**:
   - Right-click each filter → **Apply to Worksheets** → **All Using This Data Source**

---

## Step 9: Assemble the Dashboard

1. Click **New Dashboard** tab
2. Set size: **Fixed → 1400 x 900 px** (or Automatic for responsive)
3. **Layout** (top to bottom):

```
┌─────────────────────────────────────────────────────────┐
│  TITLE: C3 Clinical Command Center                      │
│  Subtitle: Consult Turnaround & Communication Friction  │
├──────────┬──────────┬──────────┬──────────┬─────────────┤
│  KPI 1   │  KPI 2   │  KPI 3   │  KPI 4   │  FILTERS   │
│ Bedside  │ Messages │ Read Rate│ Excess $ │  (sidebar)  │
├──────────┴──────────┴──────────┴──────────┤             │
│  Specialty Bottleneck Chart               │             │
│  (Horizontal Bars)                        │             │
├─────────────────────┬─────────────────────┤             │
│  Channel            │  Friction           │             │
│  Effectiveness      │  Heatmap            │             │
│  (Grouped Bars)     │  (Heat Matrix)      │             │
├─────────────────────┴─────────────────────┤             │
│  Friction vs. Delay Scatter Plot          │             │
│  (with Trendline)                         │             │
└───────────────────────────────────────────┴─────────────┘
```

4. Drag each sheet from the sidebar into the appropriate position
5. Set the dashboard **Background Color** to `#FDFEFE`
6. **Title formatting**: Deep Navy `#1B4F72`, 24pt bold
7. **Border** each section with a light gray line

---

## Step 10: Final Formatting

1. **Fonts**: Use Tableau's built-in sans-serif fonts (similar to Inter/Roboto)
2. **Gridlines**: Minimize — light gray if needed
3. **Axis labels**: Clear, descriptive (e.g., "Average Time to Bedside (Hours)")
4. **Legend placement**: Bottom or right side, compact
5. **Remove** unnecessary sheet tabs

---

## Step 11: Publish

1. Click **File** → **Save to Tableau Public**
2. Name the workbook: `C3 Clinical Command Center`
3. Add tags: `Healthcare`, `Analytics`, `Nursing`, `Hospital`, `Consult`
4. Set visibility to **Public**
5. Copy the public URL
6. Paste the URL into `dashboard/tableau_public_link.md`

---

## Post-Publication Checklist

- [ ] All 5 visualizations render correctly
- [ ] All 4 filters work across all sheets
- [ ] KPI colors update dynamically based on data
- [ ] Tooltips display meaningful information
- [ ] Dashboard is responsive and looks professional
- [ ] Public URL is accessible without login

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|:---|:---|
| Dates not parsing | Ensure timestamp columns are recognized as Date/Time type in Data Source tab |
| Joins produce too many rows | Use Left Join instead of Inner Join for optional tables |
| Heatmap cells are uneven | Set Mark Type to Square, increase size to fill |
| Trend line not showing | Ensure both axes are continuous (green pills) |
| Filters not applying globally | Right-click filter → Apply to Worksheets → All Using This Data Source |
| CSV column names have spaces | Tableau auto-renames; use the renamed versions in calculated fields |
