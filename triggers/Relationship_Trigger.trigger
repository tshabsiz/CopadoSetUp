/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 @author Peter Guest
 
*** CHANGE LOG ***
 
 28/05/2017     PG  - Created initial class.
 21/06/2017     PG  - Change variable locations in trigger.
 13/09/2017 - PG    - Add logic to use a timestamp to force conditions to be rescheduled / generate new occurrences.
 
**/ 
trigger Relationship_Trigger on Account (after update) {

    //Blank vars.
    List<Condition__c> conditions = new List<Condition__c>();
    Set<Id> accountIds = new Set<Id>();
    
    //AFTER context.
    if(Trigger.isAfter)
    {
        //AFTER UPDATE context.
        if(Trigger.isUpdate)
        {   
            //Loop through updated accounts.
            for(Account account : Trigger.new)
            {
                //Get the accounts previous state.
                Account oldAccount = Trigger.oldMap.get(account.Id); 
                
                //Was the financial year updated?
                if(account.Financial_Year_End__c != null && (oldAccount.Financial_Year_End__c != account.Financial_Year_End__c))
                {
                    //Add id to set.
                    accountIds.add(account.Id);
                }
            }
            
            //Anything to process
            if(!accountIds.isEmpty())
            {
                //Flags conditions that a reliant on this field as needing rescheduling.
                conditions = ConditionOccurrence_Helper.relativeDateChanged(accountIds, 'Account'); 
            } 
            
            //We have any records to update.
            if(!conditions.isEmpty())
            {
               for(Condition__c condition : conditions) 
               {
                   //Set update flag to true so they get reschduled.
                   condition.Forced_Update__c = DateTime.now();
               }
               
               //Update conditions
               update conditions;
            }
            
        }
        //AFTER UPDATE context.
    }
    //AFTER context.
}