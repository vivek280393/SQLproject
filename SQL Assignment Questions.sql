1.	Find how many drawn games were played in each season

SELECT Season, count(*) AS Drawn_Games FROM [Practice Database].[dbo].[EPL Data]
where Home_Score = Away_Score 
Group by Season 

2.	Find the league winner in each season--

WITH TeamPoints AS (
    SELECT Season, Team, SUM(Points) AS TotalPoints, SUM(Goals_Scored) AS Goals_Scored, SUM(Goals_Conceded) AS Goals_Conceded
    FROM (
        SELECT Season, Home_Team AS Team,
            CASE
                WHEN Home_Score > Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Home_Score AS Goals_Scored,
            Away_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
        UNION ALL
        SELECT Season, Away_Team AS Team,
            CASE
                WHEN Home_Score < Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Away_Score AS Goals_Scored,
            Home_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
    ) AS All_Matches
    GROUP BY Season, Team
),
TeamRank AS (
    SELECT Season, Team, TotalPoints, Goals_Scored, Goals_Conceded,
        RANK() OVER (PARTITION BY Season ORDER BY TotalPoints DESC, (Goals_Scored - Goals_Conceded) DESC, Goals_Scored DESC, Away_Goals DESC) AS Rank
    FROM (
        SELECT tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded,
            SUM(CASE
                WHEN ed.Home_Team = tp.Team THEN ed.Away_Score
                WHEN ed.Away_Team = tp.Team THEN ed.Home_Score
                ELSE 0
            END) AS Away_Goals
        FROM TeamPoints tp
        JOIN [Practice Database].dbo.[EPL Data] ed ON tp.Season = ed.Season
                                                AND (tp.Team = ed.Home_Team OR tp.Team = ed.Away_Team)
        GROUP BY tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded
    ) AS TeamStats
)
SELECT Season, Team AS League_Winners
FROM TeamRank
WHERE Rank = 1
ORDER BY Season;



3.	Find the team with most goals scored in each season and their rank

WITH CTE AS (
SELECT Season, Home_Team AS Team, SUM(Home_Score) AS Goals from [Practice Database].dbo.[EPL Data]
group by Season, Home_Team
UNION
SELECT Season, Away_Team AS Team, SUM(Away_Score) AS Goals from [Practice Database].dbo.[EPL Data]
group by Season, Away_Team)
, CTE2 AS (SELECT Season, Team, SUM(Goals) AS TotalGoals
FROM CTE
Group by Season, Team)
, CTE3 AS (SELECT *,
RANK() OVER(PARTITION BY Season ORDER BY TotalGoals DESC) AS RANK
FROM CTE2)
, CTE4 AS (SELECT *FROM CTE3
WHERE RANK = 1),
TeamPoints AS (
    SELECT Season, Team, SUM(Points) AS TotalPoints, SUM(Goals_Scored) AS Goals_Scored, SUM(Goals_Conceded) AS Goals_Conceded
    FROM (
        SELECT Season, Home_Team AS Team,
            CASE
                WHEN Home_Score > Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Home_Score AS Goals_Scored,
            Away_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
        UNION ALL
        SELECT Season, Away_Team AS Team,
            CASE
                WHEN Home_Score < Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Away_Score AS Goals_Scored,
            Home_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
    ) AS All_Matches
    GROUP BY Season, Team
),
TeamRank AS (
    SELECT Season, Team, TotalPoints, Goals_Scored, Goals_Conceded,
        RANK() OVER (PARTITION BY Season ORDER BY TotalPoints DESC, (Goals_Scored - Goals_Conceded) DESC, Goals_Scored DESC, Away_Goals DESC) AS Rank
    FROM (
        SELECT tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded,
            SUM(CASE
                WHEN ed.Home_Team = tp.Team THEN ed.Away_Score
                WHEN ed.Away_Team = tp.Team THEN ed.Home_Score
                ELSE 0
            END) AS Away_Goals
        FROM TeamPoints tp
        JOIN [Practice Database].dbo.[EPL Data] ed ON tp.Season = ed.Season
                                                AND (tp.Team = ed.Home_Team OR tp.Team = ed.Away_Team)
        GROUP BY tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded
    ) AS TeamStats
)
select c.Season, c.Team, totalgoals, TotalPoints, t.Rank
from TeamRank t join CTE4 c on t.Season = c.Season AND t.Team= c.Team


