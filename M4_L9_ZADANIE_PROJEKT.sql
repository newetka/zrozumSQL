--M4_L9
--1
CREATE ROLE expense_tracker_user WITH LOGIN PASSWORD 'user$1Passw0r1';
--2
--REVOKE CREATE ON SCHEMA public FROM public;
--3 Jeżeli w Twoim środowisku istnieje już schemat expense_tracker (z obiektami tabel) usuń 
--go korzystając z polecenie DROP CASCADE
drop schema if exists expense_tracker cascade
--4
CREATE ROLE expense_tracker_group;
--5
create schema expense_tracker
AUTHORIZATION expense_tracker_group;
--6
GRANT CONNECT ON DATABASE "ZrozumSQL" TO expense_tracker_group; 
GRANT ALL PRIVILEGES ON SCHEMA expense_tracker TO expense_tracker_group;
--7
GRANT expense_tracker_group TO expense_tracker_user;

--ZADANIA PROJEKTOWE
create schema if not exists expense_tracker;

CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_owner ( 
	id_ba_own integer primary key,
	owner_name character varying(50) not null,
	owner_desc character varying(250),
	user_login integer not null,
	active boolean default true not null,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_types ( 
	id_ba_type integer primary key,
	ba_type character varying(50) not null,
	ba_desc character varying(250),
	active boolean default true not null,
	is_common_account boolean default false not null,
	id_ba_own integer,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.transactions ( 
	id_ba_type integer primary key,
	id_trans_ba integer,
	id_trans_cat integer,
	id_trans_subcat integer,
	id_trans_type integer,
	id_user integer,
	transaction_date date default current_date,
	transaction_value numeric(9,2),
	transaction_descript text,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.transaction_bank_accounts ( 
	id_trans_ba integer primary key,
	id_ba_own integer,
	id_ba_typ integer,
	bank_account_name character varying(50) not null,
	bank_account_desc character varying(250),
	active boolean default true not null,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.transaction_category ( 
	id_trans_cat integer primary key,
	category_name character varying(50) not null,
	category_description character varying(250),
	active boolean default true not null,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.transaction_subcategory ( 
	id_trans_subcat integer primary key,
	id_trans_cat integer,
	subcategory_name character varying(50) not null,
	subcategory_description character varying(250),
	active boolean default true not null,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.transaction_type ( 
	id_trans_type integer primary key,
	transaction_type_name character varying(50) not null,
	transaction_type_desc character varying(250),
	active boolean default true not null,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);

CREATE TABLE IF NOT EXISTS expense_tracker.users ( 
	id_user integer primary key,
	user_login character varying(25) not null,
	user_name character varying(50) not null,
	user_password character varying(100) not null,
	password_salt character varying(100) not null,
	active boolean default true not null,
	insert_date timestamp default current_timestamp,
	update_date timestamp default current_timestamp
);
--BANK_ACCOUNT_TYPES: Atrybut ID_BA_OWN ma być referencją do BANK_ACCOUNT_OWNER (ID_BA_OWN) 
ALTER TABLE expense_tracker.BANK_ACCOUNT_TYPES 
	ADD FOREIGN KEY (ID_BA_OWN) 
	REFERENCES expense_tracker.BANK_ACCOUNT_OWNER (ID_BA_OWN);
--TRANSACTIONS: Atrybut ID_TRANS_BA ma być referencją do TRANSACTION_BANK_ACCOUNTS (ID_TRANS_BA) 
ALTER TABLE expense_tracker.TRANSACTIONS 
	ADD FOREIGN KEY (ID_TRANS_BA) 
	REFERENCES expense_tracker.TRANSACTION_BANK_ACCOUNTS (ID_TRANS_BA);
--TRANSACTIONS: Atrybut ID_TRANS_CAT ma być referencją do TRANSACTION_CATEGORY (ID_TRANS_CAT)  
ALTER TABLE expense_tracker.TRANSACTIONS 
	ADD FOREIGN KEY (ID_TRANS_CAT) 
	REFERENCES expense_tracker.TRANSACTION_CATEGORY (ID_TRANS_CAT);
--TRANSACTIONS: Atrybut ID_TRANS_SUBCAT ma być referencją do TRANSACTION_SUBCATEGORY (ID_TRANS_SUBCAT)   
ALTER TABLE expense_tracker.TRANSACTIONS 
	ADD FOREIGN KEY (ID_TRANS_SUBCAT) 
	REFERENCES expense_tracker.TRANSACTION_SUBCATEGORY (ID_TRANS_SUBCAT);
--TRANSACTIONS: Atrybut ID_TRANS_TYPE ma być referencją do TRANSACTION_TYPE (ID_TRANS_TYPE)   
ALTER TABLE expense_tracker.TRANSACTIONS 
	ADD FOREIGN KEY (ID_TRANS_TYPE) 
	REFERENCES expense_tracker.TRANSACTION_TYPE (ID_TRANS_TYPE);
--TRANSACTIONS: Atrybut ID_USER ma być referencją do USERS (ID_USER)   
ALTER TABLE expense_tracker.TRANSACTIONS 
	ADD FOREIGN KEY (ID_USER) 
	REFERENCES expense_tracker.USERS (ID_USER);
--TRANSACTION_BANK_ACCOUNTS: Atrybut ID_BA_OWN ma być referencją do BANK_ACCOUNT_OWNER (ID_BA_OWN)    
ALTER TABLE expense_tracker.TRANSACTION_BANK_ACCOUNTS 
	ADD FOREIGN KEY (ID_BA_OWN) 
	REFERENCES expense_tracker.BANK_ACCOUNT_OWNER (ID_BA_OWN);
--TRANSACTION_BANK_ACCOUNTS: Atrybut ID_BA_TYP ma być referencją do BANK_ACCOUNT_TYPES (ID_BA_TYPE)   
ALTER TABLE expense_tracker.TRANSACTION_BANK_ACCOUNTS 
	ADD FOREIGN KEY (ID_BA_TYP) 
	REFERENCES expense_tracker.BANK_ACCOUNT_TYPES (ID_BA_TYPE);
--TRANSACTION_SUBCATEGORY: Atrybut ID_TRANS_CAT ma być referencją do TRANSACTION_CATEGORY (ID_TRANS_CAT)    
ALTER TABLE expense_tracker.TRANSACTION_SUBCATEGORY 
	ADD FOREIGN KEY (ID_TRANS_CAT) 
	REFERENCES expense_tracker.TRANSACTION_CATEGORY (ID_TRANS_CAT);
	