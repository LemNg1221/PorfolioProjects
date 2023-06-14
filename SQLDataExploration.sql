select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4


select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths
---Show likelihood of dying if you contract covid in your country
select Location, date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like '%viet%'
order by 1,2

--Looking at Total cases vs Population
---Show what percentage of population got covid
select Location, date, population, max(total_cases), (total_deaths/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
--where location like '%viet%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population
select Location, population, max(total_cases) as HighestInfecttion, max((total_deaths/population)*100) as HighestPercentagePopulationInfected
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population
order by HighestPercentagePopulationInfected desc

--Showing countries with Highest Death Count per Population
select Location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Break things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continent with the highest death count per population
select continent, sum((cast(total_deaths as int)/population)*100) as DeathperPopulation
from PortfolioProject..CovidDeaths 
where continent is not null
group by continent
order by HighestDeathperPopulation desc


--Global numbers
select Location, date, total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
order by 1,2


select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
group by date
order by 1,2

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPopulationVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select * , (RollingPopulationVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store Data foe later Visualizations (hiện vĩnh viễn, không thể xóa như bảng tạm thời)
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
