/**
* Date   : 08-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Support_Case_Main_Cont
* 2017-03-30 RN - Update class for email -> case linking user story - CSC Phase II
**/

@IsTest(SeeAllData=true)
public class CSC_Support_Case_Main_Cont_Test {
    
	 public static testMethod void mainContTest() {
         
         CSC_TestDataFactory.testDataSize = 1;
         
         //test data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
         
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        insert u;
         
        //list<Case> manualCase = CSC_TestDataFactory.getTestCaseList('CSC Manual Cases', u.Id);
         
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment(); 
        CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
      	
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
          list<Case> newCase = [Select Id, Queue__c From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
         newCase[0].Queue__c = 'EBSH - Passwords';
         newCase[0].Department__c = 'EBSH';
         newCase[0].Service_Type__c = 'System';
         newCase[0].Service_Category__c = 'Incident';
         newCase[0].Service_Sub_Category__c = 'Change/Enhance';
         update newCase[0];
           list<EmailMessage> emailmsg = CSC_TestDataFactory.getTestEmailMessageList(newCase[0].Id, true);
         insert emailmsg;
          emailmsg[0].isOriginalEmail__c = true;
         update emailmsg;
         //add attachments
         Attachment att = new Attachment();
         att.ParentId = emailmsg[0].Id;
         att.Name = 'Hello World';
         att.Body = Blob.valueOf('Goodbye crule world');
         insert att;
         String libId = [Select Id, Name From ContentWorkspace Where Name = 'CSC Email Files'].Id;
         ContentVersion cv = new ContentVersion();
         cv.title = 'Hello123.txt';
         cv.versionData = att.body;
         cv.pathOnClient = 'Hello123.txt';
         cv.FirstPublishLocationId = libId;
         insert cv;
         
        FeedItem post = new FeedItem();
        post.ParentId = newCase[0].Id;
        post.Body = 'CSC email attachment related content';
        post.RelatedRecordId = cv.Id;
        post.Type = 'ContentPost';
         insert post;
         System.debug( 'Limit:' + Limits.getQueries() );
        
         
         Test.startTest();
         
         emailService.handleInboundEmail(email, env);
         
         System.debug( 'Limit:' + Limits.getQueries() );
        
          
         
         PageReference pageRef = Page.CSC_Support_Case_Main;
         Test.setCurrentPage(pageRef);     
         ApexPages.currentPage().getParameters().put('id', newCase[0].Id);
         ApexPages.currentPage().getParameters().put('isclone', 'true');
         
         ApexPages.standardController controller = new ApexPages.standardController(newCase[0]);
         CSC_Support_Case_Main_Cont theCont = new CSC_Support_Case_Main_Cont(controller);
        
         //theCont.runProcess();
         theCont.reload();
         //test exception
         
         
         Test.stopTest();
        
    }
    
}