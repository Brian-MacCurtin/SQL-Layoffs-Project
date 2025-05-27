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

Some things I went to explore were:
- Measures of spread for quantitative variables
- Trends related to the *total_laid_off* variable
- Layoffs over time
- PUT SOMETHING HER GhEOINVKTIHEKLNVPHTWKE

## Spread of Quantitative Variables
First, I wanted to get a sense of the dates this data was collected between. 
```SQL
SELECT
	min(`date`) AS earliest_date,
    max(`date`) AS latest_date
FROM layoffs_staging2;
```
| earliest_date | latest_date |
|---------------|-------------|
| 2020-03-11    | 2023-03-06  |

I then explored some of the basic measures for the quantitative variables
```SQL
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
```
| Column Name            | Minimum | Average | Maximum   | Standard Deviation |
|------------------------|---------|---------|-----------|---------------------|
| total_laid_off         | 3.00    | 237.27  | 12000.00  | 769.81              |
| percentage_laid_off    | 0.00    | 0.26    | 1.00      | 0.26                |
| funds_raised_millions  | 0.00    | 875.11  | 121900.00 | 6024.14             |


## Trends Relating to Total Layoffs

#### Total Layoffs
```SQL
SELECT
	SUM(total_laid_off) total_layoffs
FROM layoffs_staging2;
```

- There were 383,659 total layoffs recorded in this dataset during the 3-year period between March 11, 2020, and March 6, 2023.

#### Companies with Most Layoffs in a Single Day
```SQL
SELECT *
FROM layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 10;
```
| Company       | Location      | Industry   | Total Laid Off | % Laid Off | Date       | Stage     | Country        | Funds Raised ($M) |
|--------------|---------------|------------|----------------|------------|------------|-----------|----------------|-------------------|
| Google        | SF Bay Area   | Consumer   | 12,000         | 0.0600     | 2023-01-20 | Post-IPO  | United States  | 26                |
| Meta          | SF Bay Area   | Consumer   | 11,000         | 0.1300     | 2022-11-09 | Post-IPO  | United States  | 26,000            |
| Amazon        | Seattle       | Retail     | 10,000         | 0.0300     | 2022-11-16 | Post-IPO  | United States  | 108               |
| Microsoft     | Seattle       | Other      | 10,000         | 0.0500     | 2023-01-18 | Post-IPO  | United States  | 1                 |
| Ericsson      | Stockholm     | Other      | 8,500          | 0.0800     | 2023-02-24 | Post-IPO  | Sweden         | 663               |
| Amazon        | Seattle       | Retail     | 8,000          | 0.0200     | 2023-01-04 | Post-IPO  | United States  | 108               |
| Salesforce    | SF Bay Area   | Sales      | 8,000          | 0.1000     | 2023-01-04 | Post-IPO  | United States  | 65                |
| Dell          | Austin        | Hardware   | 6,650          | 0.0500     | 2023-02-06 | Post-IPO  | United States  | *(null)*          |
| Philips       | Amsterdam     | Healthcare | 6,000          | 0.1300     | 2023-01-30 | Post-IPO  | Netherlands     | *(null)*          |
| Booking.com   | Amsterdam     | Travel     | 4,375          | 0.2500     | 2020-07-30 | Acquired  | Netherlands     | *(null)*          |

- The top three companies that experienced the most layoffs in a single day, Google, Meta and Amazon are some of the biggest and most well-known companies in the world.

- Amazon had two days when they experience a large amount of layoffs.

- Six of the companies are from the US, two are from the Netherlands, followed by one from Sweden.

- Every company is in the Post-IPO stage except for Booking.com.

#### Companies with Most Layoffs in Total
```SQL
SELECT 
	company,
    sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;
```
| Company       | Total Layoffs |
|---------------|----------------|
| Amazon        | 18,150         |
| Google        | 12,000         |
| Meta          | 11,000         |
| Salesforce    | 10,090         |
| Philips       | 10,000         |
| Microsoft     | 10,000         |
| Ericsson      | 8,500          |
| Uber          | 7,585          |
| Dell          | 6,650          |
| Booking.com   | 4,601          |

