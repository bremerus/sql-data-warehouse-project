/*
==================================================================
DDL Script: Load Data to Silver Tables
==================================================================
Script purpose:
    This Percedure loads the data from the bronze layer into our silver
    It's Two  main functions are:
        -truncateing the already existing data in the bronze tables
        -inserting the data in the silver tables
Parameteres: None
  this storage precedure does not take any Parameteres
example execution:
    execute silver.load_bronze;
*/

create or alter procedure silver.load_silver as
begin 
		begin try
		declare @start_time datetime, @end_time datetime, @start_batch datetime, @end_batch datetime;

		set @start_batch = getdate();

		print '=============================================';
		print 'Loading Silver Layer';
		print '=============================================';

		print '---------------------------------------------';
		print 'Loading CRM Tables';
		print '---------------------------------------------';

		set @start_time = getdate();

		-- crm_cust_info cleaning
		print 'Truncating table silver.crm_cust_info'
		truncate table silver.crm_cust_info
		print 'Inserting table silver.crm_cust_info'
		insert into silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		select
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			case 
				when upper(trim(cst_marital_status)) = 'S' then 'Single'
				when upper(trim(cst_marital_status)) = 'M' then 'Married'
				else 'n/a'
			end as cst_marital_status,
			case 
				when upper(trim(cst_gndr)) = 'F' then 'Female'
				when upper(trim(cst_gndr)) = 'M' then 'Male'
				else 'n/a'
			end as cst_gndr,
			cst_create_date
		from  (
		select
		*,
		row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		)t 
		where flag_last = 1 

		set @end_time = getdate();
			print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
			print '-------------------------------------------------'

			set @start_time = getdate();

		-- crm_prd_info cleaning

		print 'Truncating table silver.crm_prd_info'
		truncate table silver.crm_prd_info
		print 'Inserting table silver.crm_prd_info'
		insert into silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		select
			prd_id,
			replace(substring(prd_key, 1, 5) , '-', '_') as cat_id,
			substring(prd_key, 7, len(prd_key)) as prd_key,
			prd_nm,
			coalesce(prd_cost, 0) as prd_cost,
			case upper(trim(prd_line))
				when 'M' then 'Mountain'
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				else 'n/a'
			end as prd_line,
			cast (prd_start_dt as date) as prd_start_dt,
			cast(lead(prd_start_dt) over(partition by prd_key order by prd_id) -1  as date) as prd_end_dt
		from bronze.crm_prd_info

		set @end_time = getdate();
			print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
			print '-------------------------------------------------'

			set @start_time = getdate();

		-- crm_sales_details cleaning

		print 'Truncating table silver.crm_sales_details'
		truncate table silver.crm_sales_details
		print 'Inserting table silver.crm_sales_details'
		insert into silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			case
				when sls_order_dt < = 0 or len(sls_order_dt) != 8 or sls_order_dt < 19000101 or sls_order_dt > 20500101 then null
				else cast(cast(sls_order_dt as varchar) as date)
			end as sls_order_dt,
			case
				when sls_ship_dt < = 0 or len(sls_ship_dt) != 8 or sls_ship_dt < 19000101 or sls_ship_dt > 20500101 then null
				else cast(cast(sls_ship_dt as varchar) as date)
			end as sls_ship_dt,
			case
				when sls_due_dt < = 0 or len(sls_due_dt) != 8 or sls_due_dt < 19000101 or sls_due_dt > 20500101 then null
				else cast(cast(sls_due_dt as varchar) as date)
			end as sls_due_dt,
			case
				when sls_sales != sls_quantity * abs(sls_price) or sls_sales < = 0 or sls_sales is null then sls_quantity * abs(sls_price)
				else sls_sales 
			end as sls_sales,
			sls_quantity,
			case
				when sls_price is null or sls_price <= 0 then sls_sales / nullif(sls_quantity, 0)
				else sls_price 
			end as sls_price
		from bronze.crm_sales_details

		set @end_time = getdate();
			print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
			print '-------------------------------------------------'


			print '---------------------------------------------';
			print 'Loading ERP Tables';
			print '---------------------------------------------';

		set @start_time = getdate();

		-- erp_cust_az12 cleaning

		print 'Truncating table silver.erp_cust_az12'
		truncate table silver.erp_cust_az12
		print 'Inserting table silver.erp_cust_az12'
		insert into silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		select
			case
				when cid like 'NAS%' then substring(cid, 4, len(cid))
				else cid
			end as cid,
			case
				when bdate > getdate() then null
				else bdate
			end as bdate,
			case 
				when gen is null or trim(gen) = '' then 'n/a'
				when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
				when upper(trim(gen)) in ('M', 'MALE') then 'Μale'
				else gen 
			end as gen
		from bronze.erp_cust_az12

		set @end_time = getdate();
			print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
			print '-------------------------------------------------'

		set @start_time = getdate();

		-- erp_loc_a101 cleaning

		print 'Truncating table silver.erp_loc_a101'
		truncate table silver.erp_loc_a101
		print 'Inserting table silver.erp_loc_a101'
		insert into silver.erp_loc_a101(
			cid,
			cntry
		)
		select
			replace(cid, '-','') as cid,
			case
				when trim(cntry) = 'DE' then 'Germany'
				when trim(cntry) in ('US', 'USA') then 'United States'
				when trim(cntry) = '' or cntry is null then 'n/a'
				else trim(cntry) 
			end as cntry
		from bronze.erp_loc_a101

		set @end_time = getdate();
			print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
			print '-------------------------------------------------'

			set @start_time = getdate();

		-- px_cat_g1v2 cleaning

		print 'Truncating table silver.px_cat_g1v2'
		truncate table silver.px_cat_g1v2
		print 'Inserting table silver.px_cat_g1v2'
		insert into silver.px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		select
			id,
			cat,
			subcat,
			maintenance
		from bronze.px_cat_g1v2

		set @end_time = getdate();
			print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
			print '-------------------------------------------------'

			set @end_batch = getdate();
			print 'Batch duration ' + cast(datediff(second, @start_batch, @end_batch) as nvarchar) + ' seconds';
			print '-------------------------------------------------'

	end try
		begin catch
			print '==============================='
			print 'Error Occured During Loading Bronze Layer'
			print 'Error Message: ' + ERROR_MESSAGE()
			print 'Error Message: ' + cast(ERROR_MESSAGE() as nvarchar)
			print 'Error Message: ' + cast(ERROR_STATE() as nvarchar)
			print '==============================='
		end catch
end
