-- Removing Duplicates

-- Finding duplicated rows in data
WITH duplicate_check AS(
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS data_row,
		layoffs_staging.*
	FROM layoffs_staging
)
SELECT *
FROM duplicate_check
WHERE data_row > 1;

-- Checking if these rows are actually duplicates
SELECT *
FROM layoffs_staging
WHERE
	(company = 'Casper' AND `date` = '9/14/2021') OR
    (company = 'Cazoo' AND `date` = '6/7/2022') OR
    (company = 'Hibob' AND `date` = '3/30/2020') OR
    (company = 'Wildlife Studios' AND `date` = '11/28/2022') OR
    (company = 'Yahoo' AND `date` = '2/9/2023')
ORDER BY company;


-- Deleting rows from new staging dataset
DROP TABLE IF EXISTS `layoffs_staging2`;
CREATE TABLE `layoffs_staging2` (
  `data_row` INT,
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; 

INSERT INTO layoffs_staging2
SELECT 
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS data_row,
	layoffs_staging.*
FROM layoffs_staging;


SELECT * 
FROM layoffs_staging2
WHERE data_row > 1;

DELETE
FROM layoffs_staging2
WHERE data_row > 1;
