DROP VIEW ltv_overall;

CREATE VIEW ltv_overall AS
SELECT
    ROUND(AVG(monthly_arpu), 2) AS avg_arpu,
    ROUND(AVG(subscribe_life) / 30.44, 2) AS avg_lifespan_months,
    ROUND(AVG(monthly_arpu) * (AVG(subscribe_life) / 30.44), 2) AS overall_ltv
FROM (
    SELECT
        customer_id,
        ROUND(total_revenue / total_days, 2) AS monthly_arpu
    FROM (
        SELECT
            customer_id,
            SUM(price * period_days) AS total_revenue,
            SUM(period_days) AS total_days
        FROM plan_periods
        GROUP BY customer_id
    ) AS customer_totals
    WHERE total_days >= 30
) AS arpu_per_customer
JOIN customer_lifecycle ON arpu_per_customer.customer_id = customer_lifecycle.customer_id;

SELECT * FROM ltv_overall;

