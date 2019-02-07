//CloudSmiths : RN
//Date: 08/11/2016
//Test class for : CSC_ContentDocumentLink_Trigger & CSC_ContentDocumentLink_Trigger_Func

@IsTest(SeeAllData=true)
public class CSC_ContentDocumentLink_Trigger_Test {

   public static testMethod void contentDocumentLinkTest(){
   
       //create some service mapping data
        //Service mapping
        CSC_TestDataFactory.testDataSize = 1;
        
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
       
        //inbound email and envelope objects
        Messaging.InboundEmail email = CSC_TestDataFactory.getTestInboundEmail();
        Messaging.InboundEnvelope env = CSC_TestDataFactory.getTestInboundEnvelope();
        email.binaryAttachments = CSC_TestDataFactory.getTestBinaryAttachment();
        //test cases
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
       
        Test.startTest();
       	
       		CSC_Inbound_Email_Service emailService = new CSC_Inbound_Email_Service();
            emailService.handleInboundEmail(email, env);

        Test.stopTest();
   }
    
}