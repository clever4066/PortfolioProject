/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeath
Where continent is not null 
order by 1,2

-- Show likelihood of dying if you contact covid in Malaysia

Select Location, date, total_cases,total_deaths, (cast(total_deaths as dec)/cast(total_cases as dec))*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%Malaysia%'
and continent is not null 
order by date desc

-- Looking at Infection Rate of each country

Select Location, Population, MAX(cast(total_cases as dec)) as HighestInfectionCount, Max((cast(total_cases as dec)/population))*100
   as PercentPopulationInfected
From PortfolioProject..CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Death Percentage of each country

Select Location, MAX(cast(total_deaths as dec)) as TotalDeathCount, max(cast(total_cases as dec)) as TotalCasesCount,
	(MAX(cast(total_deaths as dec))/max(cast(total_cases as dec)))*100 as DeathPercentage
From PortfolioProject..CovidDeath
Group by Location
order by DeathPercentage desc


-- Global Number of DeathPercentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeath
where continent is not null 
order by 1,2


-- Shows Percentage of Population that has receieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(CONVERT(dec,vac.new_vaccinations)) OVER 
   (Partition by dea.location Order by dea.location, dea.Date) as AggregatePeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, AggregatePeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(CONVERT(dec,vac.new_vaccinations)) OVER 
   (Partition by dea.location Order by dea.location, dea.Date) as AggregatePeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (AggregatePeopleVaccinated/Population)*100 as VaccinatedPercentage
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AggregatePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(dec,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as AggregatePeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (AggregatePeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(CONVERT(dec,vac.new_vaccinations)) OVER 
   (Partition by dea.location Order by dea.location, dea.Date) as AggregatePeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null

-- Showing Vaccinations Percentage of each country
Select Location, MAX(cast(AggregatePeopleVaccinated as dec)) as Total_Vaccin, max(cast(population as dec)) as Country_Population,
	(MAX(cast(AggregatePeopleVaccinated as dec))/max(cast(population as dec)))*100 as VaccinatedPercentage
From PortfolioProject..PercentPopulationVaccinated
Group by Location
order by VaccinatedPercentage desc

