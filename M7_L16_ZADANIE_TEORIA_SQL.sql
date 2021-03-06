DROP TABLE IF EXISTS products, sales, product_manufactured_region CASCADE;

CREATE TABLE products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),	
	manufactured_date DATE,
	product_man_region INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE product_manufactured_region (
	id SERIAL,
	region_name VARCHAR(25),
	region_code VARCHAR(10),
	established_year INTEGER
);

INSERT INTO product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('EMEA', 'E_EMEA', 2010),
	  		 ('EMEA', 'W_EMEA', 2012),
	  		 ('APAC', NULL, 2019),
	  		 ('North America', NULL, 2012),
	  		 ('Africa', NULL, 2012);

INSERT INTO products (product_name, product_code, product_quantity, manufactured_date, product_man_region)
     SELECT 'Product '||floor(random() * 10 + 1)::int,
            'PRD'||floor(random() * 10 + 1)::int,
            random() * 10 + 1,
            CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date),
            CEIL(random()*(10-5))::int
       FROM generate_series(1, 10) s(i);  
      
INSERT INTO sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 10000) s(i);   
	   
	   
--1
select * from sales;
select * from products;
select * from product_manufactured_region;

select product_name, sal_prd_id, region_name as id from sales s
inner join
products p on s.sal_prd_id=p.id
inner join
product_manufactured_region pmr on p.product_man_region=pmr.id
where pmr.region_name='EMEA'
limit 100;

--2
select p.*,pmr.REGION_NAME from products p
left join
product_manufactured_region pmr on p.product_man_region=pmr.id
AND pmr.established_year > 2012;
	
--3
select p.*,pmr.REGION_NAME from products p
left join
product_manufactured_region pmr on p.product_man_region=pmr.id
where pmr.established_year > 2012;
--w tym rozwiazaniu tylko jeden wynik, bo filtruj?? ostetczn?? tabel?? wynik??w, a w zadaniu 2 filtrowa????m elementy tablicy product_manufactured_region

--4
select product_name, extract(year from s.sal_date)||'_'||extract(month from s.sal_date) AS sal_year_month  from sales s
right join
(select * from products where product_quantity>5 )p on s.sal_prd_id=p.id
order by 1;

--5
insert into product_manufactured_region (region_name) values ('Australia');

select * from products p
full join
product_manufactured_region pmr on p.product_man_region=pmr.id;

--6
select * from products p
inner join
product_manufactured_region pmr on p.product_man_region=pmr.id;

select * from products p
left join
product_manufactured_region pmr on p.product_man_region=pmr.id;

select * from products p
right join
product_manufactured_region pmr on p.product_man_region=pmr.id;

select * from products p
cross join
product_manufactured_region pmr;

select * from products p
natural join
product_manufactured_region pmr;

--7
with podzapytane as (select * from products where product_quantity>5)
select product_name, extract(year from s.sal_date)||'_'||extract(month from s.sal_date) AS sal_year_month  from sales s
right join podzapytane p on s.sal_prd_id=p.id
order by 1;

--8
delete from products
where exists( select 1 from
			 products p  join
product_manufactured_region pmr on p.product_man_region=pmr.id
where pmr.region_name='EMEA' and pmr.region_code='E_EMEA'
)
returning *;

