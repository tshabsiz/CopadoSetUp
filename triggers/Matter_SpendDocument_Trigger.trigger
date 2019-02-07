/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 28/07/2017 - PG    - Created trigger.

**/ 
trigger Matter_SpendDocument_Trigger on Matter_Spend_Document__c (before update, after update, before insert) 
{
    System.debug('### Matter_SpendDocument_Trigger : START');

    //Before Update
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        Matter_SpendDocument_Helper.beforeUpdate(Trigger.new, Trigger.oldMap); 
    }
    //Before Update End

    //After Update
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        Matter_SpendDocument_Helper.afterUpdate(Trigger.new, Trigger.oldMap); 
    }
    //After Update End

    //After Update
    if(Trigger.isBefore && Trigger.isInsert)
    {
        Matter_SpendDocument_Helper.beforeInsert(Trigger.new); 
    }
    //After Update End
    
    System.debug('### Matter_SpendDocument_Trigger : END');
}