/* otázka 5
 * Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP
 * vzroste výraznějí v jednom roce, projeví se to na cenách potravin či mzdách ve
 * stejném nebo následujícím roce výraznějším růstem?
 */
SELECT `year`, 
       round(avg(product_avg_price),2) AS avg_price, 
       round(avg(branch_avg_wage),0) AS avg_wage, 
       avg(GDP_person) AS GDP_person
FROM t_milan_sotona_project_sql_primary_final 
GROUP BY `year`;

-- taky by šel následující SELECT, výsledek je stejný, protože GDP_person je pro `year` všude stejné
SELECT `year`, 
       round(avg(product_avg_price),2) AS avg_price, 
       round(avg(branch_avg_wage),0) AS avg_wage, 
       GDP_person
FROM t_milan_sotona_project_sql_primary_final 
GROUP BY `year`, GDP_person;

