@isTest(SeeAllData=false)
private class  Legal_Quote_Bulk_Approval_Test 
{
    static testMethod void Legal_Quote_Bulk_Approval_Test()
    {
        Cloudsmiths_TestDataClass TDC  = new Cloudsmiths_TestDataClass();
        Legal_Quote_Bulk_Approval TestClass = new Legal_Quote_Bulk_Approval();
        TestClass.workItems.put(TDC.TestLegalLegalQuote.id,TDC.TestLegalLegalQuote.id);
        TestClass.actionLoadRecords();
        TestClass.actionBulkUpdate();
        TestClass.approveSingleRow();
        TestClass.rejectSingleRow();
        
    }
}