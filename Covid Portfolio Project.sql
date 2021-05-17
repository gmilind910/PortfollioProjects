/*select * from covidvaccination
order by 3,4;*/

select * from coviddeaths
order by 3,4;

/* Select data that we are going to be using*/

select location, date, total_cases,new_cases, total_deaths, population
FROM coviddeaths
order by location, date;

-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
WHERE location LIKE '%states%'
order by date;

-- Looking at the total cases vs population
-- Shows what percentage of population got covid

Select location, date,total_cases, population, (total_cases/population)* 100 AS percentpopulationinfected 
from coviddeaths
-- WHERE location LIke '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compare to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases/population))* 100 AS percentpopulationinfected 
 FROM coviddeaths
 GROUP BY location, population
ORDER BY percentpopulationinfected  desc;

-- Showing the highest death count countries per population

SELECT location, MAX(total_deaths ) AS totaldeathCount
 FROM coviddeaths
 WHERE continent IS not null
 GROUP BY location
ORDER BY totaldeathCount desc;

-- Lets break things down by Continent

SELECT continent, MAX(total_deaths) AS totaldeathCount
 FROM coviddeaths
 WHERE continent IS not null
 GROUP BY continent
ORDER BY totaldeathCount desc;

-- Showing the continent with the highest death counts

SELECT continent, MAX(total_deaths ) AS totaldeathCount
 FROM coviddeaths
 WHERE continent IS not null
 GROUP BY continent
ORDER BY totaldeathCount desc;

-- Global numbers

select  date, sum(new_cases) AS total_cases, sum(new_deaths) AS total_deaths, sum(new_deaths)/sum(new_cases) * 100 AS deathpercentage
FROM coviddeaths
-- WHERE location LIKE '%states%'
where continent is not null
group by date
order by 1,2;

-- Looking at total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 from covidvaccination vac
join coviddeaths dea ON
dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;

-- use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 from covidvaccination vac
join coviddeaths dea ON
dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3
)
select *, (rollingpeoplevaccinated/population)* 100 
from popvsvac;

-- Temp table
Create Table percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)


Insert into percentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 from covidvaccination vac
join coviddeaths dea ON
dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3

 select *, (rollingpeoplevaccinated/population)* 100 
from percentPopulationvaccinated;

-- Creating view to store data for later visualizations

CREATE view percentPopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
 from covidvaccination vac
join coviddeaths dea ON
dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;
-- order by 2,3

select * from percentpopulationvaccinated
