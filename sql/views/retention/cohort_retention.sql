DROP VIEW cohort_retention;

CREATE VIEW cohort_retention AS
SELECT *,
    CASE
        WHEN month_sign_up <= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '45 days'
        THEN ROUND(retained_30d::NUMERIC / cohort_size, 2)
        ELSE NULL
    END AS retained_30d_pct,
    CASE
        WHEN month_sign_up <= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '105 days'
        THEN ROUND(retained_90d::NUMERIC / cohort_size, 2)
        ELSE NULL
    END AS retained_90d_pct,
    CASE
        WHEN month_sign_up <= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '195 days'
        THEN ROUND(retained_180d::NUMERIC / cohort_size, 2)
        ELSE NULL
    END AS retained_180d_pct
FROM (
    SELECT
        customer_lifecycle.month_sign_up AS month_sign_up,
        COUNT(customer_lifecycle.customer_id) AS cohort_size,
        COUNT(CASE WHEN customer_lifecycle.subscribe_life >= 30 THEN customer_lifecycle.customer_id END) AS retained_30d,
        COUNT(CASE WHEN customer_lifecycle.subscribe_life >= 90 THEN customer_lifecycle.customer_id END) AS retained_90d,
        COUNT(CASE WHEN customer_lifecycle.subscribe_life >= 180 THEN customer_lifecycle.customer_id END) AS retained_180d
    FROM customer_lifecycle
    GROUP BY month_sign_up
    ORDER BY month_sign_up
) AS cohort_counts;