-- EDA

-- Date ranges
SELECT
	min(`date`) AS earliest_date,
    max(`date`) AS latest_date
FROM layoffs_staging2;

-- Numerical column measures
SELECT
	'total_laid_off' AS column_name,
	round(min(total_laid_off), 2) AS Minimum,
	round(avg(total_laid_off), 2) AS Average,
    round(max(total_laid_off), 2) AS Maximum,
	round(stddev_samp(total_laid_off), 2) AS Standard_Deviation
FROM layoffs_staging2
UNION ALL
SELECT
	'percentage_laid_off',
	round(min(percentage_laid_off), 2),
	round(avg(percentage_laid_off), 2),
    round(max(percentage_laid_off), 2),
	round(stddev_samp(percentage_laid_off), 2)
FROM layoffs_staging2
UNION ALL
SELECT
	'funds_raised_millions',
	round(min(funds_raised_millions), 2),
	round(avg(funds_raised_millions), 2),
    round(max(funds_raised_millions), 2),
	round(stddev_samp(funds_raised_millions), 2)
FROM layoffs_staging2;


-- Total layoffs
SELECT
	SUM(total_laid_off) total_layoffs
FROM layoffs_staging2;


-- Companies with the most layoffs in a single day
SELECT *
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 10;

-- Companies with the most layoffs in total
SELECT 
	company,
    sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Companies with the most rounds of layoffs
SELECT 
	company,
    count(*) AS layoff_rounds
FROM layoffs_staging2
GROUP BY company
ORDER BY layoff_rounds DESC
LIMIT 10;


-- How many companies went completely under
SELECT count(*) AS companies_under
FROM layoffs_staging2
WHERE percentage_laid_off = 1;


-- Most funded companies that went under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
LIMIT 10;

-- Most amount of layoffs in one day for companies that went under
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
LIMIT 10;


-- Most amount of total layoffs per industry
SELECT 
	industry,
	sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC; 


-- Most amount of total layoffs per country
SELECT 
	country,
	sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 15; 

-- Most amount of total layoffs per location
SELECT 
	location,
	sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 15; 


-- Layoffs per month
SELECT
    SUBSTRING(`date`, 1, 7) AS layoff_month,
    sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT Null
GROUP BY SUBSTRING(`date`, 1, 7)
ORDER BY SUBSTRING(`date`, 1, 7) ASC;



-- Average layoff percentage per industry
SELECT 
	industry,
	avg(percentage_laid_off) AS avg_layoff_percent
FROM layoffs_staging2
GROUP BY industry; 


-- Average layoff percentage per country
SELECT 
	country,
	avg(percentage_laid_off) AS avg_layoff_percent
FROM layoffs_staging2
GROUP BY country; 