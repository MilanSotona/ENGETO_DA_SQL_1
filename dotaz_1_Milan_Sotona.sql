/* Otázka 1 
 * Rostou v průběhu let mzdy ve všech odvětvích nebo v některých klesají?
 * Pro odpověď použit SELECT ve verzi A2 od řádku 67
 * verze A1
 * Mzdy jsou rozděleny do 19 odvětví.
 * Řešení:
 * SELECT vytvoří tabulku pro všechna odvětví a roky se změnou proti minulému roku (první rok je NULL)
 * podle nastavení WHERE lze vybrat roky, kdy došlo k poklesu, významnému růstu atd.
 */
WITH t_diff AS 
/* WHERE nešlo dát do SELECT kde je window funkce, tak to je ve 2 krocích přes CTE */
(
    SELECT branch_name 
           ,`year`
           ,branch_avg_wage
           ,branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)) AS difference_CZK
           ,round(((branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`))) * 100) 
                   / (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)), 2) AS percent_change
    FROM t_milan_sotona_project_sql_primary_final
    GROUP BY `year`, branch_name
)
SELECT * FROM t_diff
WHERE difference_CZK < 0
-- WHERE percent_change < -1
-- WHERE percent_change < -5
-- WHERE percent_change > 10
ORDER BY branch_name, `year` -- různé možnosti třídění
-- ORDER BY percent_change
;
/* výstup pro difference_CZK < 0 a třídění podle odvětí a roku: 
branch_name                                                 |year|branch_avg_wage|difference_CZK|percent_change|
------------------------------------------------------------+----+---------------+--------------+--------------+
Administrativní a podpůrné činnosti                         |2013|          16829|          -212|         -1.24|
Činnosti v oblasti nemovitostí                              |2009|          20706|           -84|         -0.40|
Činnosti v oblasti nemovitostí                              |2013|          22152|          -401|         -1.78|
Doprava a skladování                                        |2011|          23062|            -1|          0.00|
Informační a komunikační činnosti                           |2013|          46155|          -486|         -1.04|
Kulturní, zábavní a rekreační činnosti                      |2013|          20511|          -297|         -1.43|
Peněžnictví a pojišťovnictví                                |2013|          46317|         -4484|         -8.83|
Profesní, vědecké a technické činnosti                      |2010|          31602|          -189|         -0.59|
Profesní, vědecké a technické činnosti                      |2013|          31825|          -992|         -3.02|
Stavebnictví                                                |2013|          22379|          -471|         -2.06|
Těžba a dobývání                                            |2009|          28361|          -912|         -3.12|
Těžba a dobývání                                            |2013|          31487|         -1053|         -3.24|
Těžba a dobývání                                            |2014|          31302|          -185|         -0.59|
Těžba a dobývání                                            |2016|          31626|          -183|         -0.58|
Ubytování, stravování a pohostinství                        |2009|          12334|          -138|         -1.11|
Ubytování, stravování a pohostinství                        |2011|          13131|           -74|         -0.56|
Velkoobchod a maloobchod; opravy a údržba motorových vozidel|2013|          23130|          -194|         -0.83|
Veřejná správa a obrana; povinné sociální zabezpečení       |2010|          26944|           -91|         -0.34|
Veřejná správa a obrana; povinné sociální zabezpečení       |2011|          26331|          -613|         -2.28|
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu |2011|          40202|           -94|         -0.23|
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu |2013|          40762|         -1895|         -4.44|
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu |2015|          40453|          -641|         -1.56|
Vzdělávání                                                  |2010|          23023|          -393|         -1.68|
Zásobování vodou; činnosti související s odpady a sanacemi  |2013|          23616|          -102|         -0.43|
Zemědělství, lesnictví, rybářství                           |2009|          17645|          -119|         -0.67| 
 */

-- =============================================================================================================
/* Otázka 1 - verze A2
 * SELECT v dotazu A1 sumarizován za rok, počet výskytů a změnu Kč
 * -------------------------------------------
 * TENTO SELECT použit pro odpověď na otázku 1
 * -------------------------------------------  
 */
WITH t_diff AS 
(
    SELECT branch_name 
           ,`year`
           ,branch_avg_wage
           ,branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)) AS difference_CZK
           ,round(((branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`))) * 100) 
                   / (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)), 2) AS percent_change
    FROM t_milan_sotona_project_sql_primary_final
    GROUP BY `year`, branch_name
)
SELECT `year`
--       ,sum(1) AS pocet
       ,sum(CASE
	            WHEN difference_CZK >= 0 THEN 1
	            ELSE 0       	
            END) AS No_positive
       ,sum(CASE
	            WHEN difference_CZK < 0 THEN 1
	            ELSE 0       	
            END) AS No_negative
       ,sum(CASE
	            WHEN difference_CZK >= 0 THEN difference_CZK
	            ELSE 0       	
            END) AS CZK_positive
       ,sum(CASE
	            WHEN difference_CZK < 0 THEN difference_CZK
	            ELSE 0       	
            END) AS CZK_negative
       ,sum(difference_CZK) AS difference_CZK    
