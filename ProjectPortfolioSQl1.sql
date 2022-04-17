select * from PortfolioProject .. CovidDeaths$ order by 3,4

--select * from PortfolioProject .. CovidVaccinations$ order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject .. CovidDeaths$ order by 1,2

--Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths$ 
where location like '%india%'
order by 1,2

--Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from PortfolioProject .. CovidDeaths$ 
where location like '%india%'
order by 1,2


--Looking at countries with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfection
from PortfolioProject .. CovidDeaths$ 
--where location like '%india%'
Group by location, population
order by PercentPopulationInfection desc

--Showing countries with Highest Death Count per population

Select location, Max(cast(total_deaths as bigint)) as MaximumTotalDeathCount
from PortfolioProject .. CovidDeaths$ 
--where location like '%india%'
where continent is not null
Group by location
order by MaximumTotalDeathCount desc


--LET'S BREAK DOWN BY BY CONTINENT

Select continent, Max(cast(total_deaths as bigint)) as MaximumTotalDeathCount
from PortfolioProject .. CovidDeaths$ 
--where location like '%india%'
where continent is not null
Group by continent
order by MaximumTotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM (new_cases) AS TOTAL_NEW_CASES, SUM(cast (new_deaths as bigint)) AS TOTAL_NEW_DEATHS, 
SUM(cast (new_deaths as bigint))/SUM
(New_Cases) *100 as DeathPercentage
From PortfolioProject. .CovidDeaths$
--Where location 1ike "%INDIA%"
where continent is not null
Group By date
order by 1,2

Select SUM (new_cases) AS TOTAL_NEW_CASES, SUM(cast (new_deaths as bigint)) AS TOTAL_NEW_DEATHS, 
SUM(cast (new_deaths as bigint))/SUM
(New_Cases) *100 as DeathPercentage
From PortfolioProject. .CovidDeaths$
--Where location 1ike "%INDIA%"
where continent is not null
--Group By date
order by 1,2


Select date, SUM (new_cases) AS TOTAL_NEW_CASES, SUM(cast (new_deaths as bigint)) AS TOTAL_NEW_DEATHS, 
(SUM(cast (new_deaths as bigint))/SUM
(New_Cases)) *100 as DeathPercentage
From PortfolioProject. .CovidDeaths$
--Where location 1ike "%INDIA%"
where continent is not null
Group By date
order by DeathPercentage DESC

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject. .CovidDeaths$ dea
Join PortfolioProject. .CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea. Location Order by dea.location,dea.Date)
as RollingPeopleVaccinated
From PortfolioProject. .CovidDeaths$ dea
Join PortfolioProject. .CovidVaccinations$ vac
On dea.location = vac.location
and dea. date = vac.date
where dea.continent is not null --and dea.location like '%india%'
order by 2,3,4


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
on dea.location=vac.location
and dea. date = vac.date
where dea.continent is not null and dea.location like '%india%'
--order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100 As PercentPeopleVaccinatedPerPopulation From PopvsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea. date, dea . population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) oVER (Partition by dea. Location Order by dea. location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From PortfolioProject. .CovidDeaths$ dea
join PortfolioProject. .covidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated

--creating view to store data to use later for visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea. date, dea . population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations )) oVER (Partition by dea. Location Order by dea. location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) *100
From PortfolioProject. .CovidDeaths$ dea
join PortfolioProject. .covidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select* from PercentPopulationVaccinated