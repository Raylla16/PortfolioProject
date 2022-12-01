SELECT * FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4


--SELECT DATA TO BE USED
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--COMPARING TOTAL CASES VS TOTAL DEATHS 
--SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN THE CANADA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percent
FROM PortfolioProject..CovidDeaths$
WHERE location = 'CANADA' AND continent IS NOT NULL
ORDER BY date

--COMPARING TOTAL CASES VS POPULATION
--SHOWS PERCENTAGE OF THE POPULATION IN CANADA HAS COVID
SELECT location, date,population, total_cases, (total_cases/population) * 100 AS pop_death_percent
FROM PortfolioProject..CovidDeaths$
WHERE location = 'CANADA' AND continent IS NOT NULL
ORDER BY date


--COUNTRIES WITH HIGHEST INFECTION RATE IN RELATION TO THEIR POPULATION
SELECT location, population, MAX(total_cases) AS MaxInfectionCount, MAX((total_cases/population)) * 100 AS PercenttPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercenttPopulationInfected DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT 
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC

--SHOWING CONTINENT WITH HIGHEST DEATH COUNT 
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--GLOBAL DEATH CASES PER DAY
SELECT date, SUM(new_cases), SUM(CAST(new_deaths AS INT)), 100 * SUM(CAST(new_deaths AS INT))/SUM(new_cases) as GlobalDeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--TOTAL POPULATION VS PEOPLE VACCINATED USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3
)
 SELECT * , (RollingPeopleVaccinated/population) * 100 as PercentPopulationVaccinated
 FROM PopvsVac


 --TEMP TABLE
 DROP Table if exists #PercentPopulationVaccinated
 CREATE Table #PercentPopulationVaccinated
 (
 Continent nVARCHAR(255),
 Location nVARCHAR(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT *, (RollingPeopleVaccinated/population) * 100 as PercentPopulationVaccinated  FROM #PercentPopulationVaccinated




--CREATE A VIEW TO STORE DATA FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT * FROM PercentPopulationVaccinated