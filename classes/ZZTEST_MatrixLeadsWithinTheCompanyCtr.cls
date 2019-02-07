/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for MatrixLeadsWithinTheCompanyController
*              Tests executed:
*               1 - testMatrixLeadsWithinTheCompany
*					Tests that related Matrix Leads (within the same company) are displayed on page
*				2 - testMatrixLeadsWithinTheCompanyErrors
*					Test errors for displaying related Matrix Leads
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/2016  Marta Malinowska   Change tests to match Matrix Leads within the same company by REF NO F.
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_MatrixLeadsWithinTheCompanyCtr {
	public static testMethod void testMatrixLeadsWithinTheCompany(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

		List<Matrix_Lead__c> matrixLeadsToIns = new List<Matrix_Lead__c>();
		for(Integer i=0; i<5; i++){
			Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
			matrixLead.REF_NO__c = '123 1';
			matrixLeadsToIns.add(matrixLead);
		}
		insert matrixLeadsToIns;

		Set<Id> matrixLeadIds = new Set<Id>();
		for(Matrix_Lead__c matrixLead : matrixLeadsToIns){
			matrixLeadIds.add(matrixLead.Id);
		}
		List<Matrix_Lead__c> matrixLeads = [SELECT Id, Name, REF_NO_F__c FROM Matrix_Lead__c WHERE Id IN :matrixLeadIds];

        Test.startTest();

        PageReference MatrixLeadsWithinTheCompany = Page.MatrixLeadsWithinTheCompany;
        Test.setCurrentPage(MatrixLeadsWithinTheCompany);

        Apexpages.Standardcontroller stc = new ApexPages.StandardController(matrixLeads[0]);
        MatrixLeadsWithinTheCompanyController controller = new MatrixLeadsWithinTheCompanyController(stc);

        Test.stopTest();

        System.assertEquals(controller.relatedMatrixLeads.size(), 4);
	}

	public static testMethod void testMatrixLeadsWithinTheCompanyErrors(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

		Matrix_Lead__c matrixLead = new Matrix_Lead__c();

        Test.startTest();

        PageReference MatrixLeadsWithinTheCompany = Page.MatrixLeadsWithinTheCompany;
        Test.setCurrentPage(MatrixLeadsWithinTheCompany);

        Apexpages.Standardcontroller stc = new ApexPages.StandardController(matrixLead);
        MatrixLeadsWithinTheCompanyController controller = new MatrixLeadsWithinTheCompanyController(stc);

        Test.stopTest();

        System.assertEquals(controller.relatedMatrixLeads.size(), 0);
	}
}