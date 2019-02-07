/**
* @Author   Marta Malinowska
* @Company: Deloitte
* @Description Unit Tests for MatrixLeadApprovalProcessUtils
*              Tests executed:
*               1 - testRequestMatrixLeadsAssignment
*                   Tests that up to 5 new Matrix Leads can be assigned to a banker and sent for approval
*               2 - testRequestMatrixLeadsAssignment2
*                   Tests that up to 5 Matrix Leads can be assigned to a banker and sent for approval
*               3 - testRequestMatrixLeadsAssignmentErrors
*                   Tests that error message is displayed if more than 5 new Matrix Leads are requested
*               4 - testRequestMatrixLeadsAssignmentErrors2()
*                   Tests that error message is displayed if user has no Manager assigned
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/2016  Marta Malinowska   Change tests to match Matrix Leads within the same company by REF NO F.
* 31/03/2016  Masie Maseli       Change tests to make sure that there are no duplicate Matrix leads within the tests.
* 04/04/2016  Masie Maseli       Created the Custom Setting MatrixLeadSelectionLimit__c in the test for the maximum number of leads
                                 selected.
* ----------------------------------------------------------------------------*/
@isTest
private class ZZTEST_MatrixLeadApprovalProcessUtils {

    public static testMethod void testRequestMatrixLeadsAssignment(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

        User barclaysStandardUser;// = userFactory.getBarclaysStandardUser(); 
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(currentUser) {
            barclaysStandardUser = userFactory.getBarclaysStandardUser(); 
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Key_Matrix_Leads_Qualification'];
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = barclaysStandardUser.Id);
    
            barclaysStandardUser.ManagerId = currentUser.Id;
            update barclaysStandardUser;
        }

        List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
        for(Integer i=0; i<5; i++){
            for(Integer j=0; j<2; j++){
                Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
                matrixLead.REF_NO__c = String.valueOf(i);
                matrixLead.REG_NO__c = String.valueOf(i);
                matrixLeads.add(matrixLead);
            }
        }

        insert matrixLeads;
        Set<Id> matrixLeadIds = new Set<Id>();
        for(Matrix_Lead__c matrixLead : matrixLeads){
            matrixLeadIds.add(matrixLead.Id);
        }

        String result;

        Test.startTest();

        System.runAs(barclaysStandardUser) {
            result = MatrixLeadApprovalProcessUtils.requestMatrixLeadsAssignment(matrixLeadIds);
        }

        Test.stopTest();

