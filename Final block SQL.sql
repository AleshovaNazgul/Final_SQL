CREATE DATABASE FINAL;
USE FINAL;
CREATE TABLE customers (
    Id_client INT PRIMARY KEY,
    Total_amount DECIMAL(10,2),
    Gender CHAR(1),
    Age INT,
    Count_city INT,
    Response_communcation TINYINT,  -- Предполагаем, что это флаг (0/1)
    Communication_3month INT,
    Tenure INT
);

CREATE TABLE transactions (
    date_new DATE,
    Id_check INT,
    ID_client INT,
    Count_products INT,
    Sum_payment DECIMAL(10,2),
    FOREIGN KEY (ID_client) REFERENCES customers(Id_client)
);

# Клиенты с непрерывной историей за год
WITH MonthlyTransactions AS (
  SELECT 
    ID_client,
    YEAR(date_new) AS year,
    MONTH(date_new) AS month,
    COUNT(*) AS transactions_in_month
  FROM transactions
  WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
  GROUP BY ID_client, year, month
),
ConsecutiveMonths AS (
  SELECT ID_client
  FROM MonthlyTransactions
  GROUP BY ID_client
  HAVING COUNT(DISTINCT CONCAT(year, month)) = 12
)
SELECT * FROM customers
WHERE Id_client IN (SELECT ID_client FROM ConsecutiveMonths);

# Средний чек за период, средняя сумма покупок за месяц
SELECT 
  ID_client,
  AVG(Sum_payment) AS avg_check_for_period,
  (SELECT AVG(Sum_payment) FROM transactions t2 WHERE t2.ID_client = t.ID_client AND date_new BETWEEN '2015-06-01' AND '2016-06-01') AS avg_monthly_spending
FROM transactions t
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY ID_client;

# Информация в разрезе месяцев
SELECT
  YEAR(date_new) AS year,
  MONTH(date_new) AS month,
  AVG(Sum_payment) AS avg_check,
  AVG(Count_products) AS avg_transactions,
  COUNT(DISTINCT ID_client) AS active_customers
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new);

# Соотношение M/F/NA по месяцам и доля затрат
SELECT
  YEAR(date_new) AS year,
  MONTH(date_new) AS month,
  Gender,
  COUNT(*) AS count_customers,
  SUM(Sum_payment) AS total_spent
FROM transactions
INNER JOIN customers USING (ID_client)
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY YEAR(date_new), MONTH(date_new), Gender
WITH ROLLUP;

# Анализ по возрастным группам
SELECT
  CASE 
    WHEN Age BETWEEN 18 AND 29 THEN '18-29'
    WHEN Age BETWEEN 30 AND 39 THEN '30-39'
    -- ... другие возрастные группы
    ELSE 'Unknown'
  END AS age_group,
  SUM(Sum_payment) AS total_spent,
  COUNT(*) AS total_transactions
FROM transactions
INNER JOIN customers USING (ID_client)
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group;
