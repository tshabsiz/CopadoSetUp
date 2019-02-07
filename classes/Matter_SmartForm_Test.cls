@isTest(SeeAllData=false)
public class Matter_SmartForm_Test 
{
	private static testMethod void testController()
	{
		//Test Data
		Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass(); 

        test.startTest();
		//VF page
        PageReference pageRef = Page.Matter_SmartForm;
        Test.setCurrentPage(pageRef);

        //Controller
		Matter_SmartForm controller = new Matter_SmartForm();

		//Method
		controller.validateForm(); 
		controller.processForm();
        test.stopTest();
	}
}