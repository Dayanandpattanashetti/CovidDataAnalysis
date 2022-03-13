select * from portfolioproject..coviddeaths 

--percentage ratio of total deaths to total cases/chances of death of an infected person
select location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from portfolioproject..coviddeaths order by 1,2;

--percantage ratio of total cases to population
select location, population, total_cases, 
(total_cases/population) as PercentageOfInfectedPopulation
from portfolioproject..coviddeaths order by 1,2

--maxpercentage of ratio of total cases to population
select location, population, 
max(total_cases) as max_cases, 
max((total_cases/population)*100) as MaxPercentageOfInfectedPopulation
from portfolioproject..coviddeaths
group by location,population 
order by 1,2

--countries with highest death per population
select location, population,
max(cast(total_deaths as int)) as max_deaths
from portfolioproject..coviddeaths
where continent is not null 
group by location,population
order by 1,2

--continents with highest death count
select continent, max(cast(total_deaths as int)) as total_deaths 
from portfolioproject..coviddeaths
where continent is not null
group by continent 
order by total_deaths

--global numbers
select date, sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from portfolioproject..coviddeaths 
where total_cases is not null and continent is not null
group by date order by date;

--Overall numbers
select sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from portfolioproject..coviddeaths 
where continent is not null

--population vs vaccinations 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) 
over (partition by d.location order by d.location, d.date) as total_vac 
from portfolioproject..coviddeaths d
join portfolioproject..covidvaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3

--using CTE
with popvsvac(continent, location, date, population, new_vaccinations, total_vac) as(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as bigint)) 
over (partition by d.location order by d.location, d.date) as total_vac
from portfolioproject..coviddeaths d
join portfolioproject..covidvaccinations v
on d.location=v.location and d.date=v.date
where d.continent is not null
order by 2,3)
select *, (total_vac/population)*100 
from popvsvac