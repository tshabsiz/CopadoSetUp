/**
 * Created by Kyle Alexander on 2018/02/21.
 */

@Istest
public class MasterAgreementEdit_Cont_test {

    public static testMethod void testUpdateAgreement() {

        Libra_TestDataClass libraTestData = new Libra_TestDataClass();
        
        Test.setCurrentPageReference(new PageReference('Page.MasterAgreementEdit'));
		System.currentPageReference().getParameters().put('id', libraTestData.testAgreement.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(libraTestData.testAgreement);
        MasterAgreementEdit_Cont testAccPlan = new MasterAgreementEdit_Cont(sc);

        testAccPlan.SaveAgreement();
        testAccPlan.CancelPage();

        testAccPlan.amendment = libraTestData.testAmendment;
        testAccPlan.amendmentDocument = true;
        testAccPlan.SaveAmendment();
        testAccPlan.CancelAmendment();
        testAccPlan.CancelClosure();
        testAccPlan.SaveClosure();
        testAccPlan.CancelChange();
        testAccPlan.SaveChange();
        
        Agreement__c ag = libraTestData.testAgreement;
        ag.RecordTypeId = Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('ISDA Agreement').getRecordTypeId();
        ag.Agreement_Status__c = 'Cancelled/Terminated';
        update ag;
       
        sc = new ApexPages.StandardController(ag);
        testAccPlan = new MasterAgreementEdit_Cont(sc);
        testAccPlan.agreement.Agreement_Status__c = 'Amended';
        testAccPlan.SaveAgreement();
        
        testAccPlan.agreement.Agreement_Status__c = 'Cancelled/Terminated';
        testAccPlan.SaveAgreement();
    }
}