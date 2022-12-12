SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4


-- Select and explore some data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date


-- Total cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY location, date


-- Total cases vs Population 
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY location, date


-- Countries with highest infection rate comparef to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDethCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDethCount DESC



-- Continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDethCount
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDethCount DESC





-- GLOBAL NUMBERS
SELECT  
	SUM(new_cases) AS TotalCases, 
	SUM(cast(new_deaths as int)) AS TotalDeaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage  --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
--ORDER BY date



-- Total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


WITH PopvsVac (Continent, Locatio, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
-- Total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




-- TEMP TABLE --

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
-- Total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- VIEW to store data for later vizualization
CREATE VIEW PercentPopulationVaccinated as
-- Total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



SELECT *
FROM PercentPopulationVaccinated