-- ============================================================
-- Query 3: Friction Analysis
-- ============================================================
-- Business Question: Is there a correlation between the number of nurse outreach messages and the consult turnaround time?
--
-- Finding: No statistical significance
-- ============================================================

WITH friction_buckets AS (
    SELECT
        af.consult_order_id,
        af.friction_score,
        CASE
            WHEN af.friction_score = 1 THEN '1 message'
            WHEN af.friction_score BETWEEN 2 AND 3 THEN '2-3 messages'
            WHEN af.friction_score BETWEEN 4 AND 5 THEN '4-5 messages'
            ELSE '6+ messages'
        END AS friction_bucket,
        cc.time_to_bedside_hours
    FROM agg_consult_friction af
    JOIN fact_consult_completions cc ON af.consult_order_id = cc.consult_order_id
)
SELECT
    friction_bucket,
    COUNT(*) AS consult_count,
    ROUND(AVG(time_to_bedside_hours), 2) AS avg_hours_to_bedside,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY time_to_bedside_hours), 2) AS median_hours_to_bedside
FROM friction_buckets
GROUP BY friction_bucket
ORDER BY avg_hours_to_bedside ASC;
