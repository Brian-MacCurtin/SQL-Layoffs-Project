# Project Overview
This project took a look at layoff numbers from companies world-wide during the COVID pandemic. The dataset provided many descriptive columns regarding each company, as well as some numerical variables regarding the layoffs they had.

# Project Motivation
The original dataset had many issues with it, so this project was designed to learn how to utilize SQL to clean the dataset, and then how to perform EDA on the dataset. This project also gave me hands-on experience working with MySQL and MySQLWorkbench

## Tools I Used
- SQL → Language used to query the database
- MySQL → Database used to store data
- MySQLWorkbench → Platform used to write SQL queries
- Git/Github → Tracks code updates and used for presentation
- Markdown → Used to write this report

## SQL Techniques I Worked On
- Creating/updating tables
- Strings
- Operators and Aggregation
- Joins
- Subqueries and CTEs

## SQL Techniques I Learned
- Optimal data cleaning practices including:
    - Making edits on a staging dataset
    - Removing duplicates
    - Data standardization
    - Dealing with nulls
- Window Functions
- Stored Procedures and Parameters
- Triggers and Events

# Data Cleaning
EXPLANATION HERE

## Removing Duplicates
The first step of the data cleaning process was to remove any rows that contained duplicated information, as these rows are redundant. 

This SQL code below returns all duplicate rows which allows me to delete them:
```SQL
WITH duplicate_check AS(
	SELECT 
		ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS data_row,
		layoffs_staging.*
	FROM layoffs_staging
)
SELECT *
FROM duplicate_check
WHERE data_row > 1;
```

| data_row | company           | location       | industry      | total_laid_off | percentage_laid_off | date       | stage     | country         | funds_raised_millions |
|----------|-------------------|----------------|---------------|----------------|----------------------|------------|-----------|------------------|------------------------|
| 2        | Casper            | New York City  | Retail        | NULL           | NULL                 | 9/14/2021  | Post-IPO  | United States    | 339                    |
| 2        | Cazoo             | London         | Transportation| 750            | 0.15                 | 6/7/2022   | Post-IPO  | United Kingdom   | 2000                   |
| 2        | Hibob             | Tel Aviv       | HR            | 70             | 0.3                  | 3/30/2020  | Series A  | Israel           | 45                     |
| 2        | Wildlife Studios  | Sao Paulo      | Consumer      | 300            | 0.2                  | 11/28/2022 | Unknown   | Brazil           | 260                    |
| 2        | Yahoo             | SF Bay Area    | Consumer      | 1600           | 0.2                  | 2/9/2023   | Acquired  | United States    | 6                      |

This query returned a table of rows that are duplicates in the dataset since the information is appearing for a second time. The code below confirms these rows are duplicates:

```SQL
SELECT *
FROM layoffs_staging
WHERE
	(company = 'Casper' AND `date` = '9/14/2021') OR
    (company = 'Cazoo' AND `date` = '6/7/2022') OR
    (company = 'Hibob' AND `date` = '3/30/2020') OR
    (company = 'Wildlife Studios' AND `date` = '11/28/2022') OR
    (company = 'Yahoo' AND `date` = '2/9/2023')
ORDER BY company;
```
| Company           | Location       | Industry      | Total Laid Off | % Laid Off | Date       | Stage     | Country         | Funds Raised (M) |
|------------------|----------------|---------------|----------------|-------------|------------|-----------|------------------|-------------------|
| Casper           | New York City  | Retail        | NULL           | NULL        | 9/14/2021  | Post-IPO | United States    | 339               |
| Casper           | New York City  | Retail        | NULL           | NULL        | 9/14/2021  | Post-IPO | United States    | 339               |
| Cazoo            | London         | Transportation| 750            | 0.15        | 6/7/2022   | Post-IPO | United Kingdom   | 2000              |
| Cazoo            | London         | Transportation| 750            | 0.15        | 6/7/2022   | Post-IPO | United Kingdom   | 2000              |
| Hibob            | Tel Aviv       | HR            | 70             | 0.3         | 3/30/2020  | Series A | Israel           | 45                |
| Hibob            | Tel Aviv       | HR            | 70             | 0.3         | 3/30/2020  | Series A | Israel           | 45                |
| Wildlife Studios | Sao Paulo      | Consumer      | 300            | 0.2         | 11/28/2022 | Unknown  | Brazil           | 260               |
| Wildlife Studios | Sao Paulo      | Consumer      | 300            | 0.2         | 11/28/2022 | Unknown  | Brazil           | 260               |
| Yahoo            | SF Bay Area    | Consumer      | 1600           | 0.2         | 2/9/2023   | Acquired | United States    | 6                 |
| Yahoo            | SF Bay Area    | Consumer      | 1600           | 0.2         | 2/9/2023   | Acquired | United States    | 6                 |

As we can see, there are 5 duplicated rows that must be deleted

## Data Standardization
The next step is to standardize the data, so we don't run into any issues when preforming EDA or analysis.

### Null and Blank Value Formatting
The first thing I did was dealing with null and blank values that appeared in the dataset. When the dataset was loaded into *MySQLWorkbench*, every column was read in **text** format. This means that every value in the dataset also was read in as text, including numerical values and nulls. 

Entries that have the word "null" must be changed to the proper format for nulls. I also changed blank values to appear as nulls. The code below shows an example of the changes that were made for one column:
```SQL
UPDATE layoffs_staging2
SET company = NULL 
WHERE company = 'NULL' OR company = '';
```

### Whitespace
I then noticed that some company names had unnecessary whitespace in their names. 
```SQL
UPDATE layoffs_staging2
SET company = TRIM(company);
```

### Combining Similar Information


### Correcting Data Types



## Null Evaluation

# Exploratory Data Analysis

# Conclusion