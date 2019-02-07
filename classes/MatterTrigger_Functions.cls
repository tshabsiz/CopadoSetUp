/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 @author Tracy de Bruin
 
*** CHANGE LOG ***
    
    TdB - 18/09/2016 - calculateNextReviewDate() - Calculate next review date based of frequency selected, exclude Weekends and Public Holidays
                       createNewMatterStatusTask() - Create new Task for each Status update and No Status update
    TdB - 01/11/2017 -  Update createNewMatterStatusTask() - Set diffrent Subject for No Status Update
	TdB - 01/08/2018 - Change "matterStatusTaskInsert != null" to "!matterStatusTaskInsert.isEmpty()"

**/
public class MatterTrigger_Functions {
    
    public static boolean firstRun = true;
    
    Public static void calculateNextReviewDate(List<advpm__Matter__c> matterList)
    {
        Set<Date> publicHolidaySet = new Set<Date>();
        DateTime todaysDate =  System.now();
        Date tempReviewDate = Date.today();
        
        //Get all public holidays
        for(Holiday eachHoliday : [ SELECT ActivityDate FROM Holiday WHERE ActivityDate >= :tempReviewDate AND ActivityDate <= :tempReviewDate.addDays(60)] )
        {
            publicHolidaySet.add(eachHoliday.ActivityDate);
        }
        
        for(advpm__Matter__c eachMatter : matterList)
        {
            //Calculate temp next review date
            tempReviewDate = Date.today();
            tempReviewDate = tempReviewDate.addDays(integer.valueof(eachMatter.Review_Frequency_days__c));

            while (todaysDate < tempReviewDate) {
                //Check for Weekends
                if (todaysDate.format('EEE') == 'Sat' || todaysDate.format('EEE') == 'Sun' || publicHolidaySet.contains(todaysDate.date())){
                    tempReviewDate = tempReviewDate.addDays(1);
                }

                todaysDate = todaysDate.addDays(1);
            }
            //Update Next Review Date
            eachMatter.Next_Review_Date__c = tempReviewDate;
            
        }
    }
    
    Public static void createNewMatterStatusTask(List<advpm__Matter__c> matterList)
    {
        System.debug('### MatterTrigger_Functions : createNewMatterStatusTask');

        List<Task> matterStatusTaskInsert = new List<Task>();
        Task eachTaskInsert = new Task();
        DatetIme todaysDate = System.now();
        //Get Matter Status History Task Record Type
        Id matterStatusHistory_RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Matter Status History').getRecordTypeId();

        
        for(advpm__Matter__c eachMatter : matterList)
        {
            eachTaskInsert = new Task();
            
            eachTaskInsert.RecordTypeId = matterStatusHistory_RecordTypeId;
            eachTaskInsert.ActivityDate =  todaysDate.date();
            eachTaskInsert.Priority = 'Medium';
            eachTaskInsert.Status = 'Completed';
            eachTaskInsert.WhatId = eachMatter.Id;

            if(eachMatter.hNext_Review_Date_Overdue__c == True)
            {
                System.debug('### MatterTrigger_Functions : createNewMatterStatusTask : IF OVERDUE');
                eachTaskInsert.Description = 'No Update';
                eachTaskInsert.Subject = 'No Matter Status Update';

            }
            else
            {
                System.debug('### MatterTrigger_Functions : createNewMatterStatusTask : IF NORMAL');
                eachTaskInsert.Description = eachMatter.Current_Status__c;
                eachTaskInsert.Subject = 'Matter Status Update';
            }

            matterStatusTaskInsert.add(eachTaskInsert);
        }
        
        if(!matterStatusTaskInsert.isEmpty())
        {
            insert matterStatusTaskInsert;
        }
    }
}