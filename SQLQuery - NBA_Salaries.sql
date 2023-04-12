USE NBAProject

-- Selecting all data
select * from NBA_Salaries


-- Changing seasonStartYear, salary and inflationAdjsalary to FLOAT

ALTER TABLE NBA_Salaries
ALTER COLUMN seasonStartYear FLOAT
ALTER COLUMN salary FLOAT
ALTER COLUMN inflationAdjsalary FLOAT


-- Deleting Duplicates from table

SELECT playerName, seasonStartYear, salary, inflationAdjSalary, count(*) as CNT
from NBA_Salaries
group by playerName, seasonStartYear, salary, inflationAdjSalary
having count(*) > 1

-- All 2021 stats are duplicate for each player. We will delete them using a CTE

WITH CTE_Salaries AS (SELECT playerName, seasonStartYear, salary, inflationAdjSalary, ROW_NUMBER() OVER (PARTITION BY playername, seasonstartyear, salary ORDER BY playername) ranking
FROM NBA_Salaries)

delete from CTE_Salaries
where ranking > 1

-- Checking duplicates were removed

SELECT playerName, seasonStartYear, salary, inflationAdjSalary, count(*) as CNT
from NBA_Salaries
group by playerName, seasonStartYear, salary, inflationAdjSalary
having count(*) > 1

-- Checking the total season played by each player

SELECT playerName, count(seasonstartyear) as SeasonsPlayed
FROM NBA_Salaries
group by playerName
order by SeasonsPlayed desc

-- Checking the amount of players that played n seasons.

--WITH Nseasons AS
--(SELECT playerName, count(seasonstartyear) as SeasonsPlayed
--FROM NBA_Salaries
--group by playerName)

--Select SeasonsPlayed, count(playername) PlayerCount
--from Nseasons
--group by SeasonsPlayed
--order by SeasonsPlayed desc

-- Checking the total amount of salaries players earned in their carreers.

WITH playersTotalSalary as
(SELECT playerName, SUM(salary) as SalaryTotals, SUM(inflationadjSalary) as SalaryTotalsADJ, count(seasonstartyear) as SeasonsPlayed
FROM NBA_Salaries
group by playerName)

Select * from playersTotalSalary
order by SalaryTotalsADJ desc

-- Checking the avg salary per season

WITH playersTotalSalary as
(SELECT playerName, SUM(salary) as SalaryTotals, SUM(inflationadjSalary) as SalaryTotalsADJ, count(seasonstartyear) as SeasonsPlayed
FROM NBA_Salaries
group by playerName)

Select playerName , CAST(SalaryTotals/SeasonsPlayed as INT) avgSalaryPerSeason, CAST(SalaryTotalsADJ/SeasonsPlayed as INT) avgSalaryPerSeasonADJ, SeasonsPlayed from playersTotalSalary
order by avgSalaryPerSeason desc

-- Checking the amount of salaries payed in each year, how many players were payed and average pay per player.

WITH CTE AS
(SELECT seasonStartYear, sum(salary) SalariesPayed, SUM(inflationAdjSalary) SalariesPayedADJ, count(playername) totalplayers
From NBA_Salaries
group by seasonStartYear)

SELECT *, CAST(SalariesPayed/totalplayers AS INT) SalaryPerPlayer, CAST(salariesPayedADJ/totalplayers AS INT) SalaryPerPlayerADJ
FROM CTE
order by SalaryPerPlayer desc

-- Checking the total amount of salaries payed and the average pay per player

WITH GlobalTotals AS
(SELECT count(playername) TotalPlayers, SUM(salary) TotalSalaries, SUM(inflationADJSalary) TotalSalariesADJ 
FROM NBA_Salaries)

Select *, CAST(TotalSalaries/TotalPlayers as INT) SalaryperPlayer, CAST(TotalSalariesADJ/TotalPlayers as INT) SalaryperPlayerADJ
From GlobalTotals



-- Creating new table for total salaries by year

CREATE TABLE Salaries_by_year(seasonStartYear FLOAT, TotalSalaries FLOAT, TotalSalariesADJ FLOAT)


INSERT INTO Salaries_by_year(seasonStartYear, TotalSalaries, TotalSalariesADJ)
SELECT seasonStartYear, sum(salary), SUM(inflationADJSalary)
from NBA_Salaries
group by seasonStartYear

SELECT * FROM Salaries_by_year


-- Checking the % each player received from the total Salaries per year

SELECT a.playerName, a.seasonStartYear, a.salary, a.inflationAdjSalary, b.TotalSalaries ,a.salary/b.totalsalaries *100 as PCTSalary, a.inflationAdjSalary/b.totalsalariesADJ *100 as PCTSalaryADJ
FROM NBA_Salaries a
INNER JOIN Salaries_by_year b
ON a.seasonStartYear = b.seasonStartYear
order by seasonStartYear desc, PCTSalary desc


--CREATING ALL VIEWS FOR FUTURE DASHBOARD

--VIEW 1
CREATE VIEW Seasons_played_by_player AS
SELECT playerName, count(seasonstartyear) as SeasonsPlayed
FROM NBA_Salaries
group by playerName

--VIEW 2
CREATE VIEW  Players_Salaries_TOTAL as
WITH playersTotalSalary as
(SELECT playerName, SUM(salary) as SalaryTotals, SUM(inflationadjSalary) as SalaryTotalsADJ, count(seasonstartyear) as SeasonsPlayed
FROM NBA_Salaries
group by playerName)

Select * from playersTotalSalary

-- VIEW 3
CREATE VIEW Player_avg_salary AS 
WITH playersTotalSalary as
(SELECT playerName, SUM(salary) as SalaryTotals, SUM(inflationadjSalary) as SalaryTotalsADJ, count(seasonstartyear) as SeasonsPlayed
FROM NBA_Salaries
group by playerName)

Select playerName , CAST(SalaryTotals/SeasonsPlayed as INT) avgSalaryPerSeason, CAST(SalaryTotalsADJ/SeasonsPlayed as INT) avgSalaryPerSeasonADJ, SeasonsPlayed from playersTotalSalary

--VIEW 4

CREATE VIEW Total_salary_by_year_player AS

WITH CTE AS
(SELECT seasonStartYear, sum(salary) SalariesPayed, SUM(inflationAdjSalary) SalariesPayedADJ, count(playername) totalplayers
From NBA_Salaries
group by seasonStartYear)

SELECT *, CAST(SalariesPayed/totalplayers AS INT) SalaryPerPlayer, CAST(salariesPayedADJ/totalplayers AS INT) SalaryPerPlayerADJ
FROM CTE

--VIEW 5

CREATE VIEW TOTAL_Salary AS

WITH GlobalTotals AS
(SELECT count(playername) TotalPlayers, SUM(salary) TotalSalaries, SUM(inflationADJSalary) TotalSalariesADJ 
FROM NBA_Salaries)

Select *, CAST(TotalSalaries/TotalPlayers as INT) SalaryperPlayer, CAST(TotalSalariesADJ/TotalPlayers as INT) SalaryperPlayerADJ
From GlobalTotals

--VIEW 6

CREATE VIEW PCT_salary_by_year AS

SELECT a.playerName, a.seasonStartYear, a.salary, a.inflationAdjSalary, b.TotalSalaries ,a.salary/b.totalsalaries *100 as PCTSalary, a.inflationAdjSalary/b.totalsalariesADJ *100 as PCTSalaryADJ
FROM NBA_Salaries a
INNER JOIN Salaries_by_year b
ON a.seasonStartYear = b.seasonStartYear




