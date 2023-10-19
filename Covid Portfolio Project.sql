/* 
Covid 19 Data Exploration 

Skill used: Joins, CTE's, Temp Tables, Windows Functions, Agregate Functions, Creating Views, Converting Data Types 

*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contact covid in your country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population infected with Covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Countries with highest death count per population

select location, max(cast(cast(total_deaths as float)as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing contintents with the highest death count per population

select continent, max(cast(cast(total_deaths as float)as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(cast(cast(total_deaths as float)as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS

--Per Date
select  date, sum(new_cases) as TotalCases, sum(cast(cast(new_deaths as float)as int)) as TotalDeaths, 
sum(cast(cast(new_deaths as float)as int))/sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--Overall
select  sum(new_cases) as TotalCases, sum(cast(cast(new_deaths as float)as int)) as TotalDeaths, 
sum(cast(cast(new_deaths as float)as int))/sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(cast(vac.new_vaccinations as float) as int))
over (partition by dea.location order by dea.location, dea.date) as TotalAccumulatedVaccinations
--(TotalAccumulatedVaccinations/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE to perform Calculation on partition By in previous query

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, TotalAccumulatedVaccinations)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(cast(vac.new_vaccinations as float) as int))
over (partition by dea.location order by dea.location, dea.date) as TotalAccumulatedVaccinations
--(TotalAccumulatedVaccinations/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (TotalAccumulatedVaccinations/Population)*100 as TingkatVaksinasiCovid
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
	(
	Continent nvarchar(255), 
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	TotalAccumulatedVaccinations numeric
	)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(cast(vac.new_vaccinations as float) as int))
over (partition by dea.location order by dea.location, dea.date) as TotalAccumulatedVaccinations
--(TotalAccumulatedVaccinations/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (TotalAccumulatedVaccinations/Population)*100 as TingkatVaksinasiCovid
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(cast(vac.new_vaccinations as float) as int))
over (partition by dea.location order by dea.location, dea.date) as TotalAccumulatedVaccinations
--(TotalAccumulatedVaccinations/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated