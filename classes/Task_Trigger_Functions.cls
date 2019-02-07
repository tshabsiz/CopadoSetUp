/**
* Date   : 2017-01-13
* Author : RN - CloudSmiths
* Desc   : Task trigger supporting class
* TestClass : Task_Trigger_Test
*------------------------------------------
* Modified By : Tonga MM
* Description : Added future Annotation on updateRelatedCases Method, this has been done due to the fact that this method gets called in the trigger context,which updates a record thats currently beng updated,
*-----------------------------------------	
* Modified By : Tonga MM
* Description : Commented out method as it is no longer required for complaint
*------------------------------------------
**/
public class Task_Trigger_Functions {
    
    
    /*public static void updateRelatedCases(list<String> caseIds, map<Id,Boolean> taskStatusMap){
        
        list<Case> updateCaseList = new list<Case>();
        String complaintRecordId = [Select Id From RecordType Where DeveloperName = 'Complaint'].Id;
        String complaintPvtRecordId = [Select Id From RecordType Where DeveloperName = 'MNPI_Complaint'].Id;
        
        for(Case c :[Select Id, RecordTypeId, Number_of_Open_Tasks__c From Case Where Id IN :caseIds]){
            
            if(c.RecordTypeId == complaintRecordId || c.RecordTypeId == complaintPvtRecordId){
                if(!taskStatusMap.get(c.Id)){
                    //The default field value is 0, this is only for old records where the field is NULL
                    if(c.Number_of_Open_Tasks__c == null){c.Number_of_Open_Tasks__c=0;}
                    
                    c.Number_of_Open_Tasks__c+= 1;
                    
                }else{
                    if(c.Number_of_Open_Tasks__c > 0){
                        c.Number_of_Open_Tasks__c-= 1;
                    }else{
                        c.Number_of_Open_Tasks__c = 0;
                    }
                }
                
                updateCaseList.add(c);
            }
            
        }
        
        
        try{
            update updateCaseList;
        }catch(DMLException e){
            System.debug('Error while updating the number of open Tasks field on Complaint Cases');
        }
        
    }
*/
    public static void conditionActivityLogged(Map<Id, Task> conditionsChaseLoggedMap){

        List<Condition__c> updatedConditions = new List<Condition__c>();
        List<Condition_Occurrence__c> updatedOccurances = new List<Condition_Occurrence__c>();
        Set<Id> conditionIds = new Set<Id>();
        Task chase;

        for(Condition_Occurrence__c conOc: [SELECT Id, Condition__c, Last_Chased_By__c, Last_Chased_On__c FROM Condition_Occurrence__c WHERE Id IN :conditionsChaseLoggedMap.keyset()]){
            
            chase = conditionsChaseLoggedMap.get(conOc.Id);

            //Preventing duplicates in the list during bulk creation of Tasks on 
            //different Occurances for the same Condition.
            //Since all those in bulk were created at the same time, the data is still corret
            if(!conditionIds.contains(conOc.Condition__c)) {

                conditionIds.add(conOc.Condition__c);
                updatedConditions.add(new Condition__c(Id = conOc.Condition__c, Last_Chased_By__c = chase.CreatedById, Last_Chased_On__c = chase.CreatedDate));
            
            }

            updatedOccurances.add(new Condition_Occurrence__c(Id = conOc.Id, Last_Chased_By__c = chase.CreatedById, Last_Chased_On__c = chase.CreatedDate));
        }

        try{
            update updatedConditions;
            update updatedOccurances;
        }catch(DMLException e){
            System.debug('Error while updating the latest chase details on Conditions');
        }
    }

    public static void conditionActivityDeleted(Set<Id> conditionsChasesDeletedIds){

        if(conditionsChasesDeletedIds.isEmpty())
            return;
            
        List<Condition__c> updatedConditions = new List<Condition__c>();
        List<Condition_Occurrence__c> updatedOccurances = new List<Condition_Occurrence__c>();
        Set<Id> parentIds = new Set<Id>();

        List<Condition_Occurrence__c> existingOccurances =  [SELECT Id, Condition__c, Last_Chased_By__c, Last_Chased_On__c FROM Condition_Occurrence__c WHERE Id IN :conditionsChasesDeletedIds];
        List<Task> previousChases = [SELECT Id, WhatId, CreatedById, CreatedDate FROM Task WHERE WhatId IN :conditionsChasesDeletedIds ORDER BY CreatedDate];
        
        for(Condition_Occurrence__c conOc: existingOccurances)
            parentIds.add(conOc.Condition__c);

        //This map is needed to see if the parent Conditions need to be updated
        Map<Id, Condition__c> parentConditions = new Map<Id, Condition__c>([SELECT Id, Last_Chased_By__c, Last_Chased_On__c FROM Condition__c WHERE Id IN :parentIds]);
        
        Map<Id, Task> occuranceChaseMap = new Map<Id, Task>();

        //As the existing tasks are ordered by date, 
        //the first found relating to a specific occurance 
        //is the latest for that occurance
        for(Task t :previousChases){

            if(!occuranceChaseMap.keySet().contains(t.WhatId))
                occuranceChaseMap.put(t.WhatId, t);

        }

        Task chase;
        Condition__c parent;
        List<Condition__c> tempConditions = new List<Condition__c>();

        for(Condition_Occurrence__c conOc: existingOccurances){
            
            chase = occuranceChaseMap.get(conOc.Id);
            parent = parentConditions.get(conOc.Condition__c);

            //If no earlier tasks than the one deleted are found, there has been no follow up.
            //The deleted tasks may not be the latest ones, and therefore be updated with the same values. This is a compromise to avoid greater complexity
            if(chase != null)            
                updatedOccurances.add(new Condition_Occurrence__c(Id = conOc.Id, Last_Chased_By__c = chase.CreatedById, Last_Chased_On__c = chase.CreatedDate));            
            else            
                updatedOccurances.add(new Condition_Occurrence__c(Id = conOc.Id, Last_Chased_By__c = null, Last_Chased_On__c = null)); 

            //Parents last chase was the task that was just deleted
            if(parent.Last_Chased_On__c == conOc.Last_Chased_On__c)
                tempConditions.add(parent);       
        }

        try{
            update updatedOccurances;
        }catch(DMLException e){
            System.debug('Error while updating the latest chase details on Conditions');
        }

        //The occurances now updated, we are certain to get the latest one to update the parents
        List<Condition_Occurrence__c> nowLatestOccurances = [SELECT Id, Condition__c, Last_Chased_By__c, Last_Chased_On__c FROM Condition_Occurrence__c WHERE Condition__c IN :tempConditions ORDER BY Last_Chased_On__c];

        for(Condition__c newTimedCondition: tempConditions)
        {
            Condition_Occurrence__c latest;

            //As they are ordered by last chase date, the first child for the Condition is the latest
            for(Condition_Occurrence__c occurance: nowLatestOccurances)
                if(occurance.Condition__c == newTimedCondition.Id){
                    latest = occurance;
                    break;
                }

            if(latest != null)
                updatedConditions.add(new Condition__c(Id = newTimedCondition.Id, Last_Chased_By__c = latest.Last_Chased_By__c, Last_Chased_On__c = latest.Last_Chased_On__c));
            else
                updatedConditions.add(new Condition__c(Id = newTimedCondition.Id, Last_Chased_By__c = null, Last_Chased_On__c = null));
        }

        try{
            update updatedConditions;
        }catch(DMLException e){
            System.debug('Error while updating the latest chase details on Conditions');
        }
    }

}