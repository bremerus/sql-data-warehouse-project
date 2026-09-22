/*
==================================================================
DDL Script: Create Bronze Tables
==================================================================

Script Perpose:
    This Script Create the tables in the bronze schema if they already exist we drop them.
    Run this if want to redefine your Schema
*/

IF OBJECT_ID('bronze.crm_cust_info', 'U') is not null
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO


if object_id ('bronze.crm_prd_info', 'U') is not null
	drop table bronze.crm_prd_info;

go

create table bronze.crm_prd_info(
	prd_id int,
	prd_key nvarchar(50),
	prd_nm nvarchar(50),
	prd_cost int,
	prd_line nvarchar(50),
	prd_start_dt datetime,
	prd_end_dt datetime
);

go

if object_id ('bronze.crm_sales_details', 'U') is not null
	drop table bronze.crm_sales_details;
create table bronze.crm_sales_details(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50),
	sls_cust_id int,
	sls_order_dt int,
	sls_ship_dt int,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int,
	sls_price int
);

go

if object_id ('bronze.erp_cust_az12', 'U') is not null
	drop table bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
	cid nvarchar(50),
	bdate date,
	gen varchar(50)
);

go

if object_id ('bronze.erp_loc_a101', 'U') is not null
	drop table bronze.erp_loc_a101;
create table bronze.erp_loc_a101(
	cid nvarchar(50),
	cntry nvarchar(50)
);

go

if object_id ('bronze.px_cat_g1v2', 'U') is not null
	drop table bronze.px_cat_g1v2;
create table bronze.px_cat_g1v2(
	id nvarchar(50),
	cat nvarchar(50),
	subcat nvarchar(50),
	maintenance nvarchar(50)
);
