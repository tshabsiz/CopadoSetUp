/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used to call approval process from Matrix Lead Report page
* @Date:        12/2015
* @ConstructorParam:    None
* @TestClass:   ZZTEST_MatrixLeadApprovalProcessUtils
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/2016  Marta Malinowska   Match Matrix Leads within the same company by REF NO F.
*------------------------------------------------------------*/
public without sharing class MatrixLeadApprovalProcessUtils {
    
    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to assign selected Matrix Leads to current user and request approval.
    * @param        Set of Matrix Lead Ids
    * @Returns:     null if successfully processed, error message otherwise 
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 12/01/2016  Marta Malinowska   Match Matrix Leads within the same company by REF NO F.
    *------------------------------------------------------------*/
    public static String requestMatrixLeadsAssignment(Set<Id> matrixLeadIds){
        Map<String, Matrix_Lead__c> matrixLeadsToSubmit = new Map<String, Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLead : [SELECT Id, Name, REF_NO_F__c FROM Matrix_Lead__c WHERE Id IN :matrixLeadIds]){
            matrixLeadsToSubmit.put(matrixLead.REF_NO_F__c, matrixLead);
        }

        List<Matrix_Lead__c> matrixLeadsToUpd = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLead : [SELECT Id, Name, OwnerId FROM Matrix_Lead__c WHERE REF_NO_F__c IN :matrixLeadsToSubmit.keySet()]){
            matrixLead.OwnerId = UserInfo.getUserId();
            matrixLeadsToUpd.add(matrixLead);
        }

        Savepoint sp = Database.setSavepoint();

        try{
            update matrixLeadsToUpd;
        } catch(DmlException ex){
            return ex.getDmlMessage(0);
        }

        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(Matrix_Lead__c matrixLead : matrixLeadsToSubmit.values()){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(matrixLead.Id);
            requests.add(req);
        }
        List<Approval.ProcessResult> results;
        try{
            results = Approval.process(requests);
        } catch(DmlException ex){
            Database.rollback(sp);
            return ex.getDmlMessage(0);
        }
        
        return null;
    }
}