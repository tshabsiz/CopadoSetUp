/**
*** CHANGE LOG ***
 
 16/11/2017 - TdB   - Created Class.
 12/02/2018 - TdB 	- Change Trigger watcher notifications from Status__c to Watcher_Status__c

**/ 
trigger Watcher_Trigger on Watcher__c (after update) {
    
    List<Watcher__c> breachedMarginRatchetWatchers = new  List<Watcher__c>();
    List<Watcher__c> reportGradingCollateralValuationWatchers = new  List<Watcher__c>();
    List<Watcher__c> resultCollateralMonitoringWatchers = new  List<Watcher__c>();
    List<Watcher__c> breachedTriggerWatchers = new  List<Watcher__c>();
    
   
    if(trigger.isAfter && Trigger.isUpdate)
    {
         for(Watcher__c eachWatcher : Trigger.new)
        {
            Watcher__c oldWatcher = Trigger.oldMap.get(eachWatcher.Id);
            if(((eachWatcher.Watcher_Status__c == 'Breached' && oldWatcher.Watcher_Status__c != 'Breached') || (eachWatcher.Watcher_Status__c == 'Breached with Action' && oldWatcher.Watcher_Status__c != 'Breached with Action')) && eachWatcher.Margin_Ratchet__c != null)
            {
                breachedMarginRatchetWatchers.add(eachWatcher);
            }
            else if(((eachWatcher.Report_Grading__c == 'Concern' && oldWatcher.Report_Grading__c != 'Concern') || (eachWatcher.Report_Grading__c == 'Escalation' && oldWatcher.Report_Grading__c != 'Escalation')) && eachWatcher.Collateral_Valuation__c != null)
            {
                reportGradingCollateralValuationWatchers.add(eachWatcher);
            }
            else if((eachWatcher.Result__c == 'Expectation Not Met' && oldWatcher.Result__c != 'Expectation Not Met') && eachWatcher.Collateral_Monitoring__c != null)
            {
                resultCollateralMonitoringWatchers.add(eachWatcher);
            }
            else if(((eachWatcher.Watcher_Status__c == 'Breached with Action' && oldWatcher.Watcher_Status__c != 'Breached with Action') || (eachWatcher.Watcher_Status__c == 'Breached Rectified' && oldWatcher.Watcher_Status__c != 'Breached Rectified')) && eachWatcher.Trigger__c != null)
            {
                breachedTriggerWatchers.add(eachWatcher);
            }
        }

        Watcher_Helper.createNextWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
        
        if(breachedMarginRatchetWatchers.size() > 0 )
        {
            Watcher_Helper.sendNotification(breachedMarginRatchetWatchers);
        }
        
        if(reportGradingCollateralValuationWatchers.size() > 0 )
        {
            Watcher_Helper.sendNotification(reportGradingCollateralValuationWatchers);
        }
        
        if(resultCollateralMonitoringWatchers.size() > 0 )
        {
            Watcher_Helper.sendNotification(resultCollateralMonitoringWatchers);
        }
        
        if(breachedTriggerWatchers.size() > 0 )
        {
            Watcher_Helper.sendNotification(breachedTriggerWatchers);
        }                             
    }
}