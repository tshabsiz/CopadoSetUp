/**
* 2017-06-29
* Rudolf Niehaus - CloudSmiths
**/
@IsTest(SeeAllData=true)
public class Payments_Outbound_SWIFT_Test {

     static testMethod void testPaymentsCaseRest() {

        //TEST DATA 
        list<Account> accList = CSC_TestDataFactory.getTestAccountList('Client - Individual');
        accList[0].BIC_Code__c = 'BIC1';
        insert accList;
        CSC_TestDataFactory.testDataSize = 1;
        list<Case> caseList = CSC_TestDataFactory.getTestCaseList('Payments', UserInfo.getUserId());
        caseList[0].SWIFT_GBP_Reference__c = 'ABC';
        insert caseList[0];       
       SWIFT_Message__c newMsg = new SWIFT_Message__c();
       newMsg.Case__c = caseList[0].Id;
       newMsg.MessageType__c = '199';
       newMsg.PaymentMessage__c = 'message';
       newMsg.QueryMessage__c = 'query';
       newMsg.TransactionReference__c = 'resf';
       newMsg.Sender_Address__c = 'ABSAZAJ0AXXX';
       newMsg.DestinationAddress__c = 'ABSAZAJJAXXX';  
       //newMsg.hSkipTrigger__c = true;
       newMsg.RelatedReference__c = 'dedede';
       insert newMsg;
         
       Test.startTest();
        
       Test.setMock(HttpCalloutMock.class, new Payments_CreateSWIFT_HTTPMock());
       Payments_Outbound_SWIFT.postToSWIFT(newMsg);
        
       Test.stopTest();
    }
    
}