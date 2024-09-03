## 1. Introduction
This report details the data cleaning and transformation steps performed on the FIFA 21 dataset, which was initially loaded into the SQL Server. The dataset required extensive cleaning to ensure data quality and consistency before conducting any meaningful analysis.

## 2. View the Raw Data
Before beginning the data cleaning process, the raw data was viewed to understand its structure and content.

``` Sql
SELECT * 
FROM fifa21_raw_data;
```
## 3. Dropping Unnecessary Columns
Several columns were identified as irrelevant to the analysis, including photoUrl, playerUrl, Name, and LOAN_DATE_END. These columns were removed to reduce data redundancy and improve the efficiency of subsequent queries.

``` sql
ALTER TABLE [dbo].[fifa21_raw_data]
DROP COLUMN photoUrl, playerUrl, Name, LOAN_DATE_END;
```
## 4. Renaming Columns
To improve clarity, the LongName column was renamed to FullName. This change ensures the column name better reflects the data it contains.

```sql

EXEC SP_RENAME '[dbo].[fifa21_raw_data].LongName', 'FullName', 'COLUMN';
```
## 5. Cleaning Data in Specific Columns
Several columns contained placeholder characters ('?') that needed to be removed. The IR, W_F, and SM columns were cleaned to replace these characters with empty strings.

```sql
UPDATE [dbo].[fifa21_raw_data]
SET IR = REPLACE(IR, '?', '');

UPDATE [dbo].[fifa21_raw_data]
SET W_F = REPLACE(W_F, '?', '');

UPDATE [dbo].[fifa21_raw_data]
SET SM = REPLACE(SM, '?', '');
In the Contract column, tildes ('~') were replaced with hyphens ('-') for consistency in formatting.
```

```sql

UPDATE [dbo].[fifa21_raw_data]
SET Contract = REPLACE(Contract, '~', '-');
```

## 6. Identifying and Removing Duplicate Records
Duplicate records were identified based on the FullName column. These duplicates were then removed, retaining only the first occurrence of each name.

```sql

SELECT FullName, COUNT(*) AS DUPLICATECOUNT
FROM [dbo].[fifa21_raw_data]
GROUP BY FullName
HAVING COUNT(*) > 1;

WITH CTE AS (
    SELECT 
        FullName,
        ROW_NUMBER() OVER (PARTITION BY FullName ORDER BY (SELECT NULL)) AS ROWNUM
    FROM [dbo].[fifa21_raw_data]
)
DELETE FROM CTE WHERE ROWNUM > 1;
```

SELECT DISTINCT FullName
FROM [dbo].[fifa21_raw_data];
## 7. Handling Empty Rows
Rows with missing values in the Hits column were identified to ensure data completeness.

```sql
SELECT Hits
FROM fifa21_raw_data
WHERE Hits IS NULL;
```
## 8. Removing Unwanted Characters from Strings
The FullName and Club columns were checked for non-alphabetic characters. Records containing such characters were identified and corrected.

```sql
SELECT FullName
FROM [dbo].[fifa21_raw_data]
WHERE FullName NOT LIKE '%[A-Za-z]%';

SELECT Club
FROM [dbo].[fifa21_raw_data]
WHERE Club NOT LIKE '%[A-Za-z]%';
```
To remove the unwanted characters from the FullName column, a transaction was initiated. The unwanted characters were replaced with appropriate substitutes or removed entirely.

```sql

BEGIN TRANSACTION;
UPDATE [dbo].[fifa21_raw_data]
SET FullName = REPLACE(REPLACE(FullName, '?', 's'), '3', '');
ROLLBACK;
```
## 9. Conclusion
The data cleaning and transformation process ensured that the FIFA 21 dataset was free of redundant columns, duplicate records, and unwanted characters. These steps were crucial in preparing the data for accurate and meaningful analysis.

This report outlines the SQL operations performed to achieve a clean and consistent dataset, ready for further analytical tasks.

👍
💻
