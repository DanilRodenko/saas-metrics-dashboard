CREATE VIEW total_mmr_by_month AS
SELECT *,
    ROUND(
        (cumulative_mrr - LAG(cumulative_mrr) OVER (ORDER BY month_date))
        / NULLIF(LAG(cumulative_mrr) OVER (ORDER BY month_date), 0) * 100,
        2
    ) AS mom_growth_pct
FROM (
    SELECT *,
        SUM(total_mrr) OVER (ORDER BY month_date) AS cumulative_mrr
    FROM (
        SELECT *,
            (new_mrr + cancellation_mrr + reactivation_mrr + upgrade_mrr + downgrade_mrr) AS total_mrr
        FROM (
            SELECT
                DATE_TRUNC('month', transaction.transaction_date) AS month_date,
                SUM(CASE WHEN transaction.event_type = 'new' THEN current_plan.price ELSE 0 END) AS new_mrr,
                SUM(CASE WHEN transaction.event_type = 'cancellation' THEN -current_plan.price ELSE 0 END) AS cancellation_mrr,
                SUM(CASE WHEN transaction.event_type = 'reactivation' THEN current_plan.price ELSE 0 END) AS reactivation_mrr,
                SUM(CASE WHEN transaction.event_type = 'upgrade' THEN current_plan.price - old_plan.price ELSE 0 END) AS upgrade_mrr,
                SUM(CASE WHEN transaction.event_type = 'downgrade' THEN current_plan.price - old_plan.price ELSE 0 END) AS downgrade_mrr
            FROM transaction
            INNER JOIN plans AS current_plan ON transaction.plan_name = current_plan.plan_name
            LEFT JOIN plans AS old_plan ON transaction.previous_plan = old_plan.plan_name
            WHERE transaction.transaction_date < DATE_TRUNC('month', CURRENT_DATE)
            GROUP BY DATE_TRUNC('month', transaction.transaction_date)
        ) AS movements
    ) AS with_total
) AS with_cumulative
ORDER BY month_date;


SELECT * FROM total_mmr_by_month;