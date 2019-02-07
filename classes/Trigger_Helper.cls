/**
*** CHANGE LOG ***

11/12/2017 - TdB   - Created Class.
				   - updateWatcherOccurence() - Get all open Watcher record and determine if Due Date should be updated/new Watcher created
                   - updateStartEndDates() - Calculate Schedule start and end date based on lowest level (Agreement/Facility/Tranche) and Relative Date
                   - insertWatcherOccurence() - Call Method to build the watcher record and insert record if due date is set
12/02/2018 - TdB   - Remove Status__c refrences on Watcher

**/ 
public class Trigger_Helper 
{
	public List<Trigger__c> triggerUpdateList;
    
    public static void updateWatcherOccurence(Map<Id,Trigger__c> triggerOldMap, Map<Id,Trigger__c> triggerNewMap)
    {
        Map<Id, Watcher__c> triggerWatcherMap = new Map<Id, Watcher__c>();
        Set<Id> watcherIdSet = new Set<Id>();
        Watcher__c watcherItem;
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        List<Watcher__c> watcherUpdateList = new List<Watcher__c>();
        Date scheduleStartDate;
        Date scheduleEndDate;
        Trigger__c triggerItem;
        List<Trigger__c> triggerList = new List<Trigger__c>();
        
        //Add all Margin Ratchet to a Set
        for(Id eachTrigger : triggerNewMap.keySet())
        {
            watcherIdSet.add(eachTrigger);
        }
        
        //Get all Watchers linked to Margin Ratchet
        for(Watcher__c eachWatcher : [SELECT Id, Trigger__c, Watcher_Status__c, Due_Date__c 
                                      FROM Watcher__c 
                                      WHERE Trigger__c IN :watcherIdSet
                                      AND (Watcher_Status__c = 'New'
                                           OR Watcher_Status__c = 'Due'
                                           OR Watcher_Status__c = 'Overdue')])
        {
            if(!TriggerWatcherMap.containsKey(eachWatcher.Trigger__c))
            {
                TriggerWatcherMap.put(eachWatcher.Trigger__c, eachWatcher);
            }
        }
        
        
        
        for(Id eachTrigger : TriggerNewMap.keySet())
        {
            //Check if schedule changed, then recalculate start date
            if(triggerNewMap.get(eachTrigger).Start_Date_End_Date_Changed__c ||  triggerNewMap.get(eachTrigger).Frequency__c != triggerOldMap.get(eachTrigger).Frequency__c || triggerNewMap.get(eachTrigger).Number_of_Days__c != TriggerOldMap.get(eachTrigger).Number_of_Days__c || TriggerNewMap.get(eachTrigger).Relative_Date__c != triggerOldMap.get(eachTrigger).Relative_Date__c || triggerNewMap.get(eachTrigger).Due_Date__c != triggerOldMap.get(eachTrigger).Due_Date__C || triggerNewMap.get(eachTrigger).Days__c != triggerOldMap.get(eachTrigger).Days__c || triggerNewMap.get(eachTrigger).Other_Relative_Date__c != triggerOldMap.get(eachTrigger).Other_Relative_Date__c)
            {
                watcherItem = new Watcher__c();
                watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(triggerNewMap.get(eachTrigger));
                
                if(!triggerWatcherMap.containsKey(eachTrigger))
                {
                    watcherInsertList.add(watcherItem);
                }
                else
                {
                    if(triggerNewMap.get(eachTrigger).Due_Date__c != null)
                    {
                        triggerWatcherMap.get(eachTrigger).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(triggerWatcherMap.get(eachTrigger));
                    }
                    else if(triggerNewMap.get(eachTrigger).Other_Relative_Date__c != null ) 
                    {
                        triggerWatcherMap.get(eachTrigger).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(triggerWatcherMap.get(eachTrigger));
                    }
                    //Only update Watcher if "new" calculate due date is not greater that the schedule end date
                    else if(triggerWatcherMap.get(eachTrigger).Due_Date__c != watcherItem.Due_Date__c && triggerWatcherMap.get(eachTrigger).Due_Date__c <= triggerNewMap.get(eachTrigger).Schedule_End_Date__c)
                    {
                        triggerWatcherMap.get(eachTrigger).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(triggerWatcherMap.get(eachTrigger));
                    }
                    else if(triggerNewMap.get(eachTrigger).Schedule_End_Date__c == null)
                    {
                        triggerWatcherMap.get(eachTrigger).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(triggerWatcherMap.get(eachTrigger));
                    }
                    
                }
            }
        }
        
        if(watcherInsertList.size() > 0) 
        {
            insert watcherInsertList;
        }
        
        if(watcherUpdateList.size() > 0) 
        {
            update watcherUpdateList;
        }
    }
    
    public static void updateStartEndDates(List<Trigger__c> triggerList)
    {
        Date scheduleStartDate;
        Date scheduleEndDate;
        Trigger__c triggerItem;
        List<Trigger__c> triggerUpdateList = new List<Trigger__c>();
        Set<Id> triggerIdSet;

        Set<Id> agreementSet = new Set<Id>();
        Map<Id, Agreement__c> agreementMap = new Map<Id, Agreement__c>();
        
        //Add Id's to Set
        for(Trigger__c eachTrigger : triggerList)
        {
            agreementSet.add(eachTrigger.Agreement__c);
        }
        
        //Get all Agreements linked to the Trigger to calculate the next due date, start and end date
        agreementMap = new Map<Id, Agreement__c>([SELECT Id, Financial_Year_End_Date__c, Effective_Date__c  , Signature_Date__c, Termination_Date__c FROM Agreement__c WHERE ID IN : agreementSet]);
        
        for(Trigger__c eachTrigger : triggerList)
        {
            //Once Off Occurances - only 1 per Trigger
            if(eachTrigger.Frequency__c == 'Once Off')
            {
                scheduleStartDate  = sObject_Scheduling_Occurences.calculateStartDate(eachTrigger,'DUE-DATE');
                scheduleEndDate = sObject_Scheduling_Occurences.calculateEndDate(eachTrigger,'DUE-DATE');
            }
            //Other Relative Date
            else
            {       
                //Agreement Level
                if (eachTrigger.Agreement__c != null)
                {
                    scheduleStartDate  = sObject_Scheduling_Occurences.calculateScheduleStartDate(eachTrigger,agreementMap.get(eachTrigger.Agreement__c));
                    scheduleEndDate = sObject_Scheduling_Occurences.calculateScheduleEndDate(eachTrigger,agreementMap.get(eachTrigger.Agreement__c));
                    
                }
            }
            
            //Assign schedule start and end date based on lowest level and relative date 
            eachTrigger.Schedule_Start_Date__c = scheduleStartDate;
            eachTrigger.Schedule_End_Date__c = scheduleEndDate;
            
            triggerUpdateList.add(eachTrigger);
        }
    }
    
    public static void insertWatcherOccurence(List<Trigger__c> triggerList)
    {
        Watcher__c watcherItem = new Watcher__c();
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        Date scheduleEndDate;
        Date scheduleStartDate;
        
        for(Trigger__c eachTrigger : triggerList)
        {
            watcherItem = new Watcher__c();
            //Call method to build te watcher record
            watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(eachTrigger); 
            watcherItem.Trigger__c = eachTrigger.id;
            
            //Only create watcher if Due Date is calculated 
            if(watcherItem != null && watcherItem.Due_Date__c != null)
            {
                watcherInsertList.add(watcherItem);
            }
        }
        
        if(watcherInsertList.size() > 0)
        {
            insert watcherInsertList;
        } 
    }  
}