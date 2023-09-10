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
)

SELECT
	depart.nome AS "Departamento",
	emp.nome AS "Empregado",
	table_salarios.salario AS "Salario Bruto",
	table_descontos.total_descontos AS "Total Desconto",
	table_salarios.salario - table_descontos.total_descontos AS "Salario Liquidoaws"
FROM
	departamento AS depart
	INNER JOIN divisao div ON depart.cod_dep = div.cod_dep
	INNER JOIN empregado emp ON div.cod_divisao = emp.lotacao_div
	LEFT JOIN total_salario_table AS table_salarios ON emp.matr = table_salarios.matr
	LEFT JOIN total_descontos_table AS table_descontos ON emp.matr = table_descontos.matr
GROUP BY
	depart.nome,
	emp.nome,
	table_salarios.salario,
	table_descontos.total_descontos,
	"Salario Liquidoaws"
ORDER BY
  "Salario Liquidoaws" DESC,
  emp.nome DESC;

