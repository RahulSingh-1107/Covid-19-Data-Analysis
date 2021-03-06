Select *
From public."CovidDeaths"
Where continent is not null 
order by 3,4;

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
From public."CovidDeaths"
Order by 1,2;

-- Total Cases vs Total Deaths (shows likelihood of dying if you contract covid in your country)

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPrecentage
From public."CovidDeaths"
WHERE location like '%India'
Order by 1,2;

-- Total Cases vs Population (shows what percentage of population in your country got infected by covid)

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PrecentagePopulationInfected
From public."CovidDeaths"
WHERE location like '%India'
Order by 1,2;

-- Countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From public."CovidDeaths"
Group by location, population
HAVING MAX(total_cases) > 0 AND Max((total_cases/population))*100 > 0
Order By PercentPopulationInfected desc;

-- Countries with highest death percentage per population

Select Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDead
From public."CovidDeaths"
WHERE continent is not null
Group by location, population
HAVING MAX(total_deaths) > 0 AND Max((total_deaths/population))*100 > 0
Order By PercentPopulationDead desc;

-- Continents with highest death percentage per population

Select continent, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDead
From public."CovidDeaths"
WHERE continent is not null
Group by continent
HAVING MAX(total_deaths) > 0 AND Max((total_deaths/population))*100 > 0
Order By PercentPopulationDead desc;

-- Global Numbers 

Select SUM(new_deaths) as total_deaths, SUM(new_cases) as total_cases, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercent
From public."CovidDeaths"
WHERE continent is not null
-- Group By date
Order By 1,2;

--Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS integer)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM public."CovidDeaths" dea
JOIN public."CovidVaccination" vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null 
Order By 2,3; 

--USE CTE
WITH PopvsVac(continent,location,date,population, new_vaccinations) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS integer)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM public."CovidDeaths" dea
JOIN public."CovidVaccination" vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null 
--Order By 2,3 
	)
SELECT * 
FROM PopvsVac;


--Creating View to store data for later visualizations


CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS integer)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM public."CovidDeaths" dea
JOIN public."CovidVaccination" vac
 ON dea.location = vac.location
 and dea.date = vac.date 
WHERE dea.continent is not null;  
SELECT *
FROM PercentagePopulationVaccinated