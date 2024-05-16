--Data cleaning in sql

select * from [Portfolio Project]..layoffs

 --1. Remove Duplicates
 --2. Standardize the data
 --3. Null values or blank values
 --4. Remove any columns   

select * from [Portfolio Project]..layoffs_staging

insert into [Portfolio Project]..layoffs_staging
select * from [Portfolio Project]..layoffs

alter table [Portfolio Project]..layoffs_staging
alter column date date

select * from [Portfolio Project]..layoffs_staging


--Removing duplicates
select *,
ROW_NUMBER() over(
partition by company, industry, total_laid_off, percentage_laid_off, date order by total_laid_off) as row_num
from [Portfolio Project]..layoffs_staging
order by row_num

with duplicate_CTE as
(
select *,
ROW_NUMBER() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions order by total_laid_off) as row_num
from [Portfolio Project]..layoffs_staging
)
select *
from duplicate_CTE
where row_num > 1

select * from [Portfolio Project]..layoffs_staging2

insert into [Portfolio Project]..layoffs_staging2
select *,
ROW_NUMBER() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions order by total_laid_off) as row_num
from [Portfolio Project]..layoffs_staging

select * from [Portfolio Project]..layoffs_staging2
where row_num > 1

delete from [Portfolio Project]..layoffs_staging2
where row_num > 1

select * from [Portfolio Project]..layoffs_staging2

--standardizing data

select * from [Portfolio Project]..layoffs_staging2

update [Portfolio Project]..layoffs_staging2
set company = TRIM(company)

select * from [Portfolio Project]..layoffs_staging2
where industry like 'Crypto%'

update [Portfolio Project]..layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'

select distinct country, TRIM(Trailing '.' from country)
from [Portfolio Project]..layoffs_staging2
order by 1

update [Portfolio Project]..layoffs_staging2
set country = 'united states'
where country = 'united states.'

select distinct country 
from [Portfolio Project]..layoffs_staging2

select * from [Portfolio Project]..layoffs_staging2
where total_laid_off is null

select * from [Portfolio Project]..layoffs_staging2
where industry is null or industry = ' '

select * from [Portfolio Project]..layoffs_staging2
where company = 'Airbnb'

select *
from [Portfolio Project]..layoffs_staging2 t1
join [Portfolio Project]..layoffs_staging2 t2
	on t1.company = t2.company
where t1.industry is null or t1.industry =''
and t2.industry is not null

select t1.industry, t2.industry
from [Portfolio Project]..layoffs_staging2 t1
join [Portfolio Project]..layoffs_staging2 t2
	on t1.company = t2.company
where t1.industry is null or t1.industry =''
and t2.industry is not null

update [Portfolio Project]..layoffs_staging2 t1
join [Portfolio Project]..layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry 
where t1.industry is null
and t2.industry is not null

select * from [Portfolio Project]..layoffs_staging2
where total_laid_off is null or total_laid_off = ''
and percentage_laid_off is null or percentage_laid_off = ''

delete from [Portfolio Project]..layoffs_staging2
where total_laid_off is null or total_laid_off = ''
and percentage_laid_off is null or percentage_laid_off = ''

select * from [Portfolio Project]..layoffs_staging2

delete from [Portfolio Project]..layoffs_staging2
where Date is null

alter table [Portfolio Project]..layoffs_staging2
drop column row_num 


--Exploratory analysis

select MAX(total_laid_off) as TotalLaidOff, MAX(percentage_laid_off) as MaxPercentage
from [Portfolio Project]..layoffs_staging2

select *
from [Portfolio Project]..layoffs_staging2
where total_laid_off > 1000 and percentage_laid_off is not null
order by funds_raised_millions desc

alter table [Portfolio Project]..layoffs_staging2
alter column total_laid_off int

select company, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by company
order by 2 desc

select min(date), max(date)
from [Portfolio Project]..layoffs_staging2

select industry, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by industry
order by 2 desc

select country, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by country
order by 2 desc

select YEAR(date) as Year, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by YEAR(date)
order by 1 desc

select stage, sum(total_laid_off)
from [Portfolio Project]..layoffs_staging2
group by stage
order by 2 desc

select SUBSTRING(date,1,6) as MONTHS, SUM(total_laid_off)
from [Portfolio Project]..layoffs_staging2
group by SUBSTRING(date,1,6)
order by 1 asc

select company, year(date)as Year, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by company, year(date)
order by company asc

select company, year(date)as Year, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by company, year(date)
order by 3 desc

with Company_Year as
(
select company, year(date)as Year, SUM(total_laid_off) Total_laid_off
from [Portfolio Project]..layoffs_staging2
group by company, year(date)
), Company_Year_Rank as
(select *,
DENSE_RANK() over(partition by year order by total_laid_off desc) as ranking
from Company_Year
where Year is not null
)
select *
from Company_Year_Rank
where ranking <= 5
order by ranking asc