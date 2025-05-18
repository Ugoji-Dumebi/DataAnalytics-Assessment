SELECT
    u.id AS customer_id,
    COALESCE(u.name, CONCAT(u.first_name, ' ', u.last_name)) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND(
        CASE 
            WHEN TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) = 0 THEN 0 
            ELSE (COALESCE(SUM(s.confirmed_amount), 0) * 0.001 * 12) / TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())
        END, 
        2
    ) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
GROUP BY u.id, name
ORDER BY estimated_clv DESC;
