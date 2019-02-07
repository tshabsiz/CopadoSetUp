/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG *** 

17/03/2017 - PG    - Created Trigger. 
21/06/2017 - PG    - Updated logic in CONDITION RECURRENCE CHANGED DIRECTLY section to handle direct condition changes. 
24/06/2017 - PG    - Fixed bug where CONDITION RECURRENCE CHANGED DIRECTLY was firing in first creation of occurrences. 
28/06/2017 - PG    - Added "Before Update" logic to block activating conditions that a based on a FYE and not all the Condition Parties have one specified.
30/06/2017 - PG    - Added "Before Update" logic to block activating CP's or GC's that dont have TA specified on the deal.
03/07/2017 - PG    - Moved reschduled condition logic "RECURRENCE CHANGED" into before update context.
04/07/2017 - IV    - Added logic to check if the FC threshold fields logic need to update future occurrences.
17/07/2017 - PG    - Move reschedule logic on After Update so that the "new" dates are used.   Before update was using the unchanged record values.
21/08/2017 - PG    - Added call to "Condition_Helper.beforeUpdate" trigger handler.   Move to new logic-less triggers.
22/08/2017 - PG    - Removed "TA" logic check directly from trigger logic and handled via the Conditon_Helper.beforeUpdate.
- Before update made generic to handle CP, GC and IU etc. as they both have this requirement. 
13/09/2017 - PG    - Add logic to use a timestamp to force conditions to be rescheduled / generate new occurrences. 
11/10/2017 - PG    - Changed "insert" into upsert on reschedule trigger logic.  Needed for reuse of condition occurrences.
08/12/2017 - PG    - Removed reference to "Condition_Helper.recordTypes()".
14/02/2018 - TdB   - Add Condition_Helper.updateConditionPartiesAfterInsert for After Update
03/01/2018 - TdB   - Add Condition_Helper.validateConditionParties_FYE in After Insert and After Update
01/08/2018 - TdB   - Remove activeConditionsList variable and logic as not in use

