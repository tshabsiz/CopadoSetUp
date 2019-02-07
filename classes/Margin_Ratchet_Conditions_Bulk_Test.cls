/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Margin_Ratchet_Conditions_Bulk_Test 
{
    public static testMethod void testClass()
	{

        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        testDataClass.testConditionFC.Active__c = True;
        
        update testDataClass.testConditionFC;


        //VF page
        PageReference pageRef = Page.Margin_Ratchet_Conditions_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testCovenantMarginRatchet.id);

		ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.testCovenantMarginRatchet);
		Margin_Ratchet_Conditions_Bulk ec = new Margin_Ratchet_Conditions_Bulk();
        
        test.startTest();
        
		ec.FinancialCovenantConditionWrapper[0].selected = true;

		//Methods
        ec.saveRecord();
        
        ec = new Margin_Ratchet_Conditions_Bulk();
        ec.FinancialCovenantConditionWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();

    }

}