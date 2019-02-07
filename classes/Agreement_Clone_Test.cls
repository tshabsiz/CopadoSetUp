/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

28/06/2017 - DF    - Created Class.

**/ 
@isTest
public class Agreement_Clone_Test 
{
    public static testMethod void attTriggerTest()
    {
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

        Test.startTest();                    
        
        PageReference pageRef1 = Page.Agreement_Clone;	
        pageRef1.getParameters().put('agreementId',testDataClass.TestAgreement.Id);
        
        Test.setCurrentPageReference(pageRef1);        
        Agreement_Clone TestCLass =  new Agreement_Clone();
        TestCLass.cloneAgreement();

        Test.stopTest(); 
    }
    
}