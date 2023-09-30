SELECT *
FROM PortfolioProject..CovidDeaths
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3, 4


--Select Data that we are using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1, 2


--Looking at Total Cases vs Total Deaths in Hungary
--Shows Likelihood of dying if you contract covid in Hungary

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location = 'Hungary'
order by 1, 2


-- Looking at Total Cases vs Population in Hungary
-- Shows what percentage of population got Covid in Hungary

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PerecentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location = 'Hungary'
order by 1, 2


--Looking at Contries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PerecentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location = 'Hungary'
Group By Location, population 
Order By PerecentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(Cast(total_deaths as int)) as TotaldeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By TotaldeathCount desc


-- Let's Break thing down by Continent

-- Showing Continents with the highest death count per population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotaldeathCount desc


-- Global Numbers


Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1, 2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
  And   dea.date = vac.date
  Where dea.continent is not null
  Order By 1, 2, 3
  

  -- Use CTE

  WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
  as (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
  And   dea.date = vac.date
  Where dea.continent is not null
  --Order By 1, 2, 3
  )
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From PopvsVac


-- Use Temptable
Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
  And   dea.date = vac.date
  Where dea.continent is not null
  --Order By 1, 2, 3

  Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated1
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
  And   dea.date = vac.date
  Where dea.continent is not null
  --Order By 1, 2, 3

  Select *
  From PercentPopulationVaccinated1