WITH monthly_transactions AS (
    -- Calculate monthly transaction counts per user
    SELECT 
        owner_id,
        DATE_FORMAT(transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS transactions
    FROM savings_savingsaccount
    GROUP BY owner_id, transaction_month
),
user_averages AS (
    -- Compute average transactions per month for all users (including those with no transactions)
    SELECT 
        u.id AS owner_id,
        COALESCE(AVG(mt.transactions), 0) AS avg_transactions_per_month
    FROM users_customuser u
    LEFT JOIN monthly_transactions mt ON u.id = mt.owner_id
    GROUP BY u.id
),
categorized_users AS (
    -- Assign frequency categories based on averages
    SELECT 
        owner_id,
        avg_transactions_per_month,
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_averages
)
-- Final aggregation to count customers and calculate category averages
SELECT 
    frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM categorized_users
GROUP BY frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;
