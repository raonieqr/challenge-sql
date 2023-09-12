SELECT temperature, COUNT(*) AS number_of_records 
FROM (
  		SELECT records.*
        FROM records
) AS all_results
GROUP BY temperature, mark ORDER BY mark;
