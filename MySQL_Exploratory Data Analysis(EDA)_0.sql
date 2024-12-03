-- Exploratory Data Analysis(EDA) --

SELECT *
FROM layoffs_staging1;

# Queries Max_laid off, MAX_%_ laid-off, Industries/Companies Suffered complete Lay-offs in Descending order, 


SELECT MAX(total_laid_off),MAX(percentage_laid_off)
FROM layoffs_staging1
;

SELECT *
FROM layoffs_staging1
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company
ORDER BY 2 DESC;

SELECT min(`date`), MAX(`date`)
FROM layoffs_staging1;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY industry
ORDER BY 2 DESC;
 
SELECT *
FROM layoffs_staging1;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR (`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY YEAR (`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY stage
ORDER BY 2 DESC;

 SELECT substring(`DATE`,1,7) AS `MONTH`, SUM(total_laid_off)
 FROM layoffs_staging1
 WHERE substring(`DATE`,1,7) IS NOT NULL
 GROUP BY `MONTH`
 ORDER BY 1 ASC
 ;
 
 
 WITH Rolling_total AS
 (
 SELECT substring(`DATE`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
 FROM layoffs_staging1
 WHERE substring(`DATE`,1,7) IS NOT NULL
 GROUP BY `MONTH`
 ORDER BY 1 ASC
 )
 SELECT `MONTH`, total_off, 
 SUM(total_off)OVER (ORDER BY `MONTH`) AS Rolling_total
 FROM Rolling_total;
 
 
 SELECT company, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company
ORDER BY 2 DESC;

 SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
)
SELECT*
FROM Company_Year;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
)
SELECT*, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC
;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
)
SELECT*
FROM Company_Year;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL

)
SELECT *
FROM Company_Year_Rank
WHERE Ranking >= 5
;




								-- XXX --

