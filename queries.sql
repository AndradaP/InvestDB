-- Select all users
SELECT * FROM Users;

-- Select a user by username
SELECT * FROM Users WHERE username = 'example_user';

-- Insert a new user
INSERT INTO Users (username, password_hash, email, full_name, financial_goal_1, financial_goal_2, financial_goal_3)
VALUES ('new_user', 'hashed_password', 'new_user@example.com', 'New User', 'save for a house', 'travel more', 'retire early');

-- Update user information
UPDATE Users
SET email = 'updated_email@example.com', full_name = 'Updated Name'
WHERE user_id = 1;

-- Delete a user by ID
DELETE FROM Users WHERE user_id = 1;

-- Select all accounts for a specific user
SELECT * FROM Accounts WHERE user_id = 1;

-- Insert a new account
INSERT INTO Accounts (user_id, account_type, account_number, balance)
VALUES (1, 'checking', '1234567890', 1000.00);

-- Update account balance
UPDATE Accounts
SET balance = 1500.00
WHERE account_id = 1;

-- Delete an account by ID
DELETE FROM Accounts WHERE account_id = 1;

-- Select all transactions for a specific account
SELECT * FROM Transactions WHERE account_id = 1;

-- Insert a new transaction
INSERT INTO Transactions (account_id, transaction_date, amount, category, description)
VALUES (1, '2024-01-01', 100.00, 'groceries', 'Bought groceries');

-- Update a transaction
UPDATE Transactions
SET amount = 120.00, description = 'Bought groceries and snacks'
WHERE transaction_id = 1;

-- Delete a transaction by ID
DELETE FROM Transactions WHERE transaction_id = 1;

-- Select all budgets for a specific user
SELECT * FROM Budgets WHERE user_id = 1;

-- Insert a new budget
INSERT INTO Budgets (user_id, category, monthly_limit, current_spending)
VALUES (1, 'groceries', 500.00, 100.00);

-- Update a budget
UPDATE Budgets
SET monthly_limit = 600.00, current_spending = 150.00
WHERE budget_id = 1;

-- Delete a budget by ID
DELETE FROM Budgets WHERE budget_id = 1;

-- Select all investment options
SELECT * FROM InvestmentOptions;

-- Insert a new investment option
INSERT INTO InvestmentOptions (investment_name, investment_type, risk_level, expected_return_rate)
VALUES ('Example Fund', 'ETF', 'Low', 5.00);

-- Update an investment option
UPDATE InvestmentOptions
SET expected_return_rate = 6.00
WHERE investment_id = 1;

-- Delete an investment option by ID
DELETE FROM InvestmentOptions WHERE investment_id = 1;

-- Select all investment recommendations for a specific user
SELECT * FROM UserInvestmentRecs WHERE user_id = 1;

-- Insert a new investment recommendation
INSERT INTO InvestmentRecs (user_id, investment_id, recommendation_date, reason)
VALUES (1, 1, '2024-01-01', 'diversify portfolio');

-- Update an investment recommendation
UPDATE InvestmentRecs
SET reason = 'updated reason for recommendation'
WHERE recommendation_id = 1;

-- Delete an investment recommendation by ID
DELETE FROM InvestmentRecs WHERE recommendation_id = 1;

-- Using a view to get the total balance for a user
SELECT * FROM UserTotalBalance WHERE user_id = 1;

-- Using a view to get the budget status for a user
SELECT * FROM UserBudgetStatus WHERE user_id = 1;

-- Using a view to get the investment recommendations for a user
SELECT * FROM UserInvestmentRecs WHERE user_id = 1;

-- Trigger to update account balance after a new transaction is inserted
DELIMITER //
CREATE TRIGGER update_balance_after_insert
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    UPDATE Accounts
    SET balance = balance + NEW.amount
    WHERE account_id = NEW.account_id;
END//
DELIMITER ;

-- Trigger to log changes to budgets
DELIMITER //
CREATE TRIGGER log_budget_changes
BEFORE UPDATE ON Budgets
FOR EACH ROW
BEGIN
    INSERT INTO BudgetChangeLog (budget_id, old_monthly_limit, new_monthly_limit)
    VALUES (OLD.budget_id, OLD.monthly_limit, NEW.monthly_limit);
END//
DELIMITER ;

-- CTE to calculate total spending per category for a specific user
WITH TotalSpendingPerCategory AS (
    SELECT category, SUM(amount) AS total_spent
    FROM Transactions
    WHERE account_id IN (SELECT account_id FROM Accounts WHERE user_id = 1)
    GROUP BY category
)
SELECT * FROM TotalSpendingPerCategory;

-- CTE to calculate monthly spending vs budget for a specific user
WITH MonthlySpending AS (
    SELECT category, SUM(amount) AS total_spent
    FROM Transactions
    WHERE account_id IN (SELECT account_id FROM Accounts WHERE user_id = 1)
    AND MONTH(transaction_date) = MONTH(CURDATE())
    AND YEAR(transaction_date) = YEAR(CURDATE())
    GROUP BY category
)
SELECT b.category, b.monthly_limit, ms.total_spent
FROM Budgets b
LEFT JOIN MonthlySpending ms ON b.category = ms.category
WHERE b.user_id = 1;
