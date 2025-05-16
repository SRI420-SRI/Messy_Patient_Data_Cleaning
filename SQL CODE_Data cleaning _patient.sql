##lets create patient_data table

CREATE TABLE patient_data (
    Patient_ID VARCHAR(10),
    Name VARCHAR(50),
    Age INTEGER,
    Gender VARCHAR(10),
    Check_in_Date DATE,
    First_Consultation DATE,
    Next_Visit DATE,
    Diagnosis VARCHAR(50),
    Heart_Rate FLOAT,
    Doctor_Notes VARCHAR(100)
);

select * from patient_data;

#handling missing age set null to -1

UPDATE patient_data
SET Age = -1
WHERE Age IS NULL;

#Step 2 Standardize Gender NULL Gender casing inconsistent So convert to uppercase, set NULL to 'UNKNOWN'.

UPDATE patient_data
SET Gender = UPPER(COALESCE(Gender, 'UNKNOWN'));

##lets clean date columns
UPDATE patient_data
SET Check_in_Date = NULL
WHERE Check_in_Date > '2025-05-16';

UPDATE patient_data
SET First_Consultation = NULL
WHERE First_Consultation > '2025-05-16';

## lets standardize diagnosis column by null to unknown

UPDATE patient_data
SET Diagnosis = UPPER(COALESCE(Diagnosis, 'UNKNOWN'));

##lets clean heart_rate data
UPDATE patient_data
SET Heart_Rate = NULL
WHERE Heart_Rate < 50 OR Heart_Rate > 180;

##lets update doctor notes with null to none

UPDATE patient_data
SET Doctor_Notes = TRIM(TRAILING '.' FROM INITCAP(COALESCE(Doctor_Notes, 'NONE')));

#removing empty rows if any

DELETE FROM patient_data
WHERE Diagnosis = 'UNKNOWN'
  AND Heart_Rate IS NULL
  AND Doctor_Notes = 'NONE'
  AND Check_in_Date IS NULL
  AND First_Consultation IS NULL
  AND Next_Visit IS NULL;


#checking missing values

  SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN Age = -1 THEN 1 ELSE 0 END) AS missing_age,
       SUM(CASE WHEN Gender = 'UNKNOWN' THEN 1 ELSE 0 END) AS missing_gender,
       SUM(CASE WHEN Diagnosis = 'UNKNOWN' THEN 1 ELSE 0 END) AS missing_diagnosis,
       SUM(CASE WHEN Heart_Rate IS NULL THEN 1 ELSE 0 END) AS missing_heart_rate,
       SUM(CASE WHEN Doctor_Notes = 'NONE' THEN 1 ELSE 0 END) AS missing_notes
FROM patient_data;


#verifying dates
SELECT MIN(Check_in_Date) min_check_in_date, MAX(Check_in_Date) max_check_in_date,
       MIN(First_Consultation) min_First_Consultation, MAX(First_Consultation) max_First_Consultation,
       MIN(Next_Visit) min_Next_Visit, MAX(Next_Visit) max_Next_Visit
FROM patient_data;


##lets check heart rate 

SELECT MIN(Heart_Rate), MAX(Heart_Rate)
FROM patient_data
WHERE Heart_Rate IS NOT NULL;


##lets check unique values

SELECT DISTINCT Diagnosis, Doctor_Notes
FROM patient_data
ORDER BY Diagnosis, Doctor_Notes;