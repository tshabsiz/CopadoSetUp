/**
* Author : Daniel Field
* Date   : 2017-10-26
* Desc   : Test class for the evEventTeamMember_Trigger
**/
@isTest
public class evEventTeamMember_Trigger_test 
{
    static testMethod void testAddContactsToEventExtr()
    {
        
        evTestDataGenerator testData = new evTestDataGenerator();
        Event_Team_Member__c  TestEventTeamMemmber = 
            [
                SELECT
                id
                FROM
                Event_Team_Member__c
                Limit 1 
            ];
        
        evTriggerHelperClass.evEventTeamMember_Trigger_FirstRun =  true;
        
        Delete TestEventTeamMemmber;
        
        evTriggerHelperClass.evEventTeamMember_Trigger_FirstRun =  true;
        
        id CurrentUserID =userInfo.getUserId();
        
        id userID = [SELECT id FROM USER WHERE isActive = true AND profile.name = 'Barclays Administrator' and id != : CurrentUserID limit 1].id;
        system.debug('userID' + userID);
        system.debug('CurrentUserID' + CurrentUserID);
        Event_Team_Member__c ETM = new Event_Team_Member__c
            (
                Event__c 								= testData.TestEvent.id,
                Team_Member__c 							= userID,
                Maximum_Number_of_Actual_Invitees__c 	= 0,
                Maximum_Number_of_Proposed_Invitees__c 	= 0,
                Event_Team_Member_Role__c 				= 'Coordinator'
            );
        insert ETM;
        evTriggerHelperClass.evEventTeamMember_Trigger_FirstRun =  true;
        delete ETM;
    }
    
    
}