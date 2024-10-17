USE Telecoms_deals;

DROP TABLE IF EXISTS internet_plans;
CREATE TABLE internet_plans (
	Carrier_ID INT PRIMARY KEY,
    Carrier VARCHAR(100),
    Plans_Available INT,
    Internet_Categories VARCHAR(255)
);

DROP TABLE IF EXISTS cell_phone_plans;
CREATE TABLE cell_phone_plans (
    Cellphone_Plan_ID INT AUTO_INCREMENT PRIMARY KEY,
    Carrier VARCHAR(100),
    Plan VARCHAR(100),
    Price VARCHAR(50),
    Best_For VARCHAR(50),
    Plan_Link VARCHAR(255),
	Carrier_ID INT,
	CONSTRAINT constraint1 FOREIGN KEY (Carrier_ID) REFERENCES internet_plans(Carrier_ID)
);

DROP TABLE IF EXISTS bundled_plans;
CREATE TABLE bundled_plans (
	Bundle_ID INT AUTO_INCREMENT PRIMARY KEY,
    Carrier VARCHAR(100),
    Bundle_Plan VARCHAR(255),
    Price VARCHAR(100),
    Best_For VARCHAR(50),
    Plan_Link VARCHAR(255),
	Carrier_ID INT,
	CONSTRAINT constraint2 FOREIGN KEY (Carrier_ID) REFERENCES internet_plans(Carrier_ID)
);

DROP TABLE IF EXISTS tmobile_plans;
CREATE TABLE tmobile_plans (
    Plan_ID INT AUTO_INCREMENT PRIMARY KEY,
    Plan VARCHAR(100),
    Line_Number VARCHAR(50),
    Price_Per_Line VARCHAR(50),
    Total_Monthly_Price VARCHAR(50),
	Carrier_ID INT,
    CONSTRAINT constraint3 FOREIGN KEY (Carrier_ID) REFERENCES internet_plans(Carrier_ID)
);

-- display all tables
SELECT * FROM cell_phone_plans;
SELECT * FROM bundled_plans;
SELECT * FROM internet_plans;
SELECT * FROM tmobile_plans;
SELECT * FROM telco_df_for_sql LIMIT 40;

-- edit table created and imported through import wizard
ALTER TABLE telco_df_for_sql ADD FOREIGN KEY (Carrier_ID) REFERENCES internet_plans(Carrier_ID);
ALTER TABLE telco_df_for_sql MODIFY COLUMN CustomerID VARCHAR(255);
ALTER TABLE telco_df_for_sql ADD PRIMARY KEY (CustomerID);

-- clean bundles_plans price column
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE bundled_plans ADD COLUMN Cleaned_Price DECIMAL(10, 2);

UPDATE bundled_plans
SET Cleaned_Price = 
TRIM(REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(Price, ' ', -2), '/', 1),'$', ''),'at', ''), ':','')) WHERE Price IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

-- clean cell_phone_plans price column
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE cell_phone_plans ADD COLUMN Cleaned_Price DECIMAL(10, 2);

UPDATE cell_phone_plans
SET Cleaned_Price = 
TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Price, '$', ''),'/month', ''),'-176',''),'(2-4 lines)','')) WHERE Price IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

-- clean tmobile_plans price columns
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE tmobile_plans ADD COLUMN Cleaned_Price_Per_Line DECIMAL(10, 2);
ALTER TABLE tmobile_plans ADD COLUMN Cleaned_Total_Monthly_Price DECIMAL(10, 2);
ALTER TABLE tmobile_plans ADD COLUMN Cleaned_Line_Number DECIMAL(10);


UPDATE tmobile_plans
SET Cleaned_Price_Per_Line = 
TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Price_Per_Line, '$', ''),'/line',''),'line',''),',','.')) WHERE Price_Per_Line IS NOT NULL;
UPDATE tmobile_plans
SET Cleaned_Total_Monthly_Price = 
TRIM(REPLACE(REPLACE(Total_Monthly_Price, '$', ''),'/month','')) WHERE Total_Monthly_Price IS NOT NULL;
UPDATE tmobile_plans
SET Cleaned_Line_Number = 
TRIM(REPLACE(Line_Number, 'lines', '')) WHERE Line_Number IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

