SELECT *
FROM [census ]..CovidDeaths
where continent is not null
order by 3,4
--SELECT *
--FROM [census ]..CovidVaccinations
--order by 3,4
SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM [census ]..CovidDeaths
order by 1,2

SELECT location,date,population,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [census ]..CovidDeaths
where location like '%nepal%'
order by 1,2
--Looking at countries with highest infestion rate compared with population
SELECT location,population,MAX(total_cases) as HighestInfected,MAX((total_cases/population))*100 as InfectedPercentage
FROM [census ]..CovidDeaths
group by location,population
order by InfectedPercentage desc
--Showing countries with highest death count
SELECT location,MAX(cast(total_deaths as int)) as totaldeath
FROM [census ]..CovidDeaths
where continent is not null
group by location
order by totaldeath desc

--Showing continent with highest death count
SELECT location,MAX(cast(total_deaths as int)) as totaldeath
FROM [census ]..CovidDeaths
where continent is  null 
group by location
order by totaldeath desc

--Showing continent with highest death count
SELECT location,MAX(cast(total_deaths as int)) as totaldeath
FROM [census ]..CovidDeaths
where continent is  null 
group by location
order by totaldeath desc

--joining two tables 
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,DEA.new_vaccinations,SUM(convert(bigint,DEA.new_vaccinations)) OVER (partition by
DEA.location order by DEA.location,DEA.date)as totalVaccinations
FROM [census ]..CovidDeaths as DEA
JOIN  [census ]..CovidVaccinations as VAC
ON DEA.location=VAC.location and DEA.date=VAC.date
where DEA.continent is not null
Order by 2,3
--newcte
With PopvsVac (continent,location,date,population,new_vaccinations,totalVaccinations)
as(
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,DEA.new_vaccinations,SUM(convert(bigint,DEA.new_vaccinations)) OVER (partition by
DEA.location order by DEA.location,DEA.date)as totalVaccinations
FROM [census ]..CovidDeaths as DEA
JOIN  [census ]..CovidVaccinations as VAC
ON DEA.location=VAC.location and DEA.date=VAC.date
where DEA.continent is not null
--Order by 2,3
)
SELECT *
FROM PopvsVac
---Creating new tempt table
DROP Table if exists #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalVaccinations numeric)
Insert into #PercentPopulationvaccinated
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,DEA.new_vaccinations,SUM(convert(bigint,DEA.new_vaccinations)) OVER (partition by
DEA.location order by DEA.location,DEA.date)as totalVaccinations
FROM [census ]..CovidDeaths as DEA
JOIN  [census ]..CovidVaccinations as VAC
ON DEA.location=VAC.location and DEA.date=VAC.date
where DEA.continent is not null
--Order by 2,3

SELECT *,(totalVaccinations/population)*100
FROM #PercentPopulationvaccinated

--creating view to look at the table
DROP VIEW IF EXISTS PercentPopulationvaccinated;
GO
CREATE VIEW PercentPopulationvaccinated AS 
SELECT DEA.continent,DEA.location,DEA.date,DEA.population,DEA.new_vaccinations,SUM(convert(bigint,DEA.new_vaccinations)) OVER (partition by
DEA.location order by DEA.location,DEA.date)as totalVaccinations
FROM [census ]..CovidDeaths as DEA
JOIN  [census ]..CovidVaccinations as VAC
ON DEA.location=VAC.location and DEA.date=VAC.date
where DEA.continent is not null
--Order by 2,3
