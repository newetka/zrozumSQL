create schema training;

alter schema training rename to training_zs;

create table training_zs.products(
	id integer,
	production_qty numeric(10,2),
	product_name varchar(100),
	product_code varchar(10),
	description text,
	manufacturing_date date
);

alter table training_zs.products add primary key (id);

DROP TABLE IF EXISTS training_zs.sales;

create table training_zs.sales(
	id integer primary key,
	sales_date timestamp,
	sales_amount numeric(38,2),
	sales_qty numeric(10,2),
	product_id integer,
	added_by  text default 'admin'
	CONSTRAINT sales_over_1k CHECK (sales_amount > 1000)
);

alter table training_zs.sales
ADD FOREIGN KEY (product_id)
REFERENCES training_zs.products(id) ON DELETE CASCADE;