-- Identifying internet providers with the most plans to help consumers identify the most flexible options.
SELECT Carrier, Plans_Available 
FROM internet_plans 
ORDER BY Plans_Available DESC LIMIT 10;

-- finding the best providers based on the number of best plans
SELECT ip.Carrier, 
    COUNT(bp.Cellphone_Plan_ID) AS Best_Plan_Count, 
    SUM(bp.Cleaned_Price) AS Total_Price 
FROM internet_plans AS ip 
LEFT JOIN cell_phone_plans AS bp 
ON ip.Carrier = bp.Carrier 
GROUP BY ip.Carrier 
ORDER BY Best_Plan_Count DESC;

-- Churn rate for customers with bundle (phone service + internet service) option
SELECT 
    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Churn_Rate
FROM 
    telco_df_for_sql
WHERE 
    PhoneService = 'Yes'
    AND InternetService != 'No';
-- Churn rate for customers with only internet service option
SELECT 
    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Churn_Rate
FROM 
    telco_df_for_sql
WHERE 
    PhoneService = 'No'
    AND InternetService != 'No';
-- Churn rate for customers with only phone service option
SELECT 
    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Churn_Rate
FROM 
    telco_df_for_sql
WHERE 
    PhoneService = 'Yes'
    AND InternetService = 'No';
    
-- In our synthetic telco customer data, the churn rate for customers with bundle services is higher than for phone service alone or for internet service alone.
-- This might be because customers will spend more with specific provider, and therefore save more when switching to a cheaper provider.
SELECT AVG(bp.Cleaned_Price) AS Bundle_Average_Price, AVG(cp.Cleaned_Price) AS Cellphone_Average_Price
FROM bundled_plans AS bp, cell_phone_plans AS cp;

SELECT 
    AVG(CASE WHEN PhoneService = 'Yes' AND InternetService = 'No' THEN MonthlyCharges 
            ELSE NULL END) AS Average_Price_phone,
    AVG(CASE WHEN PhoneService = 'No' AND InternetService != 'No' THEN MonthlyCharges 
            ELSE NULL END) AS Average_Price_internet,
	AVG(CASE WHEN PhoneService = 'Yes' AND InternetService != 'No' THEN MonthlyCharges 
            ELSE NULL END) AS Average_Price_bundle
FROM 
    telco_df_for_sql;

-- In our synthetic telco customer data, the bundle price average is higher than the sum of average phone service price and average internet service price.
-- This could mean that in our telco company, there is no bundle offer in place (or only a very small price reduction) and this would explain why there is a higher chance of churn for the customers using both internet and phone services, as most competitors have bundles in place.


-- Churn rate for customers with multiple phone lines
SELECT 
    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Churn_Rate
FROM 
    telco_df_for_sql
WHERE 
    MultipleLines = 'Yes';
-- Churn rate for customers with only one phone line
SELECT 
    (SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Churn_Rate
FROM 
    telco_df_for_sql
WHERE 
    MultipleLines = 'No';
    
-- In our synthetic telco customer data, the churn rate for customers subscribing to multiple phone lines is slightly higher than for customers subscribing to only one phone line.
-- When looking at T-Mobile family plans, offering savings on multiple lines, it clearly appears that this is also a way to reduce churn rate.
-- It seems even more relevant when analyzing the total cost for 2 lines versus 3 lines in various phone plans.

SELECT 
    Plan,
    Line_Number,
    Cleaned_Total_Monthly_Price,
    Cleaned_Total_Monthly_Price - LAG(Cleaned_Total_Monthly_Price) OVER (PARTITION BY Plan ORDER BY Cleaned_Line_Number) 
    AS Price_Difference_Per_New_Line
FROM 
    tmobile_plans
ORDER BY 
    Plan, 
    Line_Number;

-- We can see that for both entry-level family plans (essentials and Go5G) there is no price difference in total spent between 2 lines and 3 lines.
-- We can interpret this as the following: customers churn more when adding a third line to their subscription, probably looking at competitors before making this choice.
-- If we assume that the 2 lines first lines of the family plan are usually subscribed by the parents, and the third line would be when they wish to add a kid,
-- they would spend time making sure their current phone carrier is appropriate for everyone, in terms of price and in terms of capabilities.
-- By keeping the exact same price for 2 or 3 lines for some of the plans, carriers are making it easy for parents to stay with the same carrier, and one they added one kid to their family plan, they would probably add the others too.



