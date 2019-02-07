@isTest
public class MatterTrigger_test 
{
    public static testMethod void MatterTrigger_test()
    {

        Cloudsmiths_TestDataClass  TDC = new Cloudsmiths_TestDataClass();
        TDC.testMatter.advpm__Status__c = 'In Appeal';
        Update TDC.testMatter;
    }
    
    public static testMethod void MatterLibraTrigger_test()
    {
		Libra_TestDataClass libraTestData = new Libra_TestDataClass();
        
        Test.startTest();
        
        libraTestData.testMarketTransactionMatter.Relationship__c = libraTestData.testBankAccount.id;
        
        update libraTestData.testMarketTransactionMatter;
        
        Test.stopTest();
    }

}