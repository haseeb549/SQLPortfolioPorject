--select * 
--from [Portfolio Project]..CovidDeaths$
--order by 3,4


--select * 
--from [Portfolio Project]..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths
from [Portfolio Project]..CovidDeaths$
order by 1,2

-- Looking at Total Cases Vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from [Portfolio Project]..CovidDeaths$
where location like 'Pakistan'
order by 1,2

-- Looking at the Total cases Vs Population
-- Percentage of population that got covid

select location, date, total_cases, population, ROUND((total_cases/population)*100,2) as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where location like 'Pakistan'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location,max(total_cases) as HighestCasesRecorded, population, ROUND(Max((total_cases/population)*100),2) as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
--where location like 'Pakistan' 
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with highest death count per population

select location, max(total_deaths) as HighestDeathRecorded, population, ROUND(max((total_deaths/population)*100),2) as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
where continent is not null
--where location like 'Pakistan' 
Group by location, total_deaths, population
order by PercentPopulationInfected desc

-- Total Death Count by Countries

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount DESC

-- Total Death by Continents

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount DESC

-- Highest death count per population Continent wise

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount DESC


-- Global numbers

select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from [Portfolio Project]..CovidDeaths$
where continent is not null
--group by date
order by 1,2


-- Joining the two tables

select * from [Portfolio Project]..CovidDeaths$ dth
Join
[Portfolio Project]..CovidVaccinations$ vac 
On
dth.location = vac.location
and
dth.date = vac.date


-- Looking at total population vs total vacination

select dth.continent,dth.location, dth.date,dth.population,vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over ( Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dth
Join
[Portfolio Project]..CovidVaccinations$ vac 
On
dth.location = vac.location and dth.date = vac.date
where dth.continent is not null
order by 2,3


--Using CTE
With PopvsVac (Continent , Location, Date, Population, New_Vaccinations, RollingPeoplVaccinated)
as
(
select dth.continent,dth.location, dth.date,dth.population,vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over ( Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dth
Join
[Portfolio Project]..CovidVaccinations$ vac 
On
dth.location = vac.location and dth.date = vac.date
where dth.continent is not null
)

select * , (RollingPeoplVaccinated/Population)*100
from PopvsVac

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
select dth.continent,dth.location, dth.date,dth.population,vac.new_vaccinations, 
Sum(Convert(int,vac.new_vaccinations)) Over ( Partition by dth.location order by dth.location, dth.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dth
Join
[Portfolio Project]..CovidVaccinations$ vac 
On
dth.location = vac.location and dth.date = vac.date
where dth.continent is not null
--order by 2,3


  