/**
* Author : Rudolf Niehaus
* Date   : 2017-08-09
* Desc   : Test class for the Event_Team_Member__c tigger and trigger functions class evEventMemberTriggerFunctions
* Note Event_Team_Member__c for test is generated automatically by evEvent_trigger when new event created
**/
@isTest
public class evEventMemberTrigger_Test
{
    
    static testMethod void testEventMemberTrigger()
    {
        
        Test.startTest();
        //TEST DATA
        evTestDataGenerator testData = new evTestDataGenerator();
        
        Event__c TestEvent2  = new Event__c
            (
                Name = 'Test Event2', 
                Capacity__c = 2, 
                Start_Date__c = Date.today(),  
                End_Date__c = Date.today()+3,
                Discount_2__c = 10, 
                Discount__c = 5, 
                Discount_Threshold__c = 1, 
                Discount_Threshold_2__c = 2, 
                Online_Processing__c = 'Create Opportunity; Optional Payment' ,
                Currencyisocode='ZAR',
                Allow_Booking_Online_for_New_Customers__c = true,
                ID_Number_Passport_at_Booking__c = 'No',
                //Product__c = testData.Testproduct.Id,
                //PriceBook__c = test.getStandardPricebookId(),
                //Price_Book_Entry_id__c = testData.TestPricebookEntry.id,
                Use_Ticket_Types_Batches__c = True,
                Dietary_Requirements_Requiring_Payment__c =  'Kosher',
                Badge_Style__c = testData.TestBadgeEventConfig.id,
                Registration_Process__c = 'Simple',
                I_have_read_Absa_Event_Governance__c = true
            );
        
        insert TestEvent2;
        
        list<Event_Team_Member__c> teamList = new list<Event_Team_Member__c>();
        
        Event_Team_Member__c testTM =  
            [
                SELECT
                id
                FROM
                Event_Team_Member__c
                WHERE 
                EVent__C = : TestEvent2.id
                Limit 1
            ];
        
        delete testTM;
        
        Test.stopTest();
        
    }
}