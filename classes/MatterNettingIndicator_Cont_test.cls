@Istest
public with sharing class MatterNettingIndicator_Cont_test {
    public static testMethod void testMarketTransCreate() {
        Test.startTest();
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();

        advpm__Matter__c matter = libraTestData.testMarketTransactionMatter;

        Test.setCurrentPageReference(new PageReference('Page.MatterNettingIndicator'));
        System.currentPageReference().getParameters().put('id', matter.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(matter);
        Matter_Deal_Override_MarketTrans_Cont testMarketTrans = new Matter_Deal_Override_MarketTrans_Cont(sc);
        Test.stopTest();
    }
}