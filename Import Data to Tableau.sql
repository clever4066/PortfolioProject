/*
Queries used for Tableau Project
*/

-- 1. Global Number of DeathPercentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeath
where continent is not null 
order by 1,2


-- 2. Death Percentage of Each Country

Select Location, MAX(cast(total_deaths as dec)) as TotalDeathCount, max(cast(total_cases as dec)) as TotalCasesCount,
	(MAX(cast(total_deaths as dec))/max(cast(total_cases as dec)))*100 as DeathPercentage
From PortfolioProject..CovidDeath
Group by Location
order by DeathPercentage desc


-- 3. Infection Rate of Each Country

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc



-- 4. Period of Infected Rate of Each Country

Select Location, Date, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath
Group by Location, Population, date
order by PercentPopulationInfected desc