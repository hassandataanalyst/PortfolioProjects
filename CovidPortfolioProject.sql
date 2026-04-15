SELECT * FROM [Portfolio Project] .. covidDeaths$
WHERE continent is not	null
order by 3, 4

--select data that we are going to be using    --- 1

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project] .. covidDeaths$
WHERE continent is not	null
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths     ----  2
SELECT location, date, total_cases, total_deaths, 
(total_deaths / NULLIF(total_cases ,0) *100 ) AS DeathPercentage
FROM [Portfolio Project]..covidDeaths$
WHERE location = 'Pakistan' and continent is not null
ORDER BY 1, 2

--Loooking at total cases vs population    ---- 3
SELECT  location, date, total_cases, population,
(ROUND(total_cases / population * 100, 3)) AS CasesPercentages
FROM [Portfolio Project]..covidDeaths$
WHERE continent is not	null and location = 'Pakistan'

--Looking at countries with highest infection rate compared to population    --- 4
SELECT location, population, MAX(total_cases) AS HighestCases, 
ROUND(MAX((total_cases / population)) * 100, 3) AS HighestInfectionRate 
FROM [Portfolio Project]..covidDeaths$
where location = 'France' and continent is not	null
GROUP BY location, population
ORDER BY HighestInfectionRate desc

-- Showing Highest death count per continent   --- 5
SELECT continent, MAX(total_deaths) AS HighestDeaths
FROM [Portfolio Project]..covidDeaths$
WHERE continent is not	null
GROUP BY continent
ORDER BY HighestDeaths desc


--Global Numbers    --- 6
SELECT  SUM(new_cases) AS TotalCases, SUM(new_deaths) AS NewDeaths,
ROUND((SUM(new_deaths) / NULLIF(SUM(new_cases), 0) * 100), 3) AS DeathPercentage
FROM [Portfolio Project]..covidDeaths$
WHERE continent is not NULL 
--GROUP BY date
ORDER BY 1, 2



--Looking for our country deaths and cases (practice)
SELECT YEAR(date) AS Year, SUM(total_cases) AS CasesInYear, SUM(total_deaths) AS DeathInYear, MAX(population),
SUM(SUM(total_cases)) OVER () AS GrandTotalCases,
SUM(SUM(total_deaths)) OVER () AS GrandTotalDeaths,
ROUND((SUM(total_deaths) / SUM(total_cases)) * 100, 3) AS DeathPercentageInYear,
ROUND((SUM(total_cases) / MAX(population)) * 100, 3) AS CasesPercentageInYear
FROM [Portfolio Project]..covidDeaths$
WHERE location = 'Pakistan'
GROUP BY YEAR(date)
ORDER BY Year




SELECT *
FROM [Portfolio Project]..covidDeaths$ dea
JOIN [Portfolio Project]..covidVaccine$ vacc
ON dea.location = vacc.location AND dea.date = vacc.date

--Looking population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition BY dea.location ) AS RollingPeopleVaccinated
FROM [Portfolio Project]..covidDeaths$ dea
JOIN [Portfolio Project]..covidVaccine$ vacc
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent is not NULL
ORDER BY 1, 2, 3

--Use CTE
WITH popvsvacc(Continent, Location, Date, Population, New_vaccination, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) 
FROM [Portfolio Project]..covidDeaths$ dea
JOIN [Portfolio Project]..covidVaccine$ vacc
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent is not NULL
)

SELECT *, ROUND((Rolling_people_Vaccinated / CAST(Population AS FLOAT)) * 100, 3) AS People_Vaccinated_Percentage
FROM popvsvacc
ORDER BY 1, 2, 3

--Temp Table
CREATE TABLE #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_Vaccinations numeric,
Rolling_People_Vaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) 
FROM [Portfolio Project]..covidDeaths$ dea
JOIN [Portfolio Project]..covidVaccine$ vacc
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent is not NULL
SELECT *, ROUND((Rolling_people_Vaccinated / CAST(Population AS FLOAT)) * 100, 3) AS People_Vaccinated_Percentage
FROM #PercentPopulationVaccinated
ORDER BY 1, 2, 3



--Creating View for later data visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS BIGINT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..covidDeaths$ dea
JOIN [Portfolio Project]..covidVaccine$ vacc
ON dea.location = vacc.location AND dea.date = vacc.date
WHERE dea.continent is not NULL


USE [Portfolio Project]; -- Forcefully tell SQL to use your project DB
SELECT * FROM PercentPopulationVaccinated;