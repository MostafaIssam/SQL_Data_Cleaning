-- Data Cleaning Full project

Select *
from layoffs_staging2;

-- not use fact data replicate it

create table layoffs_Staging
Like layoffs; 

select *
from layoffs_Staging;

insert layoffs_Staging
Select *
from layoffs; 

-- #############################################################

-- 1-Remove Duplicates
select 
row_number() over(partition by Company, location, industry, total_laid_off,
 percentage_laid_off, stage, `date`, country, funds_raised_millions) as row_num
 from layoffs_Staging;

  
with Cte AS(
 select *, 
 row_number() over(partition by Company, location, industry, total_laid_off,
 percentage_laid_off, stage, `date`, country, funds_raised_millions) as row_num
 from layoffs_Staging
 )
select *
from Cte
where row_num > 1;

-- we should make anoher table to remove duplicates 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- then insert our query 

insert into layoffs_staging2
select *, 
row_number() over(partition by Company, location, industry, total_laid_off,
 percentage_laid_off, stage, `date`, country, funds_raised_millions) as row_num
from layoffs_Staging;  

select *
from layoffs_staging2
where row_num > 1;

Delete
from layoffs_staging2
where row_num > 1;


-- ############################################################

-- Standardizing => finding issues => 	Trim(), Trim(Trailing '' from ),  remove any extra charachters
select Distinct(company) 
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

-- ---------

select Distinct industry 
from layoffs_staging2
order by 1;

Update layoffs_staging2
set industry = 'Crypto'
where industry Like 'Crypto%';	

-- ------------

select Distinct country, trim(trailing '.' from country) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = 'United States'
where country = 'United States%';

-- -------------
select Distinct location -- , trim(Trailing '¶' from Location) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set location = trim(Trailing '¶' from Location)
where location Like 'MalmÃ%';

-- -----------------

select `date`, 
str_to_date(`date`, '%m/%d/%Y') 
from layoffs_staging2;

Update layoffs_staging2
set `date` =  str_to_date(`date`, '%m/%d/%Y') ; 

Alter table layoffs_staging2
Modify `date` Date; 


-- #####################################################

-- 3- working with null and blank values => can be remove or populate 
select *
from layoffs_staging2
where industry is null
or industry = ' '; 

select *
from layoffs_staging2 
where company = 'Airbnb';

Select t1.industry, t2.industry 
from layoffs_staging2 t1
join layoffs_staging2 t2
  on t1.company = t2.company
  And t1.location = t2.location
where t1.industry is null or t1.industry = ' '
And t2.industry is not null   ;


update layoffs_staging2 
set industry = null
where industry = '';



Update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company 
set t1.industry = t2.industry
where t1.industry is null 
And t2.industry is not null ;

-- ################################################

-- 4- remove unnessecary columns and rows  
select *
from layoffs_staging2
where total_laid_off is null  
and percentage_laid_off is null;


Delete
from layoffs_staging2
where total_laid_off is null  
and percentage_laid_off is null;


Alter table layoffs_staging2
Drop column row_num;