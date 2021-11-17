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