--1
CREATE ROLE user_training WITH LOGIN PASSWORD 'train$1Passw0r4';
--2
CREATE SCHEMA IF NOT EXISTS training
AUTHORIZATION user_training;
--3
DROP ROLE user_training;
--4
REASSIGN OWNED BY user_training TO postgres;
DROP ROLE user_training;
--5
CREATE ROLE reporting_ro;
GRANT CONNECT ON DATABASE postgres TO reporting_ro; 
GRANT USAGE ON SCHEMA training TO reporting_ro;
GRANT CREATE ON SCHEMA training TO reporting_ro;
GRANT ALL PRIVILEGES ON SCHEMA training TO reporting_ro;
--6
CREATE ROLE reporting_user WITH LOGIN PASSWORD 'repo$1Passw0r4';
GRANT reporting_ro TO reporting_user;
--7
create table training.test ()
--8
REVOKE CREATE ON SCHEMA training FROM reporting_ro;
--9
drop table training.test2 ()
create table public.test2 ()
--brak możliwośći utworzenia ww. tabel przez użytkownika reporting_user
REASSIGN OWNED BY reporting_user TO postgres;
DROP ROLE reporting_user;
REASSIGN OWNED BY reporting_ro TO postgres;
DROP OWNED BY reporting_ro;
DROP ROLE reporting_ro;

