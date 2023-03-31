/* vytvoření tabulky pro data mezd a cen potravin za ČR sjednocená na totožné porovnatelné období 
 * včetně údaje o HDP (přepočet na 1 obyvatele)
 */
CREATE OR REPLACE TABLE t_Milan_Sotona_project_SQL_primary_final AS
SELECT tab1.year, 
       tab1.product_code, 
       tab1.product_name, 
       tab1.product_avg_price,
       tab1.product_price_value,
       tab1.product_price_unit,
       tab2.branch_code,
       tab2.branch_name,
       tab2.branch_avg_wage,
       round(tab3.GDP/tab3.population,0) AS GDP_person
FROM 
(
    SELECT YEAR(czp.date_from) AS `year`,
           czpc.code AS product_code, 
           czpc.name AS product_name, 
           round(avg(czp.value),2) AS product_avg_price,
           czpc.price_value AS product_price_value,
           czpc.price_unit AS product_price_unit
    FROM czechia_price czp
    LEFT JOIN czechia_price_category czpc
        ON czp.category_code = czpc.code
    WHERE czp.region_code IS NULL -- bere se celorepublikový průměr
    GROUP BY YEAR(czp.date_from), czpc.code, czpc.name 
    ORDER BY `year`, czpc.code
) tab1
LEFT JOIN 
(
    SELECT czpay.payroll_year,
           czpay.industry_branch_code AS branch_code, 
           czpib.name branch_name, 
           ROUND(avg(czpay.value),0) AS branch_avg_wage
    FROM czechia_payroll czpay
    LEFT JOIN czechia_payroll_industry_branch czpib
        ON czpay.industry_branch_code = czpib.code
    WHERE czpay.value_type_code = 5958 -- Průměrná hrubá mzda na zaměstnance
          AND czpay.calculation_code = 200 -- bere se PŘEPOČTENÝ stav zaměstnanců
          AND czpay.unit_code = 200 -- při 2 předchozích podmínkách je všechno 200
          AND czpay.industry_branch_code IS NOT NULL -- NULL je průměr za všechny branch
    GROUP BY czpib.name, czpay.payroll_year
    ORDER BY czpay.payroll_year, czpay.industry_branch_code
) tab2
ON tab1.`year` = tab2.payroll_year
JOIN economies tab3 ON tab1.`year` = tab3.`year`
     WHERE country = 'Czech Republic'
           AND tab3.`year` BETWEEN 2006 AND 2018
ORDER BY tab1.year ASC, tab1.product_code, tab2.branch_code;

