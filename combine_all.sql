
use petsdata;
select cd.CLAIM_ID, 
a.CLAIM_AUDIT_STATUS, 
cd.CONDITION_ID,
cd.CONDITION_MIGRATED_FLAG,
cd.CONDITION_TYPE_DESC,
cd.CONDITION_TYPE_CODE,
cd.CONDITION_TREATMENT_START_DATE,
cd.CONDITION_KNOWN_FROM_DATE,
cd.CONDITION_CLAIMED_AMOUNT,
cd.CONDITION_NET_AMOUNT,
cd.CONDITION_REJECTED_AMOUNT,
cd.CONDITION_EXCESS_AMOUNT
from dbo.condition_data cd join dbo.claim_data c on cd.claim_id=c.claim_id join audit_status a on c.CLAIM_ID=a.CLAIM_ID;