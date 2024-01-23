--Select *
--From [Portfolio Project]..CovidDeaths
--order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

Select Location,date,total_cases,new_cases,total_deaths, population
from [Portfolio Project]..CovidDeaths 
order by 1,2

exec sp_help 'CovidDeaths';

Alter Table CovidDeaths
alter column total_deaths float

Alter Table CovidDeaths
alter column total_cases float


--Likelihood of dyig if you get Covid in India
Select Location,date,total_cases,total_deaths,((total_deaths/total_cases)*100) as DeathPercentage
from [Portfolio Project]..CovidDeaths 
where location like '%India%'
order by 1,2

--Total Cases vs Population
Select Location,date,total_cases,population,((total_cases/population)*100) as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths 
where location like '%India%'
order by 1,2

--Countries with highest infection rate as compared to Population
Select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as HighPercentPopulationInfected
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
group by location,population
order by HighPercentPopulationInfected desc

--Countries with highest death count per Population
Select Location,MAX(total_deaths) as TotalDeathCount
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
group by location
order by TotalDeathCount desc

--By Continent
Select continent,MAX(total_deaths) as TotalDeathCountContinent
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
group by continent
order by TotalDeathCountContinent desc

--Global Numbers
Select date,SUM(new_cases) as TotalNewCases,SUM(new_deaths) as TotalNewDeaths
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
group by date
order by 1,2

Select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercent
from [Portfolio Project]..CovidDeaths 
--where location like '%India%'
--group by date
order by 1,2



--JOIN

Select *
from [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date

Select dea.continent,dea.location,dea.date,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.date) as CumulativeVac
from [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
order by 1,2,3


--With CTE

With PopvsVac (Continent,Location,Date,Population,New_Vaccination,CumulativeVac)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.date) as CumulativeVac
from [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
--order by 1,2,3
)

select *,(CumulativeVac/Population)*100
from PopvsVac



--TEMP Table

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CumulativeVac numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.date) as CumulativeVac
from [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not NULL
--order by 1,2,3

Select *,(CumulativeVac/Population)*100
from #PercentPopulationVaccinated



--Creating View

Use [Portfolio Project]
Go
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.date) as CumulativeVac
from [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not NULL
--order by 1,2,3

select *
from PercentPopulationVaccinated;

