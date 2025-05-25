-- Standardizing the data
SELECT * 
FROM layoffs_staging2;

-- Changing 'Null' and blank strings to actually be Null
UPDATE layoffs_staging2
SET company = NULL 
WHERE company = 'NULL' OR company = '';

UPDATE layoffs_staging2
SET location = NULL 
WHERE location = 'NULL' OR location = '';

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = 'NULL' OR industry = '';

UPDATE layoffs_staging2
SET total_laid_off = NULL 
WHERE total_laid_off = 'NULL' OR total_laid_off = '';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL 
WHERE percentage_laid_off = 'NULL' OR percentage_laid_off = '';

UPDATE layoffs_staging2
SET `date` = NULL 
WHERE `date` = 'NULL' OR `date` = '';

UPDATE layoffs_staging2
SET stage = NULL 
WHERE stage = 'NULL' OR stage = '';

UPDATE layoffs_staging2
SET country = NULL 
WHERE country = 'NULL' OR country = '';

UPDATE layoffs_staging2
SET funds_raised_millions = NULL 
WHERE funds_raised_millions = 'NULL' OR funds_raised_millions = '';


-- COMPANY: Removing whitespace from company names
SELECT company, TRIM(company)
FROM layoffs_staging2
ORDER BY company;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- LOCATION: check for different unwanted location variations (no issues)
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

-- INDUSTRY: Make sure there's no repeat industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- Combine all crypto industry variations into one
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'CRYPTO%';


-- STAGE: check for different unwanted stage variations (no issues)
SELECT DISTINCT stage
FROM layoffs_staging2
ORDER BY stage;


-- COUNTRY: check for different unwanted country variations
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- Combine all United States country variations into one
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';


-- Correcting data types for certain columns

-- Changing numerical columns from text to integer / decimal type
ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT DEFAULT NULL,
MODIFY COLUMN percentage_laid_off decimal(5,4) DEFAULT NULL,
MODIFY COLUMN funds_raised_millions INT DEFAULT NULL;

-- Changing the date column to the correct format and then to a date type
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Checking if data types updated correctly
DESCRIBE layoffs_staging2;

SELECT *
FROM layoffs_staging2;