--Indeksy BTREE
DISCARD ALL;
EXPLAIN ANALYZE
SELECT  	tc.category_name ,
			t.transaction_date ,
			EXTRACT (YEAR FROM t.transaction_date) AS transaction_year,
			t.transaction_value 
	FROM expense_tracker.transactions t 
	JOIN expense_tracker.transaction_category tc ON t.id_trans_cat = tc.id_trans_cat
	JOIN expense_tracker.transaction_bank_accounts tba ON tba.id_trans_ba = t.id_trans_ba
	JOIN expense_tracker.bank_account_owner ow ON ow.id_ba_own = tba.id_ba_own
	WHERE ow.owner_name= 'Janusz Kowalski' AND EXTRACT (YEAR FROM t.transaction_date)  = '2016' 
		   
--Execution Time: 3.490 ms
 
 		  
CREATE INDEX idx_transaction_year ON expense_tracker.transactions USING btree (EXTRACT (YEAR FROM transaction_date));
CREATE INDEX idx_bank_account_owner_name ON expense_tracker.bank_account_owner USING btree (owner_name);


DISCARD ALL;
EXPLAIN ANALYZE
SELECT  	tc.category_name ,
			t.transaction_date ,
			EXTRACT (YEAR FROM t.transaction_date) AS transaction_year,
			t.transaction_value 
	FROM expense_tracker.transactions t 
	JOIN expense_tracker.transaction_category tc ON t.id_trans_cat = tc.id_trans_cat
	JOIN expense_tracker.transaction_bank_accounts tba ON tba.id_trans_ba = t.id_trans_ba
	JOIN expense_tracker.bank_account_owner ow ON ow.id_ba_own = tba.id_ba_own
	WHERE ow.owner_name= 'Janusz Kowalski' AND EXTRACT (YEAR FROM t.transaction_date)  = '2016' 
		   
--Execution Time: 0.869 ms

--widoki
DISCARD ALL;
EXPLAIN ANALYZE
SELECT CATEGORY_NAME,
	SUBCATEGORY_NAME,
	TRANSACTION_TYPE_NAME,
	OWNER_NAME,
	TRANSACTION_DATE,
	TRANSACTION_VALUE,
	EXTRACT(YEAR FROM TRANSACTION_DATE) AS YEAR,
	BA_TYPE
FROM EXPENSE_TRACKER.TRANSACTIONS T
JOIN EXPENSE_TRACKER.TRANSACTION_BANK_ACCOUNTS TBA ON T.ID_TRANS_BA = TBA.ID_TRANS_BA
JOIN EXPENSE_TRACKER.BANK_ACCOUNT_OWNER ON BANK_ACCOUNT_OWNER.ID_BA_OWN = TBA.ID_BA_OWN
JOIN EXPENSE_TRACKER.TRANSACTION_CATEGORY ON TRANSACTION_CATEGORY.ID_TRANS_CAT = T.ID_TRANS_CAT
JOIN EXPENSE_TRACKER.TRANSACTION_SUBCATEGORY ON TRANSACTION_SUBCATEGORY.ID_TRANS_SUBCAT = T.ID_TRANS_SUBCAT
JOIN EXPENSE_TRACKER.TRANSACTION_TYPE ON TRANSACTION_TYPE.ID_TRANS_TYPE = T.ID_TRANS_TYPE
JOIN EXPENSE_TRACKER.BANK_ACCOUNT_TYPES ON BANK_ACCOUNT_TYPES.ID_BA_TYPE = TBA.ID_BA_TYP
WHERE OWNER_NAME = 'Janusz Kowalski'
				AND EXTRACT(YEAR FROM TRANSACTION_DATE) = '2016'
				AND CATEGORY_NAME = 'JEDZENIE' ;

--Execution Time: 4.189 ms

CREATE MATERIALIZED VIEW EXPENSE_TRACKER.VIEW_JANUSZ_JEDZENIE_2016 AS
SELECT CATEGORY_NAME,
	SUBCATEGORY_NAME,
	TRANSACTION_TYPE_NAME,
	OWNER_NAME,
	TRANSACTION_DATE,
	TRANSACTION_VALUE,
	EXTRACT(YEAR FROM TRANSACTION_DATE) AS YEAR,
	BA_TYPE
