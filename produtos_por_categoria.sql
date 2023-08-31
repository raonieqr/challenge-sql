SELECT c.name, SUM(p.amount) AS sum
FROM categories AS c
JOIN products AS p ON c.id = p.id_categories
GROUP BY c.name;
