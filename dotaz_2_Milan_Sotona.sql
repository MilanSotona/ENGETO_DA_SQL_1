/* Otázka 2
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období
 * 111301 chleba, 114201 mléko
 */
WITH t_quantity AS 
(    SELECT branch_name,       
            concat(product_name, ' ',product_price_value, ' ', product_price_unit) AS product,
            `year`,
            round(branch_avg_wage / product_avg_price,2) AS quantity
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
       t2.quantity_last
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
ORDER BY branch_name, product;   
