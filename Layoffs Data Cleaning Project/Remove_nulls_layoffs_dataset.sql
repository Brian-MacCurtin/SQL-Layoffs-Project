-- Nulls

-- Looking to see if we can replace nulls in certain columns
SELECT *
FROM layoffs_staging2
WHERE
	industry IS Null;

SELECT *
FROM layoffs_staging2
WHERE
	company = 'Airbnb' OR
    company = 'Bally''s Interactive' OR
    company = 'Carvana' OR
    company = 'Juul';
    
-- Try to populate the Null industry if it is listed in another column for that company
SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company AND
	   t1.location = t2.location
WHERE 
	t1.industry IS Null AND
    t2.industry IS NOT Null;
    
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company AND
	   t1.location = t2.location
SET t1.industry = t2.industry
WHERE 
	t1.industry IS Null AND
    t2.industry IS NOT Null;
    
-- Checking to see if it worked
-- Bally's Interactive didn't have another row which had it's industry, so it didn't get updated
SELECT *
FROM layoffs_staging2
WHERE
	company = 'Airbnb' OR
    company = 'Bally''s Interactive' OR
    company = 'Carvana' OR
    company = 'Juul';
    
    

-- Deleting rows where total_laid_off AND percentage_laid_off is Null
DELETE
FROM layoffs_staging2
WHERE
	total_laid_off IS Null AND
    percentage_laid_off IS Null;
    
    
-- Don't need data_row column anymore -> delete it
ALTER TABLE layoffs_staging2
DROP COLUMN data_row;



-- FINAL TABLE
SELECT *
FROM layoffs_staging2;