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

SELECT * FROM cell_phone_plans;
SELECT * FROM bundled_plans;
SELECT * FROM internet_plans;
SELECT * FROM tmobile_plans;
