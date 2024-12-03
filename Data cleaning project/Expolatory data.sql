-- look at all data
select *
from layoffs_staging2;

-- look at total laid_off by company
select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 Desc;

-- look a min and max date of data
select min(`date`), max(`date`)
from layoffs_staging2;

-- look at total laid_off by industry
select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 Desc;


-- Look at total Laid_off by country
select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 Desc;


-- look at total laid_off by date
select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 1 Desc;

-- by year
select year(`date`), sum(total_laid_off)                    
from layoffs_staging2                       -- there is 3 months in 2023 only, occured 125677 laid_off  
group by year(`date`)
order by 1 Desc;                                     


-- Look at total Laid_off by stage of company
select stage, sum(total_laid_off) -- the post-ipo this is amazon and google of the world 
from layoffs_staging2
group by stage
order by 2 Desc;


-- look based on month
select substring(`date`, 6, 2), sum(total_laid_off)
from layoffs_staging2
group by 1
order by 1 Desc;

-- based month and year
select substring(`date`, 1, 7) as `year_month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by 1
order by 1 Asc;



-- rolling total partition 
with cte as (
select substring(`date`, 1, 7) as `year_month`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by 1
order by 1 Asc
) 
select `year_month`, total_off, sum(total_off) over(order by `year_month`) AS rolling_total
from cte;

-- rolling total partition by year
with MY as (
select substring(`date`, 1, 7) as `year_month`, sum(total_laid_off) as total_off, year(`date`) as `year`
from layoffs_staging2
where substring(`date`, 1, 7) is not null
group by 1, 3
order by 1 Asc
) 
select `year_month`, total_off, sum(total_off) over(partition by `year` order by `year_month`) AS rolling_total
from MY;




-- rank which years they laid off the most employee
-- who laid off the most people per year 

with company_years (company, years, total_laid_off) as
(
select company, year(`date`),  sum(total_laid_off)
from layoffs_staging2
group by company, year(`date`)
), company_year_ranking as
(select *, dense_rank() over(partition by years order by total_laid_off Desc) as ranking
from company_years
where years is not null
)
select *
from company_year_ranking               --    TOP 5 RANKING 
where ranking <= 5;


