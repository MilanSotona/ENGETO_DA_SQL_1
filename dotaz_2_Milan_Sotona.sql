/* Otázka 2
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období
 * 111301 chleba, 114201 mléko
 */
-- ==========================================================================================
-- celkem za všechna odvětví = podklad pro odpověď na otázku č.2
-- -------------------------------------------------------------
WITH t_quantity AS 
(    SELECT concat(product_name, ' ',product_price_value, ' ', product_price_unit) AS product,
            `year`,
            round(branch_avg_wage / product_avg_price,0) AS quantity
     FROM t_milan_sotona_project_sql_primary_final
     WHERE product_code IN (111301,114201)
           AND (`year` = (SELECT min(`year`) FROM t_milan_sotona_project_sql_primary_final)
                OR `year` = (SELECT max(`year`) FROM t_milan_sotona_project_sql_primary_final)
               )
)
SELECT t1.product,
       t1.year_first,
       round(avg(t1.quantity_first),0) AS quantity_first,
       t2.year_last,
       round(avg(t2.quantity_last),0) AS quantity_last,
       round((avg(t2.quantity_last)-avg(t1.quantity_first))/avg(t1.quantity_first)*100,2) AS change_perc
FROM (
    SELECT product,
           `year` AS year_first,
           quantity AS quantity_first
    FROM t_quantity 
    WHERE `year` = (SELECT min(`year`) 
                    FROM t_quantity)) t1
JOIN (
    SELECT product,
           `year` AS year_last,
           quantity AS quantity_last
   FROM t_quantity 
   WHERE `year` = (SELECT max(`year`) 
                   FROM t_quantity)) t2
ON t1.product = t2.product
GROUP BY t1.product, t1.year_first, t2.year_last
ORDER BY t1.product;   
/* výsledek:
product                        |year_first|quantity_first|year_last|quantity_last|change_perc|
-------------------------------+----------+--------------+---------+-------------+-----------+
Chléb konzumní kmínový 1 kg    |      2006|        1313.0|     2018|       1365.0|       3.98|
Mléko polotučné pasterované 1 l|      2006|        1466.0|     2018|       1670.0|       13.9|
*/

-- ===========================================================================================
-- Podle odvětví: 
-- --------------
WITH t_quantity AS 
(    SELECT branch_name,       
            concat(product_name, ' ',product_price_value, ' ', product_price_unit) AS product,
            `year`,
            round(branch_avg_wage / product_avg_price,0) AS quantity
     FROM t_milan_sotona_project_sql_primary_final
     WHERE product_code IN (111301,114201)
           AND (`year` = (SELECT min(`year`) FROM t_milan_sotona_project_sql_primary_final)
                OR `year` = (SELECT max(`year`) FROM t_milan_sotona_project_sql_primary_final)
               )
)
SELECT t1.branch_name,
       t1.product,
       t1.year_first,
       t1.quantity_first,
       t2.year_last,
       t2.quantity_last,
       round((t2.quantity_last - t1.quantity_first)/t1.quantity_first*100,1) AS change_percent 
FROM (
    SELECT branch_name,
           product,
           `year` AS year_first,
           quantity AS quantity_first
    FROM t_quantity 
    WHERE `year` = (SELECT min(`year`) 
                    FROM t_quantity)) t1
JOIN (
    SELECT branch_name,
           product,
           `year` AS year_last,
           quantity AS quantity_last
   FROM t_quantity 
   WHERE `year` = (SELECT max(`year`) 
                   FROM t_quantity)) t2
ON t1.branch_name = t2.branch_name AND t1.product = t2.product
ORDER BY product, branch_name;   
/* výsledek:
branch_name                                                 |product                        |year_first|quantity_first|year_last|quantity_last|change_percent|
------------------------------------------------------------+-------------------------------+----------+--------------+---------+-------------+--------------+
Administrativní a podpůrné činnosti                         |Chléb konzumní kmínový 1 kg    |      2006|         896.0|     2018|        864.0|          -3.6|
Činnosti v oblasti nemovitostí                              |Chléb konzumní kmínový 1 kg    |      2006|        1194.0|     2018|       1160.0|          -2.8|
Doprava a skladování                                        |Chléb konzumní kmínový 1 kg    |      2006|        1195.0|     2018|       1215.0|           1.7|
Informační a komunikační činnosti                           |Chléb konzumní kmínový 1 kg    |      2006|        2220.0|     2018|       2340.0|           5.4|
Kulturní, zábavní a rekreační činnosti                      |Chléb konzumní kmínový 1 kg    |      2006|        1044.0|     2018|       1172.0|          12.3|
...
atd. 
 */
