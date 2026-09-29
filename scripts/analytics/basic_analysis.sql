select
	*
from INFORMATION_SCHEMA.TABLES
order by TABLE_TYPE

--exploring the database

select
	*
from INFORMATION_SCHEMA.COLUMNS
where table_name = 'dim_customers'

select
	distinct category, subcategory, product_name
from gold.dim_products
order by 1,2,3



--total customers by country 
select
	country,
	count(customer_key) as total_customers
from gold.dim_customers
group by country
order by total_customers desc

--total customers by gender
select
	gender,
	count(customer_key)
from gold.dim_customers
group by gender
order by count(customer_key) desc

--find total products by category

select
	category,
	count(product_key)  as total_products
from gold.dim_products
group by category 
order by total_products desc

--find avg cost by categpry

select
	category,
	avg(cost)as average_cost
from gold.dim_products
group by category 
order by average_cost desc

-- Total revenue by category

select
	pr.category,
	sum(sl.sales_amount) as total_revenue
from gold.fact_sales as sl
left join gold.dim_products as pr
	on pr.product_key = sl.product_key
group by pr.category
order by total_revenue desc

--total sales by customer

select
	ca.customer_key,
	ca.first_name,
	ca.last_name,
	sum(sl.sales_amount) as total_sales
from gold.fact_sales as sl
left join gold.dim_customers as ca
	on ca.customer_key = sl.customer_key
group by ca.customer_key, ca.first_name, ca.last_name
order by total_sales desc

--total quantity by country

select
	ca.country,
	sum(sl.quantity) as total_quantity
from gold.fact_sales as sl
left join gold.dim_customers as ca
	on ca.customer_key = sl.customer_key
group by ca.country
order by total_quantity desc

-- 5 products with most revenue

select top 5
	product_name,
	sum(sl.sales_amount) as total_sales
from gold.fact_sales as sl
left join gold.dim_products as pr
	on pr.product_key = sl.product_key
group by product_name
order by total_sales desc

select
	*
from(
select 
	product_name,
	sum(sl.sales_amount) as total_sales,
	rank() over(order by sum(sl.sales_amount) desc) as rank_products
from gold.fact_sales as sl
left join gold.dim_products as pr
	on pr.product_key = sl.product_key
group by product_name
)t
where rank_products <=5


-- 5 products with least revenue

select top 5
	product_name,
	sum(sl.sales_amount) as total_sales
from gold.fact_sales as sl
left join gold.dim_products as pr
	on pr.product_key = sl.product_key
group by product_name
order by total_sales asc

-- Find the top 10 customers who have generated the highest revenue

select top 10
	ca.customer_key,
	ca.first_name,
	ca.last_name,
	sum(sl.sales_amount) as total_sales
from gold.fact_sales as sl
left join gold.dim_customers as ca
	on ca.customer_key = sl.customer_key
group by ca.customer_key, ca.first_name, ca.last_name
order by total_sales desc

-- The 3 customers with the fewest orders placed

select top 3
	ca.customer_key,
	ca.first_name,
	ca.last_name,
	count(sl.order_number) as total_orders
from gold.fact_sales as sl
left join gold.dim_customers as ca
	on ca.customer_key = sl.customer_key
group by ca.customer_key, ca.first_name, ca.last_name
order by total_orders asc


--firstlast date and all the months
select
	max(order_date) as first_order,
	min(order_date) as last_order,
	DATEDIFF(month, min(order_date), max(order_date)) as order_range_month
from gold.fact_sales

--oldest and youngest customers
select
	min(datediff(year, birthdate, getdate())),
	max(datediff(year,  birthdate, getdate()))
from gold.dim_customers

--total_sales
select
	sum(sales_amount) as total_sales
from gold.fact_sales

--total_quantity
select
	sum(quantity) as total_quantity
from gold.fact_sales

--average price
select
	avg(price)
from gold.fact_sales

--total orders
select
	count(distinct order_number)	
from gold.fact_sales

--total key
select
	count(distinct product_key)
from gold.fact_sales

--total customers
select
	count(customer_key)
from gold.dim_customers

--total customers that have placed orders
select
	count(distinct customer_key)
