/*
Americas Economic Metric Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
-- Get info of our table
Describe pwt100;

-- Check table out
Select * from pwt100 
order by country, year;


-- Now we look at rgdpe vs Year and add a new col to calculate economic growth per year by country

Select country, 
          year, 
          rgdpe, 
         coalesce(lag(rgdpe) over(Partition by country Order by year)) as previous_amount,
         coalesce(100.0*(((cast(rgdpe as Decimal(10,2)))-(lag(rgdpe) over(Partition by country Order by year)))/(lag(rgdpe) over(Partition by country Order by year))), 0) as Economic_Growth
From pwt100
order by country, year;

-- What was the year with with highest rgdp for each country?
Select *
From pwt100
Inner Join(
	Select country, max(rgdpe) max_gdp
    From pwt100
    Group by country
) Max_rgdp 
On Max_rgdp.country = pwt100.country
And Max_rgdp.max_gdp = pwt100.rgdpe
order by pwt100.rgdpe DESC; 

-- Looking at rGDP per capita per Country
Select country, 
          year, 
          rgdpe, 
         pop,
         round((rgdpe/pop),2) as per_capita_rgdp
From pwt100
order by country, year;


-- Looking at countries with highest per capita rGDP at 2019

Select country,
(round((rgdpe/pop),2)) as curr_per_capita
from pwt100
Where 	
	(year = 2019)
order by curr_per_capita DESC;

-- Calculation Population Growth rate per country and Comparing it to rGDP Growth Rate 
Select country, 
          year, 
          rgdpe, 
          pop,
          coalesce(lag(pop) over(Partition by country Order by year)) as previous_pop,
         coalesce(100.0*(((cast(pop as Decimal(10,2)))-(lag(pop) over(Partition by country Order by year)))/(lag(pop) over(Partition by country Order by year))), 0) as Population_Growth_Rate,
         coalesce(lag(rgdpe) over(Partition by country Order by year)) as previous_amount,
         coalesce(100.0*(((cast(rgdpe as Decimal(10,2)))-(lag(rgdpe) over(Partition by country Order by year)))/(lag(rgdpe) over(Partition by country Order by year))), 0) as Economic_Growth,
         coalesce(100.0*(((cast(pop as Decimal(10,2)))-(lag(pop) over(Partition by country Order by year)))/(lag(pop) over(Partition by country Order by year))), 0) - 
         coalesce(100.0*(((cast(rgdpe as Decimal(10,2)))-(lag(rgdpe) over(Partition by country Order by year)))/(lag(rgdpe) over(Partition by country Order by year))), 0) as difference_bw_pop_and_rgdp_growth
From pwt100
order by country, year;

-- What was the total population of the Americas per year?
Select year, ROUND(SUM(pop),3) AS mil_pop
From pwt100
group by year
order by year;


-- Show Correlation between Population and rGDP  
set sql_mode='';
Select country, 
          ((Avg(rgdpe * pop) - (Avg(rgdpe) * Avg(pop))) / (STD(rgdpe) * STD(pop))) as correlation
From pwt100
Group by country
order by correlation;

-- Looking at countries and their currency crisis by year in America
Select country, 
		year,
		coalesce(lag(xr) over(Partition by country Order by year)) as previous_xr, 
        (Case
			When coalesce(lag(xr) over(Partition by country Order by year)) = 0  
			Then "Na"
            When coalesce(lag(xr) over(Partition by country Order by year)) is NULL 
			Then cast(0 as Decimal(10,2))
			else round(coalesce((((cast(xr as Decimal(10,2)))-(lag(xr) over(Partition by country Order by year)))/(lag(xr) over(Partition by country Order by year))), 0),4)* 100.0
		end) as change_in_xr
From pwt100
order by country, year;

-- Looking at the market instability in countries in the America.
Select country, 
		year,
        pl_i,
		coalesce(lag(pl_i) over(Partition by country Order by year)) as previous_pl_i, 
        (Case
			When coalesce(lag(pl_i) over(Partition by country Order by year)) = 0  
			Then "Na"
            When coalesce(lag(pl_i) over(Partition by country Order by year)) is NULL 
			Then cast(0 as Decimal(10,2))
			else round(coalesce((((pl_i)-(lag(pl_i) over(Partition by country Order by year)))* 1/(lag(pl_i) over(Partition by country Order by year))), 0),4) *100
		end) as change_in_pl_i
From pwt100
order by country, year;

-- What are the most educated countries in the Americas? 
Select country,hc as human_capital_index
from pwt100
Where 	
	(year = 2019)
order by human_capital_index DESC;

-- Show Correlation between education and rGDP  
set sql_mode='';
Select country, 
          ((Avg(rgdpe * hc) - (Avg(rgdpe) * Avg(hc))) / (STD(rgdpe) * STD(hc))) as correlation
From pwt100
Group by country
order by correlation;

-- Lets see the average working hours per day by country on 2019 
set sql_mode='';
Select country, round(avh/260,2) as average_working_hours
From pwt100
Where 	
	(year = 2019)
Group by country
order by average_working_hours DESC;

-- AVG historic working hours per day by country 
Select country, (avg(avh)/260) as avg_working_hours
From pwt100
Group by country
order by avg_working_hours DESC; 

-- Highest working hour per day by country 
Select country, max(avh)/260 as max_working_hours
From pwt100
Group by country
order by max_working_hours DESC; 

-- Creating a Table to perform more interesting calculations

DROP Table if exists tableu_visualization;
Create Table tableu_visualization
(
Country nvarchar(255),
Currency nvarchar(255),
Year int,
rGDP double,
Economic_Growth_YOY double,
Population double,
Population_Growth_rate double,
rGDP_per_capita double,
exchange_rate double,
change_xr_YOY double,
pl_of_capital double,
change_pli_YOY double,
human_capital_index double,
working_hours double
);

Insert into tableu_visualization
Select pwt100.country, pwt100.currency_unit, pwt100.year, pwt100.rgdpe, 
coalesce(100.0*(((cast(rgdpe as Decimal(10,2)))-(lag(rgdpe) over(Partition by country Order by year)))/(lag(rgdpe) over(Partition by country Order by year))), 0) as Economic_Growth_YOY,
pwt100.pop, coalesce(100.0*(((cast(pop as Decimal(10,2)))-(lag(pop) over(Partition by country Order by year)))/(lag(pop) over(Partition by country Order by year))), 0) as Population_Growth_rate,
round((rgdpe/pop),2) as rGDP_per_capita, xr, (Case
			When coalesce(lag(xr) over(Partition by country Order by year)) = 0  
			Then "Na"
            When coalesce(lag(xr) over(Partition by country Order by year)) is NULL 
			Then cast(0 as Decimal(10,2))
			else round(coalesce((((cast(xr as Decimal(10,2)))-(lag(xr) over(Partition by country Order by year)))/(lag(xr) over(Partition by country Order by year))), 0),4)* 100.0
		end) as change_xr_YOY, 
pl_i, (Case
			When coalesce(lag(pl_i) over(Partition by country Order by year)) = 0  
			Then "Na"
            When coalesce(lag(pl_i) over(Partition by country Order by year)) is NULL 
			Then cast(0 as Decimal(10,2))
			else round(coalesce((((pl_i)-(lag(pl_i) over(Partition by country Order by year)))* 1/(lag(pl_i) over(Partition by country Order by year))), 0),4) *100
		end) as change_pli_YOY,
hc, round(avh/260,2)
From pwt100;

-- View New Table
Select * from tableu_visualization 
order by country, year;

-- Ranking the most unstable markets in the Americas 
Select Country, 
		avg(change_pli_YOY) as average_change_pli
From tableu_visualization
Group by Country
Order by average_change_pli DESC;

-- Ranking the most unstable market (proxy to capital formation) year by country in the Americas  
Select *
From tableu_visualization
Inner Join(
	Select Country, max(change_pli_YOY) change_pli_YOY
    From tableu_visualization
    Group by country
) max_change_pli_YOY
On max_change_pli_YOY.Country = tableu_visualization.Country
And max_change_pli_YOY.change_pli_YOY = tableu_visualization.change_pli_YOY
order by tableu_visualization.change_pli_YOY DESC; 

-- Ranking Biggest Recessions in the Americas
Select *
From tableu_visualization
Inner Join(
	Select Country, min(Economic_Growth_YOY) Economic_Growth_YOY
    From tableu_visualization
    Group by country
) Economic_Growth_YOY
On Economic_Growth_YOY.Country = tableu_visualization.Country
And Economic_Growth_YOY.Economic_Growth_YOY = tableu_visualization.Economic_Growth_YOY
order by tableu_visualization.Economic_Growth_YOY DESC; 


-- Ranking Economic Growth Rates in the Americas
Select Country, 
		avg(Economic_Growth_YOY) as Economic_Growth_YOY
From tableu_visualization
Group by Country
Order by Economic_Growth_YOY DESC;


-- Ranking the most unstable currencies in the Americas 
Select Country, Currency, avg(change_xr_YOY) as average_change_xr
From tableu_visualization
Group by Country
Order by average_change_xr DESC;

-- Ranking Biggest Exchange Rate Crisis in the Americas
Select *
From tableu_visualization
Inner Join(
	Select Country, min(change_xr_YOY) change_xr_YOY
    From tableu_visualization
    Group by Country
) change_xr_YOY
On change_xr_YOY.Country = tableu_visualization.Country
And change_xr_YOY.change_xr_YOY = tableu_visualization.change_xr_YOY
Group by tableu_visualization.Country
order by tableu_visualization.change_xr_YOY DESC; 


-- Creating View to store data for later visualizations
Create View tableu_visualization as
Select tableu_visualization.Country, tableu_visualization.Currency, tableu_visualization.Year, tableu_visualization.rGDP, tableu_visualization.Economic_Growth_YOY, tableu_visualization.Population,
tableu_visualization.Population_Growth_rate ,tableu_visualization.rGDP_per_capita, tableu_visualization.exchange_rate, tableu_visualization.change_xr_YOY , tableu_visualization.pl_of_capital, tableu_visualization.change_pli_YOY, 
tableu_visualization.human_capital_index, tableu_visualization.working_hours 


