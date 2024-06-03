
--SQL Project
--Data Cleaning

-- Source: -- https://www.kaggle.com/datasets/swaptr/layoffs-2022

----Aim is to clean the data and to make it more readable----


----Viewing the data----

select * from layoffs;


----Create a staging table (a backup file)----
select top 0 * into layoffs_staging from layoffs;

select * from layoffs_staging;

insert layoffs_staging
select * from layoffs;




-- Follow below steps for data cleaning:
----1. Changing data types and replacing NULL
----2. Remove duplicates
----3. Standarize the data
----4. Null values or Blank Values
----5. Remove Any columns or Rows




--1. Changing data types and replacing NULL---------------------------------------------------------------------------------------------------------------------

----Updating NULL values----

Update layoffs_staging set total_laid_off = NULL where total_laid_off='NULL'

Update layoffs_staging set industry = NULL where industry='NULL'

Update layoffs_staging set funds_raised_millions = NULL where funds_raised_millions='NULL'

----Rounding percentage values----

Update layoffs_staging set percentage_laid_off = round(percentage_laid_off,2) where percentage_laid_off is not null

----Changing Data type of columns----

alter table layoffs_staging
alter column funds_raised_millions float;

alter table layoffs_staging
alter column total_laid_off int;






--2. Remove Duplicates--------------------------------------------------------------------------------------------------------------------------------------

----Check for duplicates----

select * from layoffs_staging;

----Giving Row number by partitioning the rows----

select *,
ROW_NUMBER() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by company)
as row_num
from layoffs_staging;

----Selecting duplicate rows using CTE----

with duplicate_cte as
(select *,
ROW_NUMBER() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by company)
as row_num
from layoffs_staging)
select *
from duplicate_cte
where row_num>1;

----Lets confirm----

select * from layoffs_staging where company='Casper';


----Method 1: To delete the duplicate rows, we will create table layoffs_staging2 using design of layoffs_staging and adding row_num column to it----

select * from layoffs_staging2;

Insert into layoffs_staging2
select *,
ROW_NUMBER() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,date,stage,country,funds_raised_millions order by company)
as row_num
from layoffs_staging;

select * from layoffs_staging2
where row_num=2;

delete from layoffs_staging2
where row_num>1;


----Method 2: To delete the duplicate rows, we will create table layoffs_staging2----

ALTER TABLE layoffs_staging ADD row_num INT;


SELECT * FROM layoffs_staging;

CREATE TABLE layoffs_staging4 (
company nvarchar(50),
location nvarchar(50),
industry nvarchar(50),
total_laid_off INT,
percentage_laid_off float,
date date,
stage nvarchar(50),
country nvarchar(50),
funds_raised_millions float,
row_num INT
);

INSERT INTO layoffs_staging4
(company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions,
row_num)
SELECT company,
location,
industry,
total_laid_off,
percentage_laid_off,
date,
stage,
country,
funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,date, stage, country, funds_raised_millions
			order by company) AS row_num
	FROM 
		layoffs_staging;


DELETE FROM layoffs_staging4
WHERE row_num >= 2;






--3. Standarize the data----------------------------------------------------------------------------------------------------------------------------------

select * from layoffs_staging2;

----Trim Company column----

select distinct(trim(company))
from layoffs_staging2;

update layoffs_staging2
set company=trim(company);


----Checking for spellings in industry column----

select distinct(industry) from layoffs_staging2
order by 1;

----Crypto has multiple variations, so standardize it----

select * from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry='Crypto'
where industry like 'Crypto%';


----Spell check and Punctuation check in country column----

select distinct(country) from layoffs_staging2
order by 1;

----United States has punctuation mark----
select * from layoffs_staging2
where country like 'United States%';

update layoffs_staging2
set country=trim(trailing '.' from country)
where country like 'United States%';






--4. Null values or Blank Values-----------------------------------------------------------------------------------------------------------------------------

----Check for null values in industry column----

select * from layoffs_staging2
where industry is null

select * from layoffs_staging2
where company like 'Airbn%';

----Populate null values if possible----

select * from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company=t2.company
and t1.location=t2.location
where t1.industry is null
and t2.industry is not null

update t1
set t1.industry=t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
   on t1.company=t2.company and t1.location=t2.location
where t1.industry is null
and t2.industry is not null;






--5. Remove any columns and rows if no needed----------------------------------------------------------------------------------------------------------------

----Remove columns where total_laid_off and percentage_laid_off both are empty as it is of no use----

select * from layoffs_staging2
where total_laid_off is null;

select * from layoffs_staging2
where percentage_laid_off is NULL
and total_laid_off is null;

delete
from layoffs_staging2
where percentage_laid_off is NULL
and total_laid_off is null;

----Remove row_num column as it is no longer needed----

alter table layoffs_staging2
drop column row_num;






----Cleaned Data---------------------------------------------------------------------------------------------------------------------------------------------

select * from layoffs_staging2;

