
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