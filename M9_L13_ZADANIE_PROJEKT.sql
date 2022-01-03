--1
--Stwórz 3 osobne widoki dla wszystkich transakcji z podziałem na rodzaj właściciela
--konta. W widokach wyświetl informacje o nazwie kategorii, nazwie podkategorii, typie
--transakcji, dacie transakcji, roku z daty transakcji, wartości transakcji i type konta.
create or replace view expense_tracker.view_janusz AS
select category_name, subcategory_name, transaction_type_name, owner_name, transaction_date, transaction_value, extract(year from transaction_date) as year, ba_type from expense_tracker.transactions t
join expense_tracker.transaction_bank_accounts tba on t.id_trans_ba=tba.id_trans_ba
join expense_tracker.bank_account_owner ON bank_account_owner.id_ba_own = tba.id_ba_own
join expense_tracker.transaction_category ON transaction_category.id_trans_cat = t.id_trans_cat
join expense_tracker.transaction_subcategory ON transaction_subcategory.id_trans_subcat = t.id_trans_subcat
join expense_tracker.transaction_type ON transaction_type.id_trans_type = t.id_trans_type
join expense_tracker.bank_account_types ON bank_account_types.id_ba_type = tba.id_ba_typ
where owner_name='Janusz Kowalski';
create or replace view expense_tracker.view_janusz_grazyna AS
select category_name, subcategory_name, transaction_type_name, owner_name, transaction_date, transaction_value, extract(year from transaction_date) as year, ba_type from expense_tracker.transactions t
join expense_tracker.transaction_bank_accounts tba on t.id_trans_ba=tba.id_trans_ba
join expense_tracker.bank_account_owner ON bank_account_owner.id_ba_own = tba.id_ba_own
join expense_tracker.transaction_category ON transaction_category.id_trans_cat = t.id_trans_cat
join expense_tracker.transaction_subcategory ON transaction_subcategory.id_trans_subcat = t.id_trans_subcat
join expense_tracker.transaction_type ON transaction_type.id_trans_type = t.id_trans_type
join expense_tracker.bank_account_types ON bank_account_types.id_ba_type = tba.id_ba_typ
where owner_name='Janusz i Grażynka';
create or replace view expense_tracker.view_grazyna AS
select category_name, subcategory_name, transaction_type_name, owner_name, transaction_date, transaction_value, 
extract(year from transaction_date) as year, ba_type from expense_tracker.transactions t
join expense_tracker.transaction_bank_accounts tba on t.id_trans_ba=tba.id_trans_ba
join expense_tracker.bank_account_owner ON bank_account_owner.id_ba_own = tba.id_ba_own
join expense_tracker.transaction_category ON transaction_category.id_trans_cat = t.id_trans_cat
join expense_tracker.transaction_subcategory ON transaction_subcategory.id_trans_subcat = t.id_trans_subcat
join expense_tracker.transaction_type ON transaction_type.id_trans_type = t.id_trans_type
join expense_tracker.bank_account_types ON bank_account_types.id_ba_type = tba.id_ba_typ
where owner_name='Grażyna Kowalska';
--2
--Korzystając z widoku konta dla Janusza i Grażynki z zadania 1 przygotuj zapytanie, w
--którym wyświetlisz, rok transakcji, typ transakcji, nazwę kategorii, zgrupowaną listę
--unikatowych (DISTINCT) podkategorii razem z sumą transakcji dla grup rok transakcji,
--typ transakcji, nazwę kategorii.

SELECT DISTINCT YEAR,
	TRANSACTION_TYPE_NAME,
	CATEGORY_NAME,
	ARRAY_AGG(distinct SUBCATEGORY_NAME) AS PRODUCTS_TABLE,
	SUM(TRANSACTION_VALUE) OVER(PARTITION BY YEAR,TRANSACTION_TYPE_NAME,CATEGORY_NAME) AS SUM_TRANSACTION_VALUE
FROM EXPENSE_TRACKER.VIEW_JANUSZ_GRAZYNA
GROUP BY YEAR,
	TRANSACTION_TYPE_NAME,
	CATEGORY_NAME,
	TRANSACTION_VALUE;
	
--3
--Dodaj do schematu nową tabelę MONTHLY_BUDGET_PLANNED o atrybutach
--YEAR_MONTH VARCHAR(7) PRIMARY_KEY,
--BUDGET_PLANNED NUMERIC(10,2)
--Dodaj do tej tabeli nowy rekord z planowanym budżetem na dany miesiąc obecnego
--roku (do obu atrybutów BUDGET_PLANNED, LEFT_BUDGET ta sama wartość)
drop table if exists expense_tracker.MONTHLY_BUDGET_PLANNED;
create table expense_tracker.MONTHLY_BUDGET_PLANNED(
YEAR_MONTH VARCHAR(7) PRIMARY KEY,
BUDGET_PLANNED NUMERIC(10,2),
LEFT_BUDGET NUMERIC(10,2)
);

INSERT INTO expense_tracker.monthly_budget_planned (YEAR_MONTH,BUDGET_PLANNED,LEFT_BUDGET) values
(extract(month from CURRENT_Date), 1000,1000)

--4
--Dodaj nowy Wyzwalacz do tabeli TRANSACTIONS, który przy każdorazowym dodaniu
--/ zaktualizowaniu lub usunięciu wartości zmieni wartość LEFT_BUDGET odpowiednio
--w tabeli expense_tracker.monthly_budget_planned.
DROP FUNCTION transaction_archive_function CASCADE;
CREATE FUNCTION transaction_archive_function() 
	RETURNS TRIGGER
	LANGUAGE plpgsql
	AS $$
		BEGIN	
			IF (TG_OP = 'UPDATE') THEN
				update expense_tracker.monthly_budget_planned set LEFT_BUDGET=LEFT_BUDGET+old.TRANSACTION_value-new.TRANSACTION_value;
			ELSEIF (TG_OP = 'INSERT') THEN
				update expense_tracker.monthly_budget_planned set LEFT_BUDGET=LEFT_BUDGET-old.TRANSACTION_value;
			ELSEIF (TG_OP = 'DELETE') THEN 
				update expense_tracker.monthly_budget_planned set LEFT_BUDGET=LEFT_BUDGET+old.TRANSACTION_value;
			END IF;
 		    RETURN NULL; -- rezultat zignoruj
		END
	$$;  
CREATE TRIGGER transaction_archive_trg
	AFTER UPDATE OR DELETE OR INSERT ON expense_tracker.transactions
		FOR EACH ROW EXECUTE PROCEDURE transaction_archive_function();	

--5
--Przetestuj działanie wyzwalacza dla kilku przykładowych operacji.
update expense_tracker.transactions set transaction_value=20
where transaction_description='28d' and transaction_date='2015-07-01';

delete from expense_tracker.transactions where
transaction_description='187' and transaction_date='2015-08-01';

INSERT INTO expense_tracker.transactions (id_trans_ba ,id_trans_cat, id_trans_subcat,id_trans_type,id_user,transaction_value,transaction_description)					    
	 VALUES (1,1,1,1,2,100,'test 3' );
--insert nie działa. Po wykonoaniu inserta w kolumnie LEFT_BUDGET pojawia się null. Co jest błędne w moim zapytaniu/funkcji?

--6
--Czego brakuje w tym triggerze? Jakie potencjalnie spowoduje problemy w kontekście
--danych w tabeli MONTHLY_BUDGET_PLANNED.

--co w przypadku przekroczenia budżetu?
--null w kolumnie LEFT_BUDGET przy insercie?
--

