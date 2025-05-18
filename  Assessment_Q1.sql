-- This CTE selects customer information and plan details
WITH CustomerPlans AS (
    SELECT
        u.id AS user_id,
        u.first_name,
        u.last_name,
        p.id AS plan_id,
        p.is_regular_savings,
        p.is_a_fund
    FROM
        adashi_staging.users_customuser u
    JOIN
        adashi_staging.plans_plan p ON u.id = p.owner_id
),
TransactionDetails AS (
    SELECT
        s.owner_id,
        s.plan_id,
        s.confirmed_amount,
        s.transaction_status
    FROM
        adashi_staging.savings_savingsaccount s
    WHERE
        s.confirmed_amount > 0 -- Filter to include only funded transactions (inflow)
)
-- Main query to retrieve customer details and calculate plan information
SELECT
    cp.user_id AS owner_id,
    CONCAT(cp.first_name, ' ', cp.last_name) AS name,
    COUNT(DISTINCT CASE WHEN cp.is_regular_savings = 1 THEN cp.plan_id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN cp.is_a_fund = 1 THEN cp.plan_id END) AS investment_count,
    ROUND(SUM(CASE WHEN LOWER(td.transaction_status) = 'success' THEN td.confirmed_amount ELSE 0 END) / 100, 2) AS total_deposits -- Convert from kobo to naira (assuming division by 100) and round to 2 decimal places
FROM
    CustomerPlans cp
JOIN
    TransactionDetails td ON cp.plan_id = td.plan_id AND cp.user_id = td.owner_id
GROUP BY
    cp.user_id, cp.first_name, cp.last_name
HAVING
    COUNT(DISTINCT CASE WHEN cp.is_regular_savings = 1 THEN cp.plan_id END) >= 1
    AND COUNT(DISTINCT CASE WHEN cp.is_a_fund = 1 THEN cp.plan_id END) >= 1
ORDER BY
    total_deposits DESC;