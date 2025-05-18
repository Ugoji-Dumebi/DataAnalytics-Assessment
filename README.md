# SQL Solutions Documentation

## 1. Per-Question Explanations

### **High-Value Customers with Multiple Products**
**Objective**: Identify customers with both funded savings and investment plans.  
**Approach**:
- Used subqueries to isolate funded savings (`savings_savingsaccount.confirmed_amount > 0`) and investments (`plans_plan.amount > 0`).
- Joined results via `INNER JOIN` on `owner_id` to ensure cross-product ownership.
- Aggregated counts (`COUNT(DISTINCT)`) and totals (`SUM`) for clarity.
- Handled edge cases (e.g., missing names) with `COALESCE`.

### **Transaction Frequency Analysis**
**Objective**: Segment users by transaction frequency.  
**Approach**:
- Calculated monthly transaction counts per user using `DATE_FORMAT` and `GROUP BY`.
- Averaged transactions across months and categorized users via `CASE`:
  - **High Frequency**: ≥10/month.
  - **Medium Frequency**: 3-9/month.
  - **Low Frequency**: ≤2/month.
- Included inactive users via `LEFT JOIN` to `users_customuser`.

### **Account Inactivity Alert**
**Objective**: Flag accounts with no inflow transactions for over 365 days.  
**Approach**:
- Identified last transaction dates for savings (`MAX(transaction_date)`) and investments (`last_charge_date`).
- Merged results with `UNION ALL` and filtered accounts with `DATEDIFF(CURDATE(), last_transaction_date) > 365`.
- Explicitly checked active statuses (`is_archived=0`, `is_deleted=0`).

### **Customer Lifetime Value (CLV) Estimation**
**Objective**: Estimate CLV based on tenure and transaction volume.  
**Approach**:
- Derived tenure with `TIMESTAMPDIFF(MONTH, date_joined, CURDATE())`.
- Calculated total transactions (`COUNT`) and total transaction value (`SUM(confirmed_amount)`).
- Applied formula:  
  `CLV = (SUM(confirmed_amount) * 0.001 * 12) / tenure_months`.
- Handled division-by-zero for new users with `CASE`.

---

## 2. Key Challenges & Solutions

### **Challenge 1: Ambiguous Definitions**  
**Issue**: Clarifying "funded" status for savings and investments.  
**Solution**:  
- Used `confirmed_amount > 0` (savings) and `amount > 0` (investments) to filter funded transactions.

### **Challenge 2: Inactive Users**  
**Issue**: Missing transactions leading to skewed averages.  
**Solution**:  
- Used `LEFT JOIN` to include all users and `COALESCE` to default `NULL` values to `0`.

### **Challenge 3: Performance Optimization**  
**Issue**: Large datasets causing slow queries.  
**Solution**:  
- Reduced dataset size early via subquery filtering.
- Leveraged indexes on `owner_id` and `transaction_date`.

### **Challenge 4: Edge Cases**  
**Issue**: Division-by-zero in CLV for new users.  
**Solution**:  
- Added `CASE WHEN tenure_months = 0 THEN 0` to avoid errors.
- Used `COALESCE` to handle `NULL` transaction values.

---

## Final Notes  
These solutions balance clarity, performance, and edge-case handling. Each query aligns with the problem’s business logic while leveraging SQL’s aggregation and joining capabilities.
