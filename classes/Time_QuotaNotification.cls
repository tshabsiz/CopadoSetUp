global class Time_QuotaNotification implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {
        //Blonk vars.
        List<advpm__Time__c> timeEntries = new List<advpm__Time__c>();
        Map<Id, Decimal> timekeeperTotals = new Map<Id, Decimal>();
        Set<Id> timekeeperIds = new Set<Id>();
        List<advpm__Timekeeper__c> timekeeperUpdateList = new List<advpm__Timekeeper__c>();
    
        //Get the start and end date for the previous week.
        Date endDate    = Date.today().toStartofWeek(); //Sunday
        Date startDate  = endDate.addDays(-1).toStartofWeek().addDays(1); //Monday
        
        //Get a list of active time keepers that are configured for notifications.
        Map<Id, advpm__Timekeeper__c> timeKeepers = new Map<Id, advpm__Timekeeper__c>([
            SELECT
                Id,
                Name,
                Weekly_Quota_Notification__c,
                advpm__Staff__r.isActive,
                advpm__Staff__r.ManagerId,
                Last_Weeks_Quota_Hours__c,
                Quota_Last_Updated__c
            FROM advpm__Timekeeper__c
            WHERE 
                Weekly_Quota_Notification__c = true
                AND advpm__Staff__r.isActive = true
        ]);
        
        System.debug('### Time_QuotaNotification : execute : timeKeepers : '+timeKeepers);
        
        //Have any timekeeper records?
        if(!timeKeepers.isEmpty())
        {
            
            //Populate timekeeperTotals with default values.
            for(Id key : timeKeepers.keySet())
            {
                timekeeperTotals.put(timeKeepers.get(key).Id, 0.00);
                timekeeperIds.add(timeKeepers.get(key).Id);
            }
           
            //Get the time entries for timekeepers that need notifications.
            timeEntries = [
                SELECT
                    Id,
                    Name,
                    advpm__Timekeeper__c,
                    advpm__Entry_Date__c,
                    advpm__Time_In_Hours__c
                FROM
                    advpm__Time__c
                WHERE
                    advpm__Timekeeper__c IN :timekeeperIds 
                    AND advpm__Entry_Date__c >= :startDate AND advpm__Entry_Date__c <= :endDate // Could have use "LAST_WEEK" instead if locale starts Monday-Sunday
                    AND advpm__Time_In_Hours__c != null
            ];
            
            System.debug('### Time_QuotaNotification : execute : timeEntries : '+timeEntries);
            
            //Calculate the totals for each timekeeper
            for(advpm__Time__c timeEntry : timeEntries)
            {
                //Get the current value.
                Decimal totalHours = timekeeperTotals.get(timeEntry.advpm__Timekeeper__c);
                
                //Replace and update/add hours for timekeeper. 
                timekeeperTotals.put(timeEntry.advpm__Timekeeper__c, totalHours+timeEntry.advpm__Time_In_Hours__c);
            }
            
            System.debug('### Time_QuotaNotification : execute : timekeeperTotals : '+timekeeperTotals);
            
            //Update the weekly totals on the timekeepers.   This will trigger the notifications via workflow...
            for(Id key : timekeeperTotals.keySet())
            {
                //Get timekeeper record.
                advpm__Timekeeper__c timeKeeper = timeKeepers.get(key);
                
                //Set updated quota value.
                timeKeeper.Last_Weeks_Quota_Hours__c = timekeeperTotals.get(key);
                timeKeeper.Quota_Last_Updated__c = Date.today();
                timeKeeper.Line_Manager__c = timeKeeper.advpm__Staff__r.ManagerId;
                
                //timekeeperUpdateList
                timekeeperUpdateList.add(timeKeeper);
            }
            
            //Any records to update.
            if(!timekeeperUpdateList.isEmpty())
            {
                try
                {
                    //Update records.
                    update timekeeperUpdateList;
                }
                catch(Exception e)
                {
                    System.debug('### Time_QuotaNotification : exception : Message : '+e.getMessage());
                }
            }
        }
    }
}