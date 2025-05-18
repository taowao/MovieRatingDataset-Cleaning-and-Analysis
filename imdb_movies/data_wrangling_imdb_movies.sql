-- Data Cleaning on the imdb movies dataset

-- 1. Removing any duplicates
-- 2. Standardizing the data
-- 3. Modifying any null values
-- 4. Removing any unused columns

-- For reference
select *
from messy_imdb_dataset;

-- Creating a table to work on

create table imdb_movies
like messy_imdb_dataset;

insert into imdb_movies
select *
from messy_imdb_dataset;

select *
from imdb_movies;

-- Changing the field names for better readability

alter table imdb_movies
rename column `IMBD title ID` to IMDB_title_id,
rename column `Original titlÊ` to original_title,
rename column `Release year` to release_year,
rename column `Genrë¨` to genre,
rename column `Content Rating` to content_rating;

alter table imdb_movies
rename column `Duration` to duration,
rename column `Country` to country,
rename column `Director` to director,
rename column `Income` to income,
rename column `Votes` to votes,
rename column `Score` to score;


-- 1. Removing duplicates

select *, row_number() over(partition by 
IMDB_title_id,
original_title,
release_year,
genre,
content_rating,
duration,
country,
director,
income,
votes,
score) as row_num
from imdb_movies;

-- It seems there are no duplicates in this dataset


-- 2. Standardizing data

-- Changing the release year type from text to date

select release_year, clean_release_year
from imdb_movies;

alter table imdb_movies
add column clean_release_year text;

update imdb_movies
set clean_release_year = release_year;

select release_year,
  
  case
	-- parsing as YYYY-MM-DD
    when STR_TO_DATE(release_year, '%Y-%m-%d') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%Y-%m-%d'), '%Y-%m-%d')
    -- parsing as MM-DD-YY (like 10-29-99)
    when STR_TO_DATE(release_year, '%m-%d-%y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%m-%d-%y'), '%Y-%m-%d')
    -- parsing as MM/DD/YY (like 01/16-03, replace - with / first)
    when STR_TO_DATE(REPLACE(release_year, '-', '/'), '%m/%d/%y') is not null then DATE_FORMAT(STR_TO_DATE(REPLACE(release_year, '-', '/'), '%m/%d/%y'), '%Y-%m-%d')
    -- Parsing as DDth Month of YYYY (like '23rd December of 1966')
    when release_year like '%December%' then DATE_FORMAT(STR_TO_DATE(REPLACE(REPLACE(release_year, 'rd', ''), 'of ', ''), '%d %M %Y'), '%Y-%m-%d')
    -- Parsing "The 6th of marzo...."
    when release_Year like '%marzo%' then DATE_FORMAT(STR_TO_DATE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(release_Year, 'th ', ''), 'of', ''),'The ', ''), ', year ', ''), 'marzo', 'march'),'%d %M %Y'), '%Y-%m-%d')
    -- Parsing as YYYY-MM-DD with day/month swapped (just in case)
    when STR_TO_DATE(release_year, '%d-%m-%Y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%d-%m-%Y'), '%Y-%m-%d')
    -- Parsing as DD MM YYYY
    when STR_TO_DATE(release_year, '%m %d %Y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%m %d %Y'), '%Y-%m-%d')
    -- Parsing as YY Month DD
    when release_year like '%Feb%' then DATE_FORMAT(STR_TO_DATE('22 Feb 04', '%y %b %d'), '%Y-%m-%d')
    -- Parsing as DD/MM/YYYY
    when STR_TO_DATE(release_year, '%d/%m/%Y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%d/%m/%Y'), '%Y-%m-%d')
    
    when release_year = '1984-02-34'  then '1983-12-01'
    when release_year = '1976-13-24'  then  '1976-02-08'
    
    ELSE NULL  -- Cannot parse
  END AS standardized_release_year
FROM imdb_movies;


ALTER TABLE imdb_movies ADD COLUMN standardized_release_year DATE;