- Again, Amazon, Google and Meta make up the top three companies that had the most total layoffs.

- From the top 10 most layoffs in total, only Uber didn't appear in the top 10 layoffs in a single day.

#### Companies with Most Rounds of Layoffs
```SQL
SELECT 
	company,
    count(*) AS layoff_rounds
FROM layoffs_staging2
GROUP BY company
ORDER BY layoff_rounds DESC
LIMIT 10;
```
| Company     | Layoff Rounds |
|-------------|----------------|
| Loft        | 6              |
| Swiggy      | 5              |
| Uber        | 5              |
| WeWork      | 5              |
| Zymergen    | 4              |
| Vedantu     | 4              |
| Argo AI     | 4              |
| Shopify     | 4              |
| Salesforce  | 4              |
| Patreon     | 4              |

- Loft lead the way with the most layoff rounds with 6, the only company to have that many.

- Only Uber and Salesforce appeared in the top 10 total layoffs.

#### Numbers of Companies That Went Completely Under
```SQL
SELECT count(*) AS companies_under
FROM layoffs_staging2
WHERE percentage_laid_off = 1;
```

There were companies 116 companies that laid off 100% of their employees, meaning they went under.

#### Top Funded Companies That Went Completely Under
```SQL
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
LIMIT 10;
```
| Company             | Location      | Industry      | Total Laid Off | % Laid Off | Date       | Stage         | Country          | Funds Raised ($M) |
|---------------------|---------------|----------------|----------------|------------|------------|----------------|-------------------|--------------------|
| Britishvolt         | London        | Transportation | 206            | 1.0000     | 2023-01-17 | Unknown        | United Kingdom    | 2400               |
| Quibi               | Los Angeles   | Media          | –              | 1.0000     | 2020-10-21 | Private Equity | United States     | 1800               |
| Deliveroo Australia | Melbourne     | Food           | 120            | 1.0000     | 2022-11-15 | Post-IPO       | Australia         | 1700               |
| Katerra             | SF Bay Area   | Construction   | 2434           | 1.0000     | 2021-06-01 | Unknown        | United States     | 1600               |
| BlockFi             | New York City | Crypto         | –              | 1.0000     | 2022-11-28 | Series E       | United States     | 1000               |
| Aura Financial      | SF Bay Area   | Finance        | –              | 1.0000     | 2021-01-11 | Unknown        | United States     | 584                |
| Openpay             | Melbourne     | Finance        | 83             | 1.0000     | 2023-02-07 | Post-IPO       | Australia         | 299                |
| Pollen              | London        | Marketing      | –              | 1.0000     | 2022-08-10 | Series C       | United Kingdom    | 238                |
| Simple Feast        | Copenhagen    | Food           | 150            | 1.0000     | 2022-09-07 | Unknown        | Denmark           | 173                |
| Arch Oncology       | Brisbane      | Healthcare     | –              | 1.0000     | 2023-01-13 | Series C       | United States     | 155                |

- Of the companies that went under, Britishvolt had the most funding at approximately $2,400,000,000.

- Four other companies that went under had funding in excess of a billion dollars.

- There are multiple different industries represented in this table.

