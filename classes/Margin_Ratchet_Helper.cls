/**
*** CHANGE LOG ***

16/11/2017 - TdB    - Created Class.
                    - updateWatcherOccurence() - Get all open Watcher record and determine if Due Date should be updated/new Watcher created
                    - updateStartEndDates() - Calculate Schedule start and end date based on lowest level (Agreement/Facility/Tranche) and Relative Date
                    - insertWatcherOccurence() - Call Method to build the watcher record and insert record if due date is set
12/02/2018 - TdB   - Remove Status__c refrences on Watcher

**/ 

public class Margin_Ratchet_Helper {
    public List<Margin_Ratchet__c> marginRatchetUpdateList;
    
    public static void updateWatcherOccurence(Map<Id,Margin_Ratchet__c> marginRatchetOldMap, Map<Id,Margin_Ratchet__c> marginRatchetNewMap)
    {
        Map<Id, Watcher__c> marginRatchetWatcherMap = new Map<Id, Watcher__c>();
        Watcher__c watcherItem;
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        List<Watcher__c> watcherUpdateList = new List<Watcher__c>();
        Date scheduleStartDate;
        Date scheduleEndDate;
        Margin_Ratchet__c marginRatchetItem;
        List<Margin_Ratchet__c> marginRatchetList = new List<Margin_Ratchet__c>();

        //Get all Watchers linked to Margin Ratchet
        for(Watcher__c eachWatcher : [SELECT Id, Margin_Ratchet__c, Watcher_Status__c, Due_Date__c 
                                      FROM Watcher__c 
                                      WHERE Margin_Ratchet__c IN :marginRatchetNewMap.keySet()
                                      AND (Watcher_Status__c = 'New'
                                           OR Watcher_Status__c = 'Due'
                                           OR Watcher_Status__c = 'Overdue')])
        {
            if(!marginRatchetWatcherMap.containsKey(eachWatcher.Margin_Ratchet__c))
            {
                marginRatchetWatcherMap.put(eachWatcher.Margin_Ratchet__c, eachWatcher);
            }
        }
        
        for(Id eachMarginRatchet : marginRatchetNewMap.keySet())
        {
            //Check if schedule changed, then recalculate start date
            if(marginRatchetNewMap.get(eachMarginRatchet).Start_Date_End_Date_Changed__c ||  marginRatchetNewMap.get(eachMarginRatchet).Frequency__c != marginRatchetOldMap.get(eachMarginRatchet).Frequency__c || marginRatchetNewMap.get(eachMarginRatchet).Number_of_Days__c != marginRatchetOldMap.get(eachMarginRatchet).Number_of_Days__c || marginRatchetNewMap.get(eachMarginRatchet).Relative_Date__c != marginRatchetOldMap.get(eachMarginRatchet).Relative_Date__c || marginRatchetNewMap.get(eachMarginRatchet).Due_Date__c != marginRatchetOldMap.get(eachMarginRatchet).Due_Date__C || marginRatchetNewMap.get(eachMarginRatchet).Days__c != marginRatchetOldMap.get(eachMarginRatchet).Days__c || marginRatchetNewMap.get(eachMarginRatchet).Other_Relative_Date__c != marginRatchetOldMap.get(eachMarginRatchet).Other_Relative_Date__c)
            {
                watcherItem = new Watcher__c();
                watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(marginRatchetNewMap.get(eachMarginRatchet));
                
                if(!marginRatchetWatcherMap.containsKey(eachMarginRatchet))
                {
                    watcherInsertList.add(watcherItem);
                }
                else
                {
                    if(marginRatchetNewMap.get(eachMarginRatchet).Due_Date__c != null)
                    {
                        marginRatchetWatcherMap.get(eachMarginRatchet).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(marginRatchetWatcherMap.get(eachMarginRatchet));
                    }
                    else if (marginRatchetNewMap.get(eachMarginRatchet).Other_Relative_Date__c != null)
                    {
                        marginRatchetWatcherMap.get(eachMarginRatchet).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(marginRatchetWatcherMap.get(eachMarginRatchet));
                    }
                    //Only update Watcher if "new" calculate due date is not greater that the schedule end date
                    else if(marginRatchetWatcherMap.get(eachMarginRatchet).Due_Date__c != watcherItem.Due_Date__c && marginRatchetWatcherMap.get(eachMarginRatchet).Due_Date__c <= marginRatchetNewMap.get(eachMarginRatchet).Schedule_End_Date__c)
                    {
                        marginRatchetWatcherMap.get(eachMarginRatchet).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(marginRatchetWatcherMap.get(eachMarginRatchet));
                    }
                    else if(marginRatchetNewMap.get(eachMarginRatchet).Schedule_End_Date__c == null)
                    {
                        marginRatchetWatcherMap.get(eachMarginRatchet).Due_Date__c =  watcherItem.Due_Date__c;
                        watcherUpdateList.add(marginRatchetWatcherMap.get(eachMarginRatchet));
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
    
    public static void updateStartEndDates(List<Margin_Ratchet__c> marginRatchetList)
    {
        Date scheduleStartDate;
        Date scheduleEndDate;
        Margin_Ratchet__c marginRatchetItem;
        List<Margin_Ratchet__c> marginRatchetUpdateList = new List<Margin_Ratchet__c>();
        Set<Id> marginRatchetIdSet;
        
        Set<Id> agreementSet = new Set<Id>();
        Set<Id> facilitySet = new Set<Id>();
        Set<Id> facilityTrancheSet = new Set<Id>();
        Map<Id, Agreement__c> agreementMap = new Map<Id, Agreement__c>();
        Map<Id, Facility__c> facilityMap = new Map<Id, Facility__c>();
        Map<Id, Facility_Tranche__c> facilityTrancheMap = new Map<Id, Facility_Tranche__c>();
        
        //Add Id's to Set
        for(Margin_Ratchet__c eachMarginRatchet : marginRatchetList)
        {
            agreementSet.add(eachMarginRatchet.Agreement__c);
            facilitySet.add(eachMarginRatchet.Facility__c);
            facilityTrancheSet.add(eachMarginRatchet.Facility_Tranche__c);
        }
        
        //Get all Agreements, Facilities and Trances linked to the Margin Ratchet to calculate the next due date, start and end date
        agreementMap = new Map<Id, Agreement__c>([SELECT Id, Financial_Year_End_Date__c, Effective_Date__c  , Signature_Date__c, Termination_Date__c FROM Agreement__c WHERE ID IN : agreementSet]);
        facilityMap = new Map<Id, Facility__c>([SELECT Id, Financial_Year_End_Date__c, Availability_Start_Date__c , Signature_Date__c, Availability_End_Date__c FROM Facility__c WHERE ID IN : facilitySet]);
        facilityTrancheMap = new Map<Id, Facility_Tranche__c>([SELECT Id, Financial_Year_End_Date__c, Availability_Start_Date__c, Signature_Date__c, Availability_End_Date__c FROM Facility_Tranche__c WHERE ID IN :facilityTrancheSet]);
        
        for(Margin_Ratchet__c eachMarginRatchet : marginRatchetList)
        {
            //Once Off Occurances - only 1 per Margin Ratchet, calculate schedule start and end date based on lowest level (Agreement/Facility/Tranche)
            if(eachMarginRatchet.Frequency__c == 'Once Off')
            {
                scheduleStartDate  = sObject_Scheduling_Occurences.calculateStartDate(eachMarginRatchet,'DUE-DATE');
                scheduleEndDate = sObject_Scheduling_Occurences.calculateEndDate(eachMarginRatchet,'DUE-DATE');
            }
            //Other Relative Date - calculate schedule start and end date based on lowest level (Agreement/Facility/Tranche)
            else
            {
                //Tranche - Lowest level
                if(eachMarginRatchet.Facility_Tranche__c != null)
                {
                    scheduleStartDate  = sObject_Scheduling_Occurences.calculateScheduleStartDate(eachMarginRatchet,facilityTrancheMap.get(eachMarginRatchet.Facility_Tranche__c));
                    scheduleEndDate = sObject_Scheduling_Occurences.calculateScheduleEndDate(eachMarginRatchet,facilityTrancheMap.get(eachMarginRatchet.Facility_Tranche__c));
                    
                } 
                //Facility - Lowest level
                else if(eachMarginRatchet.Facility__c != null) 
                {
                    scheduleStartDate  = sObject_Scheduling_Occurences.calculateScheduleStartDate(eachMarginRatchet,facilityMap.get(eachMarginRatchet.Facility__c));
                    scheduleEndDate = sObject_Scheduling_Occurences.calculateScheduleEndDate(eachMarginRatchet,facilityMap.get(eachMarginRatchet.Facility__c));
                    
                }
                //Agreement - Lowest level
                else if (eachMarginRatchet.Agreement__c != null)
                {
                    scheduleStartDate  = sObject_Scheduling_Occurences.calculateScheduleStartDate(eachMarginRatchet,agreementMap.get(eachMarginRatchet.Agreement__c));
                    scheduleEndDate = sObject_Scheduling_Occurences.calculateScheduleEndDate(eachMarginRatchet,agreementMap.get(eachMarginRatchet.Agreement__c));
                    
                }
            }
            
            //Assign schedule start and end date based on lowest level and relative date 
            eachMarginRatchet.Schedule_Start_Date__c = scheduleStartDate;
            eachMarginRatchet.Schedule_End_Date__c = scheduleEndDate;
            
            marginRatchetUpdateList.add(eachMarginRatchet);
        }
        
    }
    
    public static void insertWatcherOccurence(List<Margin_Ratchet__c> marginRatchetList)
    {
        Watcher__c watcherItem = new Watcher__c();
        List<Watcher__c> watcherInsertList = new List<Watcher__c>();
        Date scheduleEndDate;
        Date scheduleStartDate;
        
        for(Margin_Ratchet__c eachMarginRatchet : marginRatchetList)
        {
            watcherItem = new Watcher__c();
            //Call method to build te watcher record
            watcherItem = sObject_Scheduling_Occurences.buildSObjectWatcher(eachMarginRatchet); 
            watcherItem.Margin_Ratchet__c = eachMarginRatchet.id;
            
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