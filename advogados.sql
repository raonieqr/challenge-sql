WITH max AS (
	SELECT
		"name",
		customers_number
	FROM
		lawyers
	WHERE
		customers_number = (SELECT MAX(customers_number) FROM lawyers)
),
min AS (
	SELECT
		"name",
		customers_number
	FROM
		lawyers
	WHERE
		customers_number = (SELECT MIN(customers_number) FROM lawyers)
),
"avg" AS (
	SELECT
		'AVERAGE' AS name,
		((SELECT MIN(customers_number) FROM lawyers) + (SELECT MAX(customers_number) FROM lawyers)) / 2 AS customers_number
)
SELECT
    "name",
    customers_number
FROM (
    SELECT
        "name",
        customers_number,
        1 AS ord
    FROM
        max
    UNION
    SELECT
        "name",
        customers_number,
        2 AS ord
    FROM
        min
    UNION
    SELECT
        'Average' AS "name",
        customers_number,
        3 AS ord
    FROM
        "avg"
) AS concat
ORDER BY ord;
