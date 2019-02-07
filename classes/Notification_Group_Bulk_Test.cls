/**
*** CHANGE LOG ***

29/11/2017 - TdB    - Created Class.
22/02/2018 - TdB    - Include Drwadown and Fit to Lend tests.

**/ 
@isTest(SeeAllData=false)
public class Notification_Group_Bulk_Test 
{
    public static testMethod void testClass_MarginRatchetLevel()
	{
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //VF page
        PageReference pageRef = Page.Notification_Group_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testEventMarginRatchet.id);

		Notification_Group_Bulk ec = new Notification_Group_Bulk();
        
        test.startTest();

		ec.distroGroupsWrapper[0].selected = true;
 
		//Methods
        ec.saveRecord();
        
        ec = new Notification_Group_Bulk();
        ec.distroGroupsWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_TriggerLevel()
	{
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();

        //VF page
        PageReference pageRef = Page.Notification_Group_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testTrigger.id);

		Notification_Group_Bulk ec = new Notification_Group_Bulk();
        
        test.startTest();

		ec.distroGroupsWrapper[0].selected = true;
 
		//Methods
        ec.saveRecord();
        
        ec = new Notification_Group_Bulk();
        ec.distroGroupsWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_CollateralValuationLevel()
	{
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //VF page
        PageReference pageRef = Page.Notification_Group_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testCollateralValuation.id);

		Notification_Group_Bulk ec = new Notification_Group_Bulk();
        
        test.startTest();

		ec.distroGroupsWrapper[0].selected = true;
 
		//Methods
        ec.saveRecord();
        
        ec = new Notification_Group_Bulk();
        ec.distroGroupsWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_CollateralMonitoringLevel()
	{
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //VF page
        PageReference pageRef = Page.Notification_Group_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testCollateralMonitoring.id);

		Notification_Group_Bulk ec = new Notification_Group_Bulk();
        
        test.startTest();

		ec.distroGroupsWrapper[0].selected = true;
 
		//Methods
        ec.saveRecord();
        
        ec = new Notification_Group_Bulk();
        ec.distroGroupsWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_DrawDownLevel()
	{
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //VF page
        PageReference pageRef = Page.Notification_Group_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testDrawDown.id);

		Notification_Group_Bulk ec = new Notification_Group_Bulk();
        
        test.startTest();

		ec.distroGroupsWrapper[0].selected = true;
 
		//Methods
        ec.saveRecord();
        
        ec = new Notification_Group_Bulk();
        ec.distroGroupsWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_FitToLendLevel()
	{
        //Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //VF page
        PageReference pageRef = Page.Notification_Group_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testFitToLend.id);

		Notification_Group_Bulk ec = new Notification_Group_Bulk();
        
        test.startTest();

		ec.distroGroupsWrapper[0].selected = true;
 
		//Methods
        ec.saveRecord();
        
        ec = new Notification_Group_Bulk();
        ec.distroGroupsWrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
}