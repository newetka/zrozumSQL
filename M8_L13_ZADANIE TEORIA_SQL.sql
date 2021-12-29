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
	   
select * from products;
select * from product_manufactured_region;
select * from sales;

--1
select pmr.region_name, avg(product_quantity) avg_per_region
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region
group by 1
order by 2 desc;

--2
select pmr.region_name, string_agg(p.product_name, ',') as product_names
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region
group by 1;

select pmr.region_name, string_agg(p.product_name, ',' order by product_name asc) as product_names
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region
group by 1;

--3
select p.product_name, pmr.region_name, count(s.sal_prd_id) count
from sales s
join products p on p.id=s.sal_prd_id
join product_manufactured_region pmr ON pmr.id = p.product_man_region
group by p.product_name, pmr.region_name
having pmr.region_name = 'EMEA';

--4
select extract(year from sal_date)|| '_'||extract(month from sal_date) year_month, count(sal_prd_id)
from sales
group by 1
order by 2 desc;

--5
select p.product_code, EXTRACT(YEAR FROM manufactured_date) as year, pmr.region_name, 
avg(product_quantity) as avg
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region
GROUP BY GROUPING SETS (p.product_code,year,pmr.region_name);

select p.product_code, EXTRACT(YEAR FROM manufactured_date) as year, pmr.region_name, 
grouping(p.product_code, EXTRACT(YEAR FROM manufactured_date), pmr.region_name) as groups,
avg(product_quantity) as avg
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region
GROUP BY GROUPING SETS (p.product_code, year,pmr.region_name);

--select p.product_code, EXTRACT(YEAR FROM manufactured_date) as year, pmr.region_name, 
--grouping(p.product_code, EXTRACT(YEAR FROM manufactured_date), pmr.region_name) as groups,
--avg(product_quantity) as avg
--from products p
--join product_manufactured_region pmr ON pmr.id = p.product_man_region
--GROUP BY rollup (p.product_code, year,pmr.region_name);
--GROUP BY cube (p.product_code, year,pmr.region_name);

--6
select product_name, product_code, manufactured_Date, product_man_region, region_name, sum(product_quantity) over (partition by region_name ) 
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region;

--7
select PRODUCT_NAME, REGION_NAME,sum_pq from(
with query6 as(
select product_name, product_code, manufactured_Date, product_man_region, region_name, 
sum(product_quantity) over (partition by region_name ) as sum_pq
from products p
join product_manufactured_region pmr ON pmr.id = p.product_man_region)
select product_name, product_code, manufactured_Date, product_man_region, region_name, sum_pq,
dense_rank() over (order by sum_pq desc) rank
from query6)a
where rank=2;





