/**
* 2017-03-15
* Rudolf Niehaus - CloudSmiths
* Test class for the Default Case Comment trigger
**/
@isTest(seeAllData=true)
public class Case_Comment_Trigger_Test{
    
    static testMethod void Case_Comment_Trigger_Test(){
         
        CSC_TestDataFactory.testDataSize = 1;
         
        //Test data factory
        Contact cont = CSC_TestDataFactory.getDefaultEmailSupportContact();
        
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;
        Database.insert(cont, dmlOptions);
        
        //insert cont;
        
        Service_Mapping__c sm = CSC_TestDataFactory.getServiceMapRecord();
        insert sm;
        
        User approver = CSC_TestDataFactory.createUser('Barclays CSC User', 'approver@rudix.com');
        insert approver; 
        
        User u = CSC_TestDataFactory.createUser('Barclays CSC User', 'rudolfniehaus@rudix.com');
        u.DelegatedApproverId = approver.Id;
        insert u;
        
        list<Case> manualCase = CSC_TestDataFactory.getTestCaseList('CSC Manual Cases', u.Id);
        manualCase[0].Queue__c = 'EBSH - Passwords';
        manualCase[0].Department__c = 'EBSH';
        manualCase[0].Service_Type__c = 'System';
        manualCase[0].Email_Status__c = 'New';
        manualCase[0].hHasClientUpdate__c = true;
        insert manualCase;
        
        Test.startTest();
        
        try{
            manualCase[0].Status = 'Closed Resolve';
            update manualCase[0];
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        CaseComment cc = new CaseComment();
        cc.ParentId = manualCase[0].Id;
        cc.CommentBody = 'Hello sexy!';
        insert cc;
        
        //manualCase[0].First_Case_Comment__c = null;
        //update manualCase[0];
        
        CaseComment cc2 = new CaseComment();
        cc2.ParentId = manualCase[0].Id;
        cc2.CommentBody = 'Hello sexy!';
        insert cc2;
        
        try{
            delete cc;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
    }    
}