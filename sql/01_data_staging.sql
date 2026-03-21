-- Customer Churn Analysis
-- Author: Gaurav Yadav
-- Description: SQL scripts for setting up the staging table

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
DROP TABLE IF EXISTS telco_churn_staging;


/* =============================================
   CREATE STAGING TABLE
============================================= */
CREATE TABLE telco_churn_staging (
    Customer_ID NVARCHAR(50),
    Gender NVARCHAR(50),
    Senior_Citizen NVARCHAR(50),
    [Partner] NVARCHAR(50),
    Dependents NVARCHAR(50),
    Tenure NVARCHAR(50),
    Phone_Service NVARCHAR(50),
    Multiple_Lines NVARCHAR(50),
    Internet_Service NVARCHAR(50),
    Online_Security NVARCHAR(50),
    Online_Backup NVARCHAR(50),
    Device_Protection NVARCHAR(50),
    Tech_Support NVARCHAR(50),
    Streaming_TV NVARCHAR(50),
    Streaming_Movies NVARCHAR(50),
    [Contract] NVARCHAR(50),
    Paperless_Billing NVARCHAR(50),
    Payment_Method NVARCHAR(50),
    Monthly_Charges NVARCHAR(50),
    Total_Charges NVARCHAR(50),
    Churn NVARCHAR(50)
);


/* =============================================
   IMPORT DATA FROM CSV
============================================= */
-- NOTE: Update file path based on your system
BULK INSERT telco_churn_staging
FROM 'C:\Path\To\Your\Telco-Customer-Churn_clean.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


/* =============================================
   VALIDATE DATA LOAD
============================================= */
SELECT COUNT(*) AS total_rows
FROM telco_churn_staging;


/* =============================================
   CHECK FOR NULL OR EMPTY VALUES
============================================= */
SELECT *
FROM telco_churn_staging
WHERE 
    Customer_ID IS NULL OR Customer_ID = '' OR
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
   REVIEW RAW DATA
============================================= */
SELECT *
FROM telco_churn_staging;


/* =============================================
   CHECK DATA TYPE CONVERSION ISSUES
============================================= */
-- Identify rows where Total_Charges cannot be converted to numeric
SELECT *
FROM telco_churn_staging
WHERE TRY_CAST(Total_Charges AS DECIMAL(10,2)) IS NULL 
      AND Total_Charges IS NOT NULL
      AND Total_Charges <> '';
