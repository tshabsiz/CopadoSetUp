/**
* Date   : 11-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Quick_Action_Transfer_Case_Cont
**/
@IsTest(SeeAllData=true)
public class CSC_EmailMessage_Trigger_Test {
	
    public static testMethod void messageTriggerTest() {
        CSC_TestDataFactory.testDataSize = 1;
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;

        //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        
        Test.startTest();
       
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        emailService.handleInboundEmail(email, env);
        
        list<Case> c = [Select Id From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
        c[0].Queue__c = 'EBSH - Passwords';
        c[0].Department__c = 'EBSH';
        c[0].Service_Type__c = 'System';
        update c[0];
        
        list<EmailMessage> msg = CSC_TestDataFactory.getTestEmailMessageList(c[0].Id, true);
        insert msg;
        
        try{
            delete msg;
        }catch(Exception e){
            System.debug('Catch message delete error');
        }
        Test.stopTest();
    }
}