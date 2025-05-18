WITH active_savings AS (
    -- Active savings plans with their last inflow transaction date
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        'Savings' AS type,
        MAX(s.transaction_date) AS last_transaction_date
    FROM plans_plan p
    LEFT JOIN savings_savingsaccount s 
        ON p.id = s.plan_id 
        AND s.confirmed_amount > 0  -- Filter for inflow transactions
    WHERE 
        p.is_regular_savings = 1   -- Savings plans
        AND p.is_archived = 0       -- Active status
        AND p.is_deleted = 0
    GROUP BY p.id, p.owner_id
    HAVING last_transaction_date IS NOT NULL  -- Ensure at least one transaction
),

active_investments AS (
    -- Active investment plans with their last charge (inflow) date
    SELECT 
        id AS plan_id,
        owner_id,
        'Investment' AS type,
        last_charge_date AS last_transaction_date
    FROM plans_plan
    WHERE 
        is_a_fund = 1              -- Investment plans
        AND is_archived = 0         -- Active status
        AND is_deleted = 0
        AND amount > 0              -- Funded
        AND last_charge_date IS NOT NULL  -- Valid transaction date
)

-- Combine and filter results
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days
FROM (
    SELECT * FROM active_savings
    UNION ALL
    SELECT * FROM active_investments
) AS combined
WHERE 
    DATEDIFF(CURDATE(), last_transaction_date) > 365  -- No transactions in the last year
ORDER BY last_transaction_date;
