-- ============================================================
-- Query 6: Specialist Performance Leaderboard
-- ============================================================
-- Business Question: Which individual specialists have the longest average response times?
-- ============================================================

WITH specialist_stats AS (
    SELECT
        cc.specialist_id,
        cc.specialist_name,
        co.target_specialty,
        COUNT(*) AS consults_completed,
        ROUND(AVG(cc.time_to_bedside_hours), 2) AS avg_hours_to_bedside,
        ROUND(AVG(af.friction_score), 2) AS avg_friction_score
    FROM fact_consult_completions cc
    JOIN fact_consult_orders co ON cc.consult_order_id = co.consult_order_id
    JOIN agg_consult_friction af ON co.consult_order_id = af.consult_order_id
    GROUP BY cc.specialist_id, cc.specialist_name, co.target_specialty
    HAVING COUNT(*) >= 10
)
SELECT
    *,
    RANK() OVER (PARTITION BY target_specialty ORDER BY avg_hours_to_bedside DESC) AS rank_in_specialty
FROM specialist_stats
ORDER BY target_specialty, rank_in_specialty;
