Select *
From SqlDataExploration.dbo.CovidDeaths
Where continent is Not Null
Order By 3,4

--Select *
--From SqlDataExploration.dbo.CovidVaccinations
--Order By 3,4

-- Data we are going to use

Select location,date,total_cases,new_cases,total_deaths, population
From SqlDataExploration.dbo.CovidDeaths
Order By 1,2

-- Looking for total cases vs total deaths
-- Shows you likelihood of dying if you contract covid in your country

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SqlDataExploration.dbo.CovidDeaths
Order By 1,2

Select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From SqlDataExploration.dbo.CovidDeaths
where location like '%India%'
Order By 1,2

--Looking at the total cases vs population of the country
 --Shows what percentage of population got covid

Select location,date,total_cases,population, (total_cases/population)*100 as CasePercentage
From SqlDataExploration.dbo.CovidDeaths
where location like '%India%'
Order By 1,2

--Looking at the countries with highest Infection rate

Select location,population,MAX(total_cases) as HighestInfection, MAX((total_cases/population)*100) as InfectionRate
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Group By location, population
Order By InfectionRate desc

--Showing countries with highest Death count vs Population

Select location,population,MAX(total_deaths) as Deaths, MAX((total_deaths/population)*100) as DeathRate
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is Not Null
Group By location, population
Order By DeathRate desc

--Showing countries with highest Death count per Population
Select location,MAX(cast (total_deaths as int)) As Deaths
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is Not Null
Group By location
Order By Deaths desc

-- Break things down using continent

Select location,MAX(cast (total_deaths as int)) As Deaths
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is  Null
Group By location
Order By Deaths desc

--if you using continent instead of location it shows different numbers using location with null statement gives you right numbers for continent


--Showing continents with the highest death count per population

Select location,population,MAX(cast (total_deaths as int)) As Deaths
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is  Null
and location <> 'World'
Group By location, population
Order By Deaths desc

-- Global Numbers

Select date,Sum(new_cases) as Total_Cases,Sum(cast(new_deaths as int)) as Total_Deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is Not Null
Group By date
Order By 1,2

-- Total NUmbers of cases and Deaths

Select Sum(new_cases) as Total_Cases,Sum(cast(new_deaths as int)) as Total_Deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is Not Null
--Group By date
Order By 1,2

-- Joining tables--

Select *
from SqlDataExploration..CovidVaccinations

Select *
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date

-- Lookind at total population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
Order By 2, 3

-- Adding vaccination based on location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast (vac.new_vaccinations as int)) over (Partition By dea.location) As TotalPopVaccinated
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
Order By 2, 3

-- If you want rolling add of vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast (vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) As RollingVaccinations
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
Order By 2, 3

-- If you want to know percentage of population vaccinated you can use either CTEs or Temp Table

--Using CTEs

With popvsvac (continent, location,date,population, new_vaccinations, RollingVaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast (vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) As RollingVaccinations
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--Order By 2, 3
)
Select location, Max(population) as pop, Max(RollingVaccinations) as Vaccinated, (Max(RollingVaccinations)/Max(population))*100 as PercentageVaccination
From popvsvac
Group By location
ORDER bY PercentageVaccination DESC

-- You can use Max to only find the percentage of total vaccinated percentage in a country

-- Using Temp Tables

 Drop Table If Exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinated numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast (vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) As RollingVaccinations
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date
--where dea.continent is not null
--Order By 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

Select Location, Max(Population), Max(RollingPeopleVaccinated),(Max(RollingPeopleVaccinated)/Max(Population))*100 
From #PercentPopulationVaccinated
Group By Location
Order By (Max(RollingPeopleVaccinated)/Max(Population))*100 desc

--Creating Views which can be used for further visualisation

Create View PercentPopulationVaccinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast (vac.new_vaccinations as int)) over (Partition By dea.location Order By dea.location, dea.date) As RollingVaccinations
From SqlDataExploration..CovidDeaths as dea
Join SqlDataExploration..CovidVaccinations as vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--Order By 2, 3

Create View CasesandDeaths as
Select Sum(new_cases) as Total_Cases,Sum(cast(new_deaths as int)) as Total_Deaths, (Sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is Not Null
--Group By date
--Order By 1,2

Create View DeathsinContinent as
Select location,population,MAX(cast (total_deaths as int)) As Deaths
From SqlDataExploration.dbo.CovidDeaths
--where location like '%India%'
Where continent is  Null
and location <> 'World'
Group By location, population
--Order By Deaths desc
