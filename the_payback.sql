SELECT DISTINCT ON (c.name)
    c.name,
    c.investment,
    o.month AS month_of_payback,
    CASE
        WHEN accumulated >= c.investment THEN accumulated - c.investment
        ELSE 0
    END AS "return"
FROM
    clients AS c
JOIN (
    SELECT
        client_id,
        month,
        SUM(profit) OVER (PARTITION BY client_id ORDER BY month) AS accumulated
    FROM
        operations
) 
AS o ON c.id = o.client_id
WHERE
    accumulated >= c.investment
ORDER BY c.name, accumulated;

