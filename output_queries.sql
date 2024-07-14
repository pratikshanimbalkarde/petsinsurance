
use petsdata;
--integrade the three sourced based on common identifier claim_id
--this query also add audit status based on the claim_id and condition id and also give the output if we have only paid for claims in which conditions are known before the treatment date as correct else wrong if				

select cd.CLAIM_ID, a.CLAIM_AUDIT_STATUS, c.CONDITION_ID, c.CONDITION_KNOWN_FROM_DATE, c.CONDITION_TREATMENT_START_DATE , c.CONDITION_CLAIMED_AMOUNT, c.CONDITION_NET_AMOUNT,
CASE 
when c.CONDITION_KNOWN_FROM_DATE < c.CONDITION_TREATMENT_START_DATE and CAST(c.CONDITION_NET_AMOUNT AS DECIMAL) > 0 THEN 'correct'
WHEN c.CONDITION_KNOWN_FROM_DATE > c.CONDITION_TREATMENT_START_DATE  and CAST(c.CONDITION_NET_AMOUNT AS DECIMAL) > 0 THEN 'wrong'
ELSE 'not_yet_paid' END as paidclaimbeforedate
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID 
order by cd.claim_id, c.CONDITION_ID;

--current audit status based on claim_id and condition_id
with rownum_status as (select cd.CLAIM_ID,c.condition_id, a.CLAIM_AUDIT_STATUS,
ROW_NUMBER() OVER(PARTITION BY cd.claim_id, c.condition_id ORDER BY c.condition_id desc) as rownum
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID
)

select * from rownum_status where rownum=1 order by claim_id, CONDITION_ID ;

--Condition data (to incorporate related disease conditions that have been paid on the claims by us as an insurer)
select c.CONDITION_TYPE_DESC, CONDITION_TYPE_CODE, count(*) as num_of_claim_insured
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID
where c.CONDITION_NET_AMOUNT > 0
group by c.CONDITION_TYPE_DESC, CONDITION_TYPE_CODE order by num_of_claim_insured desc
;

--monthly time series of the total claimed amount with a STARTS_AT for the months from January 2023 to May 2024.

select DATEFROMPARTS(YEAR(c.CONDITION_TREATMENT_START_DATE), MONTH(c.CONDITION_TREATMENT_START_DATE), 1) AS STARTS_AT,
    SUM(c.CONDITION_CLAIMED_AMOUNT) AS TOTAL_CLAIMED_AMOUNT
from claim_data cd join audit_status a on cd.claim_id=a.claim_id join condition_data c on a.CLAIM_ID=c.CLAIM_ID
group by DATEFROMPARTS(YEAR(c.CONDITION_TREATMENT_START_DATE), MONTH(c.CONDITION_TREATMENT_START_DATE), 1) ;