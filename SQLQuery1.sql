SELECT * FROM [Portfolio Project]..healthcare_messy_data$


-- Correcting the patient name   -- 1
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

-- Age doing correct -- 2
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

-- converting male, female, other to m, f, o  --- 3
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