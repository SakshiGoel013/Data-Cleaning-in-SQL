--Exploratory Data Analysis (EDA)

--Explore the data and find trends or patterns or anything interesting like outliers
-- The data of worldwide layoffs is of 3 years from 2020 to 2023

--Aim is to find:
----1. The size of layoffs
----2. Size of company who layoffs
----3. Total layoffs by different parameters
----4. Rolling Total of Layoffs
----5. Ranking the company based on total layoff yearwise



SELECT * 
FROM layoffs_staging2;




--1. The size of layoffs-------------------------------------------------------------------------------------------------------------------------------------

----Maximum Layoff----

SELECT MAX(total_laid_off)
FROM layoffs_staging2;


----Looking at total layoff to see how big these layoffs were----

SELECT MAX(total_laid_off),  MIN(total_laid_off)
FROM layoffs_staging2
WHERE  total_laid_off IS NOT NULL;


----Which companies had 1 which is basically 100 percent of they company laid off----

SELECT *
FROM layoffs_staging2
WHERE  percentage_laid_off = 1
order by total_laid_off desc;
-- these are mostly startups it looks like who all went out of business during this time






--2. Size of company who layoffs----------------------------------------------------------------------------------------------------------------------------

----if we order by funds_raised_millions we can see how big some of these companies were----

SELECT *
FROM layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- BritishVolt looks like an EV company, raised like 2 billion dollars and went under - ouch






--3. Total layoffs by different parameters---------------------------------------------------------------------------------------------------------------------

----Companies with the highest single layoff----

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

--Amazon has the biggest total layoff of 18150




----Industry with the highest layoff----

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

--Consumer has the biggest layoff of 45182




----Country with highest layoff----

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

--Maximum layoff is in the United states which is 256559




---- Layoffs by date----

select date, sum(total_laid_off)
from layoffs_staging2
group by date
order by 2 desc;

-- On 4th Jan'2023 there was a highest layoff of 16171 employees




----Layoffs by Year----

select year(date), sum(total_laid_off)
from layoffs_staging2
group by year(date)
order by 2 desc;

-- 2022 was the year of biggest layoff of 160661 people




----Layoffs by Stage----

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

--Post-IPO has biggest layoffs




----Layoffs by Year and Month----

select year(date) as 'year', month(date) as 'month_no', sum(total_laid_off) as 'sum of laidoff'
from layoffs_staging2
where month(date) is not null
group by year(date),month(date)
order by 1,2;






--4. Rolling Total of Layoffs------------------------------------------------------------------------------------------------------------------------------------

----Rolling Total Year wise----

with rolling_total (year_no,month_no, sum_of_laidoff) as
(select year(date), month(date), sum(total_laid_off)
from layoffs_staging2
where month(date) is not null
group by year(date),month(date)
)
select year_no,month_no, sum(sum_of_laidoff) over(partition by year_no order by year_no, month_no) as rolling_total_year_wise
from rolling_total;


---- Rolling Total month wise----
with rolling_total (year_no,month_no, sum_of_laidoff) as
(select year(date), month(date), sum(total_laid_off)
from layoffs_staging2
where month(date) is not null
group by year(date),month(date)
)
select year_no,month_no, sum_of_laidoff, sum(sum_of_laidoff) over(order by year_no, month_no) as Rolling_total_month_wise
from rolling_total;






-- 5.Ranking the company based on total layoff yearwise------------------------------------------------------------------------------------------------------------

----Total Layoff year wise based on company----

select company, year(date) as year_no, sum(total_laid_off) as total_laidoff
from layoffs_staging2
group by company, year(date)
order by 3 desc;

----Top 5 companies with most layoffs yearwise----

with Company_Year as
(select company, year(date) as year_no, sum(total_laid_off) as total_laidoff
from layoffs_staging2
where year(date) is not null
group by company, year(date)
),
company_year_rank as(
select * ,dense_rank() over(partition by year_no order by total_laidoff desc) as ranking
from Company_Year)
select * from company_year_rank
where ranking<=5;
