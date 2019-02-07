@Istest
public class nettingGroupExtension_test
{
    Public static testmethod void nettingGroupExtension_test()
    {
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();
        
        Netting_Group__c testNetGroup = new Netting_Group__c();
        testNetGroup.Matter_Deal__c = libraTestData.testMarketTransactionMatter.id;
        insert testNetGroup;
        
        test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.MasterAgreementEdit'));
        System.currentPageReference().getParameters().put('id', testNetGroup.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testNetGroup);
        nettingGroupExtension testCon = new nettingGroupExtension(sc);
        
        testCon.selectedBankBranches = new list<string>();
        testCon.selectedCounterParties = new list<string>();
        testCon.selectedTradeInstruments = new list<string>();
        testCon.selectedBankBranches.add(testNetGroup.id);
        testCon.selectedCounterParties.add(testNetGroup.id);
        testCon.selectedTradeInstruments.add(testNetGroup.id);
        testCon.Save();
        
        testCon.getBankBranches();
        testCon.getCounterparties();
        testCon.getTradeInstruments();
        
        testCon.saveNew();
        testCon.resetAfterError();
        testCon.deleteNettingGroup();
        
        System.currentPageReference().getParameters().put('new', 'true');
       
        sc = new ApexPages.StandardController(testNetGroup);
        testCon = new nettingGroupExtension(sc);
        test.stopTest();
    }
}