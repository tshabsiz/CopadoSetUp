@isTest(SeeAllData=false)
public class Condition_Override_Test {

	public static testMethod void testController() 
	{	
		//Setup data data
		BXDtesclassdata.setupFolder();
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestCondition);
		Condition_Override testCon = new Condition_Override(sc);
        
        test.startTest();

		//Methods
		testCon.actionViewRoute();
		testCon.actionEditRoute(); 
        testCon.cloneCondition(); 
        testCon.createBoxFolder();
        testCon.createBoxPermission();

        testDataClass.testConditionGC.active__c = true;
        
        update testDataClass.testConditionGC;
        
        Test.stopTest();
	}
    
    public static testMethod void testAfterUpdate() 
	{	
		//Setup data data
		BXDtesclassdata.setupFolder();
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        test.startTest();

        testDataClass.testConditionGC.active__c = true;
        
        update testDataClass.testConditionGC;
        
        Test.stopTest();
	}
    public static testMethod void testAfterInsert() 
	{	
		//Setup data data
		BXDtesclassdata.setupFolder();
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        test.startTest();

        testDataClass.testConditionGC.Active__c = false;
        testDataClass.testConditionGC.Activate_Later__c = true;
        
        
        update testDataClass.testConditionGC;
        
        Test.stopTest();
	}
    
    public static testMethod void testActivatOnInsert() 
	{	
		//Setup data data
		BXDtesclassdata.setupFolder();
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 
        
        test.startTest();

        testDataClass.testConditionGC.Active__c = True;
        testDataClass.testConditionGC.Activate_Later__c = True;
        
        
        update testDataClass.testConditionGC;
        
        Test.stopTest();
	}
}