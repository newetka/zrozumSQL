--1
SELECT  schemaname,	
		tablename,
		tableowner,
		't' AS object_type
FROM pg_catalog.pg_tables 
UNION All
SELECT  schemaname ,
		viewname,
		viewowner,
		'v' AS object_type
FROM pg_catalog.pg_views 
UNION All
SELECT 
	schemaname,
	tablename,
	indexname,
	'i' AS object_type
FROM pg_catalog.pg_indexes;

--2
DROP TABLE IF EXISTS users;
CREATE TABLE users(
user_name VARCHAR(100),
user_password VARCHAR(100),
crypt VARCHAR(100));

INSERT INTO users(user_name, user_password) VALUES 
	('user1','ultraSilneHa3l0$567');
CREATE EXTENSION pgcrypto;
UPDATE users SET crypt = crypt(user_password, gen_salt('md5'));
--SELECT * FROM users;
SELECT 
	user_name,
	crypt = crypt(user_password,crypt) AS correct_password
FROM users;

--3
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
id SERIAL,
c_name TEXT,
c_mail TEXT,
c_phone VARCHAR(9),
c_description TEXT
);
INSERT INTO customers (c_name, c_mail, c_phone, c_description)
VALUES ('Krzysztof Bury', 'kbur@domein.pl', '123789456',
left(md5(random()::text), 15)),
('Onufry Zagłoba', 'zagloba@ogniemimieczem.pl',
'100000001', left(md5(random()::text), 15)),
('Krzysztof Bury', 'kbur@domein.pl', '123789456',
left(md5(random()::text), 15)),
('Pan Wołodyjowski', 'p.wolodyj@polska.pl',
'987654321', left(md5(random()::text), 15)),
('Michał Skrzetuski', 'michal<at>zamek.pl',
'654987231', left(md5(random()::text), 15)),
('Bohun Tuhajbejowicz', NULL, NULL,
left(md5(random()::text), 15));

SELECT *
FROM CUSTOMERS;


SELECT c_name,
CONCAT('x.',SUBSTRING(c_mail from '[@>](.*)$')) as mail,
'XXX-XXX-' || substring(c_phone, length(c_phone) - 2) AS phone_number,c_description FROM
(SELECT c_name, c_mail, c_phone, c_description, row_number() OVER (PARTITION BY c_name, c_mail, c_phone,c_description
order by c_mail)rn FROM CUSTOMERS) sq 
WHERE rn = 1;
		
