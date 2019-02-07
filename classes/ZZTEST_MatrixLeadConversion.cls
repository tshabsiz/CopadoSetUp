/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for MatrixLeadConversion
*              Tests executed:
*               1 - testMatrixLeadConversion()
*                   Test that Matrix Lead is converted to Prospect Account and Contacts.
*				2 - testMatrixLeadConversionErrors()
*					Test that Matrix Lead cannot be converted if Company Name or Surname is empty
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/2016  Marta Malinowska   Change tests to match Matrix Leads within the same company by REF NO F.
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_MatrixLeadConversion {

	public static testMethod void testMatrixLeadConversion(){
		Integer BATCH_SIZE = 200;
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

		List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
		for(Integer i=0; i<BATCH_SIZE; i++){
			Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
			matrixLead.Sequence__c = String.valueOf(i);
			matrixLeads.add(matrixLead);
		}
		insert matrixLeads;

		Matrix_Lead__c mainMatrixLead = matrixLeads[0];

        Test.startTest();

        Id accountId = MatrixLeadConversion.convertMatrixLeadToProspect(mainMatrixLead.Id);
        Account account = [SELECT Id, Name, (SELECT Id FROM Contacts) FROM Account WHERE Id = :accountId];
        System.assertEquals(account.Name, mainMatrixLead.Company_Name__c);
        System.assertEquals(account.Contacts.size(), BATCH_SIZE);
        for(Matrix_Lead__c matrixLead : [SELECT Id, Lead_Status__c FROM Matrix_Lead__c WHERE REF_NO__c = :mainMatrixLead.REF_NO__c]){
        	System.assertEquals(matrixLead.Lead_Status__c, MatrixLeadConversion.STATUS_CONVERTED);
        }

        Test.stopTest();
	}

	public static testMethod void testMatrixLeadConversionErrors(){
		Integer BATCH_SIZE = 200;
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

		List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
		for(Integer i=0; i<BATCH_SIZE; i++){
			Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
			matrixLead.Company_Name__c = '';
			matrixLead.Surname__c = '';
			matrixLead.Sequence__c = String.valueOf(i);
			matrixLeads.add(matrixLead);
		}
		insert matrixLeads;

		Matrix_Lead__c mainMatrixLead = matrixLeads[0];
		String companyName = 'Test Company';

        Test.startTest();

        String errorMsg;

        errorMsg = MatrixLeadConversion.convertMatrixLeadToProspect(mainMatrixLead.Id);
        System.assertEquals(errorMsg.startsWith(MatrixLeadConversion.ERR_MSG_PROSPECT_CANNOT_BE_CREATED), true);

        for(Matrix_Lead__c matrixLead : matrixLeads){
        	matrixLead.Company_Name__c = companyName;
        }
        update matrixLeads;
        errorMsg = MatrixLeadConversion.convertMatrixLeadToProspect(mainMatrixLead.Id);
        System.assertEquals(errorMsg.startsWith(MatrixLeadConversion.ERR_MSG_CONTACTS_CANNOT_BE_CREATED), true);
        List<Account> accounts = [SELECT Id, Name, (SELECT Id FROM Contacts) FROM Account WHERE Name = :companyName];
        System.assertEquals(accounts.size(), 0);

        delete mainMatrixLead;
        errorMsg = MatrixLeadConversion.convertMatrixLeadToProspect(mainMatrixLead.Id);
        System.assertEquals(errorMsg, MatrixLeadConversion.ERR_MSG_MATRIX_LEAD_DELETED);

        Test.stopTest();
	}

}