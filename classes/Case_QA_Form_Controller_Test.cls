/**
* 2017-09-29 - Rudolf Niehaus - CloudSmiths
**/
@isTest(seeAllData=true)
public class Case_QA_Form_Controller_Test {

    static testMethod void QA_Form_Controller_Test(){
        
        CSC_TestDataFactory.testDataSize = 1;
        
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        Case_QA_Template__c temp = new Case_QA_Template__c();
        temp.QAName__c = 'QA123';
        temp.BusinessArea__c = 'EBSS CSC Pretoria';
        insert temp;
        
        list<Case_QA_Question__c> qaList = new list<Case_QA_Question__c>(); 
        Case_QA_Question__c q = new Case_QA_Question__c();
        q.QATemplate__c = temp.Id;
        q.Heading__c = 'test heading A';
        q.QAQuestion__c = 'test question a';
        q.IsAuditRequirement__c = false;
        q.Weighting__c = 10;
        qaList.add(q);
        Case_QA_Question__c q2 = new Case_QA_Question__c();
        q2.QATemplate__c = temp.Id;
        q2.Heading__c = 'test heading B';
        q2.QAQuestion__c = 'test question b';
        q2.IsAuditRequirement__c = false;
        q.Weighting__c = 10;
        qaList.add(q2);
        Case_QA_Question__c q3 = new Case_QA_Question__c();
        q3.QATemplate__c = temp.Id;
        q3.Heading__c = 'test heading C';
        q3.QAQuestion__c = 'test question c';
        q3.IsAuditRequirement__c = true;
        q.Weighting__c = 20;
        qaList.add(q3);
        
        insert qaList;
        
        Case_QA__c qa = new Case_QA__c();
        qa.SubmittedBy__c = UserInfo.getUserId();
        qa.RelatedCase__c = caseInsertList[0].Id;
        qa.QATemplate__c = temp.Id;
        insert qa;         
        
        qa.SavedResults__c = q.Id + '|Yes;' + q2.Id + '|No;' + q3.Id + '|NA;';
        update qa;
        
        Test.startTest();

        PageReference pageRef = Page.Case_QA_Form;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('Id', caseInsertList[0].Id);
        ApexPages.currentPage().getParameters().put('templateId', temp.Id);
        ApexPages.currentPage().getParameters().put('readOnly', '1');
        ApexPages.currentPage().getParameters().put('recId', null);
        
        Case_QA_Form_Controller theCont = new Case_QA_Form_Controller();
        
        Test.stopTest();
    }
}