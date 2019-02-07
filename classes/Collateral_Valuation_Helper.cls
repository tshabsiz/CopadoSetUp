/**
*** CHANGE LOG ***

20/11/2017 - TdB   - Created Class.
				   - updateWatcherOccurence() - Get all open Watcher record and determine if Due Date should be updated/new Watcher created
                   - updateStartEndDates() - Calculate Schedule start and end date based on lowest level (Agreement/Facility/Tranche) and Relative Date
                   - insertWatcherOccurence() - Call Method to build the watcher record and insert record if due date is set
12/02/2018 - TdB   - Remove Status__c refrences on Watcher

**/ 
public class Collateral_Valuation_Helper {
    public List<Collateral_Valuation__c> CollateralValuationUpdateList;
    public static Map <String, Schema.RecordTypeInfo> Condition_RecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    public static void updateWatcherOccurence(Map<Id,Collateral_Valuation__c> collateralValuationOldMap, Map<Id,Collateral_Valuation__c> collateralValuationNewMap)
    {
        Map<Id, Watcher__c> collateralValuationWatcherMap = new Map<Id, Watcher__c>();
        Set<Id> watcherIdSet = new Set<Id>();
        Watcher__c watcherItem;
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        List<Watcher__c> watcherUpdateList = new List<Watcher__c>();
        Date scheduleStartDate;
        Date scheduleEndDate;
        Collateral_Valuation__c collateralValuationItem;
        List<Collateral_Valuation__c> collateralValuationList = new List<Collateral_Valuation__c>();
        
        //Add all Margin Ratchet to a Set
        for(Id eachcollateralValuation : collateralValuationNewMap.keySet())
        {
            watcherIdSet.add(eachcollateralValuation);
        }
        
        //Get all Watchers linked to Margin Ratchet
        for(Watcher__c eachWatcher : [SELECT Id, Collateral_Valuation__c, Watcher_Status__c, Due_Date__c 
                                      FROM Watcher__c 
                                      WHERE Collateral_Valuation__c IN :watcherIdSet
                                      AND (Watcher_Status__c = 'New'
                                           OR Watcher_Status__c = 'Due'
                                           OR Watcher_Status__c = 'Overdue')])
        {
            if(!collateralValuationWatcherMap.containsKey(eachWatcher.Collateral_Valuation__c))
            {
                collateralValuationWatcherMap.put(eachWatcher.Collateral_Valuation__c, eachWatcher);
            }
        }
        
        
        
        for(Id eachcollateralValuation : collateralValuationNewMap.keySet())
        {
            //Check if schedule changed, then recalculate start date
            if(collateralValuationNewMap.get(eachcollateralValuation).Start_Date_End_Date_Changed__c ||  collateralValuationNewMap.get(eachcollateralValuation).Frequency__c != collateralValuationOldMap.get(eachcollateralValuation).Frequency__c || collateralValuationNewMap.get(eachcollateralValuation).Number_of_Days__c != collateralValuationOldMap.get(eachcollateralValuation).Number_of_Days__c || collateralValuationNewMap.get(eachcollateralValuation).Relative_Date__c != collateralValuationOldMap.get(eachcollateralValuation).Relative_Date__c || collateralValuationNewMap.get(eachcollateralValuation).Due_Date__c != collateralValuationOldMap.get(eachcollateralValuation).Due_Date__C || collateralValuationNewMap.get(eachcollateralValuation).Days__c != collateralValuationOldMap.get(eachcollateralValuation).Days__c || collateralValuationNewMap.get(eachcollateralValuation).Other_Relative_Date__c != collateralValuationOldMap.get(eachcollateralValuation).Other_Relative_Date__c)
            {
                watcherItem = new Watcher__c();
                watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(collateralValuationNewMap.get(eachcollateralValuation));
                
                if(!collateralValuationWatcherMap.containsKey(eachcollateralValuation))
                {
                    watcherInsertList.add(watcherItem);
                }
                else
                {
                    if(collateralValuationNewMap.get(eachcollateralValuation).Due_Date__c != null)
                    {
                        collateralValuationWatcherMap.get(eachcollateralValuation).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralValuationWatcherMap.get(eachcollateralValuation));
                    }
                    else if(collateralValuationNewMap.get(eachcollateralValuation).Other_Relative_Date__c != null ) 
                    {
                        collateralValuationWatcherMap.get(eachcollateralValuation).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralValuationWatcherMap.get(eachcollateralValuation));
                    }
                    //Only update Watcher if "new" calculate due date is not greater that the schedule end date
                    else if(collateralValuationWatcherMap.get(eachcollateralValuation).Due_Date__c != watcherItem.Due_Date__c && collateralValuationWatcherMap.get(eachcollateralValuation).Due_Date__c <= collateralValuationNewMap.get(eachcollateralValuation).Schedule_End_Date__c)
                    {
                        collateralValuationWatcherMap.get(eachcollateralValuation).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralValuationWatcherMap.get(eachcollateralValuation));
                    }
                    else if(collateralValuationNewMap.get(eachcollateralValuation).Schedule_End_Date__c == null)
                    {
                        collateralValuationWatcherMap.get(eachcollateralValuation).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(collateralValuationWatcherMap.get(eachcollateralValuation));
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
    
    public static void updateStartEndDates(List<Collateral_Valuation__c> collateralValuationList)
    {
        Date scheduleStartDate;
        Date scheduleEndDate;
        Collateral_Valuation__c collateralValuationItem;
        List<Collateral_Valuation__c> collateralValuationUpdateList = new List<Collateral_Valuation__c>();
        Set<Id> collateralValuationIdSet;
        
        Set<Id> collateralSet = new Set<Id>();
        Set<Id> agreementSet = new Set<Id>();
        Map<Id, Agreement__c> agreementMap = new Map<Id, Agreement__c>();
        Map<Id, Collateral__c> collateralMap = new Map<Id, Collateral__c>();
        
        //Add Id's to Set
        for(Collateral_Valuation__c eachcollateralValuation : collateralValuationList)
        {
            agreementSet.add(eachcollateralValuation.Agreement__c);
            collateralSet.add(eachcollateralValuation.Collateral__c);
        }
        
        //Get all Agreements and Collateral linked to the Collateral Vluation to calculate the next due date, start and end date
        agreementMap = new Map<Id, Agreement__c>([SELECT Id, Financial_Year_End_Date__c, Effective_Date__c  , Signature_Date__c, Termination_Date__c FROM Agreement__c WHERE ID IN : agreementSet]);
        collateralMap = new  Map<Id, Collateral__c>([SELECT Id, Expiry_Date__c,Signature_Date__c FROM Collateral__c WHERE ID IN : collateralSet]);
        
        for(Collateral_Valuation__c eachcollateralValuation : collateralValuationList)
        {
            //Once Off Occurances - only 1 per Collateral Valuation
            if(eachcollateralValuation.Frequency__c == 'Once Off')
            {
                scheduleStartDate  = sObject_Scheduling_Occurences.calculateStartDate(eachcollateralValuation,'DUE-DATE');
                scheduleEndDate = sObject_Scheduling_Occurences.calculateEndDate(eachcollateralValuation,'DUE-DATE');
            }
            //Other Relative Date
            else
            {       
                //Agreement Level
                if (eachcollateralValuation.Agreement__c != null)
                {
                    scheduleStartDate  = sObject_Scheduling_Occurences.calculateScheduleStartDate(eachcollateralValuation,agreementMap.get(eachcollateralValuation.Agreement__c));
                    scheduleEndDate = sObject_Scheduling_Occurences.calculateScheduleEndDate(eachcollateralValuation,agreementMap.get(eachcollateralValuation.Agreement__c));
                    
                }
            }
            
            //Assign schedule start and end date based on lowest level and relative date 
            eachcollateralValuation.Schedule_Start_Date__c = scheduleStartDate;
            eachcollateralValuation.Schedule_End_Date__c = scheduleEndDate;
            
            collateralValuationUpdateList.add(eachcollateralValuation);
        }
    }
    
    public static void insertWatcherOccurence(List<Collateral_Valuation__c> collateralValuationList)
    {
        Watcher__c watcherItem = new Watcher__c();
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        Date scheduleEndDate;
        Date scheduleStartDate;
        
        for(Collateral_Valuation__c eachValuation : collateralValuationList)
        {
            watcherItem = new Watcher__c();
            //Call method to build te watcher record
            watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(eachValuation); 
            watcherItem.Collateral_Valuation__c = eachValuation.id;
            
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