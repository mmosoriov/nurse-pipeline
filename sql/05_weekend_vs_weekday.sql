-- ============================================================
-- Query 4: Weekend vs. Weekday Analysis
-- ============================================================
-- Business Question: How much slower are consults completed on weekends vs. weekdays?
--
-- Finding: Weekend + Night Shift slowest combination.
-- ============================================================

SELECT
    CASE
        WHEN EXTRACT(DOW FROM co.order_timestamp) IN (0, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    CASE
        WHEN EXTRACT(HOUR FROM co.order_timestamp) BETWEEN 7 AND 18 THEN 'Day Shift (7a-7p)'
        ELSE 'Night Shift (7p-7a)'
    END AS shift,
    COUNT(*) AS total_consults,
    ROUND(AVG(cc.time_to_bedside_hours), 2) AS avg_hours_to_bedside,
    ROUND(AVG(af.friction_score), 2) AS avg_messages_per_consult
FROM fact_consult_orders co
JOIN fact_consult_completions cc ON co.consult_order_id = cc.consult_order_id
JOIN agg_consult_friction af ON co.consult_order_id = af.consult_order_id
WHERE co.order_status = 'Completed'
GROUP BY day_type, shift
ORDER BY avg_hours_to_bedside DESC;
