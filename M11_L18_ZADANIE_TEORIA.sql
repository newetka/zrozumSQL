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
select * from sales
--brak wyników dla 'prd8', użyję więc prd7
SELECT s.*, p.product_code, p.product_name, pmr.region_name 
FROM sales s
JOIN products p ON p.id = s.sal_prd_id
JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN now() - (INTERVAL '60 days') AND now() 
AND p.product_code = 'PRD7';
 
 --2
DISCARD ALL;
EXPLAIN ANALYZE
SELECT s.*, p.product_code, p.product_name, pmr.region_name 
FROM sales s
JOIN products p ON p.id = s.sal_prd_id
JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN now() - (INTERVAL '60 days') AND now() 
AND p.product_code = 'PRD7';

-- Execution Time: 6.202 ms
-- Hash join - algorym łączenia wyników (cost=30.79..398.53 rows=142 width=372) (actual time=0.080..6.091 rows=2043 loops=1)
-- hash cond - warunek
-- seqscan  on sales s - sekwencyjne przechodzenie przez tabele
  
--3 
SELECT cast(count(DISTINCT product_code) as float) / count(product_code) FROM products; 

--4
CREATE INDEX idx_products_product_code ON products USING btree(product_code);

--5
--DISCARD ALL;
EXPLAIN ANALYZE
SELECT s.*, p.product_code, p.product_name, pmr.region_name 
FROM sales s
JOIN products p ON p.id = s.sal_prd_id
JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN now() - (INTERVAL '60 days') AND now() 
AND p.product_code = 'PRD7';

--indeks nie został użyty

--6
CREATE INDEX idx_sales_sal_date ON sales USING btree(sal_date);

--7
--DISCARD ALL;
EXPLAIN ANALYZE
SELECT s.*, p.product_code, p.product_name, pmr.region_name 
FROM sales s
JOIN products p ON p.id = s.sal_prd_id
JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN now() - (INTERVAL '60 days') AND now() 
AND p.product_code = 'PRD7';

--indeks został użyty

--8
DROP TABLE IF EXISTS  sales, sales_partitioned CASCADE;

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);
 
 
CREATE TABLE sales_partitioned (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
) PARTITION BY RANGE (sal_date);

CREATE TABLE sales_y2018 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');

CREATE TABLE sales_y2019 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');
   
CREATE TABLE sales_y2020 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2021-01-01') TO ('2022-01-01');
   
CREATE TABLE sales_y2022 PARTITION OF sales_partitioned
	FOR VALUES FROM ('2022-01-01') TO ('2023-01-01');


--DISCARD ALL;
EXPLAIN ANALYZE
INSERT INTO sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 1000000) s(i);  
--Insert on sales  (cost=0.00..77500.00 rows=1000000 width=100) (actual time=7160.411..7160.412 rows=0 loops=1)    
--Execution Time: 7162.713 ms

--DISCARD ALL;
EXPLAIN ANALYZE
INSERT INTO sales_partitioned (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 1000000) s(i);
	   
--Insert on sales_partitioned  (cost=0.00..77500.00 rows=1000000 width=100) (actual time=7247.012..7247.013 rows=0 loops=1)
--Execution Time: 7249.467 ms

--zapytanie bez partycjonowania trwa krócej
