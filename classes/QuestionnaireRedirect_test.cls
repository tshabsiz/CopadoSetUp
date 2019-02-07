@Istest
public class QuestionnaireRedirect_test {
 public static testMethod void testQuestionnaireRedirect(){
     
     	Matter_Spend_Document__c matter_spend_document = new Matter_Spend_Document__c();
        advpm__Matter__c matter = new advpm__Matter__c(); 
     
        insert matter;

        matter_spend_document.Approver__c = UserInfo.getUserId();
        matter_spend_document.Matter__c = matter.id;

        insert matter_spend_document;

     	Test.setCurrentPageReference(new PageReference('Page.QuestionnaireRedirect'));
		System.currentPageReference().getParameters().put('id', matter_spend_document.id);

        QuestionnaireRedirect questRed = new QuestionnaireRedirect(null);
    }
}