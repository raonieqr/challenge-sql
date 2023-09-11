WITH total_descontos_table AS (
	SELECT
		e.matr,
		COALESCE(SUM(d.valor),
			0) AS total_descontos
	FROM
		empregado AS e
	LEFT JOIN emp_desc AS ed ON e.matr = ed.matr
	LEFT JOIN desconto AS d ON ed.cod_desc = d.cod_desc
GROUP BY
	e.matr
),
total_salario_table AS (
	SELECT
		emp.matr,
		COALESCE(SUM(v.valor),
			0) AS salario
	FROM
		empregado AS emp
	LEFT JOIN emp_venc AS ev ON emp.matr = ev.matr
	LEFT JOIN vencimento AS v ON ev.cod_venc = v.cod_venc
GROUP BY
	emp.matr
), div_avg AS (
	SELECT
		div.nome,
		div.cod_dep,
		div.cod_divisao,
		ROUND(AVG(table_salarios.salario), 2) AS "media"
	
	FROM
		departamento AS depart
		INNER JOIN divisao div ON depart.cod_dep = div.cod_dep
		INNER JOIN empregado emp ON div.cod_divisao = emp.lotacao_div
		LEFT JOIN total_salario_table AS table_salarios ON emp.matr = table_salarios.matr
		LEFT JOIN total_descontos_table AS table_descontos ON emp.matr = table_descontos.matr
	GROUP BY
		div.nome,
		div.cod_dep,
		div.cod_divisao

), depart_all AS (
	SELECT
		depart.nome AS departamento,
		depart.cod_dep,
		ROUND(AVG(table_salarios.salario), 2) AS "media"
	
	FROM
		departamento AS depart
		INNER JOIN divisao div ON depart.cod_dep = div.cod_dep
		INNER JOIN empregado emp ON div.cod_divisao = emp.lotacao_div
		LEFT JOIN total_salario_table AS table_salarios ON emp.matr = table_salarios.matr
		LEFT JOIN total_descontos_table AS table_descontos ON emp.matr = table_descontos.matr
	WHERE depart.cod_dep = div.cod_dep
	GROUP BY
		depart.nome,
		depart.cod_dep
	)
	
	
SELECT departamento, nome AS divisao, media
FROM (
    SELECT da.departamento, dv.nome,
        ROUND(AVG(table_salarios.salario - table_descontos.total_descontos), 2) AS media,
        RANK() OVER (PARTITION BY da.departamento ORDER BY dv.media DESC) AS ranking_div_avg
    FROM div_avg AS dv
    JOIN depart_all AS da ON dv.cod_dep = da.cod_dep
    INNER JOIN empregado emp ON dv.cod_divisao = emp.lotacao_div
    LEFT JOIN total_salario_table AS table_salarios ON emp.matr = table_salarios.matr
    LEFT JOIN total_descontos_table AS table_descontos ON emp.matr = table_descontos.matr
    GROUP BY da.departamento, dv.nome, dv.media, da.media
) AS final_table
ORDER BY ranking_div_avg ASC, nome ASC
LIMIT 3;
