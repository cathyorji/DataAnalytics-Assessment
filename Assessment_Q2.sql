WITH monthly_transaction_counts AS (
    -- Calculate the number of transactions for each user per month
    SELECT
        u.id AS user_id,
        DATE_FORMAT(s.transaction_date, '%Y-%m') AS transaction_month, -- Extracts year-month from the transaction date
        COUNT(s.id) AS transaction_count
    FROM
        adashi_staging.users_customuser AS u
    JOIN
        adashi_staging.savings_savingsaccount AS s ON u.id = s.owner_id
    WHERE
        s.transaction_status IN ('success') -- Filter transactions 
    GROUP BY
        u.id, transaction_month
),
average_monthly_transactions AS (
    -- Calculate the average number of transactions per user
    SELECT
        user_id,
        avg(transaction_count) AS avg_transactions_per_month
    FROM
        monthly_transaction_counts
    GROUP BY
        user_id
)
-- Categorize users based on their average monthly transaction count
SELECT
    CASE
        WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(user_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month),2) AS avg_transactions_per_month
FROM
    average_monthly_transactions
GROUP BY
    frequency_category