FROM t_diff
GROUP BY `year`
;
/* VÝSLEDEK:
year|No_positive|No_negative|CZK_positive|CZK_negative|difference_CZK|
----+-----------+-----------+------------+------------+--------------+
2006|          0|          0|           0|           0|              |
2007|         19|          0|       27659|           0|         27659|
2008|         19|          0|       33067|           0|         33067|
2009|         15|          4|       15476|       -1253|         14223|
2010|         16|          3|        9799|        -673|          9126|
2011|         15|          4|       12130|        -782|         11348|
2012|         19|          0|       14585|           0|         14585|
2013|          8|         11|        2618|      -10587|         -7969|
2014|         18|          1|       13164|        -185|         12979|
2015|         18|          1|       14069|        -641|         13428|
2016|         18|          1|       19482|        -183|         19299|
2017|         19|          0|       33917|           0|         33917|
2018|         19|          0|       44938|           0|         44938|
 */

-- =============================================================================================================
/* Otázka 1 - verze B
 * Rostou v průběhu let mzdy ve všech odvětvích nebo v některých klesají?
 * SELECT pro vytvoření 1 řádku s údaji pro první a poslední rok dle odvětví
 * takže v tomto případě je ve výstupním SELECT 19 řádků = pro každé odvětví 1 řádek
 */
WITH t_wages AS (
    SELECT `year` 
           ,branch_name 
           ,branch_avg_wage
           ,branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)) AS difference
           ,round(((branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`))) * 100) 
                   / (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)), 2) AS percent_change
    FROM t_milan_sotona_project_sql_primary_final
    GROUP BY `year`, branch_name
    ORDER BY branch_name, `year`
)
SELECT t1.branch_name
       ,t2.branch_avg_wage_last - t1.branch_avg_wage_first AS wage_change
       ,round(((t2.branch_avg_wage_last - t1.branch_avg_wage_first)*100) / t1.branch_avg_wage_first,2) AS percent_change 
       ,t1.year_first 
       ,t2.year_last
       ,t1.branch_avg_wage_first 
       ,t2.branch_avg_wage_last
FROM 
    (
	SELECT `year` AS year_first 
	       ,branch_name
	       ,branch_avg_wage AS branch_avg_wage_first
	FROM t_wages
	WHERE `year` = (SELECT min(`year`) 
                    FROM t_wages)
    ) t1
JOIN 
    (
	SELECT `year` AS year_last 
	       ,branch_name
	       ,branch_avg_wage AS branch_avg_wage_last
	FROM t_wages
	WHERE `year` = (SELECT max(`year`)
                    FROM t_wages)
    ) t2
ON t1.branch_name = t2.branch_name
ORDER BY percent_change DESC 
;
/* výstup: tříděno od největší změny mezd
 * je zřejmé, že mezi roky 2006 a 2018 nemohlo dojít k poklesu mezd
 * dotaz ukazuje nárůsty mezd podle odvětví
branch_name                                                 |wage_change|percent_change|year_first|year_last|branch_avg_wage_first|branch_avg_wage_last|
------------------------------------------------------------+-----------+--------------+----------+---------+---------------------+--------------------+
Zdravotní a sociální péče                                   |      14821|         77.83|      2006|     2018|                19042|               33863|
Zpracovatelský průmysl                                      |      13408|         72.55|      2006|     2018|                18482|               31890|
Zemědělství, lesnictví, rybářství                           |      10649|         71.87|      2006|     2018|                14818|               25467|
Kulturní, zábavní a rekreační činnosti                      |      11572|         68.77|      2006|     2018|                16827|               28399|
Ubytování, stravování a pohostinství                        |       7596|         65.07|      2006|     2018|                11674|               19270|
Velkoobchod a maloobchod; opravy a údržba motorových vozidel|      11752|         64.49|      2006|     2018|                18223|               29975|
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu |      17164|         58.76|      2006|     2018|                29211|               46375|
Informační a komunikační činnosti                           |      20935|         58.49|      2006|     2018|                35793|               56728|
Profesní, vědecké a technické činnosti                      |      14340|         58.19|      2006|     2018|                24645|               38985|
Stavebnictví                                                |      10317|         57.80|      2006|     2018|                17850|               28167|
Vzdělávání                                                  |      11413|         56.98|      2006|     2018|                20030|               31443|
Veřejná správa a obrana; povinné sociální zabezpečení       |      13028|         55.95|      2006|     2018|                23285|               36313|
Zásobování vodou; činnosti související s odpady a sanacemi  |       9984|         53.28|      2006|     2018|                18740|               28724|
Doprava a skladování                                        |      10203|         52.98|      2006|     2018|                19257|               29460|
Těžba a dobývání                                            |      11972|         49.74|      2006|     2018|                24067|               36039|
Činnosti v oblasti nemovitostí                              |       8867|         46.08|      2006|     2018|                19242|               28109|
Administrativní a podpůrné činnosti                         |       6510|         45.07|      2006|     2018|                14444|               20954|
Ostatní činnosti                                            |       7213|         43.76|      2006|     2018|                16484|               23697|
Peněžnictví a pojišťovnictví                                |      14856|         37.11|      2006|     2018|                40027|               54883|
*/