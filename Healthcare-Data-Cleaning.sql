SELECT * FROM [Portfolio Project]..healthcare_messy_data$


-- Correcting the patient name                              ----- 1
SELECT [Patient Name] , 
UPPER(SUBSTRING([Patient Name] , 1 , 2)) + Lower(SUBSTRING([Patient Name] , 3 , CHARINDEX( ' ', [Patient Name]) + 3))
+ ' ' + UPPER(SUBSTRING([Patient Name], CHARINDEX(' ', LTRIM([Patient Name])) + 2, 1)) + 
LOWER(SUBSTRING([Patient Name], CHARINDEX(' ', LTRIM([Patient Name])) + 3, LEN([Patient Name]))) AS PateintName
FROM [Portfolio Project]..healthcare_messy_data$

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD PatientNameUpdated varchar(255);

UPDATE [Portfolio Project]..healthcare_messy_data$
SET PatientNameUpdated = UPPER(SUBSTRING([Patient Name] , 1 , 2)) + Lower(SUBSTRING([Patient Name] , 3 , CHARINDEX( ' ', [Patient Name]) + 3))
+ ' ' + UPPER(SUBSTRING([Patient Name], CHARINDEX(' ', LTRIM([Patient Name])) + 2, 1)) + 
LOWER(SUBSTRING([Patient Name], CHARINDEX(' ', LTRIM([Patient Name])) + 3, LEN([Patient Name])))

SELECT * FROM [Portfolio Project]..healthcare_messy_data$

-- Age doing correct                                            ---- 2
SELECT Age,
CASE
	WHEN Age = 'nan' THEN NULL
	WHEN Age = 'forty' THEN 40
	ELSE Age
	END
FROM [Portfolio Project]..healthcare_messy_data$

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD AgeUpdated numeric;

UPDATE [Portfolio Project]..healthcare_messy_data$
SET AgeUpdated = CASE 
	WHEN Age = 'nan' THEN NULL
	WHEN Age = 'forty' THEN 40
	ELSE Age
	END

SELECT * FROM [Portfolio Project]..healthcare_messy_data$

-- converting male, female, other to m, f, o                    ---- 3
SELECT Gender, CASE
WHEN Gender = 'Male' THEN 'M'
WHEN Gender = 'Female' THEN 'F'
WHEN Gender = 'Other' THEN 'O'
ELSE Gender 
END

FROM [Portfolio Project]..healthcare_messy_data$

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD GenderUpdated varchar(10);

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
DROP COLUMN GenderUpdated;

UPDATE [Portfolio Project]..healthcare_messy_data$
SET GenderUpdated  =  CASE
WHEN Gender = 'Male' THEN 'M'
WHEN Gender = 'Female' THEN 'F'
WHEN Gender = 'Other' THEN 'O'
ELSE Gender 
END

SELECT * FROM [Portfolio Project]..healthcare_messy_data$

-- Medication vs. Condition Report                  -----  4

SELECT Condition, Medication, COUNT(*) AS Total_Usage
FROM [Portfolio Project]..healthcare_messy_data$
WHERE Condition <> 'None'
GROUP BY Condition, Medication
ORDER BY COUNT(*) DESC


-- Blood Pressure vs Age Logic                      -----  5

SELECT PatientNameUpdated, AgeUpdated, [Blood Pressure]
FROM [Portfolio Project]..healthcare_messy_data$
WHERE AgeUpdated > 40 AND [Blood Pressure] LIKE '140/%'

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD PatientStatus varchar(255);

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
DROP COLUMN PatientStatus;

UPDATE [Portfolio Project]..healthcare_messy_data$
SET PatientStatus  =  CASE WHEN AgeUpdated > 40 AND [Blood Pressure] LIKE '140/%' THEN 'SystolicPatient'
Else 'Normal'
END

SELECT * FROM [Portfolio Project]..healthcare_messy_data$

-- Datetime to Date                                 -----  6
ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD DateUpdated DATE;

UPDATE [Portfolio Project]..healthcare_messy_data$
SET DateUpdated = CONVERT(Date, [Visit Date])

SELECT * FROM [Portfolio Project]..healthcare_messy_data$

--- Blood Pressure                                  ------   7
ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD BloodPressureUpdated varchar(255);


UPDATE [Portfolio Project]..healthcare_messy_data$
SET BloodPressureUpdated = CASE WHEN [Blood Pressure] = 'NaN' THEN 'Null'
ELSE [Blood Pressure]
END

SELECT * FROM [Portfolio Project]..healthcare_messy_data$

--Email and Phone number updated                    ----   8
ALTER TABLE [Portfolio Project]..healthcare_messy_data$
ADD EmailUpdated varchar(255),
PhoneNumberUpdated varchar(255);


UPDATE [Portfolio Project]..healthcare_messy_data$
SET EmailUpdated = CASE WHEN [Email] = 'nan' THEN NULL
ELSE [Email]
END,

PhoneNumberUpdated = CASE WHEN [Phone Number] = 'nan' THEN NULL
ELSE [Phone Number]
END

SELECT * FROM [Portfolio Project]..healthcare_messy_data$


-- High Risk Analysis                           ------  9

SELECT PatientNameUpdated, AgeUpdated, BloodPressureUpdated, PhoneNumberUpdated, PatientStatus
FROM [Portfolio Project]..healthcare_messy_data$
WHERE PatientStatus = 'SystolicPatient'

-- Deleting Useless Coulmns                 -----   10
ALTER TABLE [Portfolio Project]..healthcare_messy_data$
DROP COLUMN [Patient Name], Age, Gender, [Visit Date], Email, [Phone Number]

ALTER TABLE [Portfolio Project]..healthcare_messy_data$
DROP COLUMN [Blood Pressure]

SELECT * FROM [Portfolio Project]..healthcare_messy_data$


--- Cheking total patients of the month                 -----   11
SELECT MONTH(DateUpdated) AS MonthNumber,COUNT(PatientNameUpdated) AS TotalPatients
FROM [Portfolio Project]..healthcare_messy_data$
GROUP BY MONTH(DateUpdated)
ORDER BY COUNT(PatientNameUpdated) 


--- Doing Unknown in columns where null exist                       ----   12

DELETE FROM [Portfolio Project]..healthcare_messy_data$
WHERE DateUpdated IS NULL;


SELECT 
    PatientNameUpdated,
    GenderUpdated,
    Condition,
    Medication,
   ISNULL(CAST(AgeUpdated AS VARCHAR), 'Unknown') AS Age,
    ISNULL(CAST(Cholesterol AS VARCHAR), 'Unknown') AS Cholesterol, 
    ISNULL(EmailUpdated, 'Unknown') AS Email,
    ISNULL(PhoneNumberUpdated, 'Unknown') AS Phone,
    PatientStatus,
    DateUpdated
FROM [Portfolio Project]..healthcare_messy_data$;


-- Making view                              -------   13

CREATE VIEW Cleaned_Healthcare_Data AS
SELECT 
    PatientNameUpdated,
    GenderUpdated,
    Condition,
    Medication,
    ISNULL(CAST(AgeUpdated AS VARCHAR), 'Unknown') AS Age,
    ISNULL(CAST(Cholesterol AS VARCHAR), 'Unknown') AS Cholesterol,
    ISNULL(EmailUpdated, 'Unknown') AS Email,
    ISNULL(PhoneNumberUpdated, 'Unknown') AS Phone,
    PatientStatus,
    DateUpdated
FROM [Portfolio Project]..healthcare_messy_data$;

SELECT * FROM Cleaned_Healthcare_Data;