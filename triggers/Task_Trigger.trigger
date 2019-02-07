/**
* Date   : 2017-01-13
* Author : RN - CloudSmiths
* Desc   : Default Task trigger
* 
**/
trigger Task_Trigger on Task (after insert, after update, after delete, after undelete) {
    
    if(trigger.isAfter){
        
          //only process Cases related to the Tasks
        list<String> relatedCaseIds = new list<String>();
        map<Id, Boolean> taskStatusMap = new map<Id, Boolean>();
        Map<Id, Task> conditionsChasesLoggedMap = new Map<Id, Task>();
        Set<Id> conditionsChasesDeletedIds = new Set<Id>();
        
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
            for(Task t :trigger.new){
                String whatid = t.WhatId;
                Boolean isClosed = t.IsClosed;
                
                if(String.isNotBlank(whatid)){
                    
                    if(whatid.startsWith('500')){
                        if(trigger.isUpdate){
                            if(trigger.oldMap.get(t.Id).IsClosed != t.IsClosed){
                                relatedCaseIds.add(whatid);
                                taskStatusMap.put(whatid,isClosed);
                            }
                        }else{
                            relatedCaseIds.add(whatid);
                            taskStatusMap.put(whatid,isClosed);
                        }
                    }
                    else if(((Id)whatid).getSObjectType().getDescribe().getName() == 'Condition_Occurrence__c' && trigger.isInsert){
                        conditionsChasesLoggedMap.put((Id)whatid, t);
                    }
                }
            }
        }
        
        if(trigger.isDelete){
            for(Task t :trigger.old){
                String whatid = t.WhatId;
                Boolean isClosed = true;
                
                 if(String.isNotBlank(whatid)){
                     
                    if(whatid.startsWith('500')){
                        relatedCaseIds.add(whatid);
                        taskStatusMap.put(whatid,isClosed);
                    }
                    else if(((Id)whatid).getSObjectType().getDescribe().getName() == 'Condition_Occurrence__c'){
                        conditionsChasesDeletedIds.add((Id)whatid);
                    }
                     
               	}
            }
        }
        //Tonga MM : removed due to function no longer required for Complaints
        //Task_Trigger_Functions.updateRelatedCases(relatedCaseIds,taskStatusMap);
        Task_Trigger_Functions.conditionActivityLogged(conditionsChasesLoggedMap);
        Task_Trigger_Functions.conditionActivityDeleted(conditionsChasesDeletedIds);
    }

}