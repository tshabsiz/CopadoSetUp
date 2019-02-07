@isTest(SeeAllData=false)
private class LegalQuote_Helper_Test
{
    static testMethod void LegalQuote_Helper_Test()
    {
        Cloudsmiths_TestDataClass TDC =  new Cloudsmiths_TestDataClass();
        
        
        List<Legal_Quote__c> legalQuoteList = new List<Legal_Quote__c>();
        TDC.TestLegalLegalQuote.Contact__c = TDC.TestContact.id;
        legalQuoteList.add(TDC.TestLegalLegalQuote);
        LegalQuote_Helper.sendNotificationEmails(legalQuoteList);
        LegalQuote_Helper.submitQuotesForApproval(legalQuoteList);
        LegalQuote_Helper.getWorkItemIds(system.UserInfo.getUserId());
        LegalQuote_Helper.getRecordTypeMap();
        Legal_Quote_Bulk_Approval.legalQuoteApprovalWrapper Temp = new Legal_Quote_Bulk_Approval.legalQuoteApprovalWrapper();
        
        Temp.selected = true;
        Temp.comment  ='Test';
        Temp.quote = TDC.TestLegalLegalQuote;
        Temp.workItemId = TDC.TestLegalLegalQuote.id;
        
        List<Legal_Quote_Bulk_Approval.legalQuoteApprovalWrapper> tempList = new List<Legal_Quote_Bulk_Approval.legalQuoteApprovalWrapper>();
        tempList.add(temp);
        LegalQuote_Helper.executeApprovals(tempList,'Approve');
        
    }
}