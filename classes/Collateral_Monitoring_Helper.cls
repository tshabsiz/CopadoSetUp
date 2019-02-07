/**
*** CHANGE LOG ***

20/11/2017 - TdB   - Created Class.
				   - updateWatcherOccurence() - Get all open Watcher record and determine if Due Date should be updated/new Watcher created
                   - updateStartEndDates() - Calculate Schedule start and end date based on lowest level (Agreement/Facility/Tranche) and Relative Date
                   - insertWatcherOccurence() - Call Method to build the watcher record and insert record if due date is set
12/02/2018 - TdB   - Remove Status__c refrences on Watcher

**/ 

public class Collateral_Monitoring_Helper {
	public List<Collateral_Monitoring__c> collateralMonitoringUpdateList;
    public static Map <String, Schema.RecordTypeInfo> Condition_RecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    //Contructor
    public static void updateWatcherOccurence(Map<Id,Collateral_Monitoring__c> collateralMonitoringOldMap, Map<Id,Collateral_Monitoring__c> collateralMonitoringNewMap)
    {
        Map<Id, Watcher__c> collateralMonitoringWatcherMap = new Map<Id, Watcher__c>();
        Set<Id> watcherIdSet = new Set<Id>();
        Watcher__c watcherItem;
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        List<Watcher__c> watcherUpdateList = new List<Watcher__c>();
        Date scheduleStartDate;
        Date scheduleEndDate;
        Collateral_Monitoring__c collateralMonitoringItem;
        List<Collateral_Monitoring__c> collateralMonitoringList = new List<Collateral_Monitoring__c>();
        
        //Add all Margin Ratchet to a Set
        for(Id eachcollateralMonitoring : collateralMonitoringNewMap.keySet())
        {
            watcherIdSet.add(eachcollateralMonitoring);
        }
        
        //Get all Watchers linked to Margin Ratchet
        for(Watcher__c eachWatcher : [SELECT Id, Collateral_Monitoring__c, Watcher_Status__c, Due_Date__c 
                                      FROM Watcher__c 
                                      WHERE Collateral_Monitoring__c IN :watcherIdSet
                                      AND (Watcher_Status__c = 'New'
                                          OR Watcher_Status__c = 'Due'
                                          OR Watcher_Status__c = 'Overdue')])
        {
            if(!collateralMonitoringWatcherMap.containsKey(eachWatcher.Collateral_Monitoring__c))
            {
                collateralMonitoringWatcherMap.put(eachWatcher.Collateral_Monitoring__c, eachWatcher);
            }
        }
        
        
        
        for(Id eachcollateralMonitoring : collateralMonitoringNewMap.keySet())
        {
            //Check if schedule changed, then recalculate start date
            if(collateralMonitoringNewMap.get(eachcollateralMonitoring).Start_Date_End_Date_Changed__c ||  collateralMonitoringNewMap.get(eachcollateralMonitoring).Frequency__c != collateralMonitoringOldMap.get(eachcollateralMonitoring).Frequency__c || collateralMonitoringNewMap.get(eachcollateralMonitoring).Number_of_Days__c != collateralMonitoringOldMap.get(eachcollateralMonitoring).Number_of_Days__c || collateralMonitoringNewMap.get(eachcollateralMonitoring).Relative_Date__c != collateralMonitoringOldMap.get(eachcollateralMonitoring).Relative_Date__c || collateralMonitoringNewMap.get(eachcollateralMonitoring).Due_Date__c != collateralMonitoringOldMap.get(eachcollateralMonitoring).Due_Date__C || collateralMonitoringNewMap.get(eachcollateralMonitoring).Days__c != collateralMonitoringOldMap.get(eachcollateralMonitoring).Days__c || collateralMonitoringNewMap.get(eachcollateralMonitoring).Other_Relative_Date__c != collateralMonitoringOldMap.get(eachcollateralMonitoring).Other_Relative_Date__c)
            {
                watcherItem = new Watcher__c();
                watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(collateralMonitoringNewMap.get(eachcollateralMonitoring));
                
                if(!collateralMonitoringWatcherMap.containsKey(eachcollateralMonitoring))
                {
                    watcherInsertList.add(watcherItem);
                }
                else
                {
                    System.debug('### watcherItem.Due_Date__c : ' + watcherItem.Due_Date__c);
                     System.debug('### collateralMonitoringNewMap.get(eachcollateralMonitoring).Other_Relative_Date__c : ' + collateralMonitoringNewMap.get(eachcollateralMonitoring).Other_Relative_Date__c);
                    if(collateralMonitoringNewMap.get(eachcollateralMonitoring).Due_Date__c != null)
                    {
						collateralMonitoringWatcherMap.get(eachcollateralMonitoring).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralMonitoringWatcherMap.get(eachcollateralMonitoring));                      
                    }
                    else if(collateralMonitoringNewMap.get(eachcollateralMonitoring).Other_Relative_Date__c != null)
                    {
                        collateralMonitoringWatcherMap.get(eachcollateralMonitoring).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralMonitoringWatcherMap.get(eachcollateralMonitoring));
                    }
                    //Only update if Due Date less or equal to Schedule end date
                    else if(collateralMonitoringWatcherMap.get(eachcollateralMonitoring).Due_Date__c != watcherItem.Due_Date__c && collateralMonitoringWatcherMap.get(eachcollateralMonitoring).Due_Date__c <= collateralMonitoringNewMap.get(eachcollateralMonitoring).Schedule_End_Date__c)
                    {
                        collateralMonitoringWatcherMap.get(eachcollateralMonitoring).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralMonitoringWatcherMap.get(eachcollateralMonitoring));
                    }
                    else if(collateralMonitoringNewMap.get(eachcollateralMonitoring).Schedule_End_Date__c == null)
                    {
                        collateralMonitoringWatcherMap.get(eachcollateralMonitoring).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralMonitoringWatcherMap.get(eachcollateralMonitoring));
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
    
    public static void updateStartEndDates(List<Collateral_Monitoring__c> collateralMonitoringList)
    {
        Date scheduleStartDate;
        Date scheduleEndDate;
        Collateral_Monitoring__c collateralMonitoringItem;
        List<Collateral_Monitoring__c> collateralMonitoringUpdateList = new List<Collateral_Monitoring__c>();
        Set<Id> collateralMonitoringIdSet;
        
        Set<Id> collateralSet = new Set<Id>();
        Set<Id> agreementSet = new Set<Id>();
        Map<Id, Agreement__c> agreementMap = new Map<Id, Agreement__c>();
        Map<Id, Collateral__c> collateralMap = new Map<Id, Collateral__c>();
        
        //Ad id's to set
        for(Collateral_Monitoring__c eachcollateralMonitoring : collateralMonitoringList)
        {
            agreementSet.add(eachcollateralMonitoring.Agreement__c);
            collateralSet.add(eachcollateralMonitoring.Collateral__c);
        }
         
        //Get related Ahreement and Collateral for start and end date calculation
        agreementMap = new Map<Id, Agreement__c>([SELECT Id, Financial_Year_End_Date__c, Effective_Date__c  , Signature_Date__c, Termination_Date__c FROM Agreement__c WHERE ID IN : agreementSet]);
        collateralMap = new  Map<Id, Collateral__c>([SELECT Id, Expiry_Date__c,Signature_Date__c FROM Collateral__c WHERE ID IN : collateralSet]);
         
        for(Collateral_Monitoring__c eachcollateralMonitoring : collateralMonitoringList)
        {
            //Once off - only 1 per Collateral Monitoring
            if(eachcollateralMonitoring.Frequency__c == 'Once Off')
            {
                scheduleStartDate  = sObject_Scheduling_Occurences.calculateStartDate(eachcollateralMonitoring,'DUE-DATE');
                scheduleEndDate = sObject_Scheduling_Occurences.calculateEndDate(eachcollateralMonitoring,'DUE-DATE');
            }
            //Other Relative Date - Calculate start and end date based on relative date and lowest level
            else
            {               
                if (eachcollateralMonitoring.Agreement__c != null)
                {
                    scheduleStartDate  = sObject_Scheduling_Occurences.calculateScheduleStartDate(eachcollateralMonitoring,agreementMap.get(eachcollateralMonitoring.Agreement__c));
                    scheduleEndDate = sObject_Scheduling_Occurences.calculateScheduleEndDate(eachcollateralMonitoring,agreementMap.get(eachcollateralMonitoring.Agreement__c));
                    
                }
            }

            eachcollateralMonitoring.Schedule_Start_Date__c = scheduleStartDate;
            eachcollateralMonitoring.Schedule_End_Date__c = scheduleEndDate;

            collateralMonitoringUpdateList.add(eachcollateralMonitoring);
        }

    }
    
    public static void insertWatcherOccurence(List<Collateral_Monitoring__c> collateralMonitoringList)
    {
        Watcher__c watcherItem = new Watcher__c();
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        Date scheduleEndDate;
        Date scheduleStartDate;
        
        for(Collateral_Monitoring__c eachMonitoring : collateralMonitoringList)
        {
            watcherItem = new Watcher__c();
            //Call method to buil the watcher record to insert
            watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(eachMonitoring); 
            watcherItem.Collateral_Monitoring__c = eachMonitoring.id;
            
            //Only insert watcher id due date calculated
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