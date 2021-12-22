--1
create schema dml_exercises;
--drop table if exists dml_exercises.sales;
--2
create table if not exists dml_exercises.sales(
	id serial primary key,
	sales_date timestamp not null,
	sales_amount numeric(38,2),
	sales_qty numeric(10,2),
	added_by text default 'admin',
	CONSTRAINT sales_less_1k CHECK (sales_amount <= 1000)
);
--3
INSERT INTO dml_exercises.sales (sales_date, sales_amount, 
				   sales_qty)
  	 VALUES ('12/12/2019', 1000, 90),
  	  	    ('24/06/2019', 100, 190),
      	    ('05/04/2018', 530, 102),
      	    ('07/04/2020', 730, 0);
INSERT INTO dml_exercises.sales (sales_date, sales_amount, 
				   sales_qty, added_by)
  	 VALUES ('12/12/2021', 500, 90, null);	
	 
--4
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by) 
        VALUES ('20/11/2019', 101, 50, NULL); 
		-- jako  format  godzina  (HH),  minuta  (MM),  sekunda  (SS) wstawione jest 00-00-00
--5		
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by) 
         VALUES ('04/04/2020', 101, 50, NULL); 
SHOW datestyle;	
--SQL/Postgres, DMY -->	day/month/year
--6
INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty,added_by) 
     SELECT NOW() + (random() * (interval '90 days')) + '30 days', 
            random() * 500 + 1, 
            random() * 100 + 1, 
            NULL 
       FROM generate_series(1, 20000) s(i);
--7
UPDATE dml_exercises.sales
   SET added_by = 'sales_over_200'
 WHERE sales_amount >= 200;
 
--8
--delete FROM dml_exercises.sales 
      WHERE added_by  = null;
--delete FROM dml_exercises.sales 
      WHERE added_by  = 'null';
delete FROM dml_exercises.sales 
      WHERE added_by  is null;
	  
--9
TRUNCATE dml_exercises.sales RESTART IDENTITY;
--10
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by) 
        VALUES ('20/11/2019', 101, 50, NULL); 