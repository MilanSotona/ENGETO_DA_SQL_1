/* tvorba tabulky t_milan_sotona_project_SQL_secondary_final
 * obsah: pro země z Evropy a roky 2006-2018 (stejné období jako tabulka _primary_final): HDP=GDP, GINI koeficient a populace
 */
-- Nejprve kontrola: které Evropské země jsou v tabulce countries a nejsou v economies
-- countries: 48 řádků pro continent = 'Europe' 
SELECT * FROM countries c 
LEFT JOIN 
( 
	SELECT DISTINCT country 
	FROM economies 
) e 
ON c.country = e.country  
WHERE c.continent = 'Europe'
      AND e.country IS NULL 
/* výsledek: v tabulce economies je 45 zemí Evropy a 3 nejsou
country                      
-----------------------------
Holy See (Vatican City State)
Northern Ireland             
Svalbard and Jan Mayen       
--> OK, nejedná se o samostatné státy */

CREATE OR REPLACE TABLE t_Milan_Sotona_project_SQL_secondary_final AS
SELECT e.country
       ,e.`year`
       ,round(e.GDP,0) AS GDP
       ,e.gini
       ,e.population
       ,round(e.GDP/e.population,0) AS GDP_person
FROM economies e
JOIN countries c ON e.country = c.country
WHERE c.continent = 'Europe'
      AND e.`year` BETWEEN 2006 AND 2018
ORDER BY e.country, e.`year`;
-- výsledek: 45 zemí * 13 roků = 585 řádků, odpovídá na SELECT      
