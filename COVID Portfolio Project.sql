SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE Continent is not NULL
ORDER BY 1,2

-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%south africa%'
WHERE Continent is not NULL
ORDER BY 1,2

-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationPercentageInfected 
FROM PortfolioProject..CovidDeaths
WHERE location like '%south africa%'
WHERE Continent is not NULL
ORDER BY 1,2

-- Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationPercentageInfected 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE Continent is not NULL
GROUP BY location, population
ORDER BY PopulationPercentageInfected DESC


-- Showing the countries with the highest death count per population

SELECT location, MAX(cast (Total_Deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE Continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK IT DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast (Total_Deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE Continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE Continent is not NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
--WHERE location like '%south africa%'
WHERE Continent is not NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccianted)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated_
Create Table #PercentPopulationVaccinated_
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated_
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated_


-- Creating view to store data for lter visualisations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM #PercentPopulationVaccinated_