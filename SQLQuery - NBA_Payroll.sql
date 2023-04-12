USE NBAProject

-- Selecting all data
select * from NBA_Payroll

-- Changing seasonStartYear, payroll and inflationAdjPayroll to FLOAT

ALTER TABLE NBA_PAYROLL
ALTER COLUMN seasonStartYear FLOAT
ALTER COLUMN payroll FLOAT
ALTER COLUMN inflationAdjPayroll FLOAT

-- Deleting Duplicates from table

SELECT team, seasonStartYear, payroll, inflationAdjPayroll, count(*) as CNT
from NBA_Payroll
group by team, seasonStartYear, payroll, inflationAdjPayroll
having count(*) > 1

-- All 2021 stats are duplicate for each franchise. We will delete them using a CTE

WITH CTE_payroll AS (SELECT f1, team, seasonStartYear, payroll, inflationAdjPayroll, ROW_NUMBER() OVER (PARTITION BY f1, team, seasonstartyear, payroll ORDER BY team) ranking
FROM NBA_Payroll)

delete from CTE_payroll
where ranking > 1

-- Checking Duplicates where removed:

SELECT team, seasonStartYear, payroll, inflationAdjPayroll, count(*) as CNT
from NBA_Payroll
group by team, seasonStartYear, payroll, inflationAdjPayroll
having count(*) > 1

-- Grouping Payroll and adjusted payroll from all teams by year

Select seasonStartYear, SUM(payroll) as Payroll, SUM(inflationAdjPayroll) as Payroll_InflationADJ
from NBA_Payroll
group by seasonStartYear
order by Payroll_InflationADJ desc

Select seasonStartYear, SUM(payroll) as Payroll, SUM(inflationAdjPayroll) as Payroll_InflationADJ
from NBA_Payroll
group by seasonStartYear
order by Payroll desc

-- Grouping Payroll and adjusted payroll by team

Select team, SUM(payroll) as Payroll, SUM(inflationAdjPayroll) as Payroll_InflationADJ
from NBA_Payroll
group by team
order by Payroll desc

Select team, SUM(payroll) as Payroll, SUM(inflationAdjPayroll) as Payroll_InflationADJ
from NBA_Payroll
group by team
order by Payroll_InflationADJ desc

-- Percentage of team's payroll vs total payroll by year. I will create a new table that shows the total payroll for each year and join the totals column to nba_payroll

CREATE TABLE payroll_by_year(seasonStartYear float, TotalPayroll float)

INSERT INTO payroll_by_year(seasonStartYear, TotalPayroll)
SELECT b.seasonStartYear, sum(b.payroll)
from NBA_Payroll b
group by seasonStartYear

	-- Final query. I filtered by 2020 as an example. Column total_yearly_payroll is added to make sure the value y correct.
SELECT a.team, a.seasonStartYear, a.payroll, b.total_yearly_payroll, a.payroll/b.total_yearly_payroll * 100 as PCT_Payroll FROM NBA_Payroll a
INNER JOIN payroll_by_year b
ON a.seasonStartYear = b.seasonStartYear
WHERE a.seasonStartYear = 2020


-- Checking total payroll by teams vs total payroll for all years to see if there's any difference in percentage compared to year on year. I will use a CTE

WITH teams_PCT_Payroll as
(SELECT a.team, sum(a.payroll) totalpayroll, sum(b.total_yearly_payroll) all_years_payroll
FROM NBA_Payroll a
INNER JOIN payroll_by_year b
ON a.seasonStartYear = b.seasonStartYear
group by a.team)

SELECT team, totalpayroll, all_years_payroll, totalpayroll/all_years_payroll * 100 as PCT_payroll
FROM teams_PCT_Payroll


--VIEW 1

CREATE VIEW yearly_payroll as
Select seasonStartYear, SUM(payroll) as Payroll, SUM(inflationAdjPayroll) as Payroll_InflationADJ
from NBA_Payroll
group by seasonStartYear

--VIEW 2

CREATE VIEW payroll_by_team AS
Select team, SUM(payroll) as Payroll, SUM(inflationAdjPayroll) as Payroll_InflationADJ
from NBA_Payroll
group by team

--VIEW 3

CREATE VIEW teams_pct_payroll_by_year AS
SELECT a.team, a.seasonStartYear, a.payroll, b.total_yearly_payroll, a.payroll/b.total_yearly_payroll * 100 as PCT_Payroll FROM NBA_Payroll a
INNER JOIN payroll_by_year b
ON a.seasonStartYear = b.seasonStartYear
WHERE a.seasonStartYear = 2020

--VIEW 4

CREATE VIEW team_yearlypayroll_vs_totalpayroll AS
WITH teams_PCT_Payroll as
(SELECT a.team, sum(a.payroll) totalpayroll, sum(b.total_yearly_payroll) all_years_payroll
FROM NBA_Payroll a
INNER JOIN payroll_by_year b
ON a.seasonStartYear = b.seasonStartYear
group by a.team)

SELECT team, totalpayroll, all_years_payroll, totalpayroll/all_years_payroll * 100 as PCT_payroll
FROM teams_PCT_Payroll


