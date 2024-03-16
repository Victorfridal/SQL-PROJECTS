/*Covid 19 Data Exploration 
-- Skills used: CTE's, Joins,Temp Table, Windows functions, Aggregate Functions, Views, Converting Data types 
*/

select * 
from portfolioproject..coviddeaths
WHERE continent is not null
AND location is not null
AND date is not null
And total_cases is not null
order by 3,4


--select * 
--from portfolioproject..covidvaccinations
--order by 3,4

-- select data that we are going to be using 

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..coviddeaths
where year(date) <= 2021
order by 1,2

-- converting the data type to suit the next query 

alter table coviddeaths alter column total_cases int;
alter table coviddeaths alter column total_deaths int;

-- looking at the Total Cases vs Total Deaths in Nigeria up the year 2021
-- shows the likelihood of dying if you contract covid in Nigeria

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where  location = 'Nigeria' 
AND YEAR(date) <= 2021
order by 1,2

-- looking at the total cases vs the population
-- shows the percentage of population that got infected 
 
select location,date,population,total_cases, (total_cases/population)*100 as InfectedPercentage
from portfolioproject..coviddeaths
where  location = 'Nigeria' 
AND YEAR(date) <= 2021
AND continent is not null
order by 1,2

-- Looking at countries with Highest Infection Rate Compared to population


select location,population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as
MaxInfectedPercentage
from portfolioproject..coviddeaths
where -- location = 'Nigeria' 
YEAR(date) <= 2021
 Group by location,population
order by MaxInfectedPercentage

-- Showing the countries with Highest Death count per Population


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
where -- location = 'Nigeria' 
YEAR(date) <= 2022
AND continent is not null 
 Group by location,population
order by TotalDeathCount DESC

-- Breaking Down By Continent


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
where -- location = 'Nigeria' 
YEAR(date) <= 2022
AND continent is not null 
 Group by continent
order by TotalDeathCount DESC


--Showing the Contitnent with the Highest Death Counts


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..coviddeaths
where -- location = 'Nigeria' 
YEAR(date) <= 2022
AND continent is not null 
 Group by continent
order by TotalDeathCount DESC

-- Global Numbers 
set ANSI_WARNINGS OFF

select sum(new_cases)as TotalCases, sum(cast(new_deaths as int))as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where -- location = 'Nigeria'
continent is not null
AND YEAR(date) <= 2022
order by 1,2

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least One Vaccine
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	AND YEAR(dea.date) <=2022
	order by 2,3 


--Using CTE to Perfom Calculation on Partition By in Previous Query

with popvsvac (continent,location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
from [portfolioproject]..coviddeaths dea
join [portfolioproject]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and year(dea.date) <=2022
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac


-- Using TEMP TABLE to perform Calculation on partition by in previous query
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVccinated
from [portfolioproject]..coviddeaths dea
join [portfolioproject]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Creating View to store data for Later Visualization 

Create View PercentPopulationVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location
, dea.date) as RollingPeopleVaccinated
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	AND YEAR(dea.date) <=2022

select * from PercentPopulationVaccinated