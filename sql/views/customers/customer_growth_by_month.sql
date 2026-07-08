CREATE VIEW customer_growth_by_month AS
SELECT
    month_date,
    new_customers,
    cancelled_customers,
    (new_customers + cancelled_customers) AS net_customer_growth,
    SUM(new_customers + cancelled_customers) OVER (ORDER BY month_date) AS cumulative_customers
FROM (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month_date,
        COUNT(CASE WHEN event_type = 'new' THEN 1 END) AS new_customers,
        -COUNT(CASE WHEN event_type = 'cancellation' THEN 1 END) AS cancelled_customers
    FROM transaction
    WHERE transaction_date < DATE_TRUNC('month', CURRENT_DATE)
    GROUP BY DATE_TRUNC('month', transaction_date)
) AS counts
ORDER BY month_date;

SELECT * FROM customer_growth_by_month;