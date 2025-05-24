-- Rolling total of layoffs per month
WITH layoffs_per_month AS (
	SELECT
		SUBSTRING(`date`, 1, 7) AS layoff_month,
		SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT Null
	GROUP BY SUBSTRING(`date`, 1, 7)	
)
SELECT 
	layoff_month,
    total_layoffs,
	SUM(total_layoffs) OVER(ORDER BY layoff_month) AS Rolling_total
FROM layoffs_per_month
ORDER BY layoff_month ASC;

-- Rolling total of layoffs per year
WITH layoffs_per_year AS (
	SELECT
		SUBSTRING(`date`, 1, 4) AS layoff_year,
		SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 4) IS NOT Null
	GROUP BY SUBSTRING(`date`, 1, 4)	
)
SELECT 
	layoff_year,
    total_layoffs,
	SUM(total_layoffs) OVER(ORDER BY layoff_year) AS Rolling_total
FROM layoffs_per_year
ORDER BY layoff_year ASC;



-- Companies with the top 5 most layoffs per year 
WITH layoffs_per_company AS (
	SELECT
		company,
		YEAR(`date`) as `year`,
		SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
	WHERE YEAR(`date`) IS NOT Null
	GROUP BY company, YEAR(`date`)	
),
company_year_rank AS(
	SELECT 
		company,
		`year`,
		total_layoffs,
		DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoffs DESC) AS layoff_rank
	FROM layoffs_per_company
	ORDER BY `year`, layoff_rank ASC
)
SELECT *
FROM company_year_rank
WHERE layoff_rank <= 5;



-- Industries with the top 5 most layoffs per year 
WITH layoffs_per_industry AS (
	SELECT
		industry,
		YEAR(`date`) as `year`,
		SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
	WHERE YEAR(`date`) IS NOT Null
	GROUP BY industry, YEAR(`date`)	
),
industry_year_rank AS(
	SELECT 
		industry,
		`year`,
		total_layoffs,
		DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoffs DESC) AS layoff_rank
	FROM layoffs_per_industry
	ORDER BY `year`, layoff_rank ASC
)
SELECT *
FROM industry_year_rank
WHERE layoff_rank <= 5;




-- Average ranking for layoffs per year for each industry
WITH layoffs_per_industry AS (
	SELECT
		industry,
		YEAR(`date`) as `year`,
		SUM(total_laid_off) AS total_layoffs
	FROM layoffs_staging2
	WHERE YEAR(`date`) IS NOT Null
	GROUP BY industry, YEAR(`date`)	
),
industry_year_rank AS(
	SELECT 
		industry,
		`year`,
		total_layoffs,
		DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoffs DESC) AS layoff_rank
	FROM layoffs_per_industry
	ORDER BY `year`, layoff_rank ASC
)
SELECT 
	industry,
	AVG(layoff_rank) AS avg_rank
FROM industry_year_rank
GROUP BY industry
ORDER BY avg_rank;