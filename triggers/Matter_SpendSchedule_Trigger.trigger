/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 04/08/2017 - PG    - Created trigger.

**/
trigger Matter_SpendSchedule_Trigger on Matter_Spend_Schedule__c (before update,after update,after Insert)
{
    System.debug('### Matter_SpendSchedule_Trigger : START');

    //Before Update
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        Matter_SpendSchedule_Helper.beforeUpdate(Trigger.new, Trigger.oldMap); 
    }
    //Before Update End
    
    if(Trigger.isAfter)
    {
       // Matter_SpendSchedule_HelperV2.ScheduleApprovals(Trigger.new); 
    }
    
    
    System.debug('### Matter_SpendSchedule_Trigger : END');
}