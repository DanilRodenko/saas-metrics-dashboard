CREATE VIEW retention_by_plan AS
SELECT *,
    ROUND(retained_30d::NUMERIC / cohort_size, 2) AS retained_30d_pct,
    ROUND(retained_90d::NUMERIC / cohort_size, 2) AS retained_90d_pct,
    ROUND(retained_180d::NUMERIC / cohort_size, 2) AS retained_180d_pct
FROM (
    SELECT
        payment_profile.current_plan AS plan,
        COUNT(customer_lifecycle.customer_id) AS cohort_size,
        COUNT(CASE WHEN customer_lifecycle.subscribe_life >= 30 THEN customer_lifecycle.customer_id END) AS retained_30d,
        COUNT(CASE WHEN customer_lifecycle.subscribe_life >= 90 THEN customer_lifecycle.customer_id END) AS retained_90d,
        COUNT(CASE WHEN customer_lifecycle.subscribe_life >= 180 THEN customer_lifecycle.customer_id END) AS retained_180d
    FROM customer_lifecycle
    INNER JOIN payment_profile ON payment_profile.customer_id = customer_lifecycle.customer_id
    GROUP BY payment_profile.current_plan
    ORDER BY payment_profile.current_plan DESC
) AS plan_counts;

SELECT * FROM retention_by_plan;