/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for JLOC_SubmitToSecretaryController
*              Tests executed:
*               1 - testJlocSubmittedToSecretary()
*                   Test that JLOC can be Submitted to Secretary.
*               2 - testJlocNotSubmittedToSecretary()
*                   Test that required fields or confirmations are missing and JLOC cannot be submitted to Secretary.
*/
@isTest
private class ZZTEST_JLOC_SubmitToSecretaryController {
	
	public static testMethod void testJlocSubmittedToSecretary(){

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        jloc.Status__c = 'New';
        jloc.CLGD_Consumption__c = 'No';
        jloc.Deal_Presented_To_Deal_Forum__c = true;
        jloc.Go_Approval_From_Deal_Forum_Quorum__c = true;
        jloc.Approved_By_Financial_Crime_Compliance__c = true;
        jloc.Conflict_Clearance_Obtained__c = true;
        jloc.Deal_Team_Polices_Confirmation__c = true;
        
        Test.startTest();

		PageReference JLOC_SubmitToSecretary = Page.JLOC_SubmitToSecretary;
        Test.setCurrentPage(JLOC_SubmitToSecretary);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_SubmitToSecretaryController controller = new JLOC_SubmitToSecretaryController(stc);

        controller.submitToSecretary();

        //System.assertEquals(ApexPages.getMessages()[0].getDetail(), System.Label.errMsg_IsThisAClosedJLOCRequired);

        Test.stopTest();
	}

	public static testMethod void testJlocNotSubmittedToSecretary(){

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;

        JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
        
        Test.startTest();

		PageReference JLOC_SubmitToSecretary = Page.JLOC_SubmitToSecretary;
        Test.setCurrentPage(JLOC_SubmitToSecretary);

        ApexPages.currentPage().getParameters().put('id', jloc.Id);
    	Apexpages.Standardcontroller stc = new ApexPages.StandardController(jloc);
        JLOC_SubmitToSecretaryController controller = new JLOC_SubmitToSecretaryController(stc);

        controller.submitToSecretary();
        controller.cancel();

        Test.stopTest();
	}
}