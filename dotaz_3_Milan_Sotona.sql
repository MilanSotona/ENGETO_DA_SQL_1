/* otázka 3
 * Která kategorie potravin zdražuje nejpomaleji (je nejnižší procentuální meziroční nárůst)
 * 
 * pro každý product je nutno hlídat první a poslední rok:
 * code 212101 Víno má data za 2015-2018, ostatní jsou 2006-2018
 * code 212101 nejde porovnat s ostatními, vyloučeno z analýzy až na konci SELECTu, kdyby někdo chtěl ať si to tam může pustit
 * 
 * výsledek: 2 položky zlevnily
 * víc zlevnila položka 118101 Cukr krystalový
 * ostatní položky zdražily, nejméně 116103 Banány žluté
 * všech 26 položek (bez vína) - viz SELECT 
 */
WITH t_w AS 
(
	SELECT `year`, 
	       product_code,
	       product_name, 
	       avg(product_avg_price) AS product_avg_price, -- šlo by dát taky min nebo max, v rámci GROUP BY jsou všechny tyto hodnoty stejné
	       first_value(`year`) OVER (PARTITION BY product_code 
	                                 ORDER BY `year`
	                                 RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS year_first,
	       last_value(`year`) OVER (PARTITION BY product_code 
	                                ORDER BY `year`
	                                RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS year_last 
	FROM t_milan_sotona_project_sql_primary_final 
	GROUP BY `year`, product_code, product_name 
)
SELECT t1.product_code,
       t1.product_name, 
       t1.`year` AS year_first,
       t1.product_avg_price AS product_avg_price_first,
       t2.`year` AS year_last,
       t2.product_avg_price AS product_avg_price_last,
       round((t2.product_avg_price - t1.product_avg_price) / t1.product_avg_price * 100, 2) AS price_change_percentage
FROM
(
  SELECT `year`, 
       product_code,
       product_name, 
       avg(product_avg_price) AS product_avg_price 
    FROM t_w 
    WHERE `year` = year_first
    GROUP BY product_code, product_name, `year`
) t1
JOIN
(
  SELECT `year`, 
       product_code,
       product_name, 
       avg(product_avg_price) AS product_avg_price 
    FROM t_w 
    WHERE `year` = year_last 
    GROUP BY product_code, product_name, `year`
) t2
ON t1.product_code = t2.product_code
WHERE t1.product_code <> 212101 -- Víno není srovnatelné s ostatními položkami
ORDER BY price_change_percentage ASC -- 1. řádek = nejnižší zdražení nebo zlevnění, příp. dát LIMIT 1
;
