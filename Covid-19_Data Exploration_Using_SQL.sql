select * from CovidDeaths;

select * from CovidVaccinations;


select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths
order by location,date;

-- Total Cases and Total Deaths

select location,date,total_cases, total_deaths,population, (total_deaths/total_cases)* 100 as deathpercentage
from CovidDeaths
where location like '%Pakistan%'
order by location,date;

-- People % in Pakistan affected by Covid_19

select location,date,total_cases, total_deaths,population, Round((total_cases/population)* 100 ,3) as deathpercentage
from CovidDeaths
where location like '%Pakistan%'
order by location,date;


-- Top Countries Affected by Covid_19 w.r.t Population

select location,date,total_cases, total_deaths,population, ROW_NUMBER() Over( Partition by location
order by total_cases/population) as RowNumber, Round((total_cases/population )* 100 ,3)as casespercentage
from CovidDeaths
order by casespercentage DESC;
-- Countries with max death rate wrt to population
select location,population, Max(total_cases) as HighestEffectiveCount , MAX((total_cases/population)* 100) as deathpercentage
from CovidDeaths
group by location,population
order by deathpercentage DESC;
  
-- Cases wrt People affected over population

select location,population, Max(total_cases) as HighestEffectiveCount , MAX((total_cases/population)* 100) as CasesPerPopulationAffected
from CovidDeaths
group by location,population
order by 1,2;

-- Total Death count per Country Highest to Lowest

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Total Death by Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Continent with highest death rate w.r.t population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent 
order by TotalDeathCount desc;


-- Global Records -> New Cases per day in the whole world

select date , sum(new_cases) as total_cases , sum(cast (new_deaths as int)) as toal_deaths, 
Round(sum(cast (new_deaths as int))/sum(new_cases)*100,2) as death_percentage
from CovidDeaths
where continent is not null
group by date
order by date,total_cases;


-- Usage of Join on date and location from 2 table

select * from
CovidDeaths dea	Join
CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date

-- Total Population Vs Vacinantions
 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) over 
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from
CovidDeaths dea	Join
CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3;


-- CTE 

With PopVsVac 
AS
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) over 
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from
CovidDeaths dea	Join
CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select (peoplevaccinated/population)*100 as VaccinatedPercentage 
from PopVsVac;

-- Temp table to store data temporary

create table #percentpopulationvaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #percentpopulationvaccination
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) over 
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from
CovidDeaths dea	Join
CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * from
#percentpopulationvaccination

-- Copying data from one table into another

select continent,location,date INTO new_table 
from CovidDeaths
where 1=1;
Select * from new_table;


-- Creating View to store data for later use

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) over 
(Partition by dea.location order by dea.location, dea.date) as peoplevaccinated
from
CovidDeaths dea	Join
CovidVaccinations vac
ON dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated