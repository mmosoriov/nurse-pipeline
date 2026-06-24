-- ============================================================
-- Query 2: Channel Effectiveness Analysis
-- ============================================================
-- Business Question: How does communication channel choice
-- affect specialist response time?
--
-- Expected Finding: Secure App Chat should drastically
-- outperform Legacy Pager in both response time and read rate.
-- Vocera Badge Call should have the fastest response due to
-- real-time voice communication.
-- ============================================================

-- Read rate computed across ALL messages (including unread);
-- Response lag computed only across read messages.
SELECT
    cl.channel,
    COUNT(*) AS total_messages,
    SUM(CASE WHEN cl.message_read_timestamp IS NOT NULL THEN 1 ELSE 0 END) AS messages_read,
    ROUND(100.0 * SUM(CASE WHEN cl.message_read_timestamp IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS read_rate_pct,
    ROUND(AVG(CASE WHEN cl.response_lag_minutes IS NOT NULL THEN cl.response_lag_minutes END), 1) AS avg_response_lag_min,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY cl.response_lag_minutes), 1) AS median_response_lag_min
FROM fact_communication_logs cl
GROUP BY cl.channel
ORDER BY avg_response_lag_min ASC;
