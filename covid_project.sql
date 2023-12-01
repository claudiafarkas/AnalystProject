
----------------------------------------------SIMPLE QUERIES---------------------------------------------
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Looking at Location, Date, total Cases, new Cases, Total Deaths and Population Data to Analyze
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

-- Looking at total_cASes vs total_deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2

-- Looking at toal_cASes vs population
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PopPercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%canada%'
ORDER BY 1,2

-- Looking at Countries With *highest* Infection Rate Per Population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS PopPercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%canada%'
GROUP BY Location, population
ORDER BY PopPercentageInfected DESC

-- Showing Countires With *highest* Death Count Per Population 
SELECT Location, MAX(cASt(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Showing Continents With *highest* Deaths Per Population 
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--World-Wide Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--World-Wide Numbers: grouped by date 
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2


-----------------------------------------COVID VACCINATION AND DEATHS JOIN QUERIES-----------------------------------------
-- Join Query of Covid Deaths and Vaccinations
SELECT *
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date

-- Join Query of Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS rollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Join Query of Total Population vs Vaccination: Using CTE (Common Table Expression)
With PopVsVac (Continent, Location, Data, Population, new_vaccinations, RollingPeopleVac) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS rollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rollingPeopleVac/Population)*100
FROM PopVsVac

DROP Table if exists #PercentPopulationVac

--Join Query of Total Population vs Vaccination: Using TempTable 
Create Table #PercentPopulationVac
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
population numeric, 
new_vaccinations numeric, 
rollingPeopleVac numeric)
Insert into #PercentPopulationVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS rollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rollingPeopleVac/Population)*100
FROM #PercentPopulationVac


-----------------------------------------CREATING VIEWS FOR VISUALIZATION-----------------------------------------
--View #1
--Checks if Table already Exists or Not
SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'PercentPopulationVac';
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'PercentPopulationVac')
DROP VIEW PercentPopulationVac;

Create View PercentPopulationVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) AS rollingPeopleVac
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *
FROM PercentPopulationVac

-- View #2
--Checks if Table already Exists or Not
SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'TotalDeathCount';
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'TotalDeathCount')
DROP VIEW TotalDeathCount;

CREATE VIEW TotalDeathCount AS
SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY Location;
SELECT *
FROM TotalDeathCount

