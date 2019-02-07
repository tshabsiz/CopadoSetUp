/**
* Date   : 11-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Quick_Action_Link_Case_Cont
**/
@IsTest(SeeAllData=true)
public class CSC_Quick_Action_Link_Case_Cont_Test {
	
    public static testMethod void linkTest() {
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
		insert sm;
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
        
        list<Case> Cases = CSC_TestDataFactory.getTestCaseList('Internal Support Case', u.Id);
        insert Cases;
        
         //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        
         list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        
        Test.startTest();
  
        emailService.handleInboundEmail(email, env);
        list<Case> newCase = [Select Id, CaseNumber, Subject, Queue__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1]; 
		list<EmailMessage> ems = CSC_TestDataFactory.getTestEmailMessageList(newCase[0].Id, true);
        insert ems; 
        ems[0].isOriginalEmail__c = true;
        update ems[0];
        
        Attachment eBody = new Attachment();
        eBody.Name = 'A File';
        eBody.ContentType = 'application/html';
        eBody.Body = Blob.valueOf('A BLOB');
        eBody.ParentId = ems[0].Id;
        insert eBody;
       
        
        PageReference pageRef = Page.CSC_Quick_Action_Link_Case;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
         
        ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
        CSC_Quick_Action_Link_Case_Cont theCont = new CSC_Quick_Action_Link_Case_Cont(controller);
        theCont.lstCaseWrapper[0].IsChecked = true;
        theCont.searchCaseNumber = newCase[0].CaseNumber;
        theCont.searchSubject = newCase[0].Subject;
        theCont.searchCases();
        //select cases
   		theCont.lstCaseWrapper[0].IsChecked = true;
        
        theCont.linkEmailToCase();  
        
        Test.stopTest();
    }
}