**/  
trigger Condition_Trigger on Condition__c (after insert, after update , before update, before insert) 
{
    System.debug('*** Condition_Trigger START');
    
    Set<Id> beforeConditionIds = new Set<Id>();
    Set<Id> activatedBeforeConditionIds = new Set<Id>();
    Map<Id, String> conditionsWithErrors_FYE = new Map<Id, String>();
    Set<Id> rescheduleConditionsIds = new Set<Id>();
    Boolean flagError = False;
    
    /**
* Before Insert Context
**/
    if(Trigger.isBefore && Trigger.isInsert)
    {
        System.debug('*** Condition_Trigger : BEFORE INSERT');
        
        //Trigger handler.
        Condition_Helper.beforeInsert(Trigger.new);
    }
    
    /**
* Before Update Context
**/
    if(Trigger.isBefore && Trigger.isUpdate)
    {  
        System.debug('*** Condition_Trigger : BEFORE UPDATE');
        
        //Move to new apporach to trigger logic.   
        Condition_Helper.beforeUpdate(Trigger.new, Trigger.oldMap);
        
        //Loop through conditions.
        for(Condition__c beforeCondition : Trigger.new)
        {
            //Get the conditions previous state.
            Condition__c oldBeforeCondition = Trigger.oldMap.get(beforeCondition.Id);
            
            //Active + FYE specified.
            if(oldBeforeCondition.Active__c == false && beforeCondition.Active__c == true && beforeCondition.Date__c == 'Financial Year End')
            {                
                beforeConditionIds.add(beforeCondition.Id);
            }
        }
        
        //Make sure the condition parties have valid FYE.
        conditionsWithErrors_FYE = Condition_Helper.validateConditionParties_FYE(beforeConditionIds);
        
        //Loop through conditions again, for error flagging.
        for(Condition__c record : Trigger.new)
        {                 
            if(conditionsWithErrors_FYE.containsKey(record.Id))
            {
                //Add error on record.
                record.addError(conditionsWithErrors_FYE.get(record.Id));
            }
        } 
    }
    
    //AFTER CONTEXT
    if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
    {       
        //RECURSION START
        if(checkRecursion.getRunOnce_Condition())
        {
            //AFTER UPDATE
            if(Trigger.isUpdate)
            {
                System.debug('*** Condition_Trigger : AFTER UPDATE');
                
                //Blank variables.
                List<Condition__c> activeConditionsList = new List<Condition__c>();
                List<Condition__c> deactivatedConditions = new List<Condition__c>();
                Set<Id> activatedConditionsIds = new Set<Id>();
                Set<Id> activatedFYEConditionsIds = new Set<Id>();
                List<Condition_Occurrence__c> occurrencesToDelete = new List<Condition_Occurrence__c>();
                List<Condition_Occurrence__c> occurrencesToInsert = new List<Condition_Occurrence__c>();
                List<Condition__c> conditions = new List<Condition__c>();
                List<Condition__c> conditionsToUpdateSchedule  = new List<Condition__c>();
                Map<Id, Condition__c> tresholdChangedMap = new Map<Id, Condition__c>();
                Map<String, RecordTypeInfo> conditionTypes = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 
                
                //Loop through updated records.
                for(Condition__c condition : Trigger.new)
                {
                    //Get the conditions previous state.
                    Condition__c oldCondition = Trigger.oldMap.get(condition.Id);
                    
                    //DEACTIVATE
                    if(oldCondition.Active__c == true && condition.Active__c == false)
                    {
                        //Add to list of condition we need to remove future occurrences for?
                        deactivatedConditions.add(condition);
                    }
                    
                    //ACTIVATE
                    if(oldCondition.Active__c == false && condition.Active__c == true)
                    {
                        //Add condition id to set for activation.
                        activatedConditionsIds.add(condition.Id);
                        activeConditionsList.add(condition);
                        
                        if(condition.Date__c == 'Financial Year End')
                        {
                            activatedFYEConditionsIds.add(condition.Id);
                        }
                    }
                    
                    //FC threshold fields changed, update future occurrences.
                    if(oldCondition.Active__c == true && condition.Active__c == true && condition.RecordTypeId == conditionTypes.get('Financial Covenant').getRecordTypeId())
                    {
                        if(ConditionOccurrence_Helper.shouldUpdateOccurances(condition, oldCondition))
                        {
                            System.debug('## SHOULD CHANGE');
                            
                            tresholdChangedMap.put(condition.Id, condition);
                        }
                    }
                    
                    //CONDITION RECURRENCE CHANGED DIRECTLY OR FORCED
                    if(oldCondition.Active__c == true && condition.Active__c == true)
                    {
                        //Condition values changed via UI.
                        if(oldCondition.Activation_Start__c != condition.Activation_Start__c || oldCondition.Activation_End__c != condition.Activation_End__c || oldCondition.Date__c != condition.Date__c || oldCondition.Recurrence__c != condition.Recurrence__c || oldCondition.Number_Of_Days__c != condition.Number_Of_Days__c || oldCondition.Other_Relative_Date__c != condition.Other_Relative_Date__c || oldCondition.Days__c != condition.Days__c || oldCondition.Due_Date__c != condition.Due_Date__c)
                        {
                            //Add to list.
                            rescheduleConditionsIds.add(condition.Id);
                        }
                        
                        //Forced to reschedule
                        if(oldCondition.Forced_Update__c != condition.Forced_Update__c)
                        {                          
                            //Add to list.
                            rescheduleConditionsIds.add(condition.Id); 
                        }
                    }
                }
                
                //DEACTIVATE
                if(!deactivatedConditions.isEmpty())
                {
                    //Process deactivated conditions.
                    occurrencesToDelete = ConditionOccurrence_Helper.deactivateConditions(deactivatedConditions);
                    
                    //Make sure for have something to delete.
                    if(!occurrencesToDelete.isEmpty())
                    {
                        //Delete condition occurrence records.
                        delete occurrencesToDelete;
                    }
                }
                //DEACTIVATE END
                
                //ACTIVATE
                if(!activeConditionsList.isEmpty())
                {
                    Condition_Helper.updateConditionPartiesAfterInsert(activeConditionsList);
                }
                if(!activatedFYEConditionsIds.isEmpty())
                {
                    conditionsWithErrors_FYE = Condition_Helper.validateConditionParties_FYE(activatedFYEConditionsIds);
                }
                //Loop through conditions again, for error flagging.
                for(Condition__c record : Trigger.new)
                {                 
                    if(conditionsWithErrors_FYE.containsKey(record.Id))
                    {
                        //Add error on record.
                        record.addError(conditionsWithErrors_FYE.get(record.Id));
                        flagError = True;
                    }
                } 
                
                if(flagError == False)
                {
                    if(!activatedConditionsIds.isEmpty())
                    {
                        System.debug('*** Condition_Trigger : AFTER UPDATE : ACTIVATE'); 
                        
                        //Query full condition records.
                        conditions = Condition_Helper.getFullConditionRecords(activatedConditionsIds);
                        
                        //Make sure we have conditions to activate.
                        if(!conditions.isEmpty())
                        {
                            //Process ACTIVATED conditions.
                            occurrencesToInsert = ConditionOccurrence_Helper.activateConditions(conditions);
                            
                            //Make sure for have something to delete.
                            if(!occurrencesToInsert.isEmpty())
                            {
                                //Insert condition occurrence records.
                                upsert occurrencesToInsert; 
                            }
                        }
                    }
                    //ACTIVATE END
                    
                    //THRESHOLD INFO UPDATED
                    if(!tresholdChangedMap.isEmpty())
                    {
                        ConditionOccurrence_Helper.updateOccuranceTreshold(tresholdChangedMap);
                    }
                    //THRESHOLD INFO UPDATED END
                    
                    //RECURRENCE CHANGED
                    if(!rescheduleConditionsIds.isEmpty())
                    {
                        System.debug('*** Condition_Trigger : AFTER UPDATE : RESCHEDULE'); 
                        
                        //Query full condition records.
                        List<Condition__c> conditionsRescheduled  = new List<Condition__c>();
                        conditionsRescheduled = Condition_Helper.getFullConditionRecords(rescheduleConditionsIds);
                        
                        //Get a list of future occurrences we need to delete.
                        List<Condition_Occurrence__c> occurrencesRescheduleDelete = new List<Condition_Occurrence__c>();
                        occurrencesRescheduleDelete = ConditionOccurrence_Helper.deactivateConditions(conditionsRescheduled);
                        
                        //Delete occurrences
                        delete occurrencesRescheduleDelete; 
                        
                        //Process ACTIVATED conditions.
                        List<Condition_Occurrence__c> occurrencesRescheduleInsert = new List<Condition_Occurrence__c>();
                        occurrencesRescheduleInsert = ConditionOccurrence_Helper.activateConditions(conditionsRescheduled);
                        
                        System.debug('*** Condition_Trigger : AFTER UPDATE : RESCHEDULE : '+occurrencesRescheduleInsert);
                        
                        for(Condition_Occurrence__c occurrence : occurrencesRescheduleInsert)
                        {
                            System.debug('*** Condition_Trigger : AFTER UPDATE : RESCHEDULE : occurrence.Id : '+occurrence.Id);
                        }
                        
                        //Upsert occurrences
                        upsert occurrencesRescheduleInsert; //PROBLEM HERE SELF LOOKUP IF THE CONDITION.
                    }
                }
                //RECURRENCE CHANGED END
            }
            //AFTER UPDATE END
            
            //AFTER INSERT
            if(Trigger.isInsert)
            {
                System.debug('*** Condition_Trigger : AFTER INSERT');
                Set<Id> activatedFYEConditionsIds = new Set<Id>();
                
                for(Condition__c condition : Trigger.new)
                {                    
                    //ACTIVATE
                    if(condition.Active__c == false && condition.Activate_Later__c == true )
                    {
                        if(condition.Date__c == 'Financial Year End')
                        {
                            activatedFYEConditionsIds.add(condition.Id);
                        }
                    }
                }
                
                if(!activatedFYEConditionsIds.isEmpty())
                {
                    conditionsWithErrors_FYE = Condition_Helper.validateConditionParties_FYE(activatedFYEConditionsIds);
                }
                //Loop through conditions again, for error flagging.
                for(Condition__c record : Trigger.new)
                {                 
                    if(conditionsWithErrors_FYE.containsKey(record.Id))
                    {
                        //Add error on record.
                        record.addError(conditionsWithErrors_FYE.get(record.Id));
                        flagError = True;
                    }
                } 
                
                if(flagError == False)
                {
                    //Call handler class for After Insert.
                    Condition_Helper.afterInsert(Trigger.new);   
                }
            }
            //AFTER INSERT END 
        }
        //RECURSION END
    }
    //AFTER CONTEXT END
    
    System.debug('*** Condition_Trigger END');
}