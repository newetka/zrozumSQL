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