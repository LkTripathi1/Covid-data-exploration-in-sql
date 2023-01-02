

Select *
from Project..covidDeaths
order by 3,4



-- selecting data we are using 

Select Location, date, total_cases, new_cases, total_deaths, population
From project..CovidDeaths
Where location = 'india'
order by date;



-- Looking at Total cases vs Total Deaths 
-- Shows likelihood of dying if you get infected in india


Select Location, date, Population, total_cases, total_deaths, (total_deaths/total_cases)* 100 as [Death Percentage] 
From project..CovidDeaths
Where location = 'india'
order by 1,2;



-- Looking Total cases vs population
-- Shows what percentage of population got covid

Select Location, date, Population, total_cases, (total_cases/population)* 100 as InfectedPopulationPercentage 
From  CovidDeaths
Where location = 'india'
order by 1,2;



-- Looking at countries with Highest infection Rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectedCount, Max((total_cases/population))* 100 as InfectedPopulationPercentage 
From  CovidDeaths
Where continent is not null
Group by Location, Population
order by InfectedPopulationPercentage desc; 



-- Showing countries with Highest Death Count per Population
 
Select Location, population, Max(Total_deaths) as TotalDeathCount
From project..covidDeaths
Where continent is not null
Group by Location, population
order by TotalDeathCount desc; 



-- Lets break things down by continent

-- Showing contintents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From project..covidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc; 



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Project..covidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project..covidDeaths dea
Join Project..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Project..covidDeaths dea
Join Project..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project..covidDeaths dea
Join Project..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Project..covidDeaths dea
Join Project..CovidVacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
