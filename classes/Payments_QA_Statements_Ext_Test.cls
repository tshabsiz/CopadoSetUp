/**
* 2017-06-29
* Rudolf Niehaus - CloudSmiths
**/
@IsTest(SeeAllData=true)
public class Payments_QA_Statements_Ext_Test {
     static testMethod void testQAExts() {
         
         //TEST DATA 
        list<Account> accList = CSC_TestDataFactory.getTestAccountList('Client - Individual');
        accList[0].BIC_Code__c = 'BIC1';
        insert accList;
        CSC_TestDataFactory.testDataSize = 1;
        list<Case> caseList = CSC_TestDataFactory.getTestCaseList('Payments', UserInfo.getUserId());
        insert caseList[0]; 
        
        Test.startTest();
        PageReference pageRef = Page.Payments_QA_Statements;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('bic','028738-ZAR-0000006712-01');
         ApexPages.currentPage().getParameters().put('custKey','P170704AAAAIN00');
         ApexPages.currentPage().getParameters().put('inputKeyTier','029389ZAR000000671201');
         ApexPages.currentPage().getParameters().put('tierref','028738-ZAR-0000006712-01');
        //list<Case> theCase = [Select Id From Case Where Email_From_Address__c = 'wouter@styne.co.za' limit 1];
        ApexPages.StandardController controller = new ApexPages.StandardController(caseList[0]);
        Payments_QA_Statements_Ext cont = new Payments_QA_Statements_Ext(controller);
        
        Test.setMock(HttpCalloutMock.class, new Payments_Outbound_Statements_Mock()); 
        cont.requestStatement();
        Test.setMock(HttpCalloutMock.class, new Payments_Outbound_Deal_Mock()); 
        cont.searchDeal(); 
        Test.setMock(HttpCalloutMock.class, new Payments_Outbound_BIC_Mock()); 
        cont.searchBIC();
        Test.setMock(HttpCalloutMock.class, new Payments_Outbound_Tier_Mock()); 
        cont.searchTier();
        Test.stopTest(); 
         
     }

}