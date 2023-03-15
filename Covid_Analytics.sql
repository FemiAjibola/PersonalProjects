use TestDb


/**
-- Select Data to be used.
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2;
**/


-- the total cases vs total deaths
-- death tendency if one gets covid in the States
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

-- total cases vs population
-- shows the % of Population with Covid
select location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopualtopm
from CovidDeaths
where location like '%states%'
order by 1,2


-- countries with highest infection rate compared with the population
-- like how many people were infected
select location, max(total_cases) as HighestNoOfCases, population, (max(total_cases)/population)*100 AS InfectionPercentage
from CovidDeaths
where continent IS NOT NULL
group by location, population
order by InfectionPercentage Desc

-- countries with highest death count/population BY CONTINENT
-- breaking things down by CONTINENT: Showing the continents with the highest death counts
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent IS NOT NULL
group by continent
order by TotalDeathCount Desc

-- GLOBAL NUMBERS
-- new cases all over the world
select date, SUM(new_cases) as newCases, SUM(CAST(new_deaths as int)) as newDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)* 100 as totalDeaths
from CovidDeaths
where continent IS NOT NULL 
group by date
HAVING SUM(new_cases) IS NOT NULL AND SUM(CAST(new_deaths as int)) IS NOT NULL
order by 1,2

-- OVERALL Global Death Numbers
select SUM(new_cases) as newCases, SUM(CAST(new_deaths as int)) as newDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as totalDeaths
from CovidDeaths
where continent IS NOT NULL 
HAVING SUM(new_cases) IS NOT NULL AND SUM(CAST(new_deaths as int)) IS NOT NULL
order by 1,2

-- Looking at TOTAL Population Vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population) * 100
from CovidDeaths dea
join CovidVacination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent IS NOT NULL
order by 2,3

-- USING CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population) * 100
from CovidDeaths dea
join CovidVacination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent IS NOT NULL
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


--USING TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
	-- (RollingPeopleVaccinated/population) * 100
from CovidDeaths dea
join CovidVacination vac
on dea.location = vac.location and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
where Continent IS NOT NULL
order by 1,2







select dea.location, dea.population, dea.new_cases, vac.continent
from TestDb..CovidDeaths dea
join TestDb..CovidVacination vac
on dea.location = vac.location;

select *
from TestDb..CovidDeaths
order by 3,4


-- countries with highest death count/population 
-- like how many people died
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent IS NOT NULL
group by location, population
order by TotalDeathCount Desc


-- countries with highest death count/population 
-- like how many people died
select location, max(total_deaths) as HighestNoOfDeaths, population, (max(total_deaths)/population)*100 AS DeathPercentage
from CovidDeaths
where continent IS NOT NULL
group by location, population
order by DeathPercentage Desc


-- Working with ViEWS to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVacination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;

-- querying the View
select *
from PercentPopulationVaccinated
order by continent, location;

/**
select *
from CovidDeaths
where continent IS NOT NULL
order by 3,4

select *
from CovidVacination
order by 3,4
**/