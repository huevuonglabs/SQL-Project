--View full table
SELECT * FROM CovidDeath
ORDER BY 3,4


--SELECT information from the CovidDeath
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1,2

--Analyse Total death vs Total cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_ratio
FROM CovidDeath
ORDER BY death_ratio DESC

--Analyse US Covid Death
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percent
FROM CovidDeath
WHERE location LIKE '%united states%'
ORDER BY death_percent DESC

--Analyse likelihood of death if contracting with Covid (1)
SELECT location, MAX(total_cases) AS TOTAL_CASES, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS, MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 AS death_percent
FROM CovidDeath
GROUP BY location
ORDER BY 4 DESC
 
 --Analyse likelihood of death if contracting with Covid (2)
SELECT location, SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percent
FROM CovidDeath
GROUP BY location
ORDER BY 4 DESC

 --GLOBAL DATA(2)
SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percent
FROM CovidDeath

--Analyse Total cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS popinfection_percent
FROM CovidDeath
ORDER BY popinfection_percent DESC

--Analyse Infection Rate by location
SELECT location, population, MAX(total_cases) AS TOTAL_CASES, MAX(total_cases)/population*100 AS popinfection_percent
FROM CovidDeath
GROUP BY location, population
ORDER BY popinfection_percent DESC


--Total Death Count
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS, MAX(total_cases)/population*100 AS popdeath_percent
FROM CovidDeath
GROUP BY location, population
ORDER BY TOTAL_DEATHS DESC

--Analyse Death Rate vs population by location
--Change total_death (nvarchar) to integer
--Show countries only (remove duplicates location = continent)
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS, MAX(total_cases)/population*100 AS popdeath_percent
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--Analyse by Continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
FROM CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC


--Analyse Population vs Vaccination with Accumulated number
SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
SUM(CAST (vaccin.new_vaccinations AS INT)) OVER (PARTITION by death.location ORDER BY death.location, death.date) AS AccumulatedVaccin
FROM CovidDeath death 
 JOIN CovidVaccination vaccin
 ON death.location=vaccin.location
 AND death.date=vaccin.date
 WHERE death.continent IS NOT NULL
 ORDER BY 1,2,3


 --USE CTE
 WITH PopvsVaccin (continent, location, date, population, new_vaccinations, AccumulatedVaccin)
 AS
    (
    SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
           SUM(CAST (vaccin.new_vaccinations AS INT)) OVER (PARTITION by death.location ORDER BY death.location, death.date) AS AccumulatedVaccin
    FROM CovidDeath death 
     JOIN CovidVaccination vaccin
     ON death.location=vaccin.location
        AND death.date=vaccin.date
    WHERE death.continent IS NOT NULL
   
	)

SELECT * , AccumulatedVaccin/population*100 AS VaccinatedRate
FROM PopvsVaccin


--CREATE VIEW FOR DATA VISUALIZATION
CREATE VIEW PopulationVaccinated AS
      SELECT death.continent, death.location, death.date, death.population, vaccin.new_vaccinations,
           SUM(CAST (vaccin.new_vaccinations AS INT)) OVER (PARTITION by death.location ORDER BY death.location, death.date) AS AccumulatedVaccin
      FROM CovidDeath death 
         JOIN CovidVaccination vaccin
      ON death.location=vaccin.location
        AND death.date=vaccin.date
      WHERE death.continent IS NOT NULL