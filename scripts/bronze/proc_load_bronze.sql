/*
==================================================================
DDL Script: Load Data to Bronze Tables
==================================================================
Script purpose:
    This Percedure loads the data from the csv Files into our DataBase
    It's Two  main functions are:
        -truncateing the al ready existing data in the table
        -inserting the data in the tables
Parameteres: None
  this storage precedure does not take any Parameteres
example execution:
    execute bronze.load_bronze;
*/
create or alter procedure bronze.load_bronze as

begin
	
	declare @start_time datetime, @end_time datetime, @start_batch datetime, @end_batch datetime;

	set @start_batch = getdate();

	begin try
		print '=============================================';
		print 'Loading Bronze Layer';
		print '=============================================';
		truncate table bronze.crm_cust_info

		print '---------------------------------------------';
		print 'Loading CRM Tables';
		print '---------------------------------------------';

		set @start_time = getdate();

		print '>> Truncating Table: bronze.crm_cust_info'
		truncate table bronze.crm_cust_info

		print '>> Inserting Data Into: bronze.crm_cust_info'
		bulk insert bronze.crm_cust_info
		from 'C:\Users\user\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		);

		set @end_time = getdate();
		print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '-------------------------------------------------'

		set @start_time = getdate();

		print '>> Truncating Table: bronze.crm_prd_info'
		truncate table bronze.crm_prd_info

		print '>> Inserting Data Into: bronze.crm_prd_info'
		bulk insert bronze.crm_prd_info
		from 'C:\Users\user\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		);

		
		set @end_time = getdate();
		print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '-------------------------------------------------'

		set @start_time = getdate();
		print '>> Truncating Table: bronze.crm_sales_details'
		truncate table bronze.crm_sales_details

		print '>> Inserting Data Into: bronze.crm_sales_details'
		bulk insert bronze.crm_sales_details
		from 'C:\Users\user\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		);

		
		set @end_time = getdate();
		print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '-------------------------------------------------'


		print '---------------------------------------------';
		print 'Loading ERP Tables';
		print '---------------------------------------------';

		set @start_time = getdate();

		print '>> Truncating Table: bronze.erp_cust_az12'
		truncate table bronze.erp_cust_az12

		print '>> Inserting Data Into: bronze.erp_cust_az12'
		bulk insert bronze.erp_cust_az12
		from 'C:\Users\user\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		);

		set @end_time = getdate();
		print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '-------------------------------------------------'

		set @start_time = getdate();

		print '>> Truncating Table: bronze.erp_loc_a101'
		truncate table bronze.erp_loc_a101

		print '>> Inserting Data Into: bronze.erp_loc_a101'
		bulk insert bronze.erp_loc_a101
		from 'C:\Users\user\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		);

		set @end_time = getdate();
		print 'Load duration ' + cast(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds';
		print '-------------------------------------------------'

		set @start_time = getdate();

		print '>> Truncating Table: bronze.px_cat_g1v2'
		truncate table bronze.px_cat_g1v2

		print '>> Inserting Data Into: bronze.px_cat_g1v2'
		bulk insert bronze.px_cat_g1v2
		from 'C:\Users\user\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock 
		);
		
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
