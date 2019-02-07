/**
* @author Deshan Pillay
* @date 17/07/2018
* @description This class is used by the evEventSetupHelper to get the Event__c record.
*/

global class evEventSetupHelper_Controller {
    
    /**
    * @author Deshan Pillay
    * @date 17/07/2018
    * @description It queries the Event__c record
    * @param eventId RecordId of the event the component is used on
    * @return Event__c
    */
    @AuraEnabled
    public static Event__c getEvent(Id eventId) {
        return 
            [
                SELECT 
                Id, 
                Name,
                Venue__c,
                Theme__c,
                Event_Configuration__c,
                Terms_and_Conditions__c,
                Event_Team_Members_Count__c,
                Delegates_Invited_Count__c,
                Event_Email_Schedule_Count__c
                FROM 
                Event__c 
                WHERE 
                Id = :eventId
            ];
    }

}