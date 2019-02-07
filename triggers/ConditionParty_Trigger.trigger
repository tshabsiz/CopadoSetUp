/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

 *** CHANGE LOG ***

 29/06/2017 - PG    - Created Trigger.
 14/09/2017 - PG    - Removed inline logic and moved to helper classes. 
 18/08/2017 - PG    - Added the "Before" & "After" delete logic.
 10/10/2017 - PG    - Removed "Before Delete" trigger context.

**/
trigger ConditionParty_Trigger on Condition_Party__c (after delete, after insert) 
{
    System.debug('### ConditionParty_Trigger : START');

    //After Delete Context
    if(Trigger.isAfter && Trigger.isDelete)
    {
        Condition_Party_Helper.afterDelete(Trigger.old);  
    }
    //After Delete Context End. 

    //After Insert Context
    if(Trigger.isAfter && Trigger.isInsert)
    {
        Condition_Party_Helper.afterInsert(Trigger.new); 
    }
    //After Insert Context End. 

    System.debug('### ConditionParty_Trigger : END');
}