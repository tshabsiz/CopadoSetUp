/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*** CHANGE LOG ***

31/10/2017  - PG    - Created Class.

**/
@IsTest
public class FitToLend_Approval_Test 
{
	@IsTest
	public static void testApprovalFlow()
	{
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		Test.startTest();

		//Set test page.
		PageReference pageRef = Page.FitToLend_ApprovalSubmit;
		Test.setCurrentPage(pageRef);

		//Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', testData.TestMatter.Id);
        ApexPages.currentPage().getParameters().put('fid', testData.TestFitToLend.Id);

        //Controller
        FitToLend_Approval controller = new FitToLend_Approval();

        //Methods
        controller.actionCancel();
        controller.actionSubmitApproval();

		Test.stopTest();

	}

	@IsTest
	public static void testApprovalNonFlow()
	{
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		//Set matter to non flow.
		testData.TestMatter.Standard__c = false;
		update testData.TestMatter;

		Test.startTest();

		//Set test page.
		PageReference pageRef = Page.FitToLend_ApprovalSubmit;
		Test.setCurrentPage(pageRef);

		//Add parameters to page URL.
        ApexPages.currentPage().getParameters().put('id', testData.TestMatter.Id);
        ApexPages.currentPage().getParameters().put('fid', testData.TestFitToLend.Id);

        //Controller.
        FitToLend_Approval controller = new FitToLend_Approval();

        //Methods
        controller.actionCancel();
        controller.actionSubmitApproval();

		Test.stopTest();
	}
}