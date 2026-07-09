CREATE VIEW plan_periods AS
SELECT
    next_transaction.*,
    plans.price,
    CASE
        WHEN next_transaction.event_type = 'cancellation' THEN 0
        ELSE (COALESCE(next_transaction.next_transaction_date, CURRENT_DATE) - next_transaction.transaction_date)
    END AS period_days
FROM (
    SELECT
        customer_id,
        transaction_date,
        event_type,
        plan_name,
        LEAD(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS next_transaction_date
    FROM transaction) AS next_transaction
INNER JOIN plans ON plans.plan_name = next_transaction.plan_name;