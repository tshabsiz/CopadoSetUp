@Istest
public with sharing class agreementTradeInstrumentsExtension_test {
    Public static testmethod void agreementTradeInstrumentsExtension_test(){
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();

        test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.agreementTradeInstruments'));
        System.currentPageReference().getParameters().put('id', libraTestData.testSuppAgreementTradeInstrument.id);
        System.currentPageReference().getParameters().put('retURL', libraTestData.testSupportingAgreement.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(libraTestData.testSuppAgreementTradeInstrument);
        agreementTradeInstrumentsExtension testCon = new agreementTradeInstrumentsExtension(sc);

        testCon.selectedTradeInstruments = new String[1];
        testCon.selectedTradeInstruments[0] = libraTestData.testTradeInstrument.id;

        testCon.save();
        testCon.getTradeInstruments();

        System.currentPageReference().getParameters().put('id', libraTestData.testAgreementTradeInstrument.id);
        System.currentPageReference().getParameters().put('retURL', libraTestData.testAgreement.id);
        sc = new ApexPages.StandardController(libraTestData.testAgreementTradeInstrument);
        testCon = new agreementTradeInstrumentsExtension(sc);

        testCon.selectedTradeInstruments = new String[1];
        testCon.selectedTradeInstruments[0] = libraTestData.testTradeInstrument.id;

        testCon.amendment = libraTestData.testAmendment;
        testCon.amendmentDocument = true;
        testCon.SaveAmendment();

        testCon.getTradeInstruments();

        test.stopTest();
    }
}