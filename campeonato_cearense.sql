WITH team_all AS (
	SELECT t1.name AS team_1_name, m.team_1_goals, m.team_2_goals, t2.name AS team_2_name
	FROM matches AS m
	JOIN teams AS t1 ON m.team_1 = t1.id
	JOIN teams AS t2 ON m.team_2 = t2.id
), matches AS (
	SELECT team_1_name AS team_name, COUNT(*) AS total
	FROM team_all
	GROUP BY team_1_name
	UNION
	SELECT team_2_name AS team_name, COUNT(*) AS total
	FROM team_all
	GROUP BY team_2_name
),
results_team AS (
	SELECT *,
	  CASE
	    WHEN team_1_goals > team_2_goals THEN 1
	    WHEN team_1_goals < team_2_goals THEN 2
	    WHEN team_1_goals = team_2_goals THEN 3
	    ELSE 0
	    END AS results
	FROM team_all
), victories AS (
	SELECT t2.name AS team_name,
       SUM(COALESCE(t1.victories, 0) + COALESCE(t2.victories, 0)) AS total
	FROM (
	  SELECT team_1_name AS name, COUNT(*) AS victories
	  FROM results_team
	  WHERE results = 1
	  GROUP BY team_1_name
	) AS t1
	RIGHT JOIN (
	  SELECT team_2_name AS name, COUNT(*) AS victories
	  FROM results_team
	  WHERE results = 2
	  GROUP BY team_2_name
	) AS t2 ON t1.name = t2.name
	GROUP BY team_name

), draw AS (
	SELECT 
	  COALESCE(t1.name, t2.name) AS team_name,
	  SUM(COALESCE(t1.victories, 0) + COALESCE(t2.victories, 0)) AS total
	FROM (
	  SELECT team_1_name AS name, COUNT(*) AS victories
	  FROM results_team
	  WHERE results = 3
	  GROUP BY team_1_name
	) AS t1
	FULL OUTER JOIN (
	  SELECT team_2_name AS name, COUNT(*) AS victories
	  FROM results_team
	  WHERE results = 3
	  GROUP BY team_2_name
	) AS t2 ON t1.name = t2.name
	GROUP BY team_name, t1.name, t2.name
)

SELECT 
  matches.team_name AS name,
  SUM(matches.total) AS matches,
  COALESCE(victories.total, 0) AS victories,
  ((SUM(matches.total) - COALESCE(victories.total, 0)) - COALESCE(draw.total, 0)) AS defeats,
  COALESCE(draw.total, 0) AS draws,
  CASE
  	WHEN COALESCE((victories.total), 0) = 1 THEN 3
  	ELSE COALESCE((victories.total * 3 + draw.total), 0)
  END AS score
FROM matches
LEFT JOIN victories ON matches.team_name = victories.team_name
LEFT JOIN draw ON matches.team_name = draw.team_name
GROUP BY name, victories.total, draw.total
ORDER BY victories DESC;

