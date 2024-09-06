## 1. Introduction
This report details the data cleaning and transformation steps performed on the FIFA 21 dataset, which was initially loaded into the SQL Server. The dataset required extensive cleaning to ensure data quality and consistency before conducting any meaningful analysis.

## 2. View the Raw Data
Before beginning the data cleaning process, the raw data was viewed to understand its structure and content.

``` Sql
SELECT * 
FROM [dbo].[fifa21_raw_data];
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
Several columns contained placeholder characters ('?') that needed to be removed. The IR, W_F, and SM columns were cleaned to replace these characters with empty strings,and the Value Wages and Release_clause columns placeholder ('M') and ('K') were removed aswell.

```sql
UPDATE [dbo].[fifa21_raw_data]
SET IR = REPLACE(IR, '?', '');

UPDATE [dbo].[fifa21_raw_data]
SET W_F = REPLACE(W_F, '?', '');

UPDATE [dbo].[fifa21_raw_data]
SET SM = REPLACE(SM, '?', '');

UPDATE [dbo].[fifa21_raw_data]
SET value= REPLACE(Value,'M','Million')

UPDATE [dbo].[fifa21_raw_data]
SET Wage= REPLACE(Wage,'k','000')

UPDATE [dbo].[fifa21_raw_data]
SET Release_Clause= REPLACE(Release_Clause,'M','Million')
```

In the Contract column, tildes ('~') were replaced with hyphens ('-') for consistency in formatting.


```sql

UPDATE [dbo].[fifa21_raw_data]
SET Contract = REPLACE(Contract, '~', '-');
```

## 6. Identifying and Removing Duplicate Records
Duplicate records were identified based on the FullName, Club, Nationality column. These duplicates were then removed, retaining only the first occurrence of each data for the respectively column.

```sql

SELECT FullName,CLUB, NATIONALITY, COUNT(*) AS DUPLICATECOUNT
FROM [dbo].[fifa21_raw_data]
GROUP BY FullName,CLUB, NATIONALITY
HAVING COUNT(*)>1;

WITH CTE AS (
    SELECT Fullname, club, nationality,
           ROW_NUMBER() OVER (PARTITION BY fullname, club, nationality ORDER BY (SELECT NULL)) AS rn
    FROM [dbo].[fifa21_raw_data]
)
DELETE FROM CTE
WHERE rn > 1;

```
## 7. Handling Empty Rows
Rows with missing values in the Hits column were identified and replaced to ensure data completeness.

```sql
SELECT Hits
FROM [dbo].[fifa21_raw_data]
WHERE Hits IS NULL;
-- REPLACE NULL ON THE HITS COLUMN WITH '0'

UPDATE [dbo].[fifa21_raw_data]
SET Hits= COALESCE (Hits,'NULL','0')

```
## 8. Removing Unwanted Characters from Strings
The FullName and Club columns were checked for non-alphabetic characters. Records containing such characters were identified and corrected.

```sql
-- script to identify fullname column non-alphaabetis characters
SELECT FullName
FROM [dbo].[fifa21_raw_data]
WHERE FullName NOT LIKE '%[A-Za-z]%';

-- script to identify club column non-alphaabetis characters
SELECT Club
FROM [dbo].[fifa21_raw_data]
WHERE Club NOT LIKE '%[A-Za-z]%';
```
To remove the unwanted characters from the FullName and club column, a transaction was initiated. The unwanted characters were replaced with appropriate substitutes or removed entirely.

```sql
BEGIN TRANSACTION;
UPDATE [dbo].[fifa21_raw_data]
SET FullName = REPLACE(REPLACE(FullName, '?', 's'), '3', '');
ROLLBACK;

BEGIN TRANSACTION;
UPDATE [dbo].[fifa21_raw_data]
SET Club = REPLACE(Club, '?', 'S')
ROLLBACK;
```
## 9. Conclusion
The data cleaning and transformation process ensured that the FIFA 21 dataset was free of redundant columns, duplicate records, and unwanted characters. These steps were crucial in preparing the data for accurate and meaningful analysis.

👍
💻
