create schema lab_merge

if object_id('lab_merge.target', 'U') is not null
	drop table lab_merge.target;

go

create table lab_merge.target(
	customer_key int not null primary key,
	customer_id int,
	customer_number varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender varchar(50),
	birthdate date,
	create_date date
)

if object_id('lab_merge.staging', 'U') is not null
	drop table lab_merge.staging;
go

create table lab_merge.staging(
	customer_key int not null primary key,
	customer_id int,
	customer_number varchar(50),
	first_name varchar(50),
	last_name varchar(50),
	country varchar(50),
	marital_status varchar(50),
	gender varchar(50),
	birthdate date,
	create_date date
)
