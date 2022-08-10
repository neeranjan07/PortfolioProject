select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccination
--order by 3,4
--total case vs total deaths
select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidVaccination
where location like '%states%'
order by 1,2

--total_cases vs population
select location, population, Max(total_cases), MAX((total_cases/population))*100 as TotalInfectedPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by TotalInfectedPercentage desc

--Deaths comparison over Population 

select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by TotalDeathCount desc

--Break things by continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--largest death cases
select date, sum(total_cases) as TotatCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(new_cases)/sum(cast(new_deaths as int))*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Total population vs vaccination
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date)
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccination vac
  on death.location = vac.location
  and death.date = vac.date
where death.continent is not null
order by 2,3

--Use CTE
with poplvsvacc (continent, location, date, population, new_vaccinations, RollingpeopleVacc)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingpeopleVacc
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccination vac
  on death.location = vac.location
  and death.date = vac.date
where death.continent is not null
--order by 2,3
)

select *, (RollingpeopleVacc/population)*100
from poplvsvacc


--Creating Table

Drop Table if exists #TotalVaccinatedPopulation
Create Table #TotalVaccinatedPopulation
(
Continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinated numeric,
RollingpeopleVacc numeric,
)

INSERT INTO #TotalVaccinatedPopulation
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date)
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccination vac
  on death.location = vac.location
  and death.date = vac.date
--where death.continent is not null
--order by 2,3

select *, (RollingpeopleVacc/population)*100
from #TotalVaccinatedPopulation

--Creating View

Create View PercentVaccinatedpeople as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations 
,Sum(convert(int,vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as RollingpeopleVacc
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccination vac
  on death.location = vac.location
  and death.date = vac.date
where death.continent is not null
--order by 2,3
