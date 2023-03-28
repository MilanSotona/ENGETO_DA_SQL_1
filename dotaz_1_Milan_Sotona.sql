/* Otázka 1 
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
WHERE difference < 0
-- WHERE percent_change < -1
-- WHERE percent_change < -5
-- WHERE percent_change > 10
ORDER BY branch_name, `year`;

-- =========================================================================
/* Otázka 1
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
