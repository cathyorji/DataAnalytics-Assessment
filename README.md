# DataAnalytics-Assessment
## Overview

This readme outlines my approach to solving the data analyst assessment questions, the challenges I encountered, and the solutions I implemented. The assessment involved using SQL to analyze customer data and calculate key metrics.
For each question, I conducted a thorough analysis to determine the specific data requirements, necessary calculations, and the expected outputs. I developed SQL queries to extract, transform, and aggregate data from the relevant tables. Throughout the process, I accounted for potential edge cases, such as customers with no transactions or accounts that were created but not yet used, and implemented logic to handle them appropriately. My focus was on writing efficient, well-structured, and readable SQL queries by applying suitable joins, filters, and aggregation methods. I carefully tested each query to ensure accuracy and that all specified requirements were fully met.

### Approach

Here's a summary of my approach to each question:

#### Question 1 : High-Value Customers with Multiple Products
The query aims to identify customers who have both a savings plan and an investment plan, and then calculate the total deposits made by those customers.
My approach was to first identify the customers who had both a savings and an investment plan. I achieved this by joining the users_customuser table with the plans_plan table using u.id = p.owner_id. This join allowed me to combine customer information with their plan details.
To ensure that I'm working with funded plans, I filtered the results using WHERE s.confirmed_amount > 0 and transaction_status ="success". I chose to specifically filter for 'success' transactions in my deposit calculation, although 'reward' also indicates a non-zero amount, because 'success' more clearly aligns with the concept of a standard deposit made by a customer. The 'reward' status might represent a bonus or other incentive, which, while involving an inflow of funds, is not a typical deposit.
To determine if these customers have both a savings and an investment plan, I used conditional counting with COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.plan_id END) which counts the distinct savings plans for each customer, and COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.plan_id END) counts the distinct investment plans.
I then used a GROUP BY clause to group the results by customer (cp.user_id, cp.first_name, cp.last_name) and a HAVING clause to filter  customers who have at least one of each plan type. Finally, I calculated the total deposits for each customer by summing the s.confirmed_amount and converting it from kobo to naira by dividing by 100. The results are ordered in descending order of total_deposits."
#### Challenges:
I faced the following challenge:
Understanding confirmed_amount and transaction_status. I had to carefully analyze these fields in the savings_savingsaccount table to determine which transactions represented actual deposits. I observed that confirmed_amount represents the inflow of cash (deposits) and when confirmed_amount is zero, the transaction_status is often 'failed' or 'pending'.
When confirmed_amount is greater than zero, the transaction_status is typically 'success' or 'reward'. Therefore, I concluded that only transactions with confirmed_amount > 0 should be considered as deposits. 

#### Question 1 :  Transaction Frequency Analysis
The query aims to categorize customers based on their average monthly transaction frequency (how many transactions they make per month) and then provide a summary count for each category.
For Question 2, my approach was to categorize customers based on their average monthly transaction frequency. I used two Common Table Expressions (CTEs) to achieve this.

First, I created a CTE called monthly_transaction_counts. In this CTE, I joined the adashi_staging.users_customuser table with the adashi_staging.savings_savingsaccount table using u.id = s.owner_id to link user information with their transaction data. I then grouped the transactions by user and by month, using DATE_FORMAT(s.transaction_date, '%Y-%m'), and counted the number of transactions for each user in each month.  I included both 'success' and 'reward' transactions, as indicated by the WHERE s.transaction_status IN ('success', 'reward') clause, because both of these statuses indicate that a transaction was completed and should be counted towards a user's transaction frequency.

Next, I created a second CTE called average_monthly_transactions. This CTE took the results from the monthly_transaction_counts CTE and calculated the average number of transactions per user across all months using AVG(transaction_count).

Finally, in the main query, I categorized each user based on their avg_transactions_per_month into 'High Frequency' (>= 10 transactions), 'Medium Frequency' (3-9 transactions), or 'Low Frequency' (< 3 transactions) using a CASE statement. I then counted the number of users in each category using COUNT(user_id) and calculated the average number of transactions per month for each category using ROUND(AVG(avg_transactions_per_month),2).  The results are grouped by the frequency category."
