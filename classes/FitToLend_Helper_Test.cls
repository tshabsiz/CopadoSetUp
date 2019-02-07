@isTest(SeeAllData=false)
private class FitToLend_Helper_Test 
{
    static testMethod void FitToLend_Helper_Test()
    {       
        Cloudsmiths_TestDataClass TDC =  new Cloudsmiths_TestDataClass();
        
        Test.startTest();

        set<id> IdSet = new set<id>();
        IdSet.add(TDC.TestFitToLend.id);
        attachment attachment;
        attachment = new attachment();
        attachment.Name= 'Test';
        attachment.Description = 'System Generated';
        attachment.ParentId = TDC.TestFitToLend.id;
        attachment.body = blob.valueOf('Test');
        Insert attachment;
        FitToLend_Helper.approvalStatuses(IdSet);
        FitToLend_Helper.sendNotificationEmails(IdSet);

        Test.stopTest();
    }
}