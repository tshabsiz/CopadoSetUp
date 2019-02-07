@isTest(SeeAllData=false)
public class FitToLend_Override_Test 
{
	public static testMethod void testController()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

		//VF page
        PageReference pageRef = Page.FitToLend_Override;
        Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(testDataClass.TestFitToLendNotInserted);
		FitToLend_Override ec = new FitToLend_Override(sc);

		ec.participantsWrapper[0].selected = true;
		ec.distroGroupsWrapper[0].selected = true; 

		//Methods
		ec.saveRecord();
	}
}