-- DATA CLEANING --

SELECT* 
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standadize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Columns/Rows.




CREATE TABLE `layoffs_staging1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;


INSERT INTO layoffs_staging1
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs
;

SELECT *
FROM layoffs_staging1;

DELETE
FROM layoffs_staging1
WHERE row_num > 1
;

SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging1
;

UPDATE layoffs_staging1
SET company = trim(company);

SELECT DISTINCT industry
FROM layoffs_staging1
	ORDER BY 1;

SELECT industry
FROM layoffs_staging1
WHERE industry LIKE 'Crypto% ';

UPDATE  layoffs_staging1
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto% '
;
SELECT DISTINCT country
FROM layoffs_staging1
WHERE country LIKE 'United States%'
ORDER BY 1
;

SELECT DISTINCT country, trim(TRAILING '.' FROM country)
FROM layoffs_staging1
WHERE country LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_staging1
SET country=trim(TRAILING '.' FROM country);

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging1;
;


UPDATE layoffs_staging1
SET `date`=STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT* 
FROM layoffs_staging1;
  
ALTER TABLE layoffs_staging1
MODIFY COLUMN `date` DATE
;

-- Null and Blank Value --
SELECT*
FROM layoffs_staging1
WHERE total_laid_off IS NULL
;


UPDATE layoffs_staging1
SET industry = NULL
WHERE industry =''
;

SELECT *
FROM layoffs_staging1
WHERE industry IS NULL
OR industry = ''
; 

SELECT *
FROM layoffs_staging1
WHERE company= 'AIRBNB'
;

SELECT *
FROM layoffs_staging1 t1
JOIN layoffs_staging1 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
    WHERE (t1.industry IS NULL OR t1.industry ='')
    AND t2. industry IS NOT NULL;
    
 UPDATE layoffs_staging1 t1
 JOIN layoffs_staging1 t2
	ON t1.company = t2.company
    SET t1.industry = t2. industry
    WHERE (t1.industry IS NULL OR t1.industry ='')
    AND t2. industry IS NOT NULL
;

SELECT *
FROM layoffs_staging1
;


SELECT *
FROM layoffs_staging1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;


DELETE 
FROM layoffs_staging1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;

SELECT * 
FROM layoffs_staging1;


ALTER TABLE layoffs_staging1
DROP COLUMN row_num;



												-- End --











