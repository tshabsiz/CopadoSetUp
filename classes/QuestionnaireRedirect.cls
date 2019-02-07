public class QuestionnaireRedirect {
    
    public id matter_spend_document_id {get; set;}
    public Matter_Spend_Document__c msd {get; set;}
    public Legal_Performance_Questionnaire__c lpq {get; set;}

    public QuestionnaireRedirect(ApexPages.StandardController controller){
        matter_spend_document_id = apexpages.currentpage().getparameters().get('id');
        msd = [select Law_Firm__c, id, Matter__c from Matter_Spend_Document__c where id = :matter_spend_document_id limit 1];
        
        lpq = new Legal_Performance_Questionnaire__c();
        lpq.LawFirm__c = msd.Law_Firm__c;
        lpq.MatterSpendDocument__c = msd.id;
        lpq.Matter__c = msd.Matter__c;
    }
}