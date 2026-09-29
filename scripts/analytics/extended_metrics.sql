/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
create view gold.report_customers as
with base_query as (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
select
	sl.order_number,
	sl.product_key,
	sl.order_date,
	sl.sales_amount,
	sl.quantity,
	cu.customer_key,
	cu.customer_number,
	concat(cu.first_name, ' ', cu.last_name) as customer_name,
	datediff(year, cu.birthdate, getdate()) as age
from gold.fact_sales as sl
left join gold.dim_customers as cu
	on sl.customer_key = cu.customer_key
where sl.order_date is not null
)
, customer_aggregations as (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
select
	customer_key,
	customer_number,
	customer_name,
	age,
	count(order_number) as total_orders,
	sum(sales_amount) as total_sales,
	sum(quantity) as total_quantity,
	count(distinct product_key) as total_products,
	max(order_date) as last_order_date,
	datediff(month, min(order_date), max(order_date)) as lifespan
from base_query
group by customer_key, customer_number,customer_name,age)


select
	customer_key,
	customer_number,
	customer_name,
	age,
	case
		when age < 20 then 'Under 20'
		when age between 20 and 29 then '20-29'
		when age between 20 and 29 then '30-39'
		when age between 20 and 29 then '40-49'
		else '50 and above'
	end  as age_group,
	case
		when lifespan >= 12 and total_sales > 5000 then 'VIP'
		when lifespan >= 12 and total_sales <= 5000 then 'Regular'
		else 'New'
	end as customer_category,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	last_order_date,
	datediff(month, last_order_date, GETDATE()) as recency,
	lifespan,
	case 
		when total_orders = 0 then 0
		else total_sales / total_orders 
	end as avg_sales_per_order,

	case 
		when lifespan = 0 then 0
		else total_sales / lifespan
	end as avg_sales_per_month
from customer_aggregations











/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
with base_query as (
select
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.cost,
    sl.sales_amount,
    sl.order_number,
    sl.quantity,
    sl.customer_key,
    sl.order_date
from gold.fact_sales as sl
left join gold.dim_products as pr
   on sl.product_key = pr.product_key)

, product_aggregation as (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
select
    product_name,
    category,
    subcategory,
    cost,
    count(order_number) as total_orders,
    sum(sales_amount) as total_sales,
    sum(quantity) as total_quantity,
    count(customer_key) as total_customers,
    datediff(month, min(order_date), max(order_date)) as lifespan,
    max(order_date) as last_order
from base_query
group by product_name, category, subcategory, cost
)

select 
    product_name,
    category,
    subcategory,
    cost,
    case
        when total_sales > 50000 then 'High-Performers'
        when total_sales > 10000 then 'Mid-Range'
        else 'Low-Performers'
    end as product_ranking,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    datediff(month, last_order, getdate()) as recency,
    last_order,
    case
        when total_orders = 0 then 0
        else total_sales / total_orders
    end as average_order_revenue,
    lifespan,
    case
        when lifespan = 0 then 0
        else total_sales / lifespan
    end as average_monthly_revenue
from product_aggregation