        System.assertEquals(result, null);
        for(Matrix_Lead__c matrixLead : [SELECT Id, OwnerId, Unique_External_Id__c, Sequence__c, REF_NO__c, Lead_Status__c FROM Matrix_Lead__c WHERE Id IN :matrixLeadIds]){
            System.assertEquals(matrixLead.Lead_Status__c, MatrixLeadTriggerHelper.STATUS_PENDING_ASSIGNMENT);
            System.assertEquals(matrixLead.OwnerId, barclaysStandardUser.Id);
        }
    }

    public static testMethod void testRequestMatrixLeadsAssignment2(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

        User barclaysStandardUser;// = userFactory.getBarclaysStandardUser(); 
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(currentUser) {
            barclaysStandardUser = userFactory.getBarclaysStandardUser(); 
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Key_Matrix_Leads_Qualification'];
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = barclaysStandardUser.Id);
    
            barclaysStandardUser.ManagerId = currentUser.Id;
            update barclaysStandardUser;
        }

        List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
        for(Integer i=0; i<3; i++){
            for(Integer j=0; j<2; j++){
                Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
                matrixLead.REF_NO__c = String.valueOf(i);
                matrixLeads.add(matrixLead);
            }
        }
        insert matrixLeads;

        for(Matrix_Lead__c matrixLead : matrixLeads){
            matrixLead.OwnerId = barclaysStandardUser.Id;
            matrixLead.Lead_Status__c = MatrixLeadTriggerHelper.STATUS_ASSIGNED;
        }
        update matrixLeads;

        matrixLeads = new List<Matrix_Lead__c>();
        for(Integer i=0; i<2; i++){
            for(Integer j=0; j<2; j++){
                Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
                matrixLead.REF_NO__c = String.valueOf(i);
                matrixLead.REG_NO__c = String.valueOf(i);
                matrixLeads.add(matrixLead);
            }
        }
        insert matrixLeads;

        Set<Id> matrixLeadIds = new Set<Id>();
        for(Matrix_Lead__c matrixLead : matrixLeads){
            matrixLeadIds.add(matrixLead.Id);
        }

        String result;

        Test.startTest();

        System.runAs(barclaysStandardUser) {
            result = MatrixLeadApprovalProcessUtils.requestMatrixLeadsAssignment(matrixLeadIds);
        }

        Test.stopTest();

        System.assertEquals(result, null);
        for(Matrix_Lead__c matrixLead : [SELECT Id, OwnerId, Unique_External_Id__c, Sequence__c, REF_NO__c, Lead_Status__c FROM Matrix_Lead__c WHERE Id IN :matrixLeadIds]){
            System.assertEquals(matrixLead.Lead_Status__c, MatrixLeadTriggerHelper.STATUS_PENDING_ASSIGNMENT);
            System.assertEquals(matrixLead.OwnerId, barclaysStandardUser.Id);
        }
    }

    public static testMethod void testRequestMatrixLeadsAssignmentErrors(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

        User barclaysStandardUser;// = userFactory.getBarclaysStandardUser(); 
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(currentUser) {
            barclaysStandardUser = userFactory.getBarclaysStandardUser(); 
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Key_Matrix_Leads_Qualification'];
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = barclaysStandardUser.Id);
    
            barclaysStandardUser.ManagerId = currentUser.Id;
            update barclaysStandardUser;
            
            Insert new MatrixLeadSelectionLimit__c(SetupOwnerId = UserInfo.getOrganizationId(), Maximum_Number_of_Leads_Allowed__c = 5);
        }

        List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
        for(Integer i=0; i<6; i++){
            for(Integer j=0; j<2; j++){
                Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
                matrixLead.REF_NO__c = String.valueOf(i);
                matrixLead.REG_NO__c = String.valueOf(i);
                matrixLeads.add(matrixLead);
            }
        }
        insert matrixLeads;

        Set<Id> matrixLeadIds = new Set<Id>();
        for(Matrix_Lead__c matrixLead : matrixLeads){
            matrixLeadIds.add(matrixLead.Id);
        }

        String result;

        Test.startTest();

        System.runAs(barclaysStandardUser) {
            result = MatrixLeadApprovalProcessUtils.requestMatrixLeadsAssignment(matrixLeadIds);
        }

        Test.stopTest();

        System.assertEquals(result, Label.errMsg_Only5OpenMatrixLeadsAllowed);
    }

    public static testMethod void testRequestMatrixLeadsAssignmentErrors2(){
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

        User barclaysStandardUser;// = userFactory.getBarclaysStandardUser(); 
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(currentUser) {
            barclaysStandardUser = userFactory.getBarclaysStandardUser(); 
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Key_Matrix_Leads_Qualification'];
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = barclaysStandardUser.Id);
        }

        List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
        for(Integer i=0; i<3; i++){
            for(Integer j=0; j<2; j++){
                Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
                matrixLead.REF_NO__c = String.valueOf(i);
                matrixLead.REG_NO__c = String.valueOf(i);
                matrixLeads.add(matrixLead);
            }
        }
        insert matrixLeads;

        Set<Id> matrixLeadIds = new Set<Id>();
        for(Matrix_Lead__c matrixLead : matrixLeads){
            matrixLeadIds.add(matrixLead.Id);
        }

        String result;

        Test.startTest();

        System.runAs(barclaysStandardUser) {
            result = MatrixLeadApprovalProcessUtils.requestMatrixLeadsAssignment(matrixLeadIds);
        }

        Test.stopTest();
        
        System.assertNotEquals(result, null);
    }
}