4.	Find the team with least goals conceded in each season and their rank

WITH TeamPoints AS (
    SELECT Season, Team, SUM(Points) AS TotalPoints, SUM(Goals_Scored) AS Goals_Scored, SUM(Goals_Conceded) AS Goals_Conceded
    FROM (
        SELECT Season, Home_Team AS Team,
            CASE
                WHEN Home_Score > Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Home_Score AS Goals_Scored,
            Away_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
        UNION ALL
        SELECT Season, Away_Team AS Team,
            CASE
                WHEN Home_Score < Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Away_Score AS Goals_Scored,
            Home_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
    ) AS All_Matches
    GROUP BY Season, Team
),
TeamRank AS (
    SELECT Season, Team, TotalPoints, Goals_Scored, Goals_Conceded,
        RANK() OVER (PARTITION BY Season ORDER BY Goals_Conceded ASC) AS Rank_LeastGoalConceded,
		RANK() OVER (PARTITION BY Season ORDER BY TotalPoints DESC, (Goals_Scored - Goals_Conceded) DESC, Goals_Scored DESC, Away_Goals DESC) AS Rank
    FROM (
        SELECT tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded,
            SUM(CASE
                WHEN ed.Home_Team = tp.Team THEN ed.Away_Score
                WHEN ed.Away_Team = tp.Team THEN ed.Home_Score
                ELSE 0
            END) AS Away_Goals
        FROM TeamPoints tp
        JOIN [Practice Database].dbo.[EPL Data] ed ON tp.Season = ed.Season
                                                AND (tp.Team = ed.Home_Team OR tp.Team = ed.Away_Team)
        GROUP BY tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded
    ) AS TeamStats
)
SELECT Season, Team, Goals_Conceded AS LeastGoalConceded, TotalPoints, Rank
FROM TeamRank
WHERE Rank_LeastGoalConceded = 1
ORDER BY Season;

5.	Find the team with the most away wins in each season

WITH CTE AS (
select Season, Away_Team from [Practice Database].dbo.[EPL Data]
Where Away_Score > Home_Score)
, CTE2 AS (SELECT *, COUNT(Away_Team) AS TotalAwayWins FROM CTE
Group By Season, Away_Team)
, CTE3 AS (SELECT *, RANK() OVER(PARTITION BY Season ORDER BY TotalAwayWins DESC) as Rank_No FROM CTE2)
SELECT Season, Away_Team AS Team, TotalAwayWins FROM CTE3
WHERE Rank_No = 1

6.	Find the team which got relegated most number of times between 2014-2015 to 2020-2021 seasons

WITH TeamPoints AS (
    SELECT Season, Team, SUM(Points) AS TotalPoints, SUM(Goals_Scored) AS Goals_Scored, SUM(Goals_Conceded) AS Goals_Conceded
    FROM (
        SELECT Season, Home_Team AS Team,
            CASE
                WHEN Home_Score > Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Home_Score AS Goals_Scored,
            Away_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
        UNION ALL
        SELECT Season, Away_Team AS Team,
            CASE
                WHEN Home_Score < Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Away_Score AS Goals_Scored,
            Home_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
    ) AS All_Matches
    GROUP BY Season, Team
),
TeamRank AS (
    SELECT Season, Team, TotalPoints, Goals_Scored, Goals_Conceded,
        RANK() OVER (PARTITION BY Season ORDER BY TotalPoints DESC, (Goals_Scored - Goals_Conceded) DESC, Goals_Scored DESC, Away_Goals DESC) AS Rank
    FROM (
        SELECT tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded,
            SUM(CASE
                WHEN ed.Home_Team = tp.Team THEN ed.Away_Score
                WHEN ed.Away_Team = tp.Team THEN ed.Home_Score
                ELSE 0
            END) AS Away_Goals
        FROM TeamPoints tp
        JOIN [Practice Database].dbo.[EPL Data] ed ON tp.Season = ed.Season
                                                AND (tp.Team = ed.Home_Team OR tp.Team = ed.Away_Team)
        GROUP BY tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded
    ) AS TeamStats
)
, CTE AS (SELECT Season, Team
FROM TeamRank
WHERE Rank IN (18,19,20))
,CTE2 as(select Team, COUNT(Team) AS RelegateCount,
Rank() OVER (ORDER BY COUNT(Team) DESC) AS Rank_No from CTE
Group By Team)
select Team AS Most_No_of_Times_RelegatedTeams from CTE2
Where Rank_No = 1

