-- Table Exploration
RENAME TABLE customer_records TO Customer_Churn;

SHOW TABLES; 

SELECT * FROM Customer_Churn
LIMIT 5;

SELECT COUNT(*) AS `Total Rows` FROM Customer_Churn;

-- Data Quality check table-- 
SELECT CustomerId
FROM Customer_Churn AS Frequency
GROUP BY CustomerID
HAVING COUNT(*) > 1; 

SELECT
    SUM(CustomerId IS NULL) AS CustomerId_nulls,
    SUM(Surname IS NULL) AS Surname_nulls,
    SUM(CreditScore IS NULL) AS CreditScore_nulls,
    SUM(Geography IS NULL) AS Geography_nulls,
    SUM(Gender IS NULL) AS Gender_nulls,
    SUM(Age IS NULL) AS Age_nulls,
    SUM(Tenure IS NULL) AS Tenure_nulls,
    SUM(Balance IS NULL) AS Balance_nulls,
    SUM(NumOfProducts IS NULL) AS NumOfProducts_nulls,
    SUM(HasCrCard IS NULL) AS HasCrCard_nulls,
    SUM(IsActiveMember IS NULL) AS IsActiveMember_nulls,
    SUM(EstimatedSalary IS NULL) AS EstimatedSalary_nulls,
    SUM(Exited IS NULL) AS Exited_nulls
FROM Customer_Churn;

-- Value Range check table 

SELECT
    MIN(CreditScore) AS min_creditscore, MAX(CreditScore) AS max_creditscore,
    MIN(Age) AS min_age, MAX(Age) AS max_age,
    MIN(Tenure) AS min_tenure, MAX(Tenure) AS max_tenure,
    MIN(Balance) AS min_balance, MAX(Balance) AS max_balance,
    MIN(EstimatedSalary) AS min_salary, MAX(EstimatedSalary) AS max_salary
FROM Customer_Churn;
 
-- Adding Columns (AgeGroup)
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE Customer_Churn
ADD COLUMN AgeGroup VARCHAR(20);

UPDATE Customer_Churn
SET AgeGroup = CASE
    WHEN Age < 25 THEN '<25'
    WHEN Age BETWEEN 25 AND 34 THEN '25-34'
    WHEN Age BETWEEN 35 AND 44 THEN '35-44'
    WHEN Age BETWEEN 45 AND 54 THEN '45-54'
    WHEN Age BETWEEN 55 AND 64 THEN '55-64'
    ELSE '65+'
END;

SELECT Age, AgeGroup FROM Customer_Churn LIMIT 10;

-- Adding Column (Balance Category) 
ALTER TABLE Customer_Churn
ADD COLUMN BalanceCategory VARCHAR(20);

UPDATE Customer_Churn
SET BalanceCategory = CASE
    WHEN Balance < 50000 THEN 'Low'
    WHEN Balance BETWEEN 50000 AND 150000 THEN 'Medium'
    WHEN Balance BETWEEN 150001 AND 250000 THEN 'High'
    ELSE 'Very High'
END;  

SELECT BalanceCategory, Balance FROM Customer_Churn;

-- Adding Column (TenureCategory) 
ALTER TABLE Customer_Churn
ADD COLUMN Tenure_Category VARCHAR(20);

UPDATE Customer_Churn
SET Tenure_Category = CASE
    WHEN Tenure <= 3 THEN 'New'
    WHEN Tenure BETWEEN 4 AND 6 THEN 'Experienced'
    WHEN Tenure BETWEEN 7 AND 10 THEN 'Loyal'
    ELSE 'Veteran'
END; 

SELECT Tenure, Tenure_Category FROM Customer_Churn
ORDER BY Tenure DESC
LIMIT 10;

-- Churn Rate Analysis 
-- Churn percentage
SELECT 
COUNT(*) AS `Total Customers`,
SUM(Exited) AS `Churned_Customers`,
ROUND(AVG(Exited) * 100, 2) AS `Churn Percentage`
FROM Customer_Churn;

-- Total Customers = 10,000
-- Churned_Customers = 2038
-- Churn Percentage = 20.38 %

-- Churn % by Gender
SELECT 
COUNT(*) AS `Total Customers`,
SUM(Exited) AS `Churned Customers`,
ROUND(AVG(Exited) * 100, 2) AS Churn_Percentage
FROM Customer_Churn
GROUP BY Gender;

-- Total Males - 4543 // Churned Cutomers - 1139 // Churn Percentage - 25.07%
-- Total Females - 5457 // Churned Customers - 899 // Churn Percentage - 16.47%

