select *
from [dbo].[CovidDeaths]
order by 3,4


update [dbo].[CovidDeaths]
set new_deaths=round (0.02*new_cases,0)
where new_cases > 8
--select *
--from [dbo].[CovidVaccination]
--order by 3,4

--select data tht we are going to be using
select location, date, total_cases, new_cases, 
		total_deaths, population
from [dbo].[CovidDeaths]
order by 1,2

-- lookin at total cases vs total deaths
select location, date, total_cases,
		total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
where location= 'Indonesia'
order by 1,2

--looking at total cases vs population
select location, date, population, total_cases,
		(total_cases/population)*100 as CasesPercentage
from [dbo].[CovidDeaths]
where location= 'Indonesia'
order by 1,2

--looking at the highest infection country
select location, population, max(total_cases),
		max((total_cases/population)*100) as CasesPercentage
from [dbo].[CovidDeaths]
--where location= 'Indonesia'
Group By Location, population
order by 4 desc;

--Showing the highest death count per population
select location, population, max(total_deaths),
		max((total_deaths/population)*100) as DeathPercentage
from [dbo].[CovidDeaths]
--where location= 'Indonesia'
Group By Location, population
order by 4 desc;

select location, max(total_deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is null
group by location
order by TotalDeathCount desc;

--lets break by continent, showing continents with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount
from [dbo].[CovidDeaths]
where continent is not null
group by continent
order by TotalDeathCount desc;

--max(cast (total_death as int)) using cast if the datatype is not int or cannt be counted

--Global numbers, showing new death per new cases

select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths,
			sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths]
--where location= 'Indonesia'
--group by date
order by 1;

Update [dbo].[CovidVaccines] 
Set new_vaccinations = (abs(cast(newid() as binary(6)) %90000) + 10000)/200;

select total_vaccinations, new_vaccinations from [dbo].[CovidVaccines];

select * 
from [dbo].[CovidDeaths] d
join [dbo].[CovidVaccines] v
on d.location = v.location
and d.date = v.date;

--looking at total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from [dbo].[CovidDeaths] d
join [dbo].[CovidVaccines] v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 1,2,3;

--with partition by
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum (convert (int,v.new_Vaccinations)) over (partition by d.location order by  d.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
from [dbo].[CovidDeaths] d
join [dbo].[CovidVaccines] v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3;

--update [dbo].[CovidVaccines]
--set new_vaccinations = 0
--where SUBSTRING(date,1,4)='2020'or SUBSTRING(date,1,7)='2021-01';


--Using CTE
With PopvsVac (continent, location, date, population, new_vaccination,RollingPeopleVaccinated )
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum (convert (int,v.new_Vaccinations)) over (partition by d.location order by  d.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
from [dbo].[CovidDeaths] d
join [dbo].[CovidVaccines] v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3;
)

select *, (RollingPeopleVaccinated/population)*100 as vacPercentage
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum (convert (int,v.new_Vaccinations)) over (partition by d.location order by  d.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
from [dbo].[CovidDeaths] d
join [dbo].[CovidVaccines] v
on d.location = v.location
and d.date = v.date
--where d.continent is not null
--order by 2,3;

select *, (RollingPeopleVaccinated/population)*100 as vacpercentage
from #PercentPopulationVaccinated


--using view to later visualization of data

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum (convert (int,v.new_Vaccinations)) over (partition by d.location order by  d.location) as RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
from [dbo].[CovidDeaths] d
join [dbo].[CovidVaccines] v
on d.location = v.location
and d.date = v.date
where d.continent is not null

select * from PercentPopulationVaccinated








