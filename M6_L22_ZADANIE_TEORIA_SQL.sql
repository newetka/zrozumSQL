DROP TABLE IF EXISTS products;
CREATE TABLE products (
id SERIAL,
product_name VARCHAR(100),
product_code VARCHAR(10),
product_quantity NUMERIC(10,2),
manufactured_date DATE,
added_by TEXT DEFAULT 'admin',
created_date TIMESTAMP DEFAULT now()
);
INSERT INTO products (product_name, product_code, product_quantity,
manufactured_date)
SELECT 'Product '||floor(random() * 10 + 1)::int,
'PRD'||floor(random() * 10 + 1)::int,
random() * 10 + 1,
CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date)
FROM generate_series(1, 10) s(i);
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
id SERIAL,
sal_description TEXT,
sal_date DATE,
sal_value NUMERIC(10,2),
sal_qty NUMERIC(10,2),
sal_product_id INTEGER,
added_by TEXT DEFAULT 'admin',
created_date TIMESTAMP DEFAULT now()
);
INSERT INTO sales (sal_description, sal_date, sal_value, sal_qty, sal_product_id)
SELECT left(md5(i::text), 15),
CAST((NOW() - (random() * (interval '60 days'))) AS DATE),
random() * 100 + 1,
floor(random() * 10 + 1)::int,
floor(random() * 10)::int
FROM generate_series(1, 10000) s(i);

--1
select distinct manufactured_date as data_stworzenia from products
select product_name, max(manufactured_date) as data_stworzenia from products
group by 1
--2
select count(product_name) as ilosc_produktow_dla_kodu, product_code from products
group by product_code
--3
select product_name from products
where product_code in('PRD1','PRD9')
--4
select * from products where manufactured_date between '01-08-2020' and '31-08-2020'
select * from products where manufactured_date > '01-08-2020' and manufactured_date <= '31-08-2020'
--5
select product_name from products p
WHERE NOT EXISTS (SELECT 1
 				 FROM sales s 
 				WHERE p.id = s.sal_product_id);
--6
SELECT product_name
FROM products p
 WHERE id
		= ANY (SELECT 1
 				 FROM sales s 
 				WHERE p.id = s.sal_product_id and sal_value>100)
--7
DROP TABLE IF EXISTS pRODUCTS_OLD_WAREHOUSE;
cREATE TABLE pRODUCTS_OLD_WAREHOUSE (
id SERIAL,
product_name VARCHAR(100),
product_code VARCHAR(10),
product_quantity NUMERIC(10,2),
manufactured_date DATE,
added_by TEXT DEFAULT 'admin',
created_date TIMESTAMP DEFAULT now()
);
INSERT INTO pRODUCTS_OLD_WAREHOUSE (product_name, product_code, product_quantity,
manufactured_date)
SELECT 'Product '||floor(random() * 10 + 1)::int,
'PRD'||floor(random() * 10 + 1)::int,
random() * 10 + 1,
CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date)
FROM generate_series(1, 10) s(i);
--8
select PRODUCT_NAME from pRODUCTS_OLD_WAREHOUSE
union all
(select PRODUCT_NAME from products
limit 5)

select PRODUCT_NAME from pRODUCTS_OLD_WAREHOUSE
union
(select PRODUCT_NAME from products
limit 5)
--w przypadku union all nie zostały pominięte żadne wiersze, w przypadku union zostały pominięte dublikaty nazw
--9
select PRODUCT_code from pRODUCTS_OLD_WAREHOUSE
except
select PRODUCT_code from products
--10
select * from sales 
order by sal_value desc
limit 10
--11
select substring(sal_description,1,3), sal_description  from sales
limit 3	
--12
select sal_description  from sales
where sal_description like 'c4c%'
				 


