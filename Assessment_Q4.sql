
SELECT DISTINCT
    u.id AS customer_id,
    CONCAT(u.first_name, " ", u.last_name) as name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,  -- Calculate the account tenure in months
    COUNT(s.id) AS total_transactions,
    ROUND((COUNT(s.id) /TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (AVG(s.confirmed_amount / 100 * 0.001)),2) AS estimated_clv -- Calculate the estimated CLV using the formula: (total_transactions / tenure_months) * 12 * average profit per transaction (0.1% of avg deposit), and round the result to 2 decimal places
FROM adashi_staging.users_customuser u
JOIN adashi_staging.savings_savingsaccount s ON u.id = s.owner_id
WHERE LOWER(s.transaction_status)='success'
GROUP BY u.id, u.name, u.date_joined
ORDER BY estimated_clv DESC;

