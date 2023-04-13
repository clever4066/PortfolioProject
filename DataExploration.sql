Select *
From PortfolioProject..CovidDeath
order by 3,4


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contact covid in Malaysia
Select Location, date, total_cases,total_deaths, (cast(total_deaths as dec)/cast(total_cases as dec))*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where location like '%Malaysia%'
order by 1,2

-- Looking at Country with Highest Infection compared to Population

Select Location, Population, MAX(cast(total_cases as dec)) as HighestInfectionCount, Max((cast(total_cases as dec)/population))*100
   as PercentPopulationInfected
From PortfolioProject..CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing continents with Highest Death Count per Population

Select continent, MAX(cast(total_deaths as dec)) as TotalDeathCount
From PortfolioProject..CovidDeath
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as dec)) as total_deaths, 
   sum(cast(new_deaths as dec))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeath
Where continent is not null

-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   sum(CONVERT(dec,vac.new_vaccinations)) OVER 
   (Partition by dea.location Order by dea.location, dea.Date) as AggregatePeopleVaccinated
From PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
   On dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2,3

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