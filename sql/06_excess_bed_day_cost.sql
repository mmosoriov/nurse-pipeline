-- ============================================================
-- Query 5: Excess Bed-Day Cost Estimation
-- ============================================================
-- Business Question: What is the estimated financial cost of consult-related discharge delays?
--
-- Assumption: Average hospital bed cost = $2,500/day.
-- ============================================================

WITH encounter_delays AS (
    SELECT
        de.encounter_id,
        de.admitting_unit,
        de.primary_diagnosis_desc,
        aes.length_of_stay_days,
        aes.estimated_excess_bed_days,
        aes.total_nurse_messages_sent,
        ROUND(aes.estimated_excess_bed_days * 2500, 2) AS estimated_excess_cost_usd
    FROM dim_encounters de
    JOIN agg_encounter_summary aes ON de.encounter_id = aes.encounter_id
    WHERE de.discharge_timestamp IS NOT NULL
      AND aes.estimated_excess_bed_days > 0.5
)
SELECT
    admitting_unit,
    COUNT(*) AS encounters_with_delay,
    ROUND(AVG(estimated_excess_bed_days), 2) AS avg_excess_bed_days,
    ROUND(SUM(estimated_excess_cost_usd), 0) AS total_estimated_cost_usd,
    ROUND(AVG(total_nurse_messages_sent), 1) AS avg_nurse_messages
FROM encounter_delays
GROUP BY admitting_unit
ORDER BY total_estimated_cost_usd DESC;
