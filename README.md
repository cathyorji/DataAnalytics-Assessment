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
