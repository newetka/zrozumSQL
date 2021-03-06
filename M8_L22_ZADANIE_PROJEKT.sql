SELECT *
FROM EXPENSE_TRACKER.TRANSACTIONS 
--1
--Oblicz sumę transakcji w podziale na kategorie transakcji. W wyniku wyświetl nazwę kategorii i całkowitą sumę.
SELECT C.CATEGORY_NAME,
	SUM(T.TRANSACTION_VALUE)
FROM EXPENSE_TRACKER.TRANSACTIONS T
JOIN EXPENSE_TRACKER.TRANSACTION_CATEGORY C ON T.ID_TRANS_CAT = C.ID_TRANS_CAT
GROUP BY 1 

--2
--Oblicz sumę wydatków na Używki dokonana przez Janusza (Janusz Kowalski) z jego konta prywatnego (ROR - Janusz) w obecnym roku 2020
--polecenie zakłada że Janusz Kowalski jest właścicielem konta ROR - Janusz, więc nie dokładam dodatkowego warunku do zapytania USER_NAME='Janusz Kowalski'
SELECT SUMA
FROM
				(SELECT C.CATEGORY_NAME,
						SUM(T.TRANSACTION_VALUE) AS SUMA
					FROM EXPENSE_TRACKER.TRANSACTIONS T
					JOIN EXPENSE_TRACKER.TRANSACTION_CATEGORY C ON T.ID_TRANS_CAT = C.ID_TRANS_CAT
					JOIN EXPENSE_TRACKER.TRANSACTION_BANK_ACCOUNTS TBA ON TBA.ID_TRANS_BA = T.ID_TRANS_BA
					WHERE CATEGORY_NAME = 'UŻYWKI'
									AND TBA.BANK_ACCOUNT_NAME = 'ROR - Janusz'
									AND EXTRACT(YEAR
																					FROM T.TRANSACTION_DATE) = 2020
					GROUP BY 1)A
--3
--Stwórz zapytanie, które będzie podsumowywać wydatki (typ transakcji: Obciążenie) na
--wspólnym koncie RoR - Janusza i Grażynki w taki sposób, aby widoczny był podział
--sumy wydatków, ze względu na rok, rok i kwartał (format: 2019_1), rok i miesiąc (format:
--2019_12) w roku 2019. Skorzystaj z funkcji ROLLUP
  SELECT EXTRACT(YEAR FROM TRANSACTION_DATE) as d_year,
  EXTRACT(YEAR FROM TRANSACTION_DATE)||'_' ||EXTRACT(QUARTER FROM TRANSACTION_DATE) d_quarter, 
  EXTRACT(YEAR FROM TRANSACTION_DATE)||'_' ||EXTRACT(MONTH FROM TRANSACTION_DATE) d_month,
         GROUPING(EXTRACT(YEAR FROM TRANSACTION_DATE),
  EXTRACT(YEAR FROM TRANSACTION_DATE)||'_' ||EXTRACT(QUARTER FROM TRANSACTION_DATE), 
  EXTRACT(YEAR FROM TRANSACTION_DATE)||'_' ||EXTRACT(MONTH FROM TRANSACTION_DATE)),
         SUM(T.TRANSACTION_VALUE)
FROM EXPENSE_TRACKER.TRANSACTIONS T
JOIN EXPENSE_TRACKER.TRANSACTION_TYPE TT ON TT.ID_TRANS_TYPE = T.ID_TRANS_TYPE
WHERE EXTRACT(YEAR FROM TRANSACTION_DATE) = '2019'
AND TT.TRANSACTION_TYPE_NAME = 'Obciążenie'
GROUP BY ROLLUP ((EXTRACT(YEAR FROM TRANSACTION_DATE)),
  (EXTRACT(YEAR FROM TRANSACTION_DATE)||'_' ||EXTRACT(QUARTER FROM TRANSACTION_DATE)), 
  (EXTRACT(YEAR FROM TRANSACTION_DATE)||'_' ||EXTRACT(MONTH FROM TRANSACTION_DATE)));	
  
