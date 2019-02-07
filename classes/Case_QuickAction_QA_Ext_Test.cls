/**
* 2017-09-01 - Rudolf Niehaus - CloudSmiths
**/
@isTest(seeAllData=true)
public class Case_QuickAction_QA_Ext_Test {
    
    static testMethod void QuickAction_QA_Ext_Test(){
        
        CSC_TestDataFactory.testDataSize = 1;
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        
        Test.startTest();
    

        ApexPages.standardController controller = new ApexPages.standardController(caseInsertList[0]);
        Case_QuickAction_QA_Ext theCont = new Case_QuickAction_QA_Ext(controller);
        
        list<Case_Checklist_Template__c> tempList = theCont.getTemplateNames();
        list<Case_QA_Template__c> qalist = theCont.getQATemplateNames();
        Test.stopTest();
        
    }

}