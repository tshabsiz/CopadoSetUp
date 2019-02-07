@isTest(SeeAllData=false)
private class Agreement_Trigger_Test 
{   
    public static testMethod void testUpdate()
    {
        Cloudsmiths_TestDataClass  COn = new Cloudsmiths_TestDataClass();
        
        Test.startTest();
        COn.testCondition.active__C = true; 
        
        COn.testCondition.Recurrence__c = 'Monthly'; 
        COn.testCondition.Date__c ='Signature Date';
        COn.testCondition.Number_Of_Days__c = 1 ;
        COn.testCondition.Due_Date__c = null;
        COn.testCondition.Days__c ='Days Before';            
        Update  COn.testCondition;

        COn.TestAgreement.Signature_Date__c = date.today();
        Update Con.TestAgreement;
        
        Test.stopTest();
    }
    
    public static testMethod void testDelete()
    {
        Libra_TestDataClass testData = new Libra_TestDataClass();
        
        testData.testAgreement.hAuto_Created__c = True;
        Update testData.testAgreement;
        
        Test.startTest();
        
        Try
        {
          Delete testData.testAgreement;
        }
        Catch (Exception e)
        {
            
        }
        
        Test.stopTest();
    }
}