7.	Find the teams which got selected to play in Champions League the most number of times between 2014-2015 to 2020-2021 seasons

WITH TeamPoints AS (
    SELECT Season, Team, SUM(Points) AS TotalPoints, SUM(Goals_Scored) AS Goals_Scored, SUM(Goals_Conceded) AS Goals_Conceded
    FROM (
        SELECT Season, Home_Team AS Team,
            CASE
                WHEN Home_Score > Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Home_Score AS Goals_Scored,
            Away_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
        UNION ALL
        SELECT Season, Away_Team AS Team,
            CASE
                WHEN Home_Score < Away_Score THEN 3
                WHEN Home_Score = Away_Score THEN 1
                ELSE 0
            END AS Points,
            Away_Score AS Goals_Scored,
            Home_Score AS Goals_Conceded
        FROM [Practice Database].dbo.[EPL Data]
    ) AS All_Matches
    GROUP BY Season, Team
),
TeamRank AS (
    SELECT Season, Team, TotalPoints, Goals_Scored, Goals_Conceded,
        RANK() OVER (PARTITION BY Season ORDER BY TotalPoints DESC, (Goals_Scored - Goals_Conceded) DESC, Goals_Scored DESC, Away_Goals DESC) AS Rank
    FROM (
        SELECT tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded,
            SUM(CASE
                WHEN ed.Home_Team = tp.Team THEN ed.Away_Score
                WHEN ed.Away_Team = tp.Team THEN ed.Home_Score
                ELSE 0
            END) AS Away_Goals
        FROM TeamPoints tp
        JOIN [Practice Database].dbo.[EPL Data] ed ON tp.Season = ed.Season
                                                AND (tp.Team = ed.Home_Team OR tp.Team = ed.Away_Team)
        GROUP BY tp.Season, tp.Team, tp.TotalPoints, tp.Goals_Scored, tp.Goals_Conceded
    ) AS TeamStats
)
, CTE AS (SELECT Season, Team
FROM TeamRank
WHERE Rank IN (1,2,3,4))
,CTE2 as(select Team, COUNT(Team) AS ChampionsLeagueCount,
Rank() OVER (ORDER BY COUNT(Team) DESC) AS Rank_No from CTE
Group By Team)
select Team AS Most_No_of_Times_Qualified_To_ChampionsLeague from CTE2
Where Rank_No = 1

8.	Which Team have played most number of drawn games each season

WITH CTE AS (
SELECT Season, Team, COUNT(*) AS DrawnGames
FROM (
    SELECT Season, Home_Team AS Team
    FROM [Practice Database].[dbo].[EPL Data]
    WHERE Home_Score = Away_Score
    UNION ALL
    SELECT Season, Away_Team AS Team
    FROM [Practice Database].[dbo].[EPL Data]
    WHERE Home_Score = Away_Score
) AS T
GROUP BY Season, Team)
, CTE2 AS (SELECT *,
RANK() OVER(PARTITION BY Season ORDER BY DrawnGames DESC) AS Rank_No
FROM CTE)
SELECT Season, Team AS MostDrawnTeam FROM CTE2
WHERE Rank_No = 1
Order By Season ASC 

9.	Which team have scored maximum away goals across seasons

WITH CTE AS (
SELECT Away_Team, SUM(Away_Score) AS TotalAwayGoals FROM [Practice Database].[dbo].[EPL Data]
Group By Away_Team)
, CTE2 AS (select *,
RANK() OVER(ORDER BY TotalAwayGoals DESC) AS Rank_No
from CTE)
SELECT Away_Team AS Team, TotalAwayGoals
from CTE2
WHERE Rank_No = 1

10.	Which season has least number of home goals scored

SELECT Season, SUM(Home_Score) AS LeastHomeGoals FROM [Practice Database].[dbo].[EPL Data]
group by Season
having SUM(Home_Score) = (
SELECT Min(TotalHomeGoals) from
(SELECT SUM(Home_Score) AS TotalHomeGoals FROM [Practice Database].[dbo].[EPL Data]
group by Season) AS CTE
)

