from gold.fact_sales





select
	'Total Sales' as measure_name,
	sum(sales_amount) as measure_value
from gold.fact_sales

union all

--total_quantity
select
	'total_quantity' as measure_name,
	sum(quantity) as measure_value
from gold.fact_sales

union all

select
	'Average_price' as measure_name,
	avg(price) as measure_value
from gold.fact_sales

union all

--total orders
select
	'total_orders' as measure_name,
	count(distinct order_number) as measure_value
from gold.fact_sales

union all

select
	'total_products' as measure_name,
	count(distinct product_key) as  measure_value
from gold.dim_products

union all

select
	'total_customers' as measure_name,
	count(customer_key) as  measure_value
from gold.dim_customers







--Sales, customers, quantity by month
select
	datetrunc(month, order_date) as order_date,
	sum(sales_amount) as total_sales,
	count(distinct customer_key) as total_customers,
	sum(quantity) as total_quantity
from gold.fact_sales
where order_date is not null
group by datetrunc(month, order_date) 
order by datetrunc(month, order_date) 


-- Calculate the total sales per month 
-- and the running total of sales over time 

select
	order_date,
	total_sales,
	sum(total_sales) over(partition by order_date order by order_date) as running_total_sales,
	avg(avg_price) over(order by order_date) as moving_average_price
from(

select
	datetrunc(year, order_date) as order_date,
	sum(sales_amount) as total_sales,
	avg(price) as avg_price
from gold.fact_sales
where datetrunc(year, order_date) is not null
group by datetrunc(year, order_date) 
)t

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

with yearly_product_sales as(
select
	year (sl.order_date) as order_year,
	pr.product_name,
	sum(sl.sales_amount) as current_sales
from gold.fact_sales as sl
left join gold.dim_products as pr
	on sl.product_key = pr.product_key
where year (sl.order_date) is not null
group by year (sl.order_date), pr.product_name
)

select
	order_year,
	product_name,
	current_sales,
	current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
	case 
		when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Avg'
		when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below Avg'
		else 'Avg'
	end avg_change,
	current_sales - lag(current_sales) over(partition by product_name order by order_year) as diff_prev_year_sales,
	case 
		when current_sales - lag(current_sales) over(partition by product_name order by order_year) < 0 then 'decrease'
		when current_sales - lag(current_sales) over(partition by product_name order by order_year) > 0 then 'Increase'
		else 'No Change'
	end prev_year_change
from yearly_product_sales
order by product_name

--percentage of contributions

with category_sales as (
select
	pr.category,
	sum(sales_amount) as total_sales
from gold.fact_sales as sl
left join gold.dim_products as pr
	on sl.product_key = pr.product_key
group by pr.category)

select
	category,
	total_sales,
	sum(total_sales) over(),
	concat(round((cast(total_sales as float) / sum(total_sales) over()) * 100, 2), '%')as percentage_of_total
from category_sales
order by total_sales desc


/*Segment products into cost ranges and 
count how many products fall into each segment*/
with product_segments as(
select
	product_key,
	product_name,
	cost,
	case
		when cost < 100 then 'Bellow 100'
		when cost between 100 and 500 then '100-500'
		when cost between 500 and 1000 then '500-1000'
		else 'above 1000'
	end as cost_range
from gold.dim_products
)

select
	cost_range,
	count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc



/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
with customer_spending as (
select	
	sl.customer_key,
	sum(sl.sales_amount) as total_sales,
	min(sl.order_date) as first_order,
	max(sl.order_date) as last_order,
	datediff(month, min(sl.order_date), max(sl.order_date)) as history_months
from gold.fact_sales as sl
left join gold.dim_customers as cu
	on sl.customer_key = cu.customer_key 
group by sl.customer_key
)
, segmetation as (
select
	customer_key,
	total_sales,
	history_months,
	case
		when history_months >= 12 and total_sales > 5000 then 'VIP'
		when history_months >= 12 and total_sales <= 5000 then 'Regular'
		else 'New'
	end as customer_category
from customer_spending )

select
	customer_category,
	count(customer_key)
from segmetation
group by customer_category

