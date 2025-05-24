-- DROP TABLE layoffs

SELECT * FROM layoffs;

-- Creating duplicate dataset to make edits in
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * 
FROM layoffs;

SELECT * FROM layoffs_staging;