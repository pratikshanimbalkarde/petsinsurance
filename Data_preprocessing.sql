create database petsdata;

use petsdata;

--view the data
SELECT * FROM audit_status; 
SELECT * FROM claim_data;
SELECT * FROM condition_data;

--count before data cleaning
SELECT count(*) FROM audit_status; 
SELECT count(*) FROM claim_data;
SELECT COUNT(*) FROM condition_data;

--missing values check
SELECT count(*) FROM audit_status where claim_id is null;
SELECT count(*) FROM claim_data where claim_id is null;
SELECT COUNT(*) FROM condition_data where claim_id is null;

--remove the missing values
delete from audit_status where claim_id is null;
delete from  condition_data where claim_id is null;

--count before data cleaning
SELECT count(*) FROM audit_status; 
SELECT count(*) FROM claim_data;
SELECT COUNT(*) FROM condition_data;


--removing the undefined and empty column fields
ALTER TABLE condition_data DROP COLUMN F12, F13, F14;

--replace the null values with 0
UPDATE condition_data SET condition_net_amount= 0 WHERE condition_net_amount IS NULL;
UPDATE condition_data SET condition_rejected_amount= 0 WHERE condition_rejected_amount IS NULL;
UPDATE condition_data SET condition_excess_amount= 0 WHERE condition_excess_amount IS NULL;


---checking values after replacement
select * from condition_data where condition_net_amount is null;
select count(*) from condition_data  where condition_rejected_amount is null;
select count(*) from condition_data  where condition_excess_amount is null;

---converting negative values to positive values
select * from condition_data where condition_excess_amount < 0;
UPDATE condition_data SET condition_net_amount = ABS(condition_net_amount)  WHERE condition_net_amount< 0;
UPDATE condition_data SET condition_excess_amount=ABS(condition_excess_amount) WHERE condition_excess_amount < 0;
