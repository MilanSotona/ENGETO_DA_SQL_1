/* otázka 5
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP
 * vzroste výraznějí v jednom roce, projeví se to na cenách potravin či mzdách ve
 * stejném nebo následujícím roce výraznějším růstem?
 */
WITH t1 AS -- kumulace: pro každý rok 1 řádek
(
	SELECT `year`
	       ,round(avg(product_avg_price),2) AS avg_price
	       ,round(avg(branch_avg_wage),0) AS avg_wage
	       ,avg(GDP_person) AS GDP_person
	FROM t_milan_sotona_project_sql_primary_final 
	GROUP BY `year`
)
SELECT `year`
       ,avg_price
       ,round((avg_price - lag(avg_price) OVER (ORDER BY `year`))/lag(avg_price) OVER (ORDER BY `year`)*100,2) AS avg_price_change
       ,avg_wage
       ,round((avg_wage - lag(avg_wage) OVER (ORDER BY `year`))/lag(avg_wage) OVER (ORDER BY `year`)*100,2) AS avg_wage_change
       ,GDP_person
       ,round((GDP_person - lag(GDP_person) OVER (ORDER BY `year`))/lag(GDP_person) OVER (ORDER BY `year`)*100,2) AS GDP_change              
FROM t1;



-- taky by šel následující SELECT, výsledek je stejný, protože GDP_person je pro `year` všude stejné
SELECT `year`, 
       round(avg(product_avg_price),2) AS avg_price, 
       round(avg(branch_avg_wage),0) AS avg_wage, 
       GDP_person
FROM t_milan_sotona_project_sql_primary_final 
GROUP BY `year`, GDP_person;

