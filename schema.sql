-- Users table: stores information about the users
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(255),
    financial_goal_1 VARCHAR(255),
    financial_goal_2 VARCHAR(255),
    financial_goal_3 VARCHAR(255)
);

-- Accounts table: stores information about different types of accounts users have
CREATE TABLE Accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    account_type VARCHAR(50) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    balance DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Transactions table: stores details about all transactions made in the accounts
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    category VARCHAR(255),
    description VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);

-- Budgets table: stores budget information set by users
CREATE TABLE Budgets (
    budget_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    category VARCHAR(255) NOT NULL,
    monthly_limit DECIMAL(15, 2) NOT NULL,
    current_spending DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Create a table to log budget changes
CREATE TABLE BudgetChangeLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    budget_id INT,
    old_monthly_limit DECIMAL(15, 2),
    new_monthly_limit DECIMAL(15, 2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (budget_id) REFERENCES Budgets(budget_id)
);

-- InvestmentOptions table: stores different investment options available
CREATE TABLE InvestmentOptions (
    investment_id INT AUTO_INCREMENT PRIMARY KEY,
    investment_name VARCHAR(255) NOT NULL,
    investment_type VARCHAR(50) NOT NULL,
    risk_level VARCHAR(50),
    expected_return_rate DECIMAL(5, 2)
);

-- InvestmentRecs table: stores investment recommendations for users
CREATE TABLE InvestmentRecs (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    investment_id INT NOT NULL,
    recommendation_date DATE NOT NULL,
    reason VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (investment_id) REFERENCES InvestmentOptions(investment_id)
);


-- Indexes to optimize queries
-- Index on user_id in Accounts for faster lookups
CREATE INDEX idx_user_id_accounts ON Accounts(user_id);

-- Index on account_id in Transactions for faster lookups
CREATE INDEX idx_account_id_transactions ON Transactions(account_id);

-- Index on user_id in Budgets for faster lookups
CREATE INDEX idx_user_id_budgets ON Budgets(user_id);

-- Index on user_id in InvestmentRecs for faster lookups
CREATE INDEX idx_user_id_investmentrecs ON InvestmentRecs(user_id);

-- Index on investment_id in InvestmentRecs for faster lookups
CREATE INDEX idx_investment_id_investmentrecs ON InvestmentRecs(investment_id);


-- Views to summarize user financial status
-- View to get total balance across all accounts for each user
CREATE VIEW UserTotalBalance AS
SELECT u.user_id, u.username, SUM(a.balance) AS total_balance
FROM Users u
JOIN Accounts a ON u.user_id = a.user_id
GROUP BY u.user_id, u.username;

-- View to get budget status for each user
CREATE VIEW UserBudgetStatus AS
SELECT u.user_id, u.username, b.category, b.monthly_limit, b.current_spending
FROM Users u
JOIN Budgets b ON u.user_id = b.user_id;

-- View to get investment recommendations for each user
CREATE VIEW UserInvestmentRecs AS
SELECT u.user_id, u.username, irec.recommendation_date, iopt.investment_name, irec.reason
FROM Users u
JOIN InvestmentRecs irec ON u.user_id = irec.user_id
JOIN InvestmentOptions iopt ON irec.investment_id = iopt.investment_id;
