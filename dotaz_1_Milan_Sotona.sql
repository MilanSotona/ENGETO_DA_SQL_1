/* Otázka 1 - verze A 
 * Rostou v průběhu let mzdy ve všech odvětvích nebo v některých klesají?
 * Řešení:
 * SELECT vytvoří tabulku pro všechna odvětví a roky se změnou proti minulému roku (první rok je NULL)
 * podle nastavení WHERE lze vybrat roky, kdy došlo k poklesu, významnému růstu atd.
 */
WITH t_diff AS (
    SELECT branch_name, 
           `year`,
           branch_avg_wage,
           branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)) AS difference_CZK,
           round(((branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`))) * 100) 
                   / (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)), 2) AS percent_change
    FROM t_milan_sotona_project_sql_primary_final
    GROUP BY `year`, branch_name
)
/* WHERE nešlo dát do SELECT kde je window funkce, tak to je ve 2 krocích přes CTE */
SELECT * FROM t_diff
WHERE difference_CZK < 0
-- WHERE percent_change < -1
-- WHERE percent_change < -5
-- WHERE percent_change > 10
ORDER BY branch_name, `year`;
/* výstup pro difference_CZK < 0: 
branch_name                                                 |year|branch_avg_wage|difference_CZK|percent_change|
------------------------------------------------------------+----+---------------+--------------+--------------+
Administrativní a podpůrné činnosti                         |2013|          16829|          -212|         -1.24|
Činnosti v oblasti nemovitostí                              |2009|          20706|           -84|         -0.40|
Činnosti v oblasti nemovitostí                              |2013|          22152|          -401|         -1.78|
Doprava a skladování                                        |2011|          23062|            -1|          0.00|
Informační a komunikační činnosti                           |2013|          46155|          -486|         -1.04|
Kulturní, zábavní a rekreační činnosti                      |2013|          20511|          -297|         -1.43|
Peněžnictví a pojišťovnictví                                |2013|          46317|         -4484|         -8.83|
... atd.
 */
-- =============================================================================================================
/* Otázka 1 - verze B
 * Rostou v průběhu let mzdy ve všech odvětvích nebo v některých klesají?
 * SELECT pro vytvoření 1 řádku s údaji pro první a poslední rok dle odvětví
 * takže v tomto případě ve výstupním SELECT 19 řádků
 */
WITH t_wages AS (
    SELECT `year`, 
           branch_name, 
           branch_avg_wage,
           branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)) AS difference,
           round(((branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`))) * 100) 
                   / (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)), 2) AS percent_change
    FROM t_milan_sotona_project_sql_primary_final
    GROUP BY `year`, branch_name
    ORDER BY branch_name, `year`
)
SELECT t1.branch_name, 
       t1.year_first, 
       t1.branch_avg_wage_first, 
       t2.year_last, 
       t2.branch_avg_wage_last,
       t2.branch_avg_wage_last - t1.branch_avg_wage_first AS wage_change,
       round(((t2.branch_avg_wage_last - t1.branch_avg_wage_first)*100) / t1.branch_avg_wage_first,2) AS percent_change 
FROM (
	SELECT `year` AS year_first, 
	       branch_name, 
	       branch_avg_wage AS branch_avg_wage_first
	FROM t_wages
	WHERE `year` = (SELECT min(`year`) 
                    FROM t_wages)) t1
JOIN (
	SELECT `year` AS year_last, 
	       branch_name, 
	       branch_avg_wage AS branch_avg_wage_last
	FROM t_wages
	WHERE `year` = (SELECT max(`year`)
                    FROM t_wages)) t2
ON t1.branch_name = t2.branch_name;
/* výstup:
branch_name                                                 |year_first|branch_avg_wage_first|year_last|branch_avg_wage_last|wage_change|percent_change|
------------------------------------------------------------+----------+---------------------+---------+--------------------+-----------+--------------+
Administrativní a podpůrné činnosti                         |      2006|                14444|     2018|               20954|       6510|         45.07|
Činnosti v oblasti nemovitostí                              |      2006|                19242|     2018|               28109|       8867|         46.08|
Doprava a skladování                                        |      2006|                19257|     2018|               29460|      10203|         52.98|
Informační a komunikační činnosti                           |      2006|                35793|     2018|               56728|      20935|         58.49|
Kulturní, zábavní a rekreační činnosti                      |      2006|                16827|     2018|               28399|      11572|         68.77|
Ostatní činnosti                                            |      2006|                16484|     2018|               23697|       7213|         43.76|
Peněžnictví a pojišťovnictví                                |      2006|                40027|     2018|               54883|      14856|         37.11|
Profesní, vědecké a technické činnosti                      |      2006|                24645|     2018|               38985|      14340|         58.19|
Stavebnictví                                                |      2006|                17850|     2018|               28167|      10317|         57.80|
Těžba a dobývání                                            |      2006|                24067|     2018|               36039|      11972|         49.74|
Ubytování, stravování a pohostinství                        |      2006|                11674|     2018|               19270|       7596|         65.07|
Velkoobchod a maloobchod; opravy a údržba motorových vozidel|      2006|                18223|     2018|               29975|      11752|         64.49|
Veřejná správa a obrana; povinné sociální zabezpečení       |      2006|                23285|     2018|               36313|      13028|         55.95|
Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu |      2006|                29211|     2018|               46375|      17164|         58.76|
Vzdělávání                                                  |      2006|                20030|     2018|               31443|      11413|         56.98|
Zásobování vodou; činnosti související s odpady a sanacemi  |      2006|                18740|     2018|               28724|       9984|         53.28|
Zdravotní a sociální péče                                   |      2006|                19042|     2018|               33863|      14821|         77.83|
Zemědělství, lesnictví, rybářství                           |      2006|                14818|     2018|               25467|      10649|         71.87|
Zpracovatelský průmysl                                      |      2006|                18482|     2018|               31890|      13408|         72.55|
*/