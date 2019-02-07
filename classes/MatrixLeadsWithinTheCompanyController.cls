/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for Visualforce page: MatrixLeadsWithinTheCompany.
* @Date:        12/2015
* @ConstructorParam:    None
* @TestClass:   ZZTEST_MatrixLeadsWithinTheCompanyCtr
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/2016  Marta Malinowska   Match Matrix Leads within the same company by REF NO F.
*------------------------------------------------------------*/
public with sharing class MatrixLeadsWithinTheCompanyController {
    private Matrix_Lead__c matrixLead;
    public List<Matrix_Lead__c> relatedMatrixLeads { get; set; }

    public MatrixLeadsWithinTheCompanyController(ApexPages.StandardController stdController) {
        matrixLead = (Matrix_Lead__c)stdController.getRecord();
        if(String.isNotBlank(matrixLead.Id)){
            relatedMatrixLeads = [SELECT Id, Name, First_Name__c, Surname__c, Job_Title__c, Tel_Code__c, Tel_No__c
                                    FROM Matrix_Lead__c WHERE Id != :matrixLead.Id AND REF_NO_F__c = :matrixLead.REF_NO_F__c];
        } else{
            relatedMatrixLeads = new List<Matrix_Lead__c>();
        }
    }
}