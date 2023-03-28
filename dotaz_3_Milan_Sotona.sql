


/* otázka 3
 * Která kategorie potravin zdražuje nejpomaleji (je nejnižší procentuální meziroční nárůst)
 * 
 * pro každý product je nutno hlídat první a poslední rok:
 * code 212101 Víno má data za 2015-2018, ostatní jsou 2006-2018
 * code 212101 nejde porovnat s ostatními, vyloučeno z analýzy až na konci SELECTu, kdyby někdo chtěl ať si to tam může pustit
 * 
 * výsledek: 26 položek (bez vína)
product_code|product_name                    |year_first|product_avg_price_first|year_last|product_avg_price_last|price_change_percentage|
------------+--------------------------------+----------+-----------------------+---------+----------------------+-----------------------+
      118101|Cukr krystalový                 |      2006|                  21.73|     2018|                 15.75|                 -27.52|
      117101|Rajská jablka červená kulatá    |      2006|                  57.83|     2018|                 44.49|                 -23.07|
      116103|Banány žluté                    |      2006|                  27.31|     2018|                 29.32|                   7.36|
      112201|Vepřová pečeně s kostí          |      2006|                 105.18|     2018|                116.85|                   11.1|
      122102|Přírodní minerální voda uhličitá|      2006|                   7.69|     2018|                  8.65|                  12.48|  
atd. viz SELECT
 */
WITH t_w AS 
-- odstranění údajů o mzdách ze vstupní tabulky a s tím souvisejících duplicit pro údaje o potravinách
-- vstupní tabulka: v rámci year a product_code je víc řádků - pro každé mzdové odvětví, ale u každého řádku stejné údaje o potravinách
(
    SELECT `year`, 
	       product_code,
	       product_name, 
	       avg(product_avg_price) AS product_avg_price, -- šlo by dát taky min nebo max, v rámci GROUP BY jsou všechny product_avg_price stejné
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
           product_avg_price 
    FROM t_w 
    WHERE `year` = year_first
) t1
JOIN
(
    SELECT `year`, 
           product_code,
           product_name, 
           product_avg_price 
    FROM t_w 
    WHERE `year` = year_last 
) t2
ON t1.product_code = t2.product_code
WHERE t1.product_code <> 212101 -- Víno není srovnatelné s ostatními položkami
ORDER BY price_change_percentage ASC 
;
