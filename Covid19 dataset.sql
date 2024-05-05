--DATA OF ALL OVER THE WORLD
SELECT * FROM CovidDeaths$
where location like 'india'
order by date asc

-- Showing Covid19 data of India
SELECT *
FROM CovidDeaths$
WHERE location LIKE 'india'

--Showing Percentage of Populations effect by covid

SELECT location, date,population,total_cases, (total_cases/population)*100 as Percentagepopulationinfected
FROM CovidDeaths$

--Showing total Deaths by Contitent

SELECT continent, SUM(CAST(total_deaths AS int)) AS total_deaths-- CONVERTING total_deaths FROM nvarchar TO int
FROM CovidDeaths$
where continent is not null -- Filtering out the null values form Continest which are representating the Aggrigated data
GROUP BY continent

--DRILL THROUGH OF THE CONTINENTS TO COUNTRY

SELECT continent, location, SUM(CAST(total_deaths AS int)) AS total_deaths
FROM CovidDeaths$
where continent is not null 
GROUP BY continent, location
ORDER BY continent,location

--MAXIMUM DEATHS BY COUNTRY

SELECT location, SUM(CAST(total_deaths AS int)) AS total_deaths
FROM CovidDeaths$
where continent is not null 
GROUP BY location
ORDER BY total_deaths DESC

--Showing Contitnents with Highest Death Count per Population

SELECT continent, 
		SUM(CAST(total_deaths AS int)) AS total_deaths 
		,SUM(CAST(population AS bigint)) AS total_population
		, SUM(CAST(total_deaths AS numeric))/SUM(CAST(population AS numeric)) AS death_rate
FROM CovidDeaths$
where continent is not null 
	--AND location LIKE 'india'
GROUP BY continent
ORDER BY death_rate DESC

--Showing Country's with Highest Death Rate per Population

SELECT location, 
		SUM(CAST(total_deaths AS int)) AS total_deaths 
		,SUM(CAST(population AS bigint)) AS total_population
		, SUM(CAST(total_deaths AS numeric))/SUM(CAST(population AS numeric)) AS death_rate
FROM CovidDeaths$
where continent is not null 
	--AND location LIKE 'india'
GROUP BY location
ORDER BY death_rate DESC


--Showing the Continents with Highest Death Count

SELECT continent, SUM(CAST(total_deaths AS bigint)) AS totalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totalDeathCount  DESC

--Showing Countries With Highest Death Count

SELECT location, SUM(CAST(total_deaths AS bigint)) AS totalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount  DESC

--Global Numbers


SELECT 
	--date,
	 SUM(new_cases) AS total_cases
	,SUM(CAST(new_deaths AS int)) total_deaths
	,SUM(CAST(new_deaths AS int))/SUM(new_cases)  AS death_percentage
FROM CovidDeaths$
	WHERE continent IS NOT NULL
--GROUP BY DATE
order by 1,2

--Looking at Total Populations vs Vaccinations

SELECT cd.continent,cd.location,cd.date, 
		CD.population,CV.new_vaccinations
		,SUM(CONVERT(INT,CV.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CD.DATE) AS RollingMoivngVaccinated
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS CV
	ON cd.location = cv.location
	and CD.date = CV.date
WHERE cd.continent IS NOT NULL
 and cd.location like 'alb%'


--Using cte

WITH PopVSVac (continent, location, date, population,vaccination,rollingvaccinated)
as
(SELECT cd.continent,cd.location,cd.date, 
		CD.population,CV.new_vaccinations
		,SUM(CONVERT(INT,CV.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CD.DATE) AS RollingMoivngVaccinated
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS CV
	ON cd.location = cv.location
	and CD.date = CV.date
WHERE cd.continent IS NOT NULL
 and cd.location like 'alb%'
 )
 select *, rollingvaccinated/population*100 from PopVSVac

 --Temp table

 DROP TABLE IF exists #RollingTotalofPeopleVvaccinated
 CREATE TABLE #RollingTotalofPeopleVvaccinated
 ( 
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population bigint,
 newvaccinations int,
 rollingvaccinatoins int)

 INSERT INTO #RollingTotalofPeopleVvaccinated
 SELECT cd.continent,cd.location,cd.date, 
		CD.population,CV.new_vaccinations
		,SUM(CONVERT(INT,CV.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CD.DATE) AS RollingMoivngVaccinated
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS CV
	ON cd.location = cv.location
	and CD.date = CV.date

 select *, rollingvaccinatoins/population*100 from #RollingTotalofPeopleVvaccinated


--views for visualaisation
CREATE VIEW RollingTotalofPeopleVvaccinated AS
SELECT cd.continent,cd.location,cd.date, 
		CD.population,CV.new_vaccinations
		,SUM(CONVERT(INT,CV.new_vaccinations))OVER(PARTITION BY cd.location ORDER BY CD.DATE) AS RollingMoivngVaccinated
FROM CovidDeaths$ AS cd
JOIN CovidVaccinations$ AS CV
	ON cd.location = cv.location
	and CD.date = CV.date
WHERE cd.continent IS NOT NULL
 