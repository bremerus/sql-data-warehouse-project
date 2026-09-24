--quality checks for silver.crm_sales_details

select
	*
from silver.crm_sales_details
where sls_ord_num != trim(sls_ord_num)
  
select
	nullif(sls_due_dt, 0)
from silver.crm_sales_details
where sls_due_dt < = 0 or 
len(sls_due_dt) != 8 or 
sls_due_dt < 1900-01-01 or
sls_due_dt > 20500101
  
select
	*
from bronze.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt or sls_ship_dt > sls_due_dt

select distinct
	sls_sales as old_sls_sales,
	sls_quantity,
	sls_price as old_sls_price
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
or sls_sales is null or sls_quantity is null or sls_price is null 
or sls_sales <=0 or sls_quantity <=0 or sls_price <=0 
order by sls_sales, sls_quantity, sls_price



--Quality Checks for silver.crm_prd_info
select
	prd_id,
	count(*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null 

select
	*
from silver.crm_prd_info
where prd_nm != trim(prd_nm)

select 
	*
from silver.crm_prd_info
where prd_cost is null or prd_cost < 0

select
	distinct(prd_line)
from bronze.crm_prd_info

select
	*
from bronze.crm_prd_info
where prd_start_dt > prd_end_dt

--quality checks silver.crm_cust_info
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;


--quality checks silver.erp_cust_az12

select distinct
	bdate
from silver.erp_cust_az12
where bdate > getdate()

--test filter for gen
select	distinct
	case 
		when gen is null or trim(gen) = '' then 'n/a'
		when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
		when upper(trim(gen)) in ('M', 'MALE') then 'Μale'
		else gen 
	end as gen
from silver.erp_cust_az12

select	
	*
from silver.erp_cust_az12




--quality checks for silver.erp_loc_a101

select distinct 
	cntry as old_cntry,	
	case
		when trim(cntry) = 'DE' then 'Germany'
		when trim(cntry) in ('US', 'USA') then 'United States'
		when trim(cntry) = '' or cntry is null then 'n/a'
		else trim(cntry) 
	end as cntry
from silver.erp_loc_a101

--quality checks silver.erp_px_cat_g1v2

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
