insert into lab_merge.staging(
	customer_key,
	customer_id,
	customer_number,
	first_name,
	last_name,
	country,
	marital_status,
	gender,
	birthdate,
	create_date 
)
values
(11, 11010, 'AW00011010', 'Bill', 'Clinton', 'USA', 'Married', 'Male' , '1946-08-19', '2026-10-13'),
(12, 11011, 'AW00011011', 'Donald', 'Trump', 'USA', 'Married', 'Male' , '1946-06-14', '2026-10-13');

update lab_merge.staging
set country = 'Russia'
where customer_key = 3

update lab_merge.staging
set country = 'Italy'
where customer_key = 3

update lab_merge.staging
set country = 'Italy'
set marital_status = 'Married'
where customer_key = 2

update lab_merge.staging
set create_date = '2026-10-13'
where customer_key = 1;

update lab_merge.staging
set create_date = '2026-10-13'
where customer_key = 2;

update lab_merge.staging
set create_date = '2026-10-13'
where customer_key = 3;

delete from lab_merge.staging
where customer_key = 9

select 
* 
from lab_merge.staging
