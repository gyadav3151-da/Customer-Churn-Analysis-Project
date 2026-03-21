-- Customer Churn Analysis
-- Author: Gaurav Yadav
-- Description: SQL scripts of final table used for data preparation and analysis

/* =============================================
   CREATE DATABASE AND SELECT IT
============================================= */
IF DB_ID('CustomerChurnDB') IS NULL
BEGIN
	CREATE DATABASE CustomerChurnDB;
END
GO

USE CustomerChurnDB;
GO


/* =============================================
   DROP EXISTING STAGING TABLE
============================================= */
DROP TABLE IF EXISTS telco_churn;


/* =============================================
   CREATE CLEAN CUSTOMER CHURN TABLE
============================================= */
-- Final cleaned table with proper data types
CREATE TABLE telco_churn (
    Customer_ID VARCHAR(20),
    Gender VARCHAR(20),
    Senior_Citizen INT,
    [Partner] VARCHAR(10),
    Dependents VARCHAR(10),
    Tenure INT,
    Phone_Service VARCHAR(30),
    Multiple_Lines VARCHAR(30),
    Internet_Service VARCHAR(30),
    Online_Security VARCHAR(30),
    Online_Backup VARCHAR(30),
    Device_Protection VARCHAR(30),
    Tech_Support VARCHAR(30),
    Streaming_TV VARCHAR(30),
    Streaming_Movies VARCHAR(30),
    [Contract] VARCHAR(30),
    Paperless_Billing VARCHAR(30),
    Payment_Method VARCHAR(50),
    Monthly_Charges DECIMAL(10,2),
    Total_Charges DECIMAL(10,2),
    Churn VARCHAR(10)
);


/* =============================================
INSERT CLEANED DATA
==============================================
Loads data from the staging table and converts fields
to the appropriate data types using TRY_CAST.

TRY_CAST prevents the query from failing if invalid
values exist by returning NULL instead of an error.
*/
INSERT INTO telco_churn
SELECT 
    Customer_ID,
    Gender,
    CASE 
        WHEN Senior_Citizen IN ('0','1') THEN CAST(Senior_Citizen AS INT)
        ELSE NULL
    END,
    [Partner],
    Dependents,
    TRY_CAST(Tenure AS INT),
    Phone_Service,
    Multiple_Lines,
    Internet_Service,
    Online_Security,
    Online_Backup,
    Device_Protection,
    Tech_Support,
    Streaming_TV,
    Streaming_Movies,
    [Contract],
    Paperless_Billing,
    Payment_Method,
    TRY_CAST(Monthly_Charges AS DECIMAL(10,2)),
    TRY_CAST(Total_Charges AS DECIMAL(10,2)),
    Churn
FROM telco_churn_staging;


/* =============================================
   DATA VALIDATION
============================================= */
SELECT COUNT(*) AS count_final FROM telco_churn; 
SELECT COUNT(*) AS count_staging FROM telco_churn_staging;

SELECT TOP 10 * FROM telco_churn;


/* =============================================
   CHECK FOR NULL VALUES
============================================= */
SELECT *
FROM telco_churn
WHERE Customer_ID IS NULL OR Customer_ID = '' OR
    Gender IS NULL OR Gender = '' OR
    Senior_Citizen IS NULL OR Senior_Citizen = '' OR
    [Partner] IS NULL OR [Partner] = '' OR
    Dependents IS NULL OR Dependents = '' OR
    Tenure IS NULL OR Tenure = '' OR
    Phone_Service IS NULL OR Phone_Service = '' OR
    Multiple_Lines IS NULL OR Multiple_Lines = '' OR
    Internet_Service IS NULL OR Internet_Service = '' OR
    Online_Security IS NULL OR Online_Security = '' OR
    Online_Backup IS NULL OR Online_Backup = '' OR
    Device_Protection IS NULL OR Device_Protection = '' OR
    Tech_Support IS NULL OR Tech_Support = '' OR
    Streaming_TV IS NULL OR Streaming_TV = '' OR
    Streaming_Movies IS NULL OR Streaming_Movies = '' OR
    [Contract] IS NULL OR [Contract] = '' OR
    Paperless_Billing IS NULL OR Paperless_Billing = '' OR
    Payment_Method IS NULL OR Payment_Method = '' OR
    Monthly_Charges IS NULL OR Monthly_Charges = '' OR
    Total_Charges IS NULL OR Total_Charges = '' OR
    Churn IS NULL OR Churn = '';


/* =============================================
   ANALYSIS
============================================= */
-- Total Customers
SELECT COUNT(*) AS total_customers
FROM telco_churn;


-- Churn Distribution
SELECT 
    Churn,
    COUNT(*) AS customers
FROM telco_churn
GROUP BY Churn;


-- Calculate Churn Rate (Key KPI)
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),
        2) AS DECIMAL(10,2)
    ) AS churn_rate
FROM telco_churn;


-- Churn by Contract Type
WITH contract_churn AS (
    SELECT
        [Contract],
        COUNT(*) AS total_customers,
        SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers
    FROM telco_churn
    GROUP BY [Contract]
)
SELECT
    [Contract],
    total_customers,
    churned_customers,
    CAST(ROUND(
        100.0 * churned_customers / NULLIF(total_customers,0),
        2) AS DECIMAL(10,2)
    ) AS churn_rate,    
    RANK() OVER (
        ORDER BY 100.0 * churned_customers / NULLIF(total_customers,0) DESC
    ) AS churn_rank
FROM contract_churn;


-- Churn by Tenure Group
WITH tenure_grouped AS (
    SELECT *,
        CASE
            WHEN Tenure <= 12 THEN '0-12 Months'
            WHEN Tenure <= 24 THEN '13-24 Months'
            WHEN Tenure <= 48 THEN '25-48 Months'
            ELSE '48+ Months'
        END AS tenure_group
    FROM telco_churn
)
SELECT
    tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),
        2) AS DECIMAL(10,2)
    ) AS churn_rate
FROM tenure_grouped
GROUP BY tenure_group
ORDER BY churn_rate DESC;


-- Churn by Payment Method
SELECT
    Payment_Method,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),
        2) AS DECIMAL(10,2)
    ) AS churn_rate
FROM telco_churn
GROUP BY Payment_Method
ORDER BY churn_rate DESC;


-- Revenue Lost from Churn
SELECT
    SUM(Monthly_Charges) AS monthly_revenue_lost
FROM telco_churn
WHERE Churn = 'Yes';


-- High-Risk Customer Segments
SELECT
    [Contract],
    Internet_Service,
    Payment_Method,   
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) AS churned_customers,
    CAST(ROUND(
        100.0 * SUM(CASE WHEN Churn='Yes' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),
        2) AS DECIMAL(10,2)
    ) AS churn_rate
FROM telco_churn
GROUP BY [Contract], Internet_Service, Payment_Method
HAVING COUNT(*) > 50
ORDER BY churn_rate DESC;


-- Which customer segments generate the most revenue but also churn frequently?
SELECT
    [Contract],    
    COUNT(*) customers,
    SUM(Monthly_Charges) AS total_monthly_revenue,
    SUM(CASE WHEN Churn='Yes' THEN Monthly_Charges ELSE 0 END) 
        AS churned_revenue
FROM telco_churn
GROUP BY [Contract]
ORDER BY churned_revenue DESC;