--4
--Stwórz zapytanie podsumowujące sumę wydatków na koncie wspólnym Janusza i
--Grażynki (ROR- Wspólny), wydatki (typ: Obciążenie), w podziale na poszczególne lata
--od roku 2015 wzwyż. Do wyników (rok, suma wydatków) dodaj korzystając z funkcji
--okna atrybut, który będzie różnicą pomiędzy danym rokiem a poprzednim (balans rok
--do roku).
WITH SUM_TRANSACTIONS AS
				(SELECT EXTRACT(YEAR FROM T.TRANSACTION_DATE) AS TRANSACTION_YEAR,
					SUM(T.TRANSACTION_VALUE) AS SUM_TRANSACTIONS_VALUE
					FROM EXPENSE_TRACKER.TRANSACTIONS T
					JOIN EXPENSE_TRACKER.TRANSACTION_TYPE TT ON TT.ID_TRANS_TYPE = T.ID_TRANS_TYPE
					AND TT.TRANSACTION_TYPE_NAME = 'Obciążenie'
					AND EXTRACT(YEAR
					FROM T.TRANSACTION_DATE) >= 2015
					JOIN EXPENSE_TRACKER.TRANSACTION_BANK_ACCOUNTS TBA ON TBA.ID_TRANS_BA = T.ID_TRANS_BA
					JOIN EXPENSE_TRACKER.BANK_ACCOUNT_TYPES BAT ON BAT.ID_BA_TYPE = TBA.ID_BA_TYP
					AND BAT.BA_TYPE = 'ROR - WSPÓLNY'
					GROUP BY TRANSACTION_YEAR),
				summary AS
				(SELECT *,
					LAG(SUM_TRANSACTIONS_VALUE) OVER (
					ORDER BY TRANSACTION_YEAR) AS PREVIOUS_YEAR_EXPENSES
					FROM SUM_TRANSACTIONS)
SELECT TRANSACTION_YEAR,
	SUM_TRANSACTIONS_VALUE AS SPENDING_SUM,
	PREVIOUS_YEAR_EXPENSES AS PREV_YEAR_SPEND,
	PREVIOUS_YEAR_EXPENSES - SUM_TRANSACTIONS_VALUE AS BALANS
FROM summary;



--5. Korzystając z funkcji LAST_VALUE pokaż różnicę w dniach, pomiędzy kolejnymi
--transakcjami (Obciążenie) na prywatnym koncie Janusza (RoR) dla podkategorii
--Technologie w 1 kwartale roku 2020.

WITH TRANSACTIONS_QUERY AS
				(SELECT T.ID_TRANSACTION,
						T.TRANSACTION_VALUE,
						TS.SUBCATEGORY_NAME,
						T.TRANSACTION_DATE
					FROM EXPENSE_TRACKER.TRANSACTIONS T
					JOIN EXPENSE_TRACKER.TRANSACTION_BANK_ACCOUNTS TBA ON TBA.ID_TRANS_BA = T.ID_TRANS_BA
					AND TBA.BANK_ACCOUNT_NAME = 'ROR - Janusz'
					AND EXTRACT (YEAR FROM T.TRANSACTION_DATE) = '2019'
					AND EXTRACT (QUARTER FROM T.TRANSACTION_DATE) = '1'
					JOIN EXPENSE_TRACKER.TRANSACTION_SUBCATEGORY TS ON TS.ID_TRANS_SUBCAT = T.ID_TRANS_SUBCAT
					AND TS.SUBCATEGORY_NAME = 'Technologie')
SELECT *,
	LAST_VALUE(TRANSACTION_DATE) OVER (
	ORDER BY TRANSACTION_DATE GROUPS BETWEEN CURRENT ROW AND 1 FOLLOWING EXCLUDE CURRENT ROW) AS NEXT_TECH_TRANSACTION,
	LAST_VALUE(TRANSACTION_DATE) OVER (
	ORDER BY TRANSACTION_DATE GROUPS BETWEEN CURRENT ROW AND 1 FOLLOWING EXCLUDE CURRENT ROW) - TRANSACTION_DATE AS DAYS_SINCE_PREVIOUS_TECH_TRANSACTIONS
FROM TRANSACTIONS_QUERY;