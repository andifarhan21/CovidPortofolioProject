--Select *
--from PortofolioProject.dbo.coviddeaths
--order by 3,4

--select *
--from PortofolioProject..CovidVaccinations
--order by 3,4

--select location, date, total_cases, new_cases, total_deaths, population
--from PortofolioProject..CovidDeaths
--order by 1, 2
--------------------------------------------------------------------------------------------------------
--total death vs total case 
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from PortofolioProject..CovidDeaths
where location like 'indonesia'
order by 1, 2

--total case vs population
select location, date, total_cases, population, (total_cases/population) * 100 as population_percentage_infected
from PortofolioProject..CovidDeaths
where location like '%states%'
order by population_percentage_infected desc

-- countries with Highest Infection Rate vs Population
select location, population, Max(total_cases) as highest_infection_rate, Max((total_cases/population) * 100) as population_percentage_infected
from PortofolioProject..CovidDeaths
group by location, population
order by highest_infection_rate desc

--countries with Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as highest_death_count
from PortofolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc


select continent, max(cast(total_deaths as int)) as highest_death_count
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc


-- Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
			sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percentage
From PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 3 desc

-- Total population vs Vaccinations


SET ANSI_WARNINGS OFF
GO

With PopVsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) 
		over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2, 3, 6
)
select *, (rolling_people_vaccinated/population) * 100 
from PopvsVac


-- TEMP TABLE
Drop Table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) 
		over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2, 3, 6

select *
from #PercentagePopulationVaccinated


-- Creating View for our visualisation later

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as bigint)) 
		over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	on Dea.location = Vac.location
	and Dea.date = Vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2, 3, 6