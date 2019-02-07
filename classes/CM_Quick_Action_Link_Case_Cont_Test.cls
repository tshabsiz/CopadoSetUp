/**
* Date   : 2017-02-22
* Author : Rudolf Niehaus - CloudSmiths
* Desc   : Test class for: CM_Quick_Action_Link_Case_Cont
**/
@IsTest(SeeAllData=true)
public class CM_Quick_Action_Link_Case_Cont_Test {
    
	public static testMethod void cmLinkTest() {
        
        CSC_TestDataFactory.testDataSize = 1;
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
		insert sm;
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
        
        list<Case> Cases = CSC_TestDataFactory.getTestCaseList('Complaint', u.Id);
        Cases[0].Queue__c = 'Complaints Client';
       	Cases[0].Service_Type__c = 'Delays';
        Cases[0].Service_Sub_Category__c = 'Takes to Long';
        Cases[0].Service_Category__c = 'Complaint';
        insert Cases[0];
        Test.startTest();
         //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
        
         list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'Complaint' , UserInfo.getUserId() );
        caseInsertList[0].Queue__c = 'Complaints Client';
       	caseInsertList[0].Service_Type__c = 'Delays';
        caseInsertList[0].Service_Sub_Category__c = 'Takes to Long';
        caseInsertList[0].Service_Category__c = 'Complaint';
        insert caseInsertList[0];
        
        
        
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
        CM_Quick_Action_Link_Case_Cont theCont = new CM_Quick_Action_Link_Case_Cont(controller);
        theCont.lstCaseWrapper[0].IsChecked = true;
        theCont.searchCaseNumber = newCase[0].CaseNumber;
        theCont.searchSubject = newCase[0].Subject;
        theCont.searchCases();
        //select cases
   		//theCont.lstCaseWrapper[0].IsChecked = true;
        
        //theCont.linkCaseToCase();  
        
        Test.stopTest();
    }
    
   
}