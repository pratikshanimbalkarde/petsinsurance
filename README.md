# petsinsurance
Questions:		
			
1.	Describe your approach to completing each below task, including the identification and rectification of any data integrity issues, any useful data fields that aren't provided, and outline processes to proactively maintain data integrity. Please provide relevant SQL statements in any SQL based environment
a.	 First step is to load the into Microsoft sql server: initial data count
1.	Audit status
o	SELECT * FROM audit status; 
o	SELECT count(*) FROM audit_status; status
o	SELECT count(*) FROM audit_status where claim_id is null;
o	–remove empty columns
o	delete from audit_status where claim_id is null;

2.	Claim data
o	SELECT * FROM claim_data; -- check the record in audit status
o	SELECT count(*) FROM claim_data;
o	SELECT count(*) FROM claim_data where claim_id is null;
	
3.	Condition data
o	SELECT * FROM condition_data;
o	SELECT COUNT(*) FROM condition_data;
o	SELECT COUNT(*) FROM condition_data where claim_id is null;
o	delete from  condition_data where claim_id is null;
o	–remove empty columns
o	ALTER TABLE condition_data DROP COLUMN F12, F13, F14;
o	–replace null with 0
o	UPDATE condition_data SET condition_net_amount= 0 WHERE condition_net_amount IS NULL;
o	UPDATE condition_data SET condition_rejected_amount= 0 WHERE condition_rejected_amount IS NULL;
o	UPDATE condition_data SET condition_excess_amount= 0 WHERE condition_excess_amount IS NULL;
o	–negative value to positive value
o	UPDATE condition_data SET condition_net_amount = ABS(condition_net_amount)  WHERE condition_net_amount< 0;
o	UPDATE condition_data SET condition_excess_amount=ABS(condition_excess_amount) WHERE condition_excess_amount < 0;

	2. What additional improvements can you make to bring the dataset to a production-ready level, and how do you prioritise these changes?	

The dataset in the `petsdata` database includes three main tables: `audit_status`, `claim_data`, and `condition_data`. Initial checks were conducted to assess the number of records in each table to understand the dataset's scope. Missing `claim_id` values were addressed in `audit_status` and `condition_data` by removing corresponding rows. Unnecessary columns (`F12`, `F13`, `F14`) were removed from `condition_data` for streamlined data management. Numeric data fields such as `condition_net_amount` and `condition_rejected_amount` were standardized by setting null values to zero. Validation procedures were employed to ensure the accuracy and integrity of data updates across all tables. This included verifying table contents and confirming record counts post-cleansing. Emphasis was placed on maintaining relational consistency, particularly concerning `CLAIM_ID` relationships between `audit_status` and `claim_data`, and `condition_data` and `claim_data`. These steps aimed to prepare the dataset for operational or analytical use, ensuring data accuracy, consistency, and relational integrity were upheld throughout.	
	
 
 3. What can you suggest to enhance the Data dictionary?:
1. Primary Key Definition
    Clearly define the primary key for each table: claim data, audit status and condition data
    Specify the data type (e.g., integer, alphanumeric).
    Explain its unique identifier role within the table.

2.Field Definitions
    Define each field with its respective data type (e.g., integer, date, string).
    Provide a concise description of what each field represents or stores.
    Include any constraints or validation rules (e.g., not null, unique).

3.Relationship Definitions
    Describe the relationships between tables claim data, audit status and condition data, focusing on how primary and foreign keys are used to establish links.
    Explain how these relationships facilitate data integrity and efficient data retrieval.

4.Additional Considerations
    Include any specific business rules or domain-specific requirements that govern the data.
    Define any standard values or codes used in categorical fields.
    Document any historical or temporal aspects related to date fields.
    Specify any audit or logging mechanisms applied to track changes or statuses.
			
			
	
 1. Expand the dataset to include:		
	1.1 Audit status:
      This query retrieves data from the claim_data, audit_status, and condition_data tables. It joins these tables based on CLAIM_ID to include audit status information. The query                 calculates a paidclaimbeforedate status for each condition, categorizing claims as 'correct' if the condition was known before treatment and a positive net amount was paid, 'wrong' if        the condition was known after treatment but a positive net amount was paid, and 'not_yet_paid' otherwise. Results are ordered by CLAIM_ID and CONDITION_ID.
 
select cd.CLAIM_ID, a.CLAIM_AUDIT_STATUS, c.CONDITION_ID, c.CONDITION_KNOWN_FROM_DATE, c.CONDITION_TREATMENT_START_DATE , c.CONDITION_CLAIMED_AMOUNT, c.CONDITION_NET_AMOUNT,
CASE 
when c.CONDITION_KNOWN_FROM_DATE < c.CONDITION_TREATMENT_START_DATE and CAST(c.CONDITION_NET_AMOUNT AS DECIMAL) > 0 THEN 'correct'
WHEN c.CONDITION_KNOWN_FROM_DATE > c.CONDITION_TREATMENT_START_DATE  and CAST(c.CONDITION_NET_AMOUNT AS DECIMAL) > 0 THEN 'wrong'
ELSE 'not_yet_paid' END as paidclaimbeforedate
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID 
order by cd.claim_id, c.CONDITION_ID;
		
	

1.2 Condition data (to incorporate related disease conditions that have been paid on the claims by us as an insurer):
    This query analyzes condition data related to diseases for claims processed by us as an insurer. It selects condition type descriptions and codes, counting the number of claims insured       for each condition type where a net amount was paid. Results are grouped by condition type and sorted in descending order by the count of insured claims.

select c.CONDITION_TYPE_DESC, CONDITION_TYPE_CODE, count(*) as num_of_claim_insured
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID
where c.CONDITION_NET_AMOUNT > 0
group by c.CONDITION_TYPE_DESC, CONDITION_TYPE_CODE order by num_of_claim_insured desc;

	
2.	Present a monthly time series of the total claimed amount with a STARTS_AT for the months from January 2023 to May 2024:
    This query calculates a monthly time series of the total claimed amount (TOTAL_CLAIMED_AMOUNT) starting from January 2023 to May 2024 (STARTS_AT). It aggregates data from the claim_data,     audit_status, and condition_data tables, grouping results by the first day of each month based on the CONDITION_TREATMENT_START_DATE. This provides a structured view of claimed amounts       over the specified period.

select DATEFROMPARTS(YEAR(c.CONDITION_TREATMENT_START_DATE), MONTH(c.CONDITION_TREATMENT_START_DATE), 1) AS STARTS_AT,
    SUM(c.CONDITION_CLAIMED_AMOUNT) AS TOTAL_CLAIMED_AMOUNT
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID
group by DATEFROMPARTS(YEAR(c.CONDITION_TREATMENT_START_DATE), MONTH(c.CONDITION_TREATMENT_START_DATE), 1) ;