-- Churn By Age
SELECT 
  CASE 
    WHEN Age BETWEEN 18 AND 25 THEN '18–25'
    WHEN Age BETWEEN 26 AND 35 THEN '26–35'
    WHEN Age BETWEEN 36 AND 45 THEN '36–45'
    WHEN Age BETWEEN 46 AND 60 THEN '46–60'
    ELSE '61+' 
  END AS Age_Group,
  COUNT(*) AS Total_Customers,
  SUM(Exited) AS Churned_Customers,
  ROUND(AVG(Exited) * 100, 2) AS Churn_Rate
FROM Customer_Churn
GROUP BY Age_Group
ORDER BY Age_Group;

-- Churn By Balance
SELECT
  CASE 
    WHEN Balance < 50000 THEN 'Low Balance'
    WHEN Balance BETWEEN 50000 AND 150000 THEN 'Medium Balance'
    ELSE 'High Balance'
  END AS `Balance Category`,
  COUNT(*) AS `Total Customers`,
  SUM(Exited) AS `Total Churned Customers`,
  ROUND(AVG(Exited) * 100, 2) AS `Churn Percentage`
FROM Customer_Churn 
GROUP BY `Balance Category`
ORDER BY MIN(Balance);

-- Geography Wise Churn-Analysis
SELECT Geography AS Region,
COUNT(*) AS `Total Customers`,
SUM(Exited) AS `Total Churned Customers`,
ROUND(AVG(Exited) * 100, 2) AS Churn_Percentage
FROM Customer_Churn
GROUP BY Geography
ORDER BY Churn_Percentage;

-- Analysis By Credit Score
SELECT 
  CASE 
    WHEN CreditScore <= 600 THEN 'Low Credit Score'
    WHEN CreditScore BETWEEN 600 AND 750 THEN 'Medium Credit Score'
    ELSE 'High Credit Score'
  END AS `Credit Score Category`,
  SUM(Exited) AS `Total Churned Customers`,
  ROUND(AVG(Exited) * 100, 2) AS `Churn Percentage`
FROM Customer_Churn
GROUP BY `Credit Score Category`
ORDER BY MIN(CreditScore);

-- Churn Rate Analysis By No. Of Products
SELECT
  CASE 
    WHEN NumOfProducts = 1 THEN '1 Product'
    WHEN NumOfProducts = 2 THEN '2 Products'
    ELSE '3+ Products'
  END AS Product_Category,
  SUM(Exited) AS Total_Churned_Customers,
  ROUND(AVG(Exited) * 100, 2) AS Churn_Percentage
FROM Customer_Churn
GROUP BY Product_Category
ORDER BY MIN(NumOfProducts);

-- Analysis By Tenure
SELECT
  CASE 
    WHEN Tenure <= 3 THEN 'New Customers'
    WHEN Tenure BETWEEN 4 AND 7 THEN 'Mid-Term Customers'
    ELSE 'Long-Term Customers'
  END AS `Tenure Category`,
  COUNT(*) AS `Total Customers`,
  SUM(Exited) AS `Total Churned Customers`,
  ROUND(AVG(Exited) * 100, 2) AS `Churn Rate`
FROM Customer_Churn
GROUP BY `Tenure Category`
ORDER BY  
  CASE 
    WHEN `Tenure Category` = 'New Customers' THEN 1
    WHEN `Tenure Category` = 'Mid-Term Customers' THEN 2
    ELSE 3
  END;

-- Analysis By Credit Card Possesion
SELECT
  CASE
    WHEN HasCrCard = 1 THEN 'Has Credit Card'
    ELSE 'No Credit Card'
  END AS `Credit Card Status`,
  COUNT(*) AS `Total Customers`,
  SUM(Exited) AS `Total Churned Customers`,
  ROUND(AVG(Exited) * 100, 2) AS `Churn Percentage`
FROM Customer_Churn
GROUP BY HasCrCard
ORDER BY HasCrCard DESC;

-- Analysis By Membership
SELECT
  CASE
    WHEN IsActiveMember = 1 THEN 'Active Member'
    ELSE 'Inactive Member'
  END AS `Membership Status`,
  COUNT(*) AS `Total Customers`,
  SUM(Exited) AS `Total Churned Customers`,
  ROUND(AVG(Exited) * 100, 2) AS `Churn Percentage`
FROM Customer_Churn
GROUP BY IsActiveMember
ORDER BY IsActiveMember DESC;

-- Final Analysis By Estimated Salary
SELECT 
  CASE 
    WHEN EstimatedSalary < 66666 THEN 'Low Income'
    WHEN EstimatedSalary BETWEEN 66666 AND 133333 THEN 'Mid Income'
    ELSE 'High Income'
  END AS `Salary Category`,
  COUNT(*) AS `Total Customers`,
  SUM(Exited) AS `Total Churned Customers`,
  ROUND(AVG(Exited) * 100, 2) AS `Churn Percentage`
FROM Customer_Churn
GROUP BY `Salary Category`
ORDER BY `Churn Percentage` DESC;

-- -- Analysis End -- --
