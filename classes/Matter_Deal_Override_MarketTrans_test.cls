@Istest
public class Matter_Deal_Override_MarketTrans_test {
    
    public static testMethod void testMarketTransCreate() {
        Test.startTest();
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();

        advpm__Matter__c matter = libraTestData.testMarketTransactionMatter;
        
        Test.setCurrentPageReference(new PageReference('Page.Matter_Deal_Override_MarketTransaction'));
        System.currentPageReference().getParameters().put('matterId', matter.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(matter);
        Matter_Deal_Override_MarketTrans_Cont testMarketTrans = new Matter_Deal_Override_MarketTrans_Cont(sc);
        
        testMarketTrans.CancelPage();
        testMarketTrans.SaveMatter();
		testMarketTrans.duplicateCheck(); 
        
        System.currentPageReference().getParameters().put('matterId', null);
        sc = new ApexPages.StandardController(matter);
        testMarketTrans = new Matter_Deal_Override_MarketTrans_Cont(sc);
        testMarketTrans.SaveMatter();
        
        System.currentPageReference().getParameters().put('matterId', matter.id);
        sc = new ApexPages.StandardController(matter);
        testMarketTrans = new Matter_Deal_Override_MarketTrans_Cont(sc);
        
        libraTestData.testNettingGroup.Netting_Type__c = 'Novation';
        update libraTestData.testNettingGroup;
        
        NettingGroupBranch__c testNettingGroupBranchTI = new NettingGroupBranch__c();
        testNettingGroupBranchTI.NettingGroup__c = libraTestData.testNettingGroup.id;
        testNettingGroupBranchTI.BranchType__c = 'Trade Instrument';
        testNettingGroupBranchTI.Trade_Instrument__c = libraTestData.testTradeInstrument.id;
        insert testNettingGroupBranchTI;
        
        testMarketTrans.SaveMatter();
        
        libraTestData.testNettingGroup.Netting_Type__c = 'Settlement';
        update libraTestData.testNettingGroup;
        
        testNettingGroupBranchTI = new NettingGroupBranch__c();
        testNettingGroupBranchTI.NettingGroup__c = libraTestData.testNettingGroup.id;
        testNettingGroupBranchTI.BranchType__c = 'Trade Instrument';
        testNettingGroupBranchTI.Trade_Instrument__c = libraTestData.testTradeInstrument.id;
        insert testNettingGroupBranchTI;
        
        testMarketTrans.SaveMatter();     
        
        Test.stopTest();
    }
    
    public static testMethod void testMarketTransTI(){
        Test.startTest();
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();

        advpm__Matter__c matter = libraTestData.testMarketTransactionMatter;
        
        Test.setCurrentPageReference(new PageReference('Page.Matter_Deal_Override_MarketTransaction'));
        System.currentPageReference().getParameters().put('matterId', matter.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(matter);
        Matter_Deal_Override_MarketTrans_Cont testMarketTrans = new Matter_Deal_Override_MarketTrans_Cont(sc);
        delete libraTestData.testNettingGroupBranchCP;
        NettingGroupBranch__c testNettingGroupBranchTI = new NettingGroupBranch__c();
        testNettingGroupBranchTI.NettingGroup__c = libraTestData.testNettingGroup.id;
        testNettingGroupBranchTI.BranchType__c = 'Trade Instrument';
        testNettingGroupBranchTI.Trade_Instrument__c = libraTestData.testTradeInstrument.id;
        insert testNettingGroupBranchTI;
        testMarketTrans.SaveMatter();
        
        libraTestData.testNettingGroup.Netting_Type__c = 'Settlement';
        update libraTestData.testNettingGroup;
        testMarketTrans.SaveMatter();
        
        libraTestData.testNettingGroup.Netting_Type__c = 'Novation';
        update libraTestData.testNettingGroup;
        testMarketTrans.SaveMatter();
        
        Test.stopTest();
    }
}