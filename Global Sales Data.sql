CREATE TABLE global_sales_data
(
	region varchar(50),
	country varchar(50),
	item_type varchar(50),
	sales_channel varchar(50),
	order_priority varchar(50),
	order_date date, 
	order_id int,
	ship_date date,
	units_sold int,
	unit_price numeric,
	unit_cost numeric,
	total_revenue numeric,
	total_cost numeric,
	total_profit numeric
);
SELECT * FROM global_sales_data 

--To get the overall revenue, profit, margin, orders and units sold
SELECT SUM(total_revenue) AS overall_revenue,
	SUM(total_profit) AS overall_profit,
	ROUND(
		SUM(total_profit) / NULLIF(SUM(total_revenue),0) * 100, 2
	) AS profit_margin,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(units_sold) AS total_units_sold
	FROM global_sales_data;
/*From the results, the overall revenue is 13,333,551,314.32; the overall profit is 3,950,893,471.93; profit margin is 29.63%; total orders 
is 10,000; and total units sold is 50,028,559.*/

--To understand how revenue and profit changed overtime
SELECT EXTRACT(YEAR FROM order_date) AS years,
	SUM(total_revenue) AS overall_revenue,
	SUM(total_profit) AS overall_profit
FROM global_sales_data
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY years DESC;
--The results show that there were changes over the years in the revenue and profit sections.*/

/*To determine which countries and regions generated the most revenue?*/
SELECT country, region,
SUM(total_revenue) AS overall_revenue
FROM global_sales_data
GROUP BY country, region
ORDER BY overall_revenue DESC
LIMIT 3;
/*The results indicate that Taiwan(Asia - 113,106,945.67), Grenada(Central America & the Carribeans - 107,335,742.59) and Bahrain(Middle East 
& North America - 99,297,049.69) are the top three countries who generated the most revenue, respectively.*/

--Which countries and regions are the most profitable?
SELECT country, region,
SUM(total_profit) AS overall_profit
FROM global_sales_data
GROUP BY country, region 
ORDER BY overall_profit DESC
LIMIT 3;
/*The results show that Kiribati(Australia & Oceania - 32,454,798.26), Qatar(Middle East & North Africa - 30,861,356.79), and Grenada(Central 
America & the Caribbeans - 30,302,769.90) are the top three countries with the highest profit, respectively.*/

SELECT country,
SUM(total_revenue) AS overall_revenue,
SUM(total_profit) AS overall_profit,
ROUND(SUM(total_profit) / NULLIF(SUM(total_revenue), 0) * 100, 2) AS profit_margin
FROM global_sales_data
GROUP BY country
ORDER BY profit_margin DESC
LIMIT 3; 
/*The results show that these three countries have the highest revenue based on their profit margin, compared to the profits they made 
overall including: Guinea-Bissau(62,298,088.48 - 37%), Australia(63,992,292 - 34.99%), and Malaysia(46,199,927.93 - 34.67%)*/

--Which products generate the most revenue and profit?
--For Revenue,
SELECT item_type,
SUM(total_revenue) AS overall_revenue
FROM global_sales_data
GROUP BY item_type
ORDER BY overall_revenue DESC
LIMIT 3;
--Household products generated the most revenue(2,898,155,340.81), followed by Office Supplies and Cosmetics.
--For Profit,
SELECT item_type,
SUM(total_profit) AS overall_profit
FROM global_sales_data
GROUP BY item_type
ORDER BY overall_profit DESC
LIMIT 3;
--Meanwhile, Household products also generated the most profit(718,738,361.19), followed by Cosmetics and Office Supplies products.
--For Units Sold,
SELECT item_type,
SUM(units_sold) AS total_units_sold,
SUM(total_revenue) AS overall_revenue,
SUM(total_profit) AS overall_profit
FROM global_sales_data
GROUP BY item_type
ORDER BY total_units_sold DESC
LIMIT 3;
/*Based on the units sold, Personal Care products sold more units in total (4,402,827) however, the Household products had both the highest 
revenue and profit.*/

--Are the best-selling products also the most profitable products?
SELECT item_type,
SUM(units_sold) AS total_units_sold,
SUM(total_revenue) AS overall_revenue,
SUM(total_profit) AS overall_profit,
ROUND(SUM(total_profit) / NULLIF(SUM(total_revenue), 0) * 100, 2) AS profit_margin
FROM global_sales_data
GROUP BY item_type
ORDER BY total_units_sold DESC
LIMIT 3;
/*The results indicate that Clothes products(67.20%) has the highest profit margin compared to Personal Care(30.66%) and Household items
(24.80%). Household items still has the highest revenue and profit while Personal Care items has the highest number of total units sold
*/
WITH product_performance AS (
	SELECT item_type,
	SUM(units_sold) AS total_units_sold,
	SUM(total_revenue) AS revenue,
	SUM(total_profit) AS profit
	FROM global_sales_data
	GROUP BY item_type
)

