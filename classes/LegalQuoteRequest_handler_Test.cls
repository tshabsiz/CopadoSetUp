@isTest(SeeAllData=false)
private class LegalQuoteRequest_handler_Test 
{
    static testMethod void LegalQuoteRequest_handler_Test()
    {
        
        Cloudsmiths_TestDataClass TDC =  new Cloudsmiths_TestDataClass();
        ApexPages.StandardController sc = new ApexPages.standardController(TDC.TestLegalLegalQuoteRequest);
        LegalQuoteRequest_handler TestClass = new LegalQuoteRequest_handler(sc);
        
        TestClass.lst_LegalQuote = new  List<Legal_Quote__c>();
        TestClass.retURL =  'test';
        TestClass.rType=  'test';
        TestClass.ChangeCostInformation();
        TestClass.HideFirmsLegalOffPanel();
        for(LegalQuoteRequest_handler.LawFirm LawFrimRec : TestClass.LstLawFirm)
        {                  
            LawFrimRec.SelectFirm = true;
        }
        
        TestClass.Save();
        TestClass.AddLegalQuote();
        LegalQuoteRequest_handler.createBoxFolder(TDC.TestLegalLegalQuoteRequest.id);
        set<string> legalQuoteSet = new set<string>();
        legalQuoteSet.add(TDC.TestLegalLegalQuoteRequest.id);
        LegalQuoteRequest_handler.createBoxFolderTriggerBulk(legalQuoteSet);
        TestClass.Redirect();
        TestClass.Cancel();
    }
}