/**
* Date   : 11-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Quick_Action_Transfer_Case_Cont
**/
@IsTest(SeeAllData=true)
public class CSC_Quick_Action_Transfer_Case_Cont_Test {
	
    public static testMethod void transferTest() {
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
         //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        
        
        
         	
        emailService.handleInboundEmail(email, env);
        list<Case> newCase = [Select Id, Queue__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1]; 
        newCase[0].Queue__c = 'EBSH - Passwords';
        newCase[0].Department__c = 'EBSH';
        newCase[0].Service_Type__c = 'System';
        
        Test.startTest();
        update newCase[0];
        
        PageReference pageRef = Page.CSC_Quick_Action_Transfer_Case;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
        
        
        ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
        CSC_Quick_Action_Transfer_Case_Cont theCont = new CSC_Quick_Action_Transfer_Case_Cont(controller);
        Test.stopTest();
        theCont.updateCase();  
        
        
    }
}