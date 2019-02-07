/**
*** CHANGE LOG ***

17/01/2018  - TdB    - Created Class.

**/
@IsTest
public class Agreement_Approval_Test {
    
    static testMethod void testApproval()
	{
		Cloudsmiths_TestDataClass testData = new Cloudsmiths_TestDataClass();

		Test.startTest();

		//Set test page.
		PageReference pageRef = Page.Agreement_ApprovalSubmit;
		Test.setCurrentPage(pageRef);

		//Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', testData.TestAgreement.Id);

        //Controller
        Agreement_Approval controller = new Agreement_Approval();
        
        controller.participantSelectedId = testData.TestParticipant1.id;
        controller.ParticipantWrapperList[0].selected=true;

        //Methods
        controller.actionCancel();
        controller.disableCheckbox();
        controller.actionSubmitApproval();
        

		Test.stopTest();

	}
}