FROM EXPENSE_TRACKER.TRANSACTIONS T
JOIN EXPENSE_TRACKER.TRANSACTION_BANK_ACCOUNTS TBA ON T.ID_TRANS_BA = TBA.ID_TRANS_BA
JOIN EXPENSE_TRACKER.BANK_ACCOUNT_OWNER ON BANK_ACCOUNT_OWNER.ID_BA_OWN = TBA.ID_BA_OWN
JOIN EXPENSE_TRACKER.TRANSACTION_CATEGORY ON TRANSACTION_CATEGORY.ID_TRANS_CAT = T.ID_TRANS_CAT
JOIN EXPENSE_TRACKER.TRANSACTION_SUBCATEGORY ON TRANSACTION_SUBCATEGORY.ID_TRANS_SUBCAT = T.ID_TRANS_SUBCAT
JOIN EXPENSE_TRACKER.TRANSACTION_TYPE ON TRANSACTION_TYPE.ID_TRANS_TYPE = T.ID_TRANS_TYPE
JOIN EXPENSE_TRACKER.BANK_ACCOUNT_TYPES ON BANK_ACCOUNT_TYPES.ID_BA_TYPE = TBA.ID_BA_TYP
WHERE OWNER_NAME = 'Janusz Kowalski'
				AND EXTRACT(YEAR FROM TRANSACTION_DATE) = '2016'
				AND CATEGORY_NAME = 'JEDZENIE' ;

DISCARD ALL;
EXPLAIN ANALYZE
SELECT *
FROM EXPENSE_TRACKER.VIEW_JANUSZ_JEDZENIE_2016
--Execution Time: 0.057 ms


-- Partycjonowanie transactions 

CREATE TABLE IF NOT EXISTS expense_tracker.transactions_partittioned(
	id_transaction serial ,
	id_trans_ba integer references expense_tracker.transaction_bank_accounts (id_trans_ba), 
	id_trans_cat integer references expense_tracker.transaction_category (id_trans_cat),
	id_trans_subcat integer references expense_tracker.transaction_subcategory (id_trans_subcat),
	id_trans_type integer references expense_tracker.transaction_type (id_trans_type),
 	id_user integer references expense_tracker.users (id_user),
	transaction_date date DEFAULT current_date,
	transaction_value NUMERIC(9,2),
	transaction_description TEXT,
	insert_date timestamp DEFAULT current_timestamp,
	update_date timestamp DEFAULT current_timestamp,
	primary key (id_transaction, transaction_date)
) PARTITION BY RANGE(transaction_date);

CREATE TABLE transactions_2015 PARTITION OF expense_tracker.transactions_partittioned 
	FOR VALUES FROM ('2015-01-01') TO ('2016-01-01'); 

CREATE TABLE transactions_2016 PARTITION OF expense_tracker.transactions_partittioned 
	FOR VALUES FROM ('2016-01-01') TO ('2017-01-01'); 

CREATE TABLE transactions_2017 PARTITION OF expense_tracker.transactions_partittioned 
	FOR VALUES FROM ('2017-01-01') TO ('2018-01-01'); 

CREATE TABLE transactions_2018 PARTITION OF expense_tracker.transactions_partittioned 
	FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');

CREATE TABLE transactions_2019 PARTITION OF expense_tracker.transactions_partittioned 
	FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');


DISCARD ALL;
EXPLAIN ANALYZE
SELECT  	tc.category_name ,
			ts.subcategory_name,
			t.transaction_date ,
			t.transaction_value 
	FROM expense_tracker.transactions t 
	JOIN expense_tracker.transaction_category tc ON t.id_trans_cat = tc.id_trans_cat
	JOIN expense_tracker.transaction_subcategory ts ON t.id_trans_subcat = ts.id_trans_subcat 
													AND tc.id_trans_cat = ts.id_trans_cat 
	WHERE transaction_date BETWEEN '2016-01-01' AND '2016-04-30';
	
--Execution Time: 1.669 ms

DISCARD ALL;
EXPLAIN ANALYZE
SELECT  	tc.category_name ,
			ts.subcategory_name,
			tp.transaction_date ,
			tp.transaction_value 
	FROM expense_tracker.transactions_partittioned tp 
	JOIN expense_tracker.transaction_category tc ON tp.id_trans_cat = tc.id_trans_cat
	JOIN expense_tracker.transaction_subcategory ts ON tp.id_trans_subcat = ts.id_trans_subcat 
													AND tc.id_trans_cat = ts.id_trans_cat 
	WHERE transaction_date BETWEEN '2016-01-01' AND '2016-04-30';
	
--Execution Time: 0.705 ms