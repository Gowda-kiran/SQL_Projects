SELECT *
FROM   dbo.layoffs;

-- Creating staging table
SELECT *
INTO   layoffs_staging
FROM   dbo.layoffs;

SELECT *
FROM   dbo.layoffs_staging;

-- 1. Remove Dupicates
-- using cte to check the duplicate rows and deleting the duplicate rows
WITH duplicate_data AS(
         SELECT   *,
                  Row_number() OVER (partition BY company,[date], [location], industry, total_laid_off, percentage_laid_off, stage, country, funds_raised_millions ORDER BY (
                         SELECT NULL)) AS row_num
         FROM     layoffs_staging )
DELETE
FROM   duplicate_data
WHERE  row_num >1;

SELECT Count(*) AS row_count
FROM   layoffs_staging;

-- 2. Standardize the Data

-- trimming the initial and last extra spaces in the company column
UPDATE layoffs_staging
SET company = Trim(company)

-- found some industry name with almost same name but different text so updating it
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE  industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging;

SELECT DISTINCT location
FROM layoffs_staging
ORDER BY 1;

UPDATE layoffs_staging
SET [location] = 'Dusseldorf'
WHERE [location] = 'Düsseldorf';

SELECT DISTINCT country
FROM layoffs_staging
ORDER BY 1;

UPDATE layoffs_staging
SET country = trim(trailing '.' FROM country)

SELECT [date]
FROM   layoffs_staging;

-- changing data type from string to date
UPDATE layoffs_staging
SET [date] = CONVERT([DATE], '21/01/2020', 103);

-- another way
-- ALTER TABLE layoffs_staging ALTER COLUMN [date] DATE

-- 3. Handling null values
SELECT *
FROM   layoffs_staging
WHERE industry IS NOT NULL;

-- checking for the missing values have the other record which have industry
SELECT t1.company,
       t1.industry,
       t2.company,
       t2.industry
FROM   layoffs_staging t1
JOIN   layoffs_staging t2
ON     t1.company=t2.company
WHERE  t1.industry IS NULL
AND    t2.industry IS NOT NULL;

-- updating the industry with the relavent values which we found from the other matcing company row
UPDATE t1
SET    t1.industry=t2.industry
FROM   layoffs_staging t1
JOIN   layoffs_staging t2
ON     t1.company = t2.company
WHERE  t1.industry IS NULL
AND    t2.industry IS NOT NULL;


-- 4. Remove unnecessory columns

-- deleting rows which have null in the both columns bcuz it's no use to keep it
SELECT *
FROM   layoffs_staging
WHERE  total_laid_off = 'NULL'
AND    percentage_laid_off = 'NULL';

DELETE
FROM   layoffs_staging
WHERE  total_laid_off = 'NULL'
AND    percentage_laid_off = 'NULL'SELECT *
FROM   layoffs_staging