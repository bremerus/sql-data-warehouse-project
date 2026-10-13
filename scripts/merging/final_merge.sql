select 
	* 
from lab_merge.target

select 
	* 
from lab_merge.staging



merge lab_merge.target as t
using lab_merge.staging as s
	on t.customer_key = s.customer_key
when matched and exists(
		select s.customer_key, s.customer_id, s.customer_number, s.first_name, s.last_name, s.country, s.marital_status, s.gender, s.birthdate, s.create_date
		except
		select t.customer_key, t.customer_id, t.customer_number, t.first_name, t.last_name, t.country, t.marital_status, t.gender, t.birthdate, t.create_date
	)
	then  update set
		t.customer_key = s.customer_key,
		t.customer_id = s.customer_id,
		t.customer_number = s.customer_number,
		t.first_name = s.first_name,
		t.last_name = s.last_name,
		t.country = s.country,
		t.marital_status = s.marital_status,
		t.gender = s.gender,
		t.birthdate = s.birthdate,
		t.create_date = s.create_date
when not matched by target
	then insert (customer_key, customer_id, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date)
		values (s.customer_key, s.customer_id, s.customer_number, s.first_name, s.last_name, s.country, s.marital_status, s.gender, s.birthdate, s.create_date)
when not matched by source
	then delete
output $action as action,
	inserted.customer_key AS new_id,
    deleted.customer_key  AS old_id;
