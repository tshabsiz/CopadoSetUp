@Istest
public class LegalPerformanceQuest_Cont_test {
    public static testMethod void testInsertLegalPerformanceQuest(){

        Legal_Performance_Questionnaire__c legal_performance_questionnaire = new Legal_Performance_Questionnaire__c();
        id accRecTypeid = [select id from RecordType where sObjectType = 'Account' and DeveloperName = 'On_Off_Panel_Law_Firm'].id;

        Account acc = new Account();
        Contact con = new Contact();
        Matter_Spend_Document__c matter_spend_document = new Matter_Spend_Document__c();
        advpm__Matter__c matter = new advpm__Matter__c(); 

        acc.Name = 'TestAcc';
        acc.RecordTypeId = accRecTypeid;
        
        insert acc;

        con.FirstName = 'TestConFirstName';
        con.LastName = 'TestConLastName';
        con.AccountId = acc.id;

        insert matter;

        matter_spend_document.Approver__c = UserInfo.getUserId();
        matter_spend_document.Matter__c = matter.id;

        insert con;
        insert matter_spend_document;
        
        legal_performance_questionnaire.LawFirm__c = acc.id;
        legal_performance_questionnaire.ExternalLegalCounselName__c = con.id;
        legal_performance_questionnaire.MatterSpendDocument__c = matter_spend_document.id;

        ApexPages.StandardController sc = new ApexPages.StandardController(legal_performance_questionnaire);
        LegalPerformanceQuest_Cont testAccPlan = new LegalPerformanceQuest_Cont(sc);
        
        testAccPlan.SaveQuestionnaire();
        testAccPlan.CancelPage();
    }
}