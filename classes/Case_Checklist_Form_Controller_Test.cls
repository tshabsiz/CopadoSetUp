/**
* 2017-09-01 - Rudolf Niehaus - CloudSmiths
*============================================
* 2017-06-27 Mabhedle Tonga - Updated running user hub to use RCS Corporate PTA
=============================================
**/
@isTest(seeAllData=true)
public class Case_Checklist_Form_Controller_Test {
    
    static testMethod void Checklist_Form_Controller_Test(){
        
        CSC_TestDataFactory.testDataSize = 1;
         
        User currentUser  = new User(ID = UserInfo.getUserId(),Hub__c = 'RSC - Corporate PTA');
        update currentUser;
        //create some service mapping data
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        list<Case> caseInsertList = CSC_TestDataFactory.getTestCaseList( 'CSC Emails' , UserInfo.getUserId() );
        insert caseInsertList;
        Case_Checklist_Template__c temp = new Case_Checklist_Template__c();
        temp.ChecklistName__c = 'Checklis';
        temp.BusinessArea__c = 'EBSS CSC Pretoria';
        insert temp;
        
        Case_Checklist_Question__c q = new Case_Checklist_Question__c();
        q.Checklist_Template__c = temp.Id;
        q.Heading__c = 'test heading';
        q.Question__c = 'test question a';
        insert q;
        
            Case_Checklist__c currentChkList = new Case_Checklist__c();
            currentChkList.SubmittedBy__c = UserInfo.getUserId();
            currentChkList.RelatedCase__c = caseInsertList[0].Id;
            currentChkList.ChecklistTemplate__c = temp.Id;
            insert currentChkList;         
            
            currentChkList.SavedResults__c = q.Id + '|No;';
            update currentChkList;
      
        Test.startTest();

        PageReference pageRef = Page.Case_Checklist_Form;
        Test.setCurrentPage(pageRef);     
        ApexPages.currentPage().getParameters().put('Id', caseInsertList[0].Id);
        ApexPages.currentPage().getParameters().put('templateId', temp.Id);
        ApexPages.currentPage().getParameters().put('readOnly', '1');
        ApexPages.currentPage().getParameters().put('recId', null);
        
        Case_Checklist_Form_Controller theCont = new Case_Checklist_Form_Controller();
        theCont.updateChecklist();
        
        Test.stopTest();
        
    }

}