#### Most Layoffs in One Day for Companies That Went Completely Under
```SQL
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
LIMIT 10;
```
| Company             | Location      | Industry      | Total Laid Off | % Laid Off | Date       | Stage         | Country          | Funds Raised ($M) |
|---------------------|---------------|----------------|----------------|------------|------------|----------------|-------------------|--------------------|
| Katerra             | SF Bay Area   | Construction   | 2434           | 1.0000     | 2021-06-01 | Unknown        | United States     | 1600               |
| Butler Hospitality  | New York City | Food           | 1000           | 1.0000     | 2022-07-08 | Series B       | United States     | 50                 |
| Deliv               | SF Bay Area   | Retail         | 669            | 1.0000     | 2020-05-13 | Series C       | United States     | 80                 |
| Jump                | New York City | Transportation | 500            | 1.0000     | 2020-05-07 | Acquired       | United States     | 11                 |
| SEND                | Sydney        | Food           | 300            | 1.0000     | 2022-05-04 | Seed           | Australia         | 3                  |
| HOOQ                | Singapore     | Consumer       | 250            | 1.0000     | 2020-03-27 | Unknown        | Singapore         | 95                 |
| Stoqo               | Jakarta       | Food           | 250            | 1.0000     | 2020-04-25 | Series A       | Indonesia         | –                  |
| Stay Alfred         | Spokane       | Travel         | 221            | 1.0000     | 2020-05-20 | Series B       | United States     | 62                 |
| Britishvolt         | London        | Transportation | 206            | 1.0000     | 2023-01-17 | Unknown        | United Kingdom    | 2400               |
| Planetly            | Berlin        | Other          | 200            | 1.0000     | 2022-11-04 | Acquired       | Germany           | 5                  |

- Katerra had the most people laid off at a single time for companies that went under at a staggering 2434 employees.

- The top four companies in this table are from New York City and San Francisco

#### Most Layoffs per Industry
```SQL
SELECT 
	industry,
	sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 15; 
```
| Industry        | Total Layoffs |
|----------------|---------------|
| Consumer        | 45,182        |
| Retail          | 43,613        |
| Other           | 36,289        |
| Transportation  | 33,748        |
| Finance         | 28,344        |
| Healthcare      | 25,953        |
| Food            | 22,855        |
| Real Estate     | 17,565        |
| Travel          | 17,159        |
| Hardware        | 13,828        |
| Education       | 13,338        |
| Sales           | 13,216        |
| Crypto          | 10,693        |
| Marketing       | 10,258        |
| Fitness         | 8,748         |

- The industries hit the heaviest by the pandemic had jobs that mainly required face-to-face interactions.

- Many jobs weren't classified into one of the named industries from the dataset and can be found under *Other*

#### Most Layoffs per Country
```SQL
SELECT 
	country,
	sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC
LIMIT 15; 
```
| Country               | Total Layoffs |
|-----------------------|---------------|
| United States         | 256,559       |
| India                 | 35,993        |
| Netherlands           | 17,220        |
| Sweden                | 11,264        |
| Brazil                | 10,391        |
| Germany               | 8,701         |
| United Kingdom        | 6,398         |
| Canada                | 6,319         |
| Singapore             | 5,995         |
| China                 | 5,905         |
| Israel                | 3,638         |
| Indonesia             | 3,521         |
| Australia             | 2,324         |
| Nigeria               | 1,882         |
| United Arab Emirates  | 995           |

- The US had more than seven times more layoffs than India, which had the second most layoffs.

- Many of the most populous countries experienced high amounts of layoffs

- Surprisingly, some relatively smaller countries, like the Netherlands, Sweden, Israel, and the UAE, appeared on this list

#### Most Layoffs per Location
```SQL
SELECT 
	location,
	sum(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 15; 
```
| Location      | Total Layoffs |
|---------------|---------------|
| SF Bay Area   | 125,631       |
| Seattle      | 34,743        |
| New York City | 29,364        |
| Bengaluru     | 21,787        |
| Amsterdam     | 17,140        |
| Stockholm    | 11,217        |
| Boston       | 10,785        |
| Sao Paulo    | 9,081         |
| Austin       | 8,980         |
| Chicago      | 6,419         |
| Los Angeles  | 6,415         |
| London       | 6,177         |
| Singapore    | 5,995         |
| Mumbai       | 5,915         |
| Gurugram     | 5,376         |

- San Francisco experienced the most total layoffs with more than three times the amount of layoffs in Seattle.

- All the cities on this list are located in one of the countries that appeared in the top 15 layoffs per country

## Layoffs over Time


## PUT SOMETHING HERE GHIOREKNLVHTOVENLKBHTKWNLVIPHKNV


# Conclusion