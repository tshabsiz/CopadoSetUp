/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG *** 
 
 05/07/2017 - IV    - Created Trigger.
 05/07/2017 - IV    - Added "Before Insert" logic handling.
 20/09/2017 - PG    - Added "afterInsert" context.
 09/10/2017 - PG    - Added "beforeUpdate" context. 
 20/10/2017 - PG    - Added "Other__c" to original SOQL query for condition
 08/11/2017 - TdB   - Added ConditionOccurrence_Helper.validateSupportDocumentsUploaded to after Update
 

**/
trigger Condition_Occurrence_Trigger on Condition_Occurrence__c (before insert, before update, after insert)   
{
    //Before Insert Context
    if(Trigger.isBefore && Trigger.isInsert)
    {
        Set<Id> parentIds = new Set<Id>();

        //Pick up Condition Ids
        for(Condition_Occurrence__c c: Trigger.new)
        {
            parentIds.add(c.Condition__c);
        }

        //Select Conditions into a map
        Map<Id, Condition__c> parentRecords = new Map<Id, Condition__c>([ 
            SELECT 
                Id, 
                Required_Base__c,
                Required_Base_Multiple__c,
                Required_Base_Percentage__c,
                Required_Base_Number__c,
                Required_Base_Range_Number_From__c, 
                Required_Base_Range_Number_To__c,
                Required_Base_Range_Multiple_Range_From__c,
                Required_Base_Range_Multiple_To__c,
                Required_Base_Range_Percentage_From__c,
                Required_Base_Range_Percentage_To__c,
                Required_Base_Range_Ratio_From__c,
                Required_Base_Range_Ratio_From_Two__c,
                Required_Base_Range_Ratio_To__c,
                Required_Base_Range_Ratio_To_Two__c,
                Required_Base_Ratio__c,
                Required_Base_Ratio_From__c,
                Required_Base_Ratio_To__c,
                Source__c,
                Threshold_Category__c,
                Threshold_Comparator__c,
                Threshold_Type__c,
                Margin_Ratchet__c,
                Other__c
            FROM Condition__c 
            WHERE 
                Id IN :parentIds
        ]);

        //Set treshold values from Condition to Condition Occurrence
        for(Condition_Occurrence__c occurence: Trigger.new)
        {
            Condition__c parent = parentRecords.get(occurence.Condition__c);
            ConditionOccurrence_Helper.setTresholdVals(occurence, parent);
        }
    }

    //After Insert Context
    if(Trigger.isAfter && Trigger.isInsert)
    {
        ConditionOccurrence_Helper.afterInsert(Trigger.new);  
    }

    //Before Update Context
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        ConditionOccurrence_Helper.beforeUpdate(Trigger.new, Trigger.oldMap);  
        ConditionOccurrence_Helper.validateSupportDocumentsUploaded(Trigger.new);
    }
}