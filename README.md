# DataAnalytics-Assessment
## Overview

This readme outlines my approach to solving the data analyst assessment questions, the challenges I encountered, and the solutions I implemented. The assessment involved using SQL to analyze customer data and calculate key metrics.
For each question, I conducted a thorough analysis to determine the specific data requirements, necessary calculations, and the expected outputs. I developed SQL queries to extract, transform, and aggregate data from the relevant tables. Throughout the process, I accounted for potential edge cases, such as customers with no transactions or accounts that were created but not yet used, and implemented logic to handle them appropriately. My focus was on writing efficient, well-structured, and readable SQL queries by applying suitable joins, filters, and aggregation methods. I carefully tested each query to ensure accuracy and that all specified requirements were fully met.

### Approach

Here's a summary of my approach to each question:

*# Question 1: High-Value Customers with Multiple Products
The query aims to identify customers who have both a savings plan and an investment plan, and then calculate the total deposits made by those customers.
My approach was to first identify the customers who had both a savings and an investment plan. I achieved this by joining the users_customuser table with the plans_plan table using u.id = p.owner_id. This join allowed me to combine customer information with their plan details.
To ensure that I'm working with funded plans, I filtered the results using WHERE s.confirmed_amount > 0.
To determine if these customers have both a savings and an investment plan, I used conditional counting with COUNT(DISTINCT CASE WHEN ... THEN ... END).  Specifically,  COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.plan_id END) counts the distinct savings plans for each customer, and COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.plan_id END) counts the distinct investment plans.
I then used a GROUP BY clause to group the results by customer (u.id, u.name) and a HAVING clause to filter out any customers who didn't have at least one of each plan type.
Finally, I calculated the total deposits for each customer by summing the s.confirmed_amount and converting it from kobo to naira by dividing by 100. The results are ordered in descending order of total_deposits."
