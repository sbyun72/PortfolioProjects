/*
  Queries used to make Tableau dashboard: COVID-19 Dashboard (Jan 2020-Apr 2021)
  https://public.tableau.com/views/COVID-19DashboardJan2020-Apr2021/Dashboard1
*/

-- 1. Total Death Percentage Globally

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- 2. Total Death Count by Country

-- Three locations are removed as they are not included in the above queries, for consistency
-- ie. European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3. Percent Population Infected By Country

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- 4. Countries with Highest Percent of Population Infected Over Time

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  
	MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population, date
ORDER BY PercentPopulationInfected DESC
