--1
SELECT owner_name, owner_desc, ba_type, ba_desc, ba.active, bank_account_name, user_login 
FROM expense_tracker.bank_account_owner ao
JOIN expense_tracker.transaction_bank_accounts ba ON ao.ID_BA_OWN=ba.ID_BA_OWN
JOIN expense_tracker.bank_account_types bt ON ao.ID_BA_OWN=bt.ID_BA_OWN
WHERE OWNER_NAME='Janusz Kowalski';
--2
select * from expense_tracker.transaction_category;
select * from expense_tracker.transaction_subcategory;

select category_name, subcategory_name  
from expense_tracker.transaction_category c 
join expense_tracker.transaction_subcategory s on s.id_trans_cat= c.id_trans_cat
order by c.id_trans_cat;

--3
select * from expense_tracker.transactions t
join expense_tracker.transaction_category c on c.id_trans_cat=t.id_trans_cat and category_name='JEDZENIE'

--4
insert into expense_tracker.transaction_subcategory (subcategory_name, id_trans_cat) values ('Jedzenie NOWE',1);

with transaction_3  as (select * from expense_tracker.transactions t
join expense_tracker.transaction_category c on c.id_trans_cat=t.id_trans_cat and c.category_name='JEDZENIE' where t.id_trans_subcat=-1 )

update expense_tracker.transactions t
set id_trans_subcat=(select s.id_trans_subcat from expense_tracker.transaction_subcategory s where subcategory_name='Jedzenie NOWE')
where t.id_trans_subcat=-1 and t.id_trans_cat=1
returning *

--5
select c.category_name, s.subcategory_name, tt.transaction_type_name, t.transaction_date, t.transaction_value from expense_tracker.transactions t
join expense_tracker.transaction_category c on c.id_trans_cat=t.id_trans_cat
join expense_tracker.transaction_subcategory s on s.id_trans_cat= c.id_trans_cat
join expense_tracker.transaction_type tt ON tt.id_trans_type = t.id_trans_type
join expense_tracker.transaction_bank_accounts ba on ba.id_trans_ba = t.id_trans_ba
where cast(extract(year from t.transaction_date) as text)='2020'
and ba.bank_account_name='OSZCZ - Janusz i Grażynka'
