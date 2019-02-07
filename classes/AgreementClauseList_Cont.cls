/**
 * Created by KyleAlexander on 2018/03/19.
 */

public with sharing class AgreementClauseList_Cont {

    Public Id agreementId {get;set;}
    Public List<ClauseWrapper> addedClauses {get;set;}
    Public List<ClauseWrapper> notAddedClauses {get;set;}

    Public List<Agreement_Clause__c> agreementClauses {get;set;}
    Public List<Clause__c> clauses {get;set;}

    public Agreement__c agreement {get;set;}
    public Boolean mustBeAmended {get;set;}
    public Boolean clausesPanel {get;set;}
    public Boolean amendmentPanel {get;set;}

    public Amendment__c amendment {get;set;}
    public String amendmentType {get;set;}
    public String amendmentReason {get;set;}
    public Date amendmentDate {get;set;}
    public String regulationName {get;set;}
    public Boolean amendmentDocument {get;set;}

    public Boolean isAddedClause = false;
    
    public static final String ISDA_RECORD_TYPE = 'ISDA Agreement';
    public static final String GMRA_RECORD_TYPE = 'GMRA Agreement';
    public static final String GMSLA_RECORD_TYPE = 'GMSLA Agreement';

    public AgreementClauseList_Cont(ApexPages.StandardController controller) {
        agreementId = ApexPages.currentPage().getParameters().get('id');

        agreement = [select id, recordTypeId, RecordType.Name, Agreement_Status__c, Agreement_Type__c from Agreement__c where id = :agreementId];

        String recordTypeName = agreement.RecordType.Name;

        if(agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended') {
            mustBeAmended = true;
        }
        else{
            mustBeAmended = false;
        }

        amendment = new Amendment__c();

        getCategories();

        clausesPanel = true;
        amendmentPanel = false;

        agreementClauses = new List<Agreement_Clause__c>();
        clauses = new List<Clause__c>();

        addedClauses = new List<ClauseWrapper>();
        notAddedClauses = new List<ClauseWrapper>();

        agreementClauses = [select id, Clause__c from Agreement_Clause__c where Agreement__c = :agreementId];

        if(recordTypeName == ISDA_RECORD_TYPE){
            clauses = [select id, Clause_Name__c, HotDocs__c from Clause__c where ISDA_Clause__c = true order by Sort_Order__c, Clause_Name__c];
        }
        else if(recordTypeName == GMRA_RECORD_TYPE){
            clauses = [SELECT id, Clause_Name__c, HotDocs__c FROM Clause__c WHERE GMRA_Clause__c = true OR GMRA_Default__c = true ORDER BY Sort_Order__c, Clause_Name__c];
        }
        else if(recordTypeName == GMSLA_RECORD_TYPE){
            clauses = [select id, Clause_Name__c, HotDocs__c from Clause__c where GMSLA_Clause__c = true OR GMSLA_Default__c = true order by Sort_Order__c, Clause_Name__c];
        }

        for(Clause__c cl : clauses){
            Boolean addedClause = false;
            
            for(Agreement_Clause__c ac : agreementClauses){
                if(cl.id == ac.Clause__c){
                    ClauseWrapper cw = new ClauseWrapper(cl);
                    cw.selected = false;
                    addedClauses.add(cw);
                    addedClause = true;
                }
            }
            if(!addedClause){
                ClauseWrapper cw = new ClauseWrapper(cl);
                cw.selected = false;
                notAddedClauses.add(cw);
            }
        }
    }

    public void addAllClauses(){
        Integer count = 0;
        List<Integer> indexToRemove = new List<Integer>();

        List<Agreement_Clause__c> agreementClauses = new List<Agreement_Clause__c>();
        for(ClauseWrapper clauseWrapper : notAddedClauses) {
            if(clauseWrapper.selected){
                Agreement_Clause__c agreementClause = new Agreement_Clause__c();
                agreementClause.Agreement__c = agreementId;
                agreementClause.Clause__c = clauseWrapper.clause.id;
				agreementClauses.add(agreementClause);
                
                clauseWrapper.selected = false;
                addedClauses.add(clauseWrapper);
                indexToRemove.add(count);
            }
            count++;
        }
        insert agreementClauses;

        //numIterated is used here because as we remove from the list the index's change
        Integer numIterated = 0;
        if(!indexToRemove.isEmpty()){
            for(Integer index : indexToRemove) {
                notAddedClauses.remove(index - numIterated);
                numIterated++;
            }
        }
    }

    public PageReference AddClauses(){
        isAddedClause = true;
        if(mustBeAmended) {
            clausesPanel = false;
            amendmentPanel = true;
        }
        else{
            addAllClauses();
        }
        return null;
    }

    public void removeAllClauses(){
        Integer count = 0;
        List<Integer> indexToRemove = new List<Integer>();

        for(ClauseWrapper clauseWrapper : addedClauses) {
            if(!(!clauseWrapper.selected)){
                Agreement_Clause__c agreementClause = [select id, Clause__c from Agreement_Clause__c where Agreement__c = :agreementId and Clause__c = :clauseWrapper.clause.id limit 1];

                delete agreementClause;
                clauseWrapper.selected = false;
                notAddedClauses.add(clauseWrapper);
                indexToRemove.add(count);
            }
            count++;
        }

        //numIterated is used here because as we remove from the list the index's change
        Integer numIterated = 0;
        if(!indexToRemove.isEmpty()){
            for(Integer index : indexToRemove) {
                addedClauses.remove(index - numIterated);
                numIterated++;
            }
        }
    }

    public PageReference RemoveClauses(){
        isAddedClause = false;
        if(mustBeAmended) {
            clausesPanel = false;
            amendmentPanel = true;
        }
        else{
            removeAllClauses();
        }
        return null;
    }

    public PageReference SaveAmendment() {
        amendment.Amendment_Reason__c = amendmentReason;
        amendment.Amendment_Reason_Type__c = amendmentType;
        amendment.Effective_date__c = amendmentDate;
        amendment.Name_of_Regulation__c = regulationName;
        amendment.Agreement__c = agreementId;

        if (amendmentDocument) {
            amendment.Amendment_Document_Uploaded__c = true;
        } else {
            amendment.Amendment_Document_Uploaded__c = false;
        }

        try {

            if(isAddedClause){
                addAllClauses();
            }
            else{
                removeAllClauses();
            }

            insert amendment;
        }
        catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }

        clausesPanel = true;
        amendmentPanel = false;

        return null;
    }

    public List<SelectOption> getCategories() {
        List<SelectOption> categories = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Amendment__c.Amendment_Reason_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            categories.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return categories;
    }

}