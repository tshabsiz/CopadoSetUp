@isTest
public class evTimeLine_Controller_Test 
{
    static testMethod void evEvent_Trigger_test()
    {
        
        //TEST DATA
        evTestDataGenerator testData = new evTestDataGenerator();
        
        evTimeLine_Controller con = new evTimeLine_Controller();
        evTimeLine_Controller.getTimeLine(null);
        EM_Event_Email_Configuration__c testEmailConfig = new EM_Event_Email_Configuration__c
            (  

                Label__c = 'test',
                Start_Send_Date__c = date.today(),
                Stop_Send_Date__c = date.today(),
                SMS_Text__c = 'test',
                Event__c = testData.testevent.id
            );
        
        insert testEmailConfig;
        
        evTimeLine_Controller.getTimeLine(testData.testevent.id);
    }
}