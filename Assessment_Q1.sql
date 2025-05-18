SELECT 
    u.id AS owner_id,
    COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
    COUNT(DISTINCT savings.plan_id) AS savings_count,  -- Use correct alias `savings`
    COUNT(DISTINCT investment_plans.id) AS investment_count,
    (IFNULL(SUM(savings.confirmed_amount), 0) + IFNULL(SUM(investment_plans.amount), 0)) AS total_deposits
FROM users_customuser u
-- Get funded savings plans (via savings_savingsaccount)
INNER JOIN (
    SELECT s.owner_id, s.plan_id, s.confirmed_amount
    FROM savings_savingsaccount s
    INNER JOIN plans_plan p ON s.plan_id = p.id
    WHERE 
        p.is_regular_savings = 1 
        AND s.confirmed_amount > 0  -- Funded savings
) savings ON u.id = savings.owner_id  -- Alias is `savings`, not `savings_plans`
-- Get funded investment plans (directly from plans_plan)
INNER JOIN (
    SELECT id, owner_id, amount 
    FROM plans_plan 
    WHERE 
        is_a_fund = 1 
        AND amount > 0  -- Funded investment
) investment_plans ON u.id = investment_plans.owner_id
GROUP BY u.id, name
HAVING 
    savings_count >= 1 
    AND investment_count >= 1
ORDER BY total_deposits DESC;