SELECT item_type,
		total_units_sold,
		revenue,
		profit,
		
	RANK() OVER (
		ORDER BY total_units_sold DESC
	) AS units_rank,

	RANK() OVER (
		ORDER BY revenue DESC
	) AS revenue_rank,

	RANK() OVER (
		ORDER BY profit DESC
	) AS profit_rank

FROM product_performance
ORDER BY units_rank;
--The results support the above queries and results for the top three products based on Units Sold, Revenue and Profit.

--To find the most valuable customer based on revenue, profit, and/or purchase frequency
SELECT order_id,
	SUM(total_revenue) AS overall_revenue
FROM global_sales_data
GROUP BY order_id
ORDER BY overall_revenue DESC
LIMIT 5;
--Based on revenue, the most valuable customer is ID 182281482 with revenue 6,680,026.92
--For Profit,
SELECT order_id,
	SUM(total_profit) AS overall_profit
FROM global_sales_data
GROUP BY order_id
ORDER BY overall_profit DESC
LIMIT 5;
--Based on profit, the most valuable customer is ID 431603753 with profit 1,738,178.39
--For Purchase Frequency,
SELECT order_id,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(total_revenue) AS overall_revenue,
	SUM(total_profit) AS overall_profit
FROM global_sales_data
GROUP BY order_id
ORDER BY total_orders DESC
LIMIT 3;
--Order ID 100089156 made one order that had the highest revenue(1,534,522) and profit(660,881.40), which made such customer the most valuable.

--How concentrated is the revenue among customers, products and countries?
--For Customer Concentration,
WITH customer_revenue AS (
	SELECT order_id,
		SUM(total_revenue) AS overall_revenue 
	FROM global_sales_data
	GROUP BY order_id
)

	SELECT order_id, overall_revenue,
		ROUND(overall_revenue / NULLIF(SUM(overall_revenue) OVER (), 0) * 100, 2) AS revenue_contribution_pct
FROM customer_revenue
ORDER BY overall_revenue DESC;
--There is a 5% revenue concentration from the top 5 customers
--For Product Concentration,
WITH product_revenue AS (
	SELECT item_type,
		SUM(total_revenue) AS overall_revenue 
	FROM global_sales_data
	GROUP BY item_type
)

	SELECT item_type, overall_revenue,
		ROUND(overall_revenue / NULLIF(SUM(overall_revenue) OVER (), 0) * 100, 2) AS revenue_contribution_pct
FROM product_revenue
ORDER BY overall_revenue DESC;
--Household items(21.74%), Office Supplies(20.12%) and Cosmetics(13.45%) have the highest percentage revenue concentration.
WITH country_revenue AS (
	SELECT country,
		SUM(total_revenue) AS overall_revenue 
	FROM global_sales_data
	GROUP BY country
)

	SELECT country, overall_revenue,
		ROUND(overall_revenue / NULLIF(SUM(overall_revenue) OVER (), 0) * 100, 2) AS revenue_contribution_pct
FROM country_revenue
ORDER BY overall_revenue DESC;
--Taiwan(85%), Grenada(81%) and Bahrain(74%) have the highest percentage revenue concentration.

--Which products represent the greatest growth opportunities?
WITH yearly_market_sales AS (
	SELECT country,
	EXTRACT(YEAR FROM order_date) AS year,
	SUM(total_revenue) AS overall_revenue,
	SUM(total_profit) AS overall_profit
	FROM global_sales_data
	GROUP BY country,
	EXTRACT(YEAR FROM order_date)
), 

market_growth AS (
	SELECT country, year, overall_revenue, overall_profit,

	LAG(overall_revenue) OVER (
		PARTITION BY country
		ORDER BY year
	) AS previous_year_revenue
	FROM yearly_market_sales
)

SELECT country, year, overall_revenue, overall_profit,

	ROUND(
		(overall_revenue - previous_year_revenue) / NULLIF(previous_year_revenue, 0) * 100, 2
	) AS revenue_growth_pct

FROM market_growth
ORDER BY year, revenue_growth_pct DESC;
/*The results indicate the profit and loss percentages of the company in various countries which did began to reflect after 2010 and ttrends over the years.*/


WITH yearly_product_sales AS(
	SELECT item_type,
		EXTRACT (YEAR FROM order_date) AS year,
		SUM(total_revenue) AS overall_revenue,
		SUM(total_profit) AS overall_profit
		FROM global_sales_data
		GROUP BY item_type,
			EXTRACT(YEAR FROM order_date)
)

SELECT item_type, year, overall_revenue, overall_profit,
	ROUND(overall_profit / NULLIF(overall_revenue, 0) * 100, 2) AS profit_margin,
	LAG(overall_revenue) OVER (
		PARTITION BY item_type
		ORDER BY YEAR
	) AS previous_year_revenue
FROM yearly_product_sales
ORDER BY year, overall_revenue DESC;
/*Based on the results, revenue percentages for each item types began after 2010 which has low and high profit margins over the years.*/

