# DataAnalytics-Assessment
## Overview

This readme outlines my approach to solving the data analyst assessment questions, the challenges I encountered, and the solutions I implemented. The assessment involved using SQL to analyze customer data and calculate key metrics.
For each question, I conducted a thorough analysis to determine the specific data requirements, necessary calculations, and the expected outputs. I developed SQL queries to extract, transform, and aggregate data from the relevant tables. Throughout the process, I accounted for potential edge cases, such as customers with no transactions or accounts that were created but not yet used, and implemented logic to handle them appropriately.

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
Understanding confirmed_amount and transaction_status. I had to carefully analyze these fields in the savings_savingsaccount table to determine which transactions represented actual deposits. I observed that confirmed_amount represents the inflow of cash (deposits) and when confirmed_amount is zero, the transaction_status is often 'failed' or 'pending',"abandoned","reversal" etc.
When confirmed_amount is greater than zero, the transaction_status is typically 'success' or 'reward'. Therefore, I concluded that only transactions with confirmed_amount > 0 should be considered as deposits. 

#### Question 2 :  Transaction Frequency Analysis
The query aims to categorize customers based on their average monthly transaction frequency (how many transactions they make per month) and then provide a summary count for each category.
For Question 2, my approach was to categorize customers based on their average monthly transaction frequency. I used two Common Table Expressions (CTEs) to achieve this.

First, I created a CTE called monthly_transaction_counts. In this CTE, I joined the adashi_staging.users_customuser table with the adashi_staging.savings_savingsaccount table using u.id = s.owner_id to link user information with their transaction data. I then grouped the transactions by user and by month, using DATE_FORMAT(s.transaction_date, '%Y-%m'), and counted the number of transactions for each user in each month. 

Next, I created a second CTE called average_monthly_transactions. This CTE took the results from the monthly_transaction_counts CTE and calculated the average number of transactions per user across all months using AVG(transaction_count).

Finally, in the main query, I categorized each user based on their avg_transactions_per_month into 'High Frequency' (>= 10 transactions), 'Medium Frequency' (3-9 transactions), or 'Low Frequency' (< 3 transactions) using a CASE statement. I then counted the number of users in each category using COUNT(user_id) and calculated the average number of transactions per month for each category using ROUND(AVG(avg_transactions_per_month),2).  The results are grouped by the frequency category."

#### Challenges:
I faced the following challenge:
Determining whether 'reward' transactions should be included in the calculation of transaction frequency. I decided to exclude them because, like 'success' transactions, they represent completed transactions and also indicate user activity, which is not relevant to measuring frequency. 'Success' transactions clearly indicate a user actively using the platform to make a transaction and 'Reward' transactions, while not initiated by the user in the same way, do represent a completed interaction where the user received value. But this question, which asks for the average number of transactions per customer per month, it's wise I focus on the core financial transactions that drive the platform's primary function which is deposit. I decided to filter for transaction_status = 'success' and excluding transactions with a status of "reward" unless there's a reason to believe they represent  user activity in the context of the question.

#### Question 3 : Account Inactivity Alert

For Question 3, my approach was to identify savings and investment accounts that have been inactive for one year. I used a Common Table Expression (CTE) called last_transactions to achieve this.

In the last_transactions CTE, I joined the adashi_staging.plans_plan table with the adashi_staging.savings_savingsaccount table using a LEFT JOIN on p.id = s.plan_id.  This allowed me to include plans even if they had no transactions yet. I determined the type of plan ('Savings' or 'Investment') using a CASE statement based on the p.is_regular_savings and p.is_a_fund.
A key part of this query was determining the last transaction date. I noticed that some account are active but have not performed any transaction since inception. I decided to use a CASE statement with MAX(s.transaction_date) to find plans with no transactions (MAX(s.transaction_date) is NULL), I used the plan's creation date (p.created_on), otherwise, I used the date of the most recent transaction.
I then calculated the number of days of inactivity (inactivity_days) by subtracting the last_transaction_date from the current date using DATEDIFF(CURDATE(),  
                 CASE 
                     WHEN MAX(s.transaction_date) IS NULL THEN p.created_on -- If there are no transactions, use the plan's creation date
                     ELSE MAX(s.transaction_date)  -- Otherwise, use the date of the last transaction
                 END) AS inactivity_days ).

From my analysis on the table, i saw two columns is_deleted and is_archived having a "0" for active accounts and "1" for deleted or archived account. So I filtered the plans to include only those that are not deleted (p.is_deleted = 0), not archived (p.is_archived = 0), and are either savings or investment plans.
Finally, I used a HAVING clause to filter for plans where the last_transaction_date was more than 365 days (1 year) before the current date. The main query then selects the plan details (plan_id, owner_id, type, last_transaction_date, and inactivity_days) from the last_transactions CTE.

#### Challenges:
I faced the following challenge:
Correctly accounting for plans that have never had a transaction. The challenge was that MAX(s.transaction_date) would return NULL for these plans, which would cause issues when calculating inactivity.  I solved this by using a CASE statement: If MAX(s.transaction_date) is NULL, meaning there are no transactions, the last_transaction_date is set to the plan's creation date (p.created_on).
Otherwise, the last_transaction_date is set to the actual MAX(s.transaction_date).  This ensures that even for plans with no transactions, we have a date to use for the inactivity calculation, effectively using the creation date as the "last activity" date.

#### Question 4 : Customer Lifetime Value (CLV) Estimation
I calculated the Customer Lifetime Value (CLV) for each customer by joining the users_customuser table with the savings_savingsaccount table using u.id = s.owner_id to link customer information with their transaction data.
I calculated the account tenure in months using TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()).
I counted the total number of transactions for each customer using COUNT(s.id) and then estimated the CLV using the following formula: (COUNT(s.id) /TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())) * 12 * (SUM(s.confirmed_amount) / 100 * 0.001)

