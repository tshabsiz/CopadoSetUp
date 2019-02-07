@isTest(SeeAllData=false)
private class Generic_FileUploader_Test 
{
    static testMethod void Generic_FileUploader_Test()
    {
        Cloudsmiths_TestDataClass TDC =  new Cloudsmiths_TestDataClass();
        
        Generic_FileUploader TestClass = new Generic_FileUploader();
        TestClass.addFile();
        TestClass.attachment.Name= 'Test';
        TestClass.attachment.ParentId = TDC.TestAccount.id;
        TestClass.attachment.body = blob.valueOf('Test');
        TestClass.addFile();	  
        TestClass.getExistingAttachments();
        TestClass.getExistingAttachmentsSize();
              TestClass.saveUrl = 'Test'; 
        TestClass.finish();
  
    }
}