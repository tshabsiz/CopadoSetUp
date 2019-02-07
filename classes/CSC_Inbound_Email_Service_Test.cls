/**
* Date   : 04-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_Inbound_Email_Service
**/
@IsTest(SeeAllData=true)
public class CSC_Inbound_Email_Service_Test {
    
    public static testMethod void serviceTest() {
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
		insert u;  
  
        //create test queue
        //String qid = CSC_TestDataFactory.getTestQueueId('testQueue');

        //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;

        Test.startTest();
       
            CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
            emailService.handleInboundEmail(email, env);
            
            list<Case> theCase = [Select Id From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
      
            theCase[0].OwnerId = [Select Id From User Where Email = 'one@test.sbsa.co.za'].Id;
            update theCase[0];
            
            String Case_ThreadID = CSC_TestDataFactory.getTestCaseThreadID(theCase[0].Id);
            
            email.Subject = 'Thread Id ' + Case_ThreadID;
            emailService.handleInboundEmail(email, env);
        
        Test.stopTest();
    }

}