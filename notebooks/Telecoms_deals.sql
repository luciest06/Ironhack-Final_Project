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

UPDATE tmobile_plans
SET Cleaned_Price_Per_Line = 
TRIM(REPLACE(REPLACE(REPLACE(REPLACE(Price_Per_Line, '$', ''),'/line',''),'line',''),',','.')) WHERE Price_Per_Line IS NOT NULL;
UPDATE tmobile_plans
SET Cleaned_Total_Monthly_Price = 
TRIM(REPLACE(REPLACE(Total_Monthly_Price, '$', ''),'/month','')) WHERE Total_Monthly_Price IS NOT NULL;
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

-- number of customers with a partner + dependent wish to have family plan
-- within these customers are they using internet or telephone or both
-- could group if partner or dependent = yes then look at internet use and provide prices