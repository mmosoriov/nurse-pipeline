-- ============================================================
-- Query 1: Consult Turnaround Time by Specialty
-- ============================================================
-- Business Question: What is the average consult turnaround time (order to bedside and order to note signed) by specialty?
--
-- Finding: Cardiology and Psychiatry as the slowest specialties.
-- ============================================================

SELECT
    co.target_specialty,
    COUNT(*) AS total_consults,
    ROUND(AVG(cc.time_to_bedside_hours), 2) AS avg_hours_to_bedside,
    ROUND(AVG(cc.time_to_note_signed_hours), 2) AS avg_hours_to_note_signed
FROM fact_consult_orders co
JOIN fact_consult_completions cc ON co.consult_order_id = cc.consult_order_id
WHERE co.order_status = 'Completed'
GROUP BY co.target_specialty
ORDER BY avg_hours_to_bedside DESC;
