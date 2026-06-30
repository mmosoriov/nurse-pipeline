-- ============================================================
-- Query 2: Communication Channel Effectiveness
-- ============================================================
-- Business Question: How does communication channel choice affect specialist response time?
--
-- Finding: Vocera Badge Call (real-time voice) fastest, phone call slowest
-- ============================================================

SELECT
    cl.channel,
    COUNT(*) AS total_messages,
    SUM(CASE WHEN cl.message_read_timestamp IS NOT NULL THEN 1 ELSE 0 END) AS messages_read,
    ROUND(100.0 * SUM(CASE WHEN cl.message_read_timestamp IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS read_rate_pct,
    ROUND(AVG(cl.response_lag_minutes), 1) AS avg_response_lag_min,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY cl.response_lag_minutes), 1) AS median_response_lag_min
FROM fact_communication_logs cl
WHERE cl.response_lag_minutes IS NOT NULL
GROUP BY cl.channel
ORDER BY avg_response_lag_min ASC;
