@Istest
Public class supportingAgreementExtension_test 
{
    Public static testmethod void supportingAgreementExtension_test()
    {
        Libra_TestDataClass libraTestData = new Libra_TestDataClass();
        
        test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.MasterAgreementEdit'));
        System.currentPageReference().getParameters().put('new', 'true');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(libraTestData.testSupportingAgreement);
        supportingAgreementExtension testCon = new supportingAgreementExtension(sc);
        
        testCon.save();
        
        System.currentPageReference().getParameters().put('id', libraTestData.testSupportingAgreement.id);
        System.currentPageReference().getParameters().put('new', 'false');

        sc = new ApexPages.StandardController(libraTestData.testSupportingAgreement);
        testCon = new supportingAgreementExtension(sc);
        
        testCon.save();
        testCon.amendmentDocument = true;
        testCon.SaveAmendment();
        testCon.CancelAmendment();
        
        test.stopTest();
    }
}