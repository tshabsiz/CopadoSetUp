/**
* 2017-06-29
* Rudolf Niehaus - CloudSmiths
**/
@IsTest(SeeAllData=true)
public class Payments_Inbound_RESTful_Create_Test {

     static testMethod void testPaymentsCaseRest() {

        //TEST DATA        
        CSC_TestDataFactory.testDataSize = 10;
        list<Account> accList = CSC_TestDataFactory.getTestAccountList('Client - Individual');
        accList[0].BIC_Code__c = 'BIC1';
        accList[0].Swift_Code__c = 'RUDIX7777777';
        accList[1].BIC_Code__c = 'BIC2';
        accList[1].Swift_Code__c = 'RUDIX007';
        insert accList;
        
        Test.startTest();
        
       Test.setMock(HttpCalloutMock.class, new Payments_CreateCase_HTTPMock());
       Payments_Inbound_RESTful_CreateSWIFT.logCase('RUDIX7777777;739998367.0', '{1:F01ABSAZAJJAXXX1967564145}{2:O1961459140103POPUESMMAXXX99195802601401031600N}', 'relatedRef', 'DZ;ABooZAJ0AXIX', 'originPack', 'MT199', 'transactionRef'); 
       Payments_Inbound_RESTful_CreateSWIFT.logCase('eeee;4444444', '{1:F01ABSAZAJJAXXX1967564145}{2:O1961459140103POPUESMMAXXX99195802601401031600N}', 'werewr', 'werew', 'erwer', 'ewrewr', 'werw');
       Payments_Inbound_RESTful_CreateSWIFT.logCase('', '', '', '', '', '', '');
        
       Test.stopTest();
    }
    
}