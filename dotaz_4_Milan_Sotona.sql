/* otázka 4
 * Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst med (větší než 10%)?
 * vytvořeny 2 CTE, aby byl SELECT přehlednější a taky window funkce by v některých případech nefungovaly
 */
WITH t_1 AS -- kumulace ze vstupních dat
(
	SELECT `year`
	       ,round(avg(product_avg_price),2) AS price_avg
	       ,round(avg(branch_avg_wage),0) AS wage_avg
	FROM t_milan_sotona_project_sql_primary_final
	WHERE product_code <> 212101 -- víno vyloučeno, údaje jsou jen za 2015 až 2018 
	GROUP BY `year` 
),
t_2 AS 
/* vytvoření více údajů než je potřeba v zadání, ale byly by užitečné při rozšíření výzkumné otázky
 * a taky testuji co všechno jde ve window funcích
 * ty window funkce jsou super
 */
( 
    SELECT `year`
	       ,price_avg
	       ,lag(price_avg) OVER (ORDER BY `year`) AS price_previous
	       ,round((price_avg - lag(price_avg) OVER (ORDER BY `year`))/lag(price_avg) OVER (ORDER BY `year`) * 100,1) AS price_change_perc
	       ,wage_avg
	       ,lag(wage_avg) OVER (ORDER BY `year`) AS wage_previous
	       ,round((wage_avg - lag(wage_avg) OVER (ORDER BY `year`))/lag(wage_avg) OVER (ORDER BY `year`) * 100,1) AS wage_change_perc
	       ,round((wage_avg - lag(wage_avg) OVER (ORDER BY `year`))/lag(wage_avg) OVER (ORDER BY `year`) * 100,1) 
	           - round((price_avg - lag(price_avg) OVER (ORDER BY `year`))/lag(price_avg) OVER (ORDER BY `year`) * 100,1) AS change_perc_wage_price
	       ,round((price_avg - lag(price_avg) OVER (ORDER BY `year`))/lag(price_avg) OVER (ORDER BY `year`) * 100,1) 
	           - round((wage_avg - lag(wage_avg) OVER (ORDER BY `year`))/lag(wage_avg) OVER (ORDER BY `year`) * 100,1) AS change_perc_price_wage
           ,round(avg(price_avg) OVER (ORDER BY `year`
	                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS price_avg_cumul
	       ,round(avg(wage_avg) OVER (ORDER BY `year`
	                                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),0) AS wage_avg_cumul	                              	           
	FROM t_1
)
SELECT `year` 
       ,price_avg
       ,price_change_perc
       ,wage_avg
       ,wage_change_perc
       ,change_perc_price_wage
--       ,round(wage_avg_cumul / price_avg_cumul,0) AS ratio_wage_avg_price_avg
FROM t_2
ORDER BY `year`
-- ORDER BY change_perc_wage_price
;
/* výstup pro otázku 4:
year|price_avg|price_change_perc|wage_avg|wage_change_perc|change_perc_price_wage|
----+---------+-----------------+--------+----------------+----------------------+
2006|    45.52|                 |   21165|                |                      |
2007|    48.59|              6.7|   22621|             6.9|                  -0.2|
2008|     51.6|              6.2|   24361|             7.7|                  -1.5|
2009|    48.29|             -6.4|   25110|             3.1|                  -9.5|
2010|    49.23|              1.9|   25590|             1.9|                   0.0|
2011|    50.88|              3.4|   26188|             2.3|                   1.1|
2012|     54.3|              6.7|   26955|             2.9|                   3.8|
2013|    57.07|              5.1|   26536|            -1.6|                   6.7|
2014|    57.49|              0.7|   27219|             2.6|                  -1.9|
2015|    55.82|             -2.9|   27926|             2.6|                  -5.5|
2016|    55.03|             -1.4|   28941|             3.6|                  -5.0|
2017|     60.6|             10.1|   30726|             6.2|                   3.9|
2018|    61.86|              2.1|   33092|             7.7|                  -5.6|
Nárůst cen potravin proti nárůstu cen mezd v žádném roce nepřekročil 10%
Největší rozdíl byl v roce 2013, kdy potraviny vzrostly o 5.1 % a mzdy klesly o 1.6 %
 */
