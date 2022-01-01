Select *
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccination
--order by 3,4

-- Select the Data that will be used

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%' and continent is not null and location not like '%income%'
order by 1,2

-- Looking at Totla Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population) * 100 as PopluationPercentInfected
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 
	as PopluationPercentInfected
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
--Where location like '%states%'
Group by Location, population
order by PopluationPercentInfected desc

-- Looking at Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc



-- Things done by continent from this point


-- Highest Death Count by Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null
--Where location like '%states%'
Group by continent
order by TotalDeathCount desc

-- Global Numbers per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentageGlobal
From [Portfolio Project]..CovidDeaths
--Where location like '%states%' and 
where continent is not null and location not like '%income%'
Group by date
order by 1,2

-- Global Numbers total
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentageGlobal
From [Portfolio Project]..CovidDeaths
--Where location like '%states%' and 
where continent is not null and location not like '%income%'
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by 
	dea.location,dea.date) as RollingPoepleVaccinated
--, (RollingPEopleVaccinated/population)* 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'
order by 2,3

--USE CTE
With PopsvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by 
	dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPEopleVaccinated/population)* 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsvsVac

--Doing it by temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by 
	dea.location,dea.date) as RollingPoepleVaccinated
--, (RollingPEopleVaccinated/population)* 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null and dea.location not like '%income%'
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Use [Portfolio Project] 
go

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by 
	dea.location,dea.date) as RollingPoepleVaccinated
--, (RollingPEopleVaccinated/population)* 100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location not like '%income%'
--order by 2,3

Select *
From PercentPopulationVaccinated



Create View PercentPopulationInfected as
Select Location, date, total_cases, population, (total_cases/population) * 100 as PopluationPercentInfected
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
--Where location like '%states%'
--order by 1,2

Create View TotalDeathCount as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
where continent is not null and location not like '%income%'
--Where location like '%states%'
Group by Location

Create View DeathPercentageGlobal as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentageGlobal
From [Portfolio Project]..CovidDeaths
--Where location like '%states%' and 
where continent is not null and location not like '%income%'
Group by date
