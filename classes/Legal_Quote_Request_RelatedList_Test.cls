@isTest(SeeAllData=false)
private class  Legal_Quote_Request_RelatedList_Test
{
    static testMethod void testController()
    {
        Cloudsmiths_TestDataClass TDC =  new Cloudsmiths_TestDataClass();
        ApexPages.StandardController sc = new ApexPages.standardController(TDC.TestLegalLegalQuoteRequest);
        Legal_Quote_Request_RelatedList TestClass = new Legal_Quote_Request_RelatedList(sc);
        
        Legal_Quote_Request_RelatedList.LegalQuoteWrapper wrapperItem = new Legal_Quote_Request_RelatedList.LegalQuoteWrapper();
        wrapperItem.legalQuote = TDC.TestLegalLegalQuote;
        wrapperItem.selected = True; 
        
        System.debug('### Legal_Quote_Request_RelatedList : wrapperItem : '+wrapperItem);
        
        //Add to wrapper list.
        TestClass.legalQuotesWrapper.add(wrapperItem);  
        
        TestClass.setupRedirect();
        ApexPages.currentPage().getParameters().Put('selectedRecords',TDC.TestLegalLegalQuote.id ); 
        
        TestClass.actionLoadApprovalRecords();
        TestClass.actionSubmitForApproval();
     }
}