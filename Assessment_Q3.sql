-- CTE to identify active accounts and calculate their last transaction date and inactivity
WITH last_transactions AS(
SELECT 
    p.id AS plan_id,
    p.owner_id,
    p.created_on,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
    END AS type,
    CASE
        WHEN MAX(s.transaction_date) IS NULL THEN p.created_on
        ELSE MAX(s.transaction_date)
    END AS last_transaction_date,
	DATEDIFF(CURDATE(),  -- Calculate the difference in days between the current date and the last activity date
                 CASE 
                     WHEN MAX(s.transaction_date) IS NULL THEN p.created_on -- If there are no transactions, use the plan's creation date
                     ELSE MAX(s.transaction_date)  -- Otherwise, use the date of the last transaction
                 END) AS inactivity_days 

FROM
    adashi_staging.plans_plan p
LEFT JOIN
    adashi_staging.savings_savingsaccount s ON p.id = s.plan_id
WHERE
    p.is_deleted = 0 -- this will filter out accounts that are not deleted from the database
    AND p.is_archived = 0 -- this will filter accounts that are not archived in the database
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
GROUP BY
    1, 2, 3
HAVING last_transaction_date < DATE_SUB(CURDATE(), INTERVAL 365 DAY)) -- Filter out accounts that has not transacted for over 365 days

-- Final SELECT statement to retrieve the plan details of active accounts that has not transacted for over 1 year.
SELECT 
  plan_id, 
  owner_id, 
  type, 
  last_transaction_date, 
  inactivity_days
FROM last_transactions;
