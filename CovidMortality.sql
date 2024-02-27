SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in each country, over time
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%' 
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT Location, Date, Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Andorra had the highest at 17.1% but smaller population at 77k
--United States had the 9th highest at 9.77% from population of 331 million

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- TAKING A LOOK BY CONTINENT

-- Total Death Count per Continent (based on sum of countries' max death counts)
WITH TotalCountryDeathCount AS (
	SELECT continent, location, MAX(CAST(total_deaths as int)) AS TotalDeathCount 
	FROM PortfolioProject..CovidDeaths 
	WHERE continent IS NOT NULL
	GROUP BY continent, location)
SELECT continent, SUM(TotalDeathCount) AS ContinentDeathCount
FROM TotalCountryDeathCount
GROUP BY continent
ORDER BY ContinentDeathCount DESC


-- Total Death Count per Continent including Regions such as the European Union and the World
-- Not used for visualization because those regions do not contain country information to drill down into
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continents with Highest Death Count per Country
SELECT Continent, MAX(CAST(total_deaths as int)) AS HighestCountryDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestCountryDeathCount DESC



-- GLOBAL NUMBERS

-- Showing Global Cases, Deaths, and Death Percentage Over Time
SELECT Date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		(SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2
-- Data runs from 2020-01-01 to 2021-04-30

-- Showing Total Global Cases, Deaths, and Death Percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		(SUM(CAST(new_deaths as int))/SUM(new_cases)) * 100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2
-- By 2021-04-30 (the last date in this dataset), 1.66% of global reported COVID cases had resulted in death.




-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (
			PARTITION BY dea.location
			ORDER BY dea.location, dea.date
			) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location
ORDER BY 2,3



-- USE CTE to show rolling percent vaccinated of population
-- Cannot use aggregate number RollingPeopleVaccinated in SELECT; must create separate function 
-- to calculate the VaccinatedPercent.

WITH PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (
			PARTITION BY dea.location
			ORDER BY dea.location, dea.date
			) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercent
FROM PopvsVac



-- TEMP TABLE to show rolling percent vaccinated of population

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (
			PARTITION BY dea.location
			ORDER BY dea.location, dea.date
			) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercent
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (
			PARTITION BY dea.location
			ORDER BY dea.location, dea.date
			) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
