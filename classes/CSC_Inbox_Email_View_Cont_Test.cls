/**
* Date   : 11-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Inbox_Email_View_Cont
**/
@IsTest(SeeAllData=true)
public class CSC_Inbox_Email_View_Cont_Test {
	
    public static testMethod void emailViewTest() {
     	
         CSC_TestDataFactory.testDataSize = 1;
         
         //test data
         Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
		 insert sm;
        
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment(); 
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        emailService.handleInboundEmail(email, env);
         
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        
        Test.startTest();
       
        
        list<Case> newCase = [Select Id, Queue__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1]; 
         	
        PageReference pageRef = Page.CSC_Inbox_Email_View;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
         
        ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
        CSC_Inbox_Email_View_Cont theCont = new CSC_Inbox_Email_View_Cont(controller);

         Test.stopTest();
     
     }

}