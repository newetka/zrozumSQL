--1
--cd C:\Program Files\PostgreSQL\12\bin
--psql -U postgres -p 5433 -h localhost -d ZrozumSQL -f "‪C:\Users\Laptop\Documents\SQL\skrypt.sql"

--2
--powiązania z tabelami są zgodne z założeniami (wniosek na podstawie porównania diagramów)
--
select * from expense_tracker.transactions where id_trans_ba=-1 or id_trans_cat=-1 or id_trans_subcat=-1 or id_user=-1
--689 transakcji ma brakujące połączenia z tabelami powiazanymi ( gdzie we wszystkich brakuje połączenia z tabelą transaction_subcategory)

--3
--dodanie wierszy tych samych co w zadaniu z modułu 5 (użyłam tych samych 'Testowych wpisów')
--problem jedynie z kolumną Active, która w skrypcie ustawiona jest jako character(1), a w mojej wersji był to boolean. Skłaniałabym się ku takiej zmianie
INSERT INTO expense_tracker.bank_account_owner (owner_name, owner_desc, user_login, active)					    
	 VALUES ('Test', 'wpis testowy',1, '0' );
INSERT INTO expense_tracker.bank_account_types (ba_type, ba_desc, id_ba_own)					    
	 VALUES ('Test', 'wpis testowy', 1 );
INSERT INTO expense_tracker.transaction_bank_accounts (id_ba_own, id_ba_typ, bank_account_name, bank_account_desc)					    
	 VALUES (1,2 , 'Test Bank account name','Test Bank account desc' );	 
INSERT INTO expense_tracker.transaction_category (category_name, category_description)					    
	 VALUES ('Test','Test Category' );
INSERT INTO expense_tracker.transaction_subcategory (id_trans_cat, subcategory_name, subcategory_description)					    
	 VALUES (1,'Test Subcategory','Test Subcategory desc' );
INSERT INTO expense_tracker.transaction_type (transaction_type_name, transaction_type_desc)					    
	 VALUES ('Test type name','Test type desc' );
INSERT INTO expense_tracker.users (user_login,user_name,user_password,password_salt)					    
	 VALUES ('test', 'Test user', 'test','test' );
INSERT INTO expense_tracker.transactions (id_trans_ba ,id_trans_cat, id_trans_subcat,id_trans_type,id_user,transaction_value,transaction_description)					    
	 VALUES (2,1,1,1,3,1000,'test transaction' );
--PRPOPZYCJE ZMIAN:
----ze względu na występujące braki powiązań, należałoby rozszerzyć tabelę podkategorii, gdyż najwyraźniej brakuje odpowiednich
--połączenie tabel USERS i BANK_ACCOUNT_OWNER, sądze że przy tak małej ilosci użytkowników, rozbicie na dwie tabele jest zbędne
--podobny wniosek co do tabel transaction_bank_accounts i bank_account_types, tabele te połączyłabym w jedną (przy takiej ilości danych rozbicie uważam za nadmiarowe)
--zbędna relacja między tabelą transactions, a transaction_category - istnieje relacja między transactions, a transaction_subcategory - tutaj jest relacja z transaction_category. To powinno być wystarczajace (znając podkategorię, jesteśmy już w stanie wskazać kategorię). 
--Powtórzenie relacji między tabelą transactions, a transaction_category jest przydatna jedynie wówczas, gdy brakuje podkategorii, lub gdy użytkownik chce na pierwszy rzut oka widzieć w tabeli kategorię.
