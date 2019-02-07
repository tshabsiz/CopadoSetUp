/**
* 2017-09-19
* Rudolf Niehaus - CloudSmiths
**/
@isTest
public class Payments_SWIFT_Trigger_Func_Test {

 static testMethod void testPayments_SWIFT_Trigger() {  
     
     CSC_TestDataFactory.testDataSize = 1;
     list<Case> caseList = CSC_TestDataFactory.getTestCaseList('Payments', UserInfo.getUserId());
     insert caseList;
     
     //New SWIFT
     SWIFT_Message__c SWIFT = new SWIFT_Message__c();
     SWIFT.Case__c = caseList[0].Id;
     SWIFT.QueryMessage__c = '7trctr37cty3cytyct93y';
     insert SWIFT;
     
     Test.startTest();
     update SWIFT;
     Test.stopTest();
 }    
}