/* Otázka 1 
 * Rostou v průběhu let mzdy ve všech odvětvích nebo v některých klesají?
 * Řešení:
 * SELECT vytvoří tabulku pro všechna odvětví a roky se změnou proti minulému roku (první rok je NULL)
 * podle nastavení WHERE lze vybrat roky, kdy došlo k poklesu, významnému růstu atd.
 */
WITH t_diff AS (
    SELECT `year`, 
           branch_name, 
           branch_avg_wage,
           branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)) AS difference,
           round(((branch_avg_wage - (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`))) * 100) / (lag(branch_avg_wage) OVER (PARTITION BY branch_name ORDER BY `year`)), 2) AS percent_change
    FROM t_milan_sotona_project_sql_primary_final
    GROUP BY `year`, branch_name
)
/* WHERE nešlo dát do SELECT kde je window funkce, tak to je ve 2 krocích */
SELECT * FROM t_diff
-- WHERE difference < 0
-- WHERE percent_change < -1
-- WHERE percent_change < -5
-- WHERE percent_change > 10
ORDER BY branch_name, `year`;
