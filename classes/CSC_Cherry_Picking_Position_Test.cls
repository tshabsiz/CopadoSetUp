/**
* Date   : 09-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Cherry_Picking_Position
**/
@IsTest(SeeAllData=true)
public class CSC_Cherry_Picking_Position_Test {

    public static testMethod void cherryClassTest(){
    
        CSC_TestDataFactory.testDataSize = 10;
         
         //test data
         Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();

        //Create special email template reply contact
        Contact con = new Contact();
        con.Email = 'agentss@support.net';
        con.FirstName = 'Supportt';
        con.LastName = 'Agentt';
        insert con;
         
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
         
        list<Case> lstCase = CSC_TestDataFactory.getTestCaseList('CSC Emails', u.Id);
        
        Test.startTest();
        
        insert lstCase;

        Integer x = CSC_Cherry_Picking_Position.getCaseQueuePosition(lstCase[0].Id);
        //System.assertEquals(1, x);
        x = CSC_Cherry_Picking_Position.getCaseQueuePosition(con.Id);
        System.assertEquals(0, x);
        
        Test.stopTest();
    }
    
}