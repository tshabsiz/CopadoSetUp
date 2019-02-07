/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - JLOC
*
* 13-Jun-2016	Mohsin Wadee	Changed phone number to correct format in method getDefaultMatrixLead.
*/
@isTest
public class ZZTEST_F_MatrixLead {
	public enum MatrixLeadRecordType {DEFAULT_MATRIX_LEAD}

    private static ZZTEST_F_MatrixLead instance;

    private Integer productCounter;
   
    private ZZTEST_F_MatrixLead() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_MatrixLead getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_MatrixLead();
        }
        return instance;
    }

    public Matrix_Lead__c getProduct(MatrixLeadRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == MatrixLeadRecordType.DEFAULT_MATRIX_LEAD)
                return getDefaultMatrixLead(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Matrix_Lead__c getInsertedProduct(MatrixLeadRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if(type == MatrixLeadRecordType.DEFAULT_MATRIX_LEAD) 
                return getInsertedDefaultMatrixLead(dataContainer);

        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Matrix_Lead__c getDefaultMatrixLead(ZZTEST_DataContainer dataContainer) {
        Matrix_Lead__c matrixLead = new Matrix_Lead__c();
        //matrixLead.KI_Ref__c = 100;
        matrixLead.REF_NO__c = '1177';
        matrixLead.Lead_Status__c = 'Open';
        matrixLead.Company_Name__c = 'TEST Company Name';
        matrixLead.Trade_Division__c = 'Trade Division';
        matrixLead.REG_No__c = '111777';
        matrixLead.SICCODE_Description__c = 'SICCODE Description';
        matrixLead.Bank__c = 'Bank';
        matrixLead.Turn_Over__c = 1000;
        matrixLead.Postal_Address1__c = 'Address 1';
        matrixLead.Postal_Area__c = 'Postal Area';
        matrixLead.Post_Code__c = '1234';
        matrixLead.Street_Address_1__c = 'Street Address 1';
        matrixLead.Tel_Code__c = '';
        matrixLead.Tel_No__c = '486 732 1678';
        matrixLead.Responsibility__c = 'Responsibility';
        matrixLead.Position__c = 'Position';
        matrixLead.Salutation__c = 'Mr.';
        matrixLead.First_Name__c = 'Thomas';
        matrixLead.Surname__c = 'Cook';
        matrixLead.Job_Title__c = 'Job Title';
        matrixLead.Personal_Email__c = 'tcook@example.com';
        return matrixLead;
    }

    private Matrix_Lead__c getInsertedDefaultMatrixLead(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Matrix_Lead__c.getSObjectType()).isEmpty()) {
            Matrix_Lead__c matrixLead = this.getDefaultMatrixLead(dataContainer);
            insert matrixLead;
            dataContainer.put(matrixLead);
            return matrixLead;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Matrix_Lead__c.getSobjectType(), null).values()) {
                return (Matrix_Lead__c) s;
            }
        }
        return null;
    }
}