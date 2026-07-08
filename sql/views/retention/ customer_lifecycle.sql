CREATE VIEW customer_lifecycle AS
    SELECT *,
       DATE_TRUNC('month', signup_date) as month_sign_up,
    (last_activity_date - signup_date) AS subscribe_life
FROM (
    SELECT DISTINCT
    customer_id,
    MIN(CASE WHEN event_type = 'new' THEN transaction_date END) OVER (PARTITION BY customer_id) AS signup_date,
    MAX(CASE WHEN event_type = 'cancellation' THEN transaction_date END) OVER (PARTITION BY customer_id) AS cancellation_date,
    MAX(transaction_date) OVER (PARTITION BY customer_id) AS last_activity_date
FROM transaction
) AS customer_dates;

SELECT * FROM customer_lifecycle LIMIT 10;