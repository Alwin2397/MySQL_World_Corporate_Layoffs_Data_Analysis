-- Analyze the trend of layoffs by year and the average percentage of layoffs over time.

SELECT 
    YEAR(`date`) AS year,
    COUNT(*) AS total_events,
    AVG(total_laid_off) AS avg_laid_off,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging1
GROUP BY year
ORDER BY year DESC
;

--  Calculate the year-over-year(yoy) growth of layoffs

WITH Yearly_Layoffs AS (
    SELECT 
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging1
    GROUP BY year
)
SELECT 
    current.year,
    current.total_laid_off,
    ((current.total_laid_off - previous.total_laid_off) / previous.total_laid_off) * 100 AS yoy_growth_percentage
FROM Yearly_Layoffs current
LEFT JOIN Yearly_Layoffs previous
    ON current.year = previous.year + 1
ORDER BY current.year DESC
;
 
-- Compare layoffs between two specific locations, e.g., "New York" and "Los Angeles." --

UPDATE layoffs_staging1
SET location = TRIM(LOWER(location));

SELECT DISTINCT location FROM layoffs_staging1;
 
UPDATE layoffs_staging1
SET location = 'New York'
WHERE location LIKE 'new york%';

UPDATE layoffs_staging1
SET location = 'Los Angeles'
WHERE location LIKE 'los angeles%';
 
SELECT 
    company,
    SUM(CASE WHEN location = 'New York' THEN total_laid_off ELSE 0 END) AS New_York_layoffs,
    SUM(CASE WHEN location = 'Los Angeles' THEN total_laid_off ELSE 0 END) AS Los_Angeles_layoffs
FROM layoffs_staging1
WHERE location IN ('New York', 'Los Angeles')
GROUP BY company
ORDER BY company
;

-- Companies with layoffs increasing by more than 50% between consecutive years --

WITH YearlyLayoffs AS (
    SELECT 
        company,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS yearly_layoffs
    FROM layoffs_staging1
    GROUP BY company, YEAR(`date`)
),
LayoffChange AS (
    SELECT 
        company,
        year,
        yearly_layoffs,
        LAG(yearly_layoffs) OVER (PARTITION BY company ORDER BY year) AS prev_year_layoffs
    FROM YearlyLayoffs
)
SELECT 
    company,
    year,
    yearly_layoffs,
    prev_year_layoffs,
    ((yearly_layoffs - prev_year_layoffs) / prev_year_layoffs) * 100 AS percentage_increase
FROM LayoffChange
WHERE prev_year_layoffs IS NOT NULL
AND ((yearly_layoffs - prev_year_layoffs) / prev_year_layoffs) > 0.5
ORDER BY percentage_increase DESC
;
 
 
-- Companies with layoffs significantly above or below the average for their industry --
WITH IndustryAvg AS (
    SELECT 
        industry,
        AVG(total_laid_off) AS avg_layoffs,
        STDDEV(total_laid_off) AS stddev_layoffs
    FROM layoffs_staging1
    GROUP BY industry
),
CompanyLayoffs AS (
    SELECT 
        l.company,
        l.industry,
        SUM(l.total_laid_off) AS total_layoffs
    FROM layoffs_staging1 l
    GROUP BY l.company, l.industry
)
SELECT 
    c.company,
    c.industry,
    c.total_layoffs,
    i.avg_layoffs,
    i.stddev_layoffs,
    (c.total_layoffs - i.avg_layoffs) / i.stddev_layoffs AS z_score
FROM CompanyLayoffs c
JOIN IndustryAvg i ON c.industry = i.industry
WHERE ABS((c.total_layoffs - i.avg_layoffs) / i.stddev_layoffs) > 2
ORDER BY z_score DESC
;

-- Companies with the highest layoffs relative to funds raised --

SELECT 
    company,
    SUM(total_laid_off) AS total_layoffs,
    MAX(funds_raised_millions) AS total_funding,
    SUM(total_laid_off) / MAX(funds_raised_millions) AS layoffs_per_million
FROM layoffs_staging1
WHERE funds_raised_millions IS NOT NULL AND funds_raised_millions > 0
GROUP BY company
ORDER BY layoffs_per_million DESC
LIMIT 10;

-- Analyzing the correlation between funds raised and layoffs --

WITH Stats AS (
    SELECT 
        AVG(funds_raised_millions) AS avg_funds,
        AVG(total_laid_off) AS avg_layoffs,
        STDDEV(funds_raised_millions) AS stddev_funds,
        STDDEV(total_laid_off) AS stddev_layoffs
    FROM layoffs_staging1
    WHERE funds_raised_millions IS NOT NULL AND total_laid_off IS NOT NULL
),
Covariance AS (
    SELECT 
        SUM((funds_raised_millions - s.avg_funds) * (total_laid_off - s.avg_layoffs)) / 
        (COUNT(*) - 1) AS covariance
    FROM layoffs_staging1, Stats s
    WHERE funds_raised_millions IS NOT NULL AND total_laid_off IS NOT NULL
)
SELECT 
    c.covariance / (s.stddev_funds * s.stddev_layoffs) AS correlation
FROM Covariance c, Stats s;


SELECt*
from layoffs_staging1;
