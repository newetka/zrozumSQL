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
	   
--0
SELECT * FROM SALES;
SELECT * FROM PRODUCT_MANUFACTURED_REGION;
SELECT * FROM PRODUCTS;
--1
CREATE OR REPLACE VIEW SALES_2020_EMEA AS
SELECT S.*,
	PMR.REGION_NAME
FROM SALES S
JOIN PRODUCTS P ON P.ID = S.SAL_PRD_ID
JOIN PRODUCT_MANUFACTURED_REGION PMR ON PMR.ID = P.PRODUCT_MAN_REGION
WHERE PMR.REGION_NAME = 'EMEA'
				AND EXTRACT(YEAR
																FROM SAL_DATE) = 2021
				AND EXTRACT(QUARTER
																FROM SAL_DATE) = 4;
--2
--Zmie?? zapytanie z zadania pierwszego w taki spos??b, aby w wynikach dodatkowo,
--obliczy?? sum?? sprzeda??y w podziale na kod produktu (product_code) sortowane wed??ug
--daty sprzeda??y (sal_date), wynik wy??wietl dla ka??dego wiersza (OVER). Tak
--przygotowane zapytanie wykorzystaj do stworzenia widoku zmaterializowanego, kt??ry
--b??dzie m??g?? by?? od??wie??any r??wnolegle (CONCURRENTLY)

CREATE MATERIALIZED VIEW SALES_2020_EMEA_V2 AS
SELECT S.*,
	PMR.REGION_NAME,
	SUM(S.SAL_VALUE) OVER(PARTITION BY P.PRODUCT_CODE
																							ORDER BY S.SAL_DATE) AS SUM_SAL_VALUE
FROM SALES S
JOIN PRODUCTS P ON P.ID = S.SAL_PRD_ID
JOIN PRODUCT_MANUFACTURED_REGION PMR ON PMR.ID = P.PRODUCT_MAN_REGION
WHERE PMR.REGION_NAME = 'EMEA'
				AND EXTRACT(YEAR
																FROM SAL_DATE) = 2021
				AND EXTRACT(QUARTER
																FROM SAL_DATE) = 4 WITH DATA;
CREATE UNIQUE INDEX idx_unique_SALES_2020_EMEA_V2 ON SALES_2020_EMEA_V2 (id);																
REFRESH MATERIALIZED VIEW CONCURRENTLY SALES_2020_EMEA_V2;
--3
--Stw??rz zapytanie, w kt??rego wynikach znajd?? si?? atrybuty: PRODUCT_CODE,
--REGION_NAME i tablica zawieraj?? nazwy produkt??w (PRODUCT_NAME) dla
--wszystkich produkt??w z tabeli PRODUCTS.
SELECT PRODUCT_CODE,
	REGION_NAME,
	ARRAY_AGG(P.PRODUCT_NAME) AS PRODUCTS_TABLE
FROM PRODUCTS P
JOIN PRODUCT_MANUFACTURED_REGION PMR ON PMR.ID = P.PRODUCT_MAN_REGION
GROUP BY PRODUCT_CODE,
	REGION_NAME;
--4
--Dla zapytania z zdania 3 stw??rz now?? tabel?? korzystaj??c z konstrukcji CTAS. Dodaj
--dodatkowo do nowej tabeli 1 kolumn?? zawieraj??c?? warto???? TRUE lub FALSE obliczan??
--na podstawie danych z atrybutu tablicy nazw produkt??w dla kodu i regionu (zadanie 3)
--w taki spos??b, ??e gdy tablica zawiera wi??cej ni?? 1 element warto???? ma by?? TRUE, w
--przeciwnym razie FALSE.
CREATE TABLE expense_tracker.PRODUCTS_V2 AS WITH PRODUCTS_NAMES AS
				(SELECT P.PRODUCT_CODE,
						PMR.REGION_NAME,
						ARRAY_AGG(P.PRODUCT_NAME) AS PRODUCTS_NAMES
					FROM PRODUCTS P
					LEFT JOIN PRODUCT_MANUFACTURED_REGION PMR ON PMR.ID = P.PRODUCT_MAN_REGION
					GROUP BY P.PRODUCT_CODE,
						PMR.REGION_NAME)
SELECT pn.*,
	CASE ARRAY_LENGTH(pn.PRODUCTS_NAMES,1) > 1
					WHEN TRUE THEN TRUE
					ELSE FALSE
	END PRODUCTS_V3
FROM PRODUCTS_NAMES pn;

--5
--Stw??rz now?? tabel?? SALES_ARCHIVE (jako zwyk??y CREATE TABLE nie CTAS), kt??ra
--b??dzie mia??a struktur?? na podstawie tabeli SALES z wyj??tkami:
--nowy atrybut: operation_type VARCHAR(1) NOT NULL
--nowy atrybut: archived_at TIMESTAMP z automatycznym przypisywaniemwarto??ci NOW()
--atrybut created_date powinien by?? usuni??ty
CREATE TABLE sales_archive (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	operation_type VARCHAR(1) NOT NULL,
	archived_at TIMESTAMP DEFAULT now()
);

--6
--Dla tabeli stworzonej w zadaniu 5, utw??rz TRIGGER + FUNKCJE DLA TRIGGERA, kt??ry
--w momencie usuwania, lub aktualizacji wierszy w tabeli SALES, wstawi informacj?? o
--poprzedniej warto??ci do tabeli SALES_ARCHIVE. Po przypisaniu TRIGGERA, usu?? z
--tabeli SALES wszystkie dane sprzeda??owe z Pa??dziernika 2020 (10.2020).
DROP FUNCTION sales_archive_function CASCADE;
CREATE FUNCTION sales_archive_function() 
	RETURNS TRIGGER
	LANGUAGE plpgsql
	AS $$
		BEGIN	
			IF (TG_OP = 'UPDATE') THEN
				INSERT INTO sales_archive (sal_description, sal_date, sal_value, sal_prd_id, operation_type)
					 VALUES(OLD.sal_description, OLD.sal_date, OLD.sal_value, OLD.sal_prd_id, 'U');
			ELSEIF (TG_OP = 'DELETE') THEN 
				INSERT INTO sales_archive (sal_description, sal_date, sal_value, sal_prd_id, operation_type)
					 VALUES(OLD.sal_description, OLD.sal_date, OLD.sal_value, OLD.sal_prd_id, 'D');
			END IF;
 		    RETURN NULL; -- rezultat zignoruj
		END
	$$;  
CREATE TRIGGER sales_archive_trg
	AFTER UPDATE OR DELETE ON sales
		FOR EACH ROW EXECUTE PROCEDURE sales_archive_function();	
DELETE
FROM SALES
WHERE EXTRACT (YEAR
															FROM SAL_DATE) = 2020
				AND EXTRACT(MONTH
																FROM SAL_DATE) = 10







