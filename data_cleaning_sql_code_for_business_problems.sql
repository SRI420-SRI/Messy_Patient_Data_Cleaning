##business questions on Patient_data
##1. What is the distribution of patient diagnoses, and how does it vary by gender and age group?

SELECT Diagnosis,Gender,
    CASE 
        WHEN Age = -1 THEN 'Unknown'
        WHEN Age BETWEEN 0 AND 18 THEN '0-18'
        WHEN Age BETWEEN 19 AND 40 THEN '19-40'
        WHEN Age BETWEEN 41 AND 65 THEN '41-65'
        WHEN Age > 65 THEN '66+'
    END AS Age_Group,
    COUNT(*) AS Patient_Count
FROM patient_data
GROUP BY Diagnosis, Gender, Age_Group
ORDER BY Diagnosis, Gender, Age_Group;

##2. How frequently are patients scheduling follow-up visits, and what factors (e.g., diagnosis, heart rate) influence follow-up needs?

SELECT Diagnosis,
    CASE 
        WHEN Heart_Rate IS NULL THEN 'Missing'
        WHEN Heart_Rate <= 100 THEN 'Normal (≤100)'
        WHEN Heart_Rate > 100 THEN 'High (>100)'
    END AS Heart_Rate_Range,
    Doctor_Notes,
    COUNT(Next_Visit) AS Follow_Up_Count,
    COUNT(*) AS Total_Patients
FROM patient_data
WHERE Next_Visit IS NOT NULL
GROUP BY Diagnosis, Heart_Rate_Range, Doctor_Notes
ORDER BY Follow_Up_Count DESC;

##3. What is the average heart rate across different diagnoses, and are there significant outliers indicating critical cases?

SELECT 
    Diagnosis,
    ROUND(AVG(Heart_Rate)::NUMERIC, 1) AS Avg_Heart_Rate,
    MIN(Heart_Rate) AS Min_Heart_Rate,
    MAX(Heart_Rate) AS Max_Heart_Rate,
    COUNT(CASE WHEN Heart_Rate > 140 THEN 1 END) AS Outlier_Count
FROM patient_data
WHERE Heart_Rate IS NOT NULL
GROUP BY Diagnosis
ORDER BY Avg_Heart_Rate DESC;

##4 4. Which patient age groups or genders have the highest rates of missing data (e.g., NULL Age, Heart_Rate, or Diagnosis)?

SELECT 
    Gender,
    CASE 
        WHEN Age = -1 THEN 'Unknown'
        WHEN Age BETWEEN 0 AND 18 THEN '0-18'
        WHEN Age BETWEEN 19 AND 40 THEN '19-40'
        WHEN Age BETWEEN 41 AND 65 THEN '41-65'
        WHEN Age > 65 THEN '66+'
    END AS Age_Group,
    COUNT(*) AS Total_Patients,
    SUM(CASE WHEN Age = -1 THEN 1 ELSE 0 END) AS Missing_Age,
    SUM(CASE WHEN Heart_Rate IS NULL THEN 1 ELSE 0 END) AS Missing_Heart_Rate,
    SUM(CASE WHEN Diagnosis = 'UNKNOWN' THEN 1 ELSE 0 END) AS Missing_Diagnosis
FROM patient_data
GROUP BY Gender, Age_Group
ORDER BY Missing_Heart_Rate DESC, Missing_Diagnosis DESC;

##5. How does the timing of check-in dates correlate with diagnoses or doctor notes (e.g., seasonal patterns or trends over years)?

SELECT 
    EXTRACT(YEAR FROM Check_in_Date) AS Visit_Year,
    EXTRACT(MONTH FROM Check_in_Date) AS Visit_Month,
    Diagnosis,
    Doctor_Notes,
    COUNT(*) AS Visit_Count
FROM patient_data
WHERE Check_in_Date IS NOT NULL
GROUP BY Visit_Year, Visit_Month, Diagnosis, Doctor_Notes
ORDER BY Visit_Year, Visit_Month, Diagnosis;

##6. What are the most common doctor notes for patients with Hypertension, and how do they relate to heart rate or follow-up needs?

SELECT 
    Doctor_Notes,
    CASE 
        WHEN Heart_Rate IS NULL THEN 'Missing'
        WHEN Heart_Rate <= 100 THEN 'Normal (≤100)'
        WHEN Heart_Rate > 100 THEN 'High (>100)'
    END AS Heart_Rate_Range,
    COUNT(Next_Visit) AS Follow_Up_Count,
    COUNT(*) AS Total_Patients
FROM patient_data
WHERE Diagnosis = 'HYPERTENSION'
GROUP BY Doctor_Notes, Heart_Rate_Range
ORDER BY Total_Patients DESC;


##7. Which patients have multiple visits (based on Check_in_Date, First_Consultation, Next_Visit), and what are their characteristics?

SELECT 
    Patient_ID,
    Age,
    Gender,
    Diagnosis,
    COUNT(CASE WHEN Check_in_Date IS NOT NULL THEN 1 END) +
    COUNT(CASE WHEN First_Consultation IS NOT NULL THEN 1 END) +
    COUNT(CASE WHEN Next_Visit IS NOT NULL THEN 1 END) AS Visit_Count
FROM patient_data
GROUP BY Patient_ID, Age, Gender, Diagnosis
HAVING COUNT(CASE WHEN Check_in_Date IS NOT NULL THEN 1 END) +
       COUNT(CASE WHEN First_Consultation IS NOT NULL THEN 1 END) +
       COUNT(CASE WHEN Next_Visit IS NOT NULL THEN 1 END) > 1
ORDER BY Visit_Count DESC;


##8. Are there geographic or temporal clusters of high heart rates or specific diagnoses based on visit dates?

SELECT 
    EXTRACT(YEAR FROM Check_in_Date) AS Visit_Year,
    EXTRACT(MONTH FROM Check_in_Date) AS Visit_Month,
    Diagnosis,
    COUNT(CASE WHEN Heart_Rate > 140 THEN 1 END) AS High_Heart_Rate_Count,
    COUNT(*) AS Total_Visits
FROM patient_data
WHERE Check_in_Date IS NOT NULL
GROUP BY Visit_Year, Visit_Month, Diagnosis
ORDER BY High_Heart_Rate_Count DESC, Visit_Year, Visit_Month;