update imdb_movies
set release_year =
 case
	-- parsing as YYYY-MM-DD
    when STR_TO_DATE(release_year, '%Y-%m-%d') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%Y-%m-%d'), '%Y-%m-%d')
    -- parsing as MM-DD-YY (like 10-29-99)
    when STR_TO_DATE(release_year, '%m-%d-%y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%m-%d-%y'), '%Y-%m-%d')
    -- parsing as MM/DD/YY (like 01/16-03, replace - with / first)
    when STR_TO_DATE(REPLACE(release_year, '-', '/'), '%m/%d/%y') is not null then DATE_FORMAT(STR_TO_DATE(REPLACE(release_year, '-', '/'), '%m/%d/%y'), '%Y-%m-%d')
    -- Parsing as DDth Month of YYYY (like '23rd December of 1966')
    when release_year like '%December%' then DATE_FORMAT(STR_TO_DATE(REPLACE(REPLACE(release_year, 'rd', ''), 'of ', ''), '%d %M %Y'), '%Y-%m-%d')
    -- Parsing "The 6th of marzo...."
    when release_Year like '%marzo%' then DATE_FORMAT(STR_TO_DATE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(release_Year, 'th ', ''), 'of', ''),'The ', ''), ', year ', ''), 'marzo', 'march'),'%d %M %Y'), '%Y-%m-%d')
    -- Parsing as YYYY-MM-DD with day/month swapped (just in case)
    when STR_TO_DATE(release_year, '%d-%m-%Y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%d-%m-%Y'), '%Y-%m-%d')
    -- Parsing as DD MM YYYY
    when STR_TO_DATE(release_year, '%m %d %Y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%m %d %Y'), '%Y-%m-%d')
    -- Parsing as YY Month DD
    when release_year like '%Feb%' then DATE_FORMAT(STR_TO_DATE('22 Feb 04', '%y %b %d'), '%Y-%m-%d')
    -- Parsing as DD/MM/YYYY
    when STR_TO_DATE(release_year, '%d/%m/%Y') is not null then DATE_FORMAT(STR_TO_DATE(release_year, '%d/%m/%Y'), '%Y-%m-%d')
    
    when release_year = '1984-02-34'  then '1983-12-01'
    when release_year = '1976-13-24'  then  '1976-02-08'
    
    ELSE NULL  -- Cannot parse
  END
;

SET SESSION SQL_MODE='ALLOW_INVALID_DATES';

select *
from imdb_movies;










-- Changing invalid dates

select *
from imdb_movies
where release_year like '%13-24%'
	or release_year like '%34%'
	or release_year like ''
;



delete from imdb_movies
where IMDB_title_id = '';

SELECT * FROM imdb_movies
WHERE release_year IS NULL OR release_year = '';

select *
from imdb_movies
where release_year = '09 21 1972';

select *
from imdb_movies
;

-- Standardizing the duration column

alter table imdb_movies
rename column duration to `duration (min)`
;

select `duration (min)`,
case 
	when `duration (min)` in ('Nan','Inf','Not Applicable','-',' ') then null
    when `duration (min)` = '178c' then '178'
    else `duration (min)`
end as standardized_duration
from imdb_movies
;

update imdb_movies
set `duration (min)` =
case 
	when `duration (min)` in ('Nan','Inf','Not Applicable','-',' ') then null
    when `duration (min)` = '178c' then '178'
    else `duration (min)`
end
;

-- Standardizing the country column

select distinct country
from imdb_movies;

select distinct country
from imdb_movies
where country like 'New Ze%'
	or country like 'US%'
    or country like 'Italy%'
;

update imdb_movies
set country = 
case 
    when country like 'New Ze%' then 'New Zealand'
    when country like 'US%' then 'USA'
    when country like 'Italy%' then 'Italy'
    else country
end
;

ALTER TABLE imdb_movies
MODIFY COLUMN country text AFTER `duration (min)`;


select *
from imdb_movies;

update imdb_movies as m
join messy_imdb_dataset as r 
	on m.IMDB_title_id = r.`IMBD title ID`
set m.country = r.Country
;

-- Standardizing the content_rating column

update imdb_movies 
set content_rating = null
where content_rating like '#N/A'
;

-- Standardizing the income column

update imdb_movies
set income = replace(replace(income, '$', ''), ' ', '')
;

update imdb_movies
set income = '408035783'
where income = '4o8,035,783'
;

-- Standardizing the votes column

update imdb_movies
set votes = replace(votes, '.', '')
;

-- Standardizing the score column

update imdb_movies
set score =
case
	when score = '9.' then '9.0'
    when score = '9,.0' then '9.0'
    when score = '8,9f' then '8.9'
    when score = '08.9' then '8.9'
    when score in ('8..8' , '8:8') then '8.8'
    when score in ('++8.7', '8.7.', '8,7e-0') then '8.7'
    when score = '8,6' then '8.6'
    else score
end
;

update imdb_movies as m
join messy_imdb_dataset as r 
	on m.IMDB_title_id = r.`IMBD title ID`
set m.score = r.Score
;


select *
from imdb_movies
;

alter table imdb_movies
rename column income to `income ($)`
;

alter table imdb_movies
drop column MyUnknownColumn
;

alter table imdb_movies
modify column release_year date,
modify column `duration (min)` int,
modify column `income ($)` int,
modify column `votes` int
;

alter table imdb_movies
modify column score DECIMAL(3,1)
;

select *
from messy_imdb_dataset;

alter table imdb_movies
add column score text;

update imdb_movies as m
join messy_imdb_dataset as r
	on m.IMDB_title_id = r.`IMBD title ID`
set m.score = r.Score
;





	

