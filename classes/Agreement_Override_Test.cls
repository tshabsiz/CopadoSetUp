/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 31/10/2017 - PG    - Created Class. 
 09/11/2017 - TdB   - API Name change. Facility_Limit__c  to Limit__c on Agreements Object

**/ 
@IsTest
public class Agreement_Override_Test 
{   
    @IsTest
    public static void testOverrideEdit() 
    {
        CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();

        Test.startTest();

        PageReference pageRef = Page.Agreement_Override;
        Test.setCurrentPage(pageRef);

        //Controller + Extension
        ApexPages.StandardController sc = new ApexPages.standardController(testData.TestAgreement);
        Agreement_Override ec = new Agreement_Override(sc); 

        //Methods
        ec.actionHandleEntry();
        ec.populateProductAgreementTypes();
        ec.updateSelectedProduct();
        ec.getAgreementTypesList();
        ec.actionSave();

        Test.stopTest();
    }

    @IsTest
    public static void testOverrideNew() 
    {
        CloudSmiths_TestDataClass testData = new CloudSmiths_TestDataClass();

        //New Agreement
        Agreement__c newAgreement = new Agreement__c
        (
            Matter_Deal__c =  testData.TestMatter.id,
            Name = 'Test',
            Agreement_Type__c =    testData.TestProductAgreement.id,
            TMG_Product_Level_3__c = testData.TestProductLevel3.id,
            Signature_Date__c = Date.today().addDays(5),
            Effective_Date__c = Date.today().addDays(5),
            Limit__c = 10000
        );

        Test.startTest();

        PageReference pageRef = Page.Agreement_Override;
        Test.setCurrentPage(pageRef);

        //Controller + Extension
        ApexPages.StandardController sc = new ApexPages.standardController(newAgreement);
        Agreement_Override ec = new Agreement_Override(sc); 

        //Methods
        ec.actionHandleEntry();
        ec.populateProductAgreementTypes();
        ec.updateSelectedProduct();
        ec.getAgreementTypesList();
        ec.actionSave();

        Test.stopTest(); 
    }
}