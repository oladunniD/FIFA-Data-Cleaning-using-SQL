--VIEW TABLE
SELECT *
FROM [dbo].[fifa21_raw_data]

-- REMOVE PHOTOURL,PLAYER URL NAME ANDLOANDATE COLUMN

ALTER TABLE[dbo].[fifa21_raw_data]
DROP COLUMN photoUrl, playerUrl, Name,LOAN_DATE_END;

-- CHANGE COLUMN NAME FROM LongName TO FULLNAME

EXEC SP_RENAME'[dbo].[fifa21_raw_data].LongName', 'FullName', 'COLUMN'

--UPDATING AND REPLACING THE WING FORWARD, SM AND IR 

UPDATE [dbo].[fifa21_raw_data]
SET IR =REPLACE(IR, '?', '')

UPDATE [dbo].[fifa21_raw_data]
SET 
   W_F = REPLACE(W_F,'?', '')

UPDATE [dbo].[fifa21_raw_data]
SET SM= REPLACE(SM,'?','')

-- REPLACE ~ TO - IN CONTRACT COLUMN 

UPDATE [dbo].[fifa21_raw_data]
SET Contract= REPLACE(Contract,'~','-')

--REPLACING THE M,K AND . IN THE VALUE,WAGE,RELEASE_CLAUSE
BEGIN TRANSACTION
UPDATE [dbo].[fifa21_raw_data]
SET value= REPLACE(Value,'M','Million')


UPDATE [dbo].[fifa21_raw_data]
SET Wage= REPLACE(Wage,'k','000')

UPDATE [dbo].[fifa21_raw_data]
SET Release_Clause= REPLACE(Release_Clause,'M','Million')

-- FIND DULPICATES

SELECT FullName,CLUB, NATIONALITY, COUNT(*) AS DUPLICATECOUNT
FROM [dbo].[fifa21_raw_data]
GROUP BY FullName,CLUB, NATIONALITY
HAVING COUNT(*)>1;


-- REMOVE DUPLICATES

	WITH CTE AS (
    SELECT Fullname, club, nationality,
           ROW_NUMBER() OVER (PARTITION BY fullname, club, nationality ORDER BY (SELECT NULL)) AS rn
    FROM [dbo].[fifa21_raw_data]
)
DELETE FROM CTE
WHERE rn > 1;


-- REPLACE NULL WITH 0 AND K . IN HITS COLUMN
--IDENTIFY NULL IN THE HITS COLUMN

SELECT Hits
FROM [dbo].[fifa21_raw_data]
WHERE Hits IS NULL

-- REPLACE 'NULL' WITH '0'

UPDATE [dbo].[fifa21_raw_data]
SET Hits= COALESCE (Hits,'NULL','0')

-- IDENTIFY CHARACTERS TO REPLACE
SELECT Hits
FROM [dbo].[fifa21_raw_data]
WHERE Hits NOT LIKE '[%1-0]'

-- REPLACE K WITH 00 AND  . WITH ,

UPDATE [dbo].[fifa21_raw_data]
SET Hits= REPLACE(REPLACE(Hits,'K','00'), '.',',')

-- FULL NAME COLUMN

SELECT FullName
FROM [dbo].[fifa21_raw_data]
WHERE FullName NOT LIKE '%[A-A,a-z%]'

--REPLACE '?' WITH 'S' IN FULLNAME COLUMN
UPDATE [dbo].[fifa21_raw_data]
SET FullName= REPLACE(FullName,'?','S')

SELECT Club
FROM [dbo].[fifa21_raw_data]
WHERE Club NOT LIKE '%[A-Za-z]%';


```BEGIN TRANSACTION;
UPDATE [dbo].[fifa21_raw_data]
SET Club = REPLACE(Club, '?', 'S')
ROLLBACK;


