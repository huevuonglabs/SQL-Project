
# 🏥 SQL for Healthcare — COVID-19 Outcomes & Vaccination Analysis

## 📌 Project Overview

This project uses SQL to analyze global COVID-19 data, focusing on infection trends, mortality rates, population impact, and vaccination progress. The goal is to turn raw public health data into metrics that help compare outcomes across locations and support reporting or visualization workflows.

This mirrors how healthcare analysts evaluate disease impact using indicators like case fatality rate, infection rate, and vaccination coverage.

---

## 🧩 Objectives

Healthcare teams need reliable metrics to answer:
* How severe is COVID-19 by country?

* How widely did it spread?

* How fast did vaccination coverage grow over time?

---

## 🛠️ Approach (SQL Workflow)
---

## ✅ Data Exploration & Validation

### Step 1) View the full CovidDeath table

```sql
--View full table
SELECT * FROM CovidDeath
ORDER BY 3,4
```

### Step 2) Select key public health fields for analysis

```sql
SELECT
   location
  ,date
  ,total_cases
  ,new_cases
  ,total_deaths
  ,population
FROM CovidDeath
ORDER BY 1,2
```

---

## ✅ Mortality Analysis (Deaths vs Cases)

### Step 3) Total deaths vs total cases (death ratio)

```sql
SELECT
   location
  ,date
  ,total_cases
  ,total_deaths
  ,(total_deaths/total_cases) AS death_ratio
FROM CovidDeath
ORDER BY death_ratio DESC
```

### Step 4) U.S. COVID death rate (%)

```sql
SELECT
   location
  ,date
  ,total_cases
  ,total_deaths
  ,(total_deaths/total_cases)*100 AS death_percent
FROM CovidDeath
WHERE location LIKE '%united states%'
ORDER BY death_percent DESC
```

### Step 5) Likelihood of death if contracting COVID (method 1: max totals)

```sql
SELECT
   location
  ,MAX(total_cases) AS TOTAL_CASES
  ,MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
  ,MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 AS death_percent
FROM CovidDeath
GROUP BY location
ORDER BY 4 DESC
```

### Step 6) Likelihood of death if contracting COVID (method 2: deaths/new cases)

```sql
SELECT
   location
  ,SUM(new_cases) AS TOTAL_CASES
  ,SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS
  ,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percent
FROM CovidDeath
GROUP BY location
ORDER BY 4 DESC
```

### Step 7) Global case fatality rate

```sql
SELECT
   SUM(new_cases) AS TOTAL_CASES
  ,SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATHS
  ,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percent
FROM CovidDeath
```

## ✅ Infection Impact (Cases vs Population)

### Step 8) Total cases vs population over time

```sql
SELECT
   location
  ,date
  ,population
  ,total_cases
  ,(total_cases/population)*100 AS popinfection_percent
FROM CovidDeath
ORDER BY popinfection_percent DESC
```

### Step 9) Highest infection rate by location

```sql
SELECT
   location
  ,population
  ,MAX(total_cases) AS TOTAL_CASES
  ,MAX(total_cases)/population*100 AS popinfection_percent
FROM CovidDeath
GROUP BY location, population
ORDER BY popinfection_percent DESC
```

---

## ✅ Death Burden by Population (Country + Continent Level)

### Step 10) Total death count ranking

```sql
SELECT
   location
  ,population
  ,MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
  ,MAX(total_cases)/population*100 AS popdeath_percent
FROM CovidDeath
GROUP BY location, population
ORDER BY TOTAL_DEATHS DESC
```

### Step 11) Death rate vs population (countries only)

Filtered out continent-level summary rows for cleaner country comparisons.

```sql
--Analyse Death Rate vs population by location
--Change total_death (nvarchar) to integer
--Show countries only (remove duplicates location = continent)
SELECT
   location
  ,population
  ,MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
  ,MAX(total_cases)/population*100 AS popdeath_percent
FROM CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC
```

### Step 12) Continent-level comparison

```sql
SELECT location, MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
FROM CovidDeath
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC
```
---

## ✅ Vaccination Progress (Population vs Vaccination Over Time)

### Step 13) Join vaccination data + build cumulative vaccinations (window function)

```sql
SELECT
   death.continent
  ,death.location
  ,death.date
  ,death.population
  ,vaccin.new_vaccinations
  ,SUM(CAST (vaccin.new_vaccinations AS INT)) OVER (
       PARTITION by death.location
       ORDER BY death.location, death.date
    ) AS AccumulatedVaccin
FROM CovidDeath death 
JOIN CovidVaccination vaccin
 ON death.location=vaccin.location
 AND death.date=vaccin.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2,3
```

### Step 14) Use a CTE to calculate vaccination rate

```sql
 WITH PopvsVaccin (continent, location, date, population, new_vaccinations, AccumulatedVaccin)
 AS (
    SELECT
           death.continent
          ,death.location
          ,death.date
          ,death.population
          ,vaccin.new_vaccinations
          ,SUM(CAST (vaccin.new_vaccinations AS INT)) OVER (
               PARTITION by death.location
               ORDER BY death.location, death.date
            ) AS AccumulatedVaccin
    FROM CovidDeath death 
    JOIN CovidVaccination vaccin
      ON death.location=vaccin.location
      AND death.date=vaccin.date
    WHERE death.continent IS NOT NULL
	)

SELECT * , AccumulatedVaccin/population*100 AS VaccinatedRate
FROM PopvsVaccin
```

### Step 15) Create a reusable view for visualization / reporting

```sql
CREATE VIEW PopulationVaccinated AS
      SELECT
         death.continent
        ,death.location
        ,death.date
        ,death.population
        ,vaccin.new_vaccinations
        ,SUM(CAST (vaccin.new_vaccinations AS INT)) OVER (
            PARTITION by death.location
            ORDER BY death.location, death.date
        ) AS AccumulatedVaccin
      FROM CovidDeath death 
      JOIN CovidVaccination vaccin
        ON death.location=vaccin.location
        AND death.date=vaccin.date
      WHERE death.continent IS NOT NULL
```

✅ Skills demonstrated here:

* combining public health datasets using multi-key joins (`location + date`)
* cumulative metrics using window functions (`SUM() OVER`)
* building reusable transformations via **CTE**
* creating a **view** for downstream BI tools and reporting

---

## 🔍 Insights

This project enables analysis like:

* how mortality compares across locations (**death % / death ratio**)
* which countries show the highest infection penetration (**cases per population**)
* global death rate trends using aggregated totals
* separating country-level vs continent-level reporting to avoid duplicates
* vaccination rollout progress by country over time (**accumulated vaccinations**)
* vaccination coverage rate (**vaccinated % of population**) for comparison

---

## 🎯 Impact

This analysis supports healthcare and policy decisions such as:

* compare mortality impact between regions
* identify countries with higher case fatality indicators
* generate clean, reusable metrics for reporting dashboards
* track infection spread as a share of population
* measure vaccination coverage growth over time
* compare rollout speed between locations
* creates a reporting-friendly view (`PopulationVaccinated`)
* makes metrics easier to reuse in BI tools and scheduled reporting

---

## 🛠 Tools / SQL Concepts Used

* SQL Aggregations: `SUM()`, `MAX()`
* Filtering: `WHERE`, `LIKE`
* Type Conversion: `CAST()`
* Joins: `JOIN` on `location + date`
* Window Functions: `SUM() OVER (PARTITION BY ... ORDER BY ...)`
* CTEs: `WITH ... AS (...)`
* View Creation: `CREATE VIEW`

---
