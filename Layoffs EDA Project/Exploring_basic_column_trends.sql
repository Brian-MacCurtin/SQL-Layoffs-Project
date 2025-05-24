-- EDA

-- Spread of numerical columns
SELECT
	min(`date`) AS earliest_date,
    max(`date`) AS latest_date,
    min(total_laid_off) AS min_layoffs,
    max(total_laid_off) AS max_layoffs,
    min(percentage_laid_off) AS min_layoffs_percent,
    max(percentage_laid_off) AS max_layoffs_percent,
    min(funds_raised_millions) AS min_funds,
    max(funds_raised_millions) AS max_funds
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


-- Most layoffs per month
SELECT
    DATE_FORMAT(`date`, '%m/%Y') AS layoff_month,
    sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY layoff_month
ORDER BY total_layoffs DESC;



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