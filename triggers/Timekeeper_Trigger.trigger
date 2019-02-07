/**
 * 04/04/2018 - TdB    - Created Trigger. 
**/
trigger Timekeeper_Trigger on advpm__Timekeeper__c (before insert, before update) 
{
    List<advpm__Timekeeper__c> timekeeperUpdateList = new  List<advpm__Timekeeper__c>();
	if(Trigger.isBefore)
    {
        //Before insert call method to check for dupliacte timekeeper records
        if(Trigger.isInsert) 
        {
            Timekeeper_Helper.checkDuplicate(Trigger.new);
        }
        //After insert call method to check for dupliacte timekeeper records
        else if (Trigger.isUpdate)
        {
            for(advpm__Timekeeper__c eachTimeKeeper : Trigger.New)
            {
                //Check if Staff/User changed, if it did call method to check duplicate
                advpm__Timekeeper__c oldTimeKeeper = Trigger.oldMap.get(eachTimeKeeper.Id);
                if(eachTimeKeeper.advpm__Staff__c != oldTimeKeeper.advpm__Staff__c)
                {
                    timekeeperUpdateList.add(eachTimeKeeper);
                }
            }
            
            if(!timekeeperUpdateList.isEmpty())
            {
                Timekeeper_Helper.checkDuplicate(timekeeperUpdateList);
            }
        }
        
    }
}