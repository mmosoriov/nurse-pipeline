-- ============================================================
-- Query 1: Average Consult Turnaround Time by Specialty
-- ============================================================
-- Business Question: What is the average consult turnaround time
-- (order to note signed) by specialty?
--
-- Expected Finding: Cardiology and Psychiatry should have the
-- longest average turnaround times, significantly exceeding
-- the 4-hour SLA target.
-- ============================================================

SELECT
    co.target_specialty,
    COUNT(*) AS total_consults,
    ROUND(AVG(cc.time_to_bedside_hours), 2) AS avg_hours_to_bedside,
    ROUND(AVG(cc.time_to_note_signed_hours), 2) AS avg_hours_to_note_signed,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY cc.time_to_bedside_hours), 2) AS median_hours_to_bedside,
    ROUND(PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY cc.time_to_bedside_hours), 2) AS p90_hours_to_bedside
FROM fact_consult_orders co
JOIN fact_consult_completions cc ON co.consult_order_id = cc.consult_order_id
WHERE co.order_status = 'Completed'
GROUP BY co.target_specialty
ORDER BY avg_hours_to_bedside DESC;
