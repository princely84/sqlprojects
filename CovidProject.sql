select * from [Portfolio Project]..CovidDeath
where continent is not null
order by 3, 4

select * from [Portfolio Project]..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project]..CovidDeath
where continent = 'Africa' and location = 'Cameroon'
order by 2 desc

--looking at total cases vs total deaths

--Chaniging data type

alter table [Portfolio Project]..CovidDeath
alter column population float

alter table [Portfolio Project]..CovidDeath
alter column total_cases float

alter table [Portfolio Project]..CovidDeath
alter column new_cases float

alter table [Portfolio Project]..CovidDeath
alter column total_deaths float

alter table [Portfolio Project]..CovidDeath
alter column date date

select year(date) as Date, max(total_cases) as TotalCases, max(new_cases) as NewCases, max(total_deaths) as TotalDeaths, max(population) as Population
from [Portfolio Project]..CovidDeath
where location = 'Cameroon'
group by location, year(date) 
order by 2 desc


select year(date) as Year, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from [Portfolio Project]..CovidDeath
where location = 'Cameroon' and (total_deaths/total_cases)*100 is not null
order by 1 desc

--total cases vs population

select year(date) as Year, max(total_cases) as TotalCases, max(total_deaths) as TotalDeaths, max((total_deaths/population)*100) as PercentPopulation
from [Portfolio Project]..CovidDeath
where location = 'Cameroon'
group by year(date)
order by 1 desc 

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_deaths/population))*100 as PercentPopulationInfected 
from [Portfolio Project]..CovidDeath
where continent = 'Africa' 
group by location, population
order by HighestInfectionCount desc

--showing countries with highest death count per population

select location, max(total_deaths) as TotalDeathcounted
from [Portfolio Project]..CovidDeath
where continent = 'Africa'
group by location
order by TotalDeathcounted desc

---break things down by continent

select location, max(total_deaths) as TotalDeathcount
from [Portfolio Project]..CovidDeath
where continent is not null
group by location
order by TotalDeathcount desc

--Showing continents with the highest death count per population

select continent, max(total_deaths) as TotalDeathcount
from [Portfolio Project]..CovidDeath
where continent is not null
group by continent
order by TotalDeathcount desc 

--Global numbers

select date, sum(new_cases) as New_Cases, sum(new_deaths) as New_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeath
--where location like '%roon%'
where continent is not null
group by date
order by 1, 2


 --Looking at Total Population vs Vaccinations

alter table [Portfolio Project]..['Covid Vaccinations$']
alter column new_vaccinations int


select Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeath as Dea
join [Portfolio Project]..CovidVaccinations as vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.location = 'Cameroon' and new_vaccinations is not null
order by 2 desc


--use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select Dea.continent, Dea.location, Dea.year(date), Dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..['Covid Death$'] as Dea
join [Portfolio Project]..['Covid Vaccinations$'] as vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent = 'Africa'
----order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



---Temp table

drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
New_vaccination numeric,
RollingPeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeath as Dea
join [Portfolio Project]..CovidVaccinations as vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent = 'Africa'
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated
where RollingPeopleVaccinated is not null
order by RollingPeoplevaccinated desc


---Creating view for data visualization 

create view PercentPopulationVaccinated as
select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeath as Dea
join [Portfolio Project]..CovidVaccinations as vac
	on Dea.location = vac.location
	and Dea.date = vac.date
where Dea.continent = 'Africa'
--order by 2, 3

select * from PercentPopulationVaccinated
where RollingPeopleVaccinated is not null and location = 'cameroon'
order by 3 desc
