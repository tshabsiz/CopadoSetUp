/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 04/07/2017 - PG    - Created trigger.
 29/09/2017 - PG    - Renamed trigger from "AgreementTemplate_Trigger" to "Agreement_Template_Trigger"
                    - Refactored trigger to be logic-less.

**/ 
trigger Agreement_Template_Trigger on Agreement_Template__c (after insert, before update)  
{

    //Before Update
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        Agreement_Template_Helper.beforeUpdate(Trigger.new, Trigger.oldMap); 
    }

    //After Insert
    if(Trigger.isAfter && Trigger.isInsert) 
    {
        Agreement_Template_Helper.afterInsert(Trigger.new);  
    }
}