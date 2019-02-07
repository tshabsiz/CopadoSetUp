@IsTest
public class dealPartyOverride_Cont_test {
    Public static testmethod void dealPartyOverride_Cont_test()
    {
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();

        test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.dealPartyOverride'));
        System.currentPageReference().getParameters().put('matterId', libraTestData.testMatter.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(libraTestData.testDealParty);
        dealPartyOverride_Cont testCon = new dealPartyOverride_Cont(sc);

        testCon.dealParty.Relationship_Type__c = 'Counterparty Branch';
        testCon.save();
        testCon.cancel();
        
        testCon.amendment = libraTestData.testAmendment;
        testCon.amendmentDocument = true;
        testCon.getCategories();
        testCon.SaveAmendment();
        
        testCon.saveTmgDealParty();

        test.stopTest();
    }
}