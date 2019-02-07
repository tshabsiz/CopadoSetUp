/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 01/08/2017 - PG    - Created class.
 04/08/2017 - PG    - Added new status changes.
 08/08/2017 - PG    - Added "Closed" status to update logic.
 04/10/2017 - SP    - Added condition to check if litigation approval has started
 
**/ 
public class Matter_SpendSchedule_Helper {

    /**
    * Updates the overall status if a schedule based on Spend Document statuses.
    **/
    public static void updateSchedulesStatuses(Set<Id> inputScheduleIds) 
    {
        System.debug('### Matter_SpendSchedule_Helper : updateSchedulesStatuses');
        
        //Blank list.
        List<Matter_Spend_Schedule__c> schedules = new List<Matter_Spend_Schedule__c>();

        //Get schedules and documents for it.
        schedules = [
            SELECT
                Id,
                Status__c,Litigation_Approval_Started__c,Matter_Type__c,
                (
                    SELECT
                        Id,
                        Status__c,
                        Matter_Spend_Schedule__c
                    FROM Matter_Spend_Documents__r

                )
            FROM Matter_Spend_Schedule__c
            WHERE
                Id IN :inputScheduleIds
        ];

        //Loop through each schedule.
        for(Matter_Spend_Schedule__c schedule : schedules)
        {   
            //Counter to hold num approved vs. total.
            Integer totalApproved = 0;
            Integer totalPaid = 0;
            Integer totalDocuments = schedule.Matter_Spend_Documents__r.size();
            String scheduleStatus = '';

            System.debug('### totalDocuments : '+totalDocuments);

            for(Matter_Spend_Document__c spendDocument : schedule.Matter_Spend_Documents__r)
            {
               System.debug('### Matter_SpendSchedule_Helper : updateSchedulesStatuses : spendDocument : '+spendDocument);
                
                if(spendDocument.Status__c == 'Approved For Payment')
                {
                    //Increment counter.
                    totalApproved++;
                }

                if(spendDocument.Status__c == 'Paid')
                {
                    //Increment counter.
                    totalPaid++;
                }
            }

            //Change status to "Open"
            if((totalApproved != totalDocuments) && schedule.Status__c == 'Approved')
            {
                schedule.Status__c = 'Open';
            }

            //Change status to "Approved"
            if((totalApproved == totalDocuments) && schedule.Status__c == 'Open')
            {
                schedule.Status__c = 'Approved';
            }

            //Change status to "Closed"
            if((totalPaid == totalDocuments) && schedule.Status__c == 'Pending Payment')
            {
                schedule.Status__c = 'Closed';
            }
            
            //Change status to "Closed"
            if(totalDocuments == 0)
            {
                schedule.Status__c = 'Closed';
            }
       //Sean added this condition to check if litigation approval has started
            
            if(schedule.Matter_Type__c=='Litigation' && totalApproved>0){
                schedule.Litigation_Approval_Started__c=True;
            }
        }

        //Update records.
        update schedules;
    }

    /**
    * Before Update trigger handler.
    **/
    public static void beforeUpdate(List<Matter_Spend_Schedule__c> inputNewList, Map<Id, Matter_Spend_Schedule__c> inputOldMap)
    {
        System.debug('### Matter_SpendSchedule_Helper : beforeUpdate');
        
        //Blank list.
        List<Matter_Spend_Schedule__c> statusChanged = new List<Matter_Spend_Schedule__c>();

        //Loop through updated schedules.
        for(Matter_Spend_Schedule__c spendSchedule : inputNewList)
        {
            //Has the status changed on Schedule?
            if(spendSchedule.Status__c != inputOldMap.get(spendSchedule.Id).Status__c)
            {
                statusChanged.add(spendSchedule);
            }
        }

        //Anything to process.
        if(!statusChanged.isEmpty())
        {
            updateStatusDates(statusChanged);
        }
        
        System.debug('### Matter_SpendSchedule_Helper : beforeUpdate : END');
    }

    /**
    * Sets the date fields for a status change on a schedule.
    **/
    public static void updateStatusDates(List<Matter_Spend_Schedule__c> inputSpendSchedules)
    {
        System.debug('### Matter_SpendSchedule_Helper : updateStatusDates');
        
        //Loop thought records and detemine what status changed.
        for(Matter_Spend_Schedule__c spendSchedule : inputSpendSchedules)
        {
            if(spendSchedule.Status__c == 'Approved')
            {
                spendSchedule.Approved_Date__c = Date.Today();
            }
            else if(spendSchedule.Status__c == 'Exported')
            {
                spendSchedule.Exported_Date__c = Date.Today();
            }
            else if(spendSchedule.Status__c == 'Pending Payment')
            {
                spendSchedule.Payment_Date__c = Date.Today();
            }
            else if(spendSchedule.Status__c == 'Closed')
            {
                spendSchedule.Closed_Date__c = Date.Today();
            }
        }
    }
    
    /**
    * Notifies accounts of a schedule that needs payment.
    **/
    public static void sendReadyForPaymentEmail()
    {
        Messaging.reserveSingleEmailCapacity(1);
    }
}