@Istest
public class SupportingAgreementDealsRelatedList_test {
    
    public static testMethod void testSuppAgreementAddDeals() {
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();
    
        Test.setCurrentPageReference(new PageReference('Page.SupportingAgreementDealsRelatedList'));
        System.currentPageReference().getParameters().put('id', libraTestData.testSupportingAgreement.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(libraTestData.testSupportingAgreement);
        SupportingAgreementDealsRelatedList_Cont testSuppAgreement = new SupportingAgreementDealsRelatedList_Cont(sc);
        testSuppAgreement.dealId = libraTestData.testDealParty.id;
        testSuppAgreement.addDeal();
        testSuppAgreement.removeDeal();
        testSuppAgreement.addDeal();
        testSuppAgreement.submitChanges();
        
        testSuppAgreement.amendment = libraTestData.testAmendment;
        testSuppAgreement.amendmentDocument = true;
        testSuppAgreement.SaveAmendment();
        testSuppAgreement.CancelAmendment();
    }
}