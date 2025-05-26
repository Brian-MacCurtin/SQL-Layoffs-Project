# Project Overview
This project took a look at layoff numbers from companies world-wide during the COVID pandemic. The dataset provided many descriptive columns regarding each company, as well as some numerical variables regarding the layoffs they had. 

I mainly wanted to explore different trends related to the total amount of people laid off at a time for different companies and what percentage of the company was laid off.

# Project Motivation
The original dataset had many issues with it, so this project was designed to learn how to utilize SQL to clean the dataset, and then how to perform EDA on the dataset. This project also gave me hands-on experience working with MySQL and MySQLWorkbench.

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
Next, I checked each variable to see if it had any redundant information as values. Any values containing similar information should be normalized.

For example, every variation of *Crypto* can be combined into one singe industry.
| Industry          |
|-------------------|
| Consumer          |
| Crypto            |
| Crypto Currency   |
| CryptoCurrency    |
| Data              |

```SQL
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'CRYPTO%';
```
This normalizes all *Crypto* variations into one single industry.

I also had to do the same thing for the *Country* column. Some rows of data listed the United States with a period at the end by accident. This code corrects that error:
```SQL
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';
```

### Correcting Data Types
Finally, as mentioned earlier, all the data was read into the table in text format. In order to perform proper analysis on numerical variables they must be formatted as the right data type.
```SQL
ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT DEFAULT NULL,
MODIFY COLUMN percentage_laid_off decimal(5,4) DEFAULT NULL,
MODIFY COLUMN funds_raised_millions INT DEFAULT NULL;
```

I also changed the *date* variable to the date format for future filtering and time series analysis 
```SQL
UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```

## Null Evaluation
The final step to data cleaning was dealing with null values in the dataset. 


#### Qualitative Variables
First, I looked at every column to see if it had null values in it. Of the qualitative variables, only *industry* had a handful of null values. To combat this issue, I ran a query that found all the company names that didn't have an industry listed. Then, I checked if that company had their industry listed in another entry in the dataset, as seen below:
| data_row | company            | location      | industry      | total_laid_off | percentage_laid_off | date       | stage          | country         | funds_raised_millions |
|----------|--------------------|---------------|----------------|----------------|----------------------|------------|----------------|------------------|------------------------|
| 1        | Airbnb             | SF Bay Area   | *null*         | 30             | *null*               | 2023-03-03 | Post-IPO       | United States    | 6400                   |
| 1        | Airbnb             | SF Bay Area   | Travel         | 1900           | 0.2500               | 2020-05-05 | Private Equity | United States    | 5400                   |
| 1        | Bally's Interactive| Providence     | *null*         | *null*         | 0.1500               | 2023-01-18 | Post-IPO       | United States    | 946                    |
| 1        | Carvana            | Phoenix        | *null*         | 2500           | 0.1200               | 2022-05-10 | Post-IPO       | United States    | 1600                   |
| 1        | Carvana            | Phoenix        | Transportation | 1500           | 0.0800               | 2022-11-18 | Post-IPO       | United States    | 1600                   |
| 1        | Carvana            | Phoenix        | Transportation | *null*         | *null*               | 2023-01-13 | Post-IPO       | United States    | 1600                   |
| 1        | Juul               | SF Bay Area    | *null*         | 400            | 0.3000               | 2022-11-10 | Unknown        | United States    | 1500                   |
| 1        | Juul               | SF Bay Area    | Consumer       | 900            | 0.3000               | 2020-05-05 | Unknown        | United States    | 1500                   |

Three of the four companies that didn't have an industry listed in one row have their industry listed in another row. I used a self join to add a company's industry instead of the null.
```SQL
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
```

#### Quantitative Variables
Of the three quantitative variables, I wanted to look at trends in the *total_laid_off* and *percentage_laid_off* columns in the EDA section, so any row that had nulls for **both** variables would be useless. 

However, if a row had only one of these columns as null, since the other column contained helpful layoff information about the company, I would keep this row. Therefore, I only removed rows where *total_laid_off* and *percentage_laid_off* were null.
```SQL
DELETE
FROM layoffs_staging2
WHERE
	total_laid_off IS Null AND
    percentage_laid_off IS Null;
```

# Exploratory Data Analysis
After cleaning the data, exploratory data analysis is important to gauge different aspects of the data. Insights gained during EDA can be very influential during higher level analysis of the data.

I first wanted to get a sense of the dates this data was collected between. 
```SQL
SELECT
	min(`date`) AS earliest_date,
    max(`date`) AS latest_date
FROM layoffs_staging2;
```
| earliest_date | latest_date |
|---------------|-------------|
| 2020-03-11    | 2023-03-06  |

I also wanted to explore some of the basic measures for the quantitative variables
```SQL
SELECT
	'total_laid_off' AS column_name,
	round(min(total_laid_off), 2) AS Minimum,
	round(avg(total_laid_off), 2) AS Average,
    round(max(total_laid_off), 2) AS Maximum
FROM layoffs_staging2
UNION ALL
SELECT
	'percentage_laid_off',
	round(min(percentage_laid_off), 2),
	round(avg(percentage_laid_off), 2),
    round(max(percentage_laid_off), 2)
FROM layoffs_staging2
UNION ALL
SELECT
	'funds_raised_millions',
	round(min(funds_raised_millions), 2),
	round(avg(funds_raised_millions), 2),
    round(max(funds_raised_millions), 2)
FROM layoffs_staging2;
```
| Column_name         | Minimum | Average     | Maximum    |
|---------------------|---------|-------------|------------|
| total_laid_off      | 3.00  | 237.27| 12000.00 |
| percentage_laid_off | 0.00  | 0.26  | 1.00     |
| funds_raised_millions| 0.00 | 875.11| 121900.00|

Next, I wanted to explore some of the *total_laid_off* trends. 

#### Total Layoffs
```SQL
SELECT
	SUM(total_laid_off) total_layoffs
FROM layoffs_staging2;
```
| total_layoffs |
|---------------|
| 383,659       |


#### Companies with Most Layoffs in a Single Day
```SQL

```


#### Companies with Most Layoffs in Total
```SQL

```


#### Companies with Most Rounds of Layoffs
```SQL

```


#### Numbers of Companies That Went Completely Under
```SQL

```


#### Top Funded Companies That Went Completely Under
```SQL

```


#### Most Layoffs in One Day for Companies That Went Completely Under
```SQL

```


#### Most Layoffs per Industry
```SQL

```


#### Most Layoffs per Country
```SQL

```


#### Most Layoffs per Location
```SQL

```

# Conclusion