select location, date, total_cases, new_cases, total_deaths, population from [dbo].[CovidDeath]
order by 1,2 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[owid-covid-death]
where location = 'nigeria'
order by 1,2 

select location, date,population, total_cases, (total_cases/population)*100 as PopulationPercentage
from [dbo].[owid-covid-death]
where location = 'nigeria'
order by 1,2 

countries with highest infection rate vs population
select location, population, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from [dbo].[owid-covid-death]
group by location, population
order by PercentPopulationInfected desc 

countries with highest death count per population
select location, population, MAX(total_deaths) as TotalDeathCount, max(total_deaths/population)*100 as PercentPopulationDead
from [dbo].[owid-covid-death]
where continent is not null
group by location, population
order by PercentPopulationDead desc 

select location, MAX(total_deaths) as TotalDeathCount
from [dbo].[owid-covid-death]
where continent is not null
group by location
order by TotalDeathCount desc 

select continent, MAX(total_deaths) as TotalDeathCount
from [dbo].[owid-covid-death]
where continent is not null
group by continent
order by TotalDeathCount desc 

select SUM(new_cases), SUM(new_deaths)
from [dbo].[CovidDeath]
where continent is not null
--group by date
order by 1,2 

total population vs vaccination 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(new_vaccinations as float)) over (partition by cd.location) from [dbo].[owid-covid-death] cd
join dbo.CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2, 3

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from [dbo].[owid-covid-death] cd 
join dbo.CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2, 3

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from [dbo].[owid-covid-death] cd 
join dbo.CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
--where cd.continent is not null
--order by 2, 3)
)
select * , (RollingPeopleVaccinated/population)*100
from PopVsVac