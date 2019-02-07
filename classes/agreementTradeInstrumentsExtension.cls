public class agreementTradeInstrumentsExtension {
    
    private Agreement_Trade_Instrument__c agreementTradeInstrument;
    private ApexPages.StandardController stdController;
    
    public Boolean isNewRecord {get;set;}
    public String[] selectedTradeInstruments {get;set;}
    private List<Agreement_Trade_Instrument__c> agreementTradeInstrumentList = new List<Agreement_Trade_Instrument__c>();
    private List<Agreement_Trade_Instrument__c> agreementTradeInstrumentToDelete = new List<Agreement_Trade_Instrument__c>();
    
    private String retURL;
    private Id agreementId;
    private Id atiRecordId;

    public Boolean isAgreement {get;set;}
    public Boolean isSuppAgreement {get;set;}

    public Set<String> tradeInstrumentIdSet {get;set;}

    public Agreement__c agreement {get;set;}
    public Supporting_Agreement__c suppAgreement {get;set;}

    private advpm__Matter__c matter;

    public Amendment__c amendment {get;set;}
    public String amendmentType {get;set;}
    public String amendmentReason {get;set;}
    public Date amendmentDate {get;set;}
    public String regulationName {get;set;}
    public Boolean amendmentDocument {get;set;}

    public Boolean mustBeAmended {get;set;}
    public Boolean tradeInstrumentPanel {get;set;}
    public Boolean amendmentPanel {get;set;}
    
    public agreementTradeInstrumentsExtension(ApexPages.StandardController stdController) 
    {
        this.agreementTradeInstrument = (Agreement_Trade_Instrument__c)stdController.getRecord();
        this.stdController = stdController;
        
        atiRecordId = ApexPages.currentPage().getParameters().get('id');
        
        isNewRecord = atiRecordId == null ? true : false;

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(!Test.isRunningTest()){
            retURL = retURL.substring(1);
        }
        agreementId = Id.ValueOf(retURL);

        mustBeAmended = false;

        //Trade Instruments
        try{
            agreement = [select id, name, Agreement_Type__c, Matter_Deal__c, RecordTypeId, Agreement_Status__c from Agreement__c where id = :agreementId limit 1];
            matter = [select id, name, Netting_Complete__c from advpm__Matter__c where id = :agreement.Matter_Deal__c limit 1];
            //Amendments
            if(agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended') {
                mustBeAmended = true;
            }

            amendment = new Amendment__c();

            getCategories();
            if(matter.Netting_Complete__c == true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING,'By Saving these Trade Instruments, it will make Netting Incomplete.'));
            }
        }
        catch (Exception e){
            System.debug('Agreement is a Supporting Agreement');
        }

        tradeInstrumentPanel = true;
        amendmentPanel = false;

        //Supporting Agreement
        try{
            suppAgreement = [select id, name, Supporting_Agreement_Type__c, Agreement__c from Supporting_Agreement__c where id = :agreementId limit 1];
        }
        catch (Exception e){
            System.debug('Agreement is not Supporting Agreement');
        }

        if(agreement != null){
            isAgreement = true;
            isSuppAgreement = false;
        }
        else if(suppAgreement != null) {
            isAgreement = false;
            isSuppAgreement = true;
        }
        
        if(!isNewRecord){
            if(isAgreement){
                Agreement_Trade_Instrument__c thisATI =
                [
                        SELECT
                                Id,
                                Trade_Instrument__c,
                                Agreement__c
                        FROM
                                Agreement_Trade_Instrument__c
                        WHERE
                                Id =: atiRecordId
                ];
                agreementId = thisATI.Agreement__c;
            }
            else if(isSuppAgreement){
                Agreement_Trade_Instrument__c thisATI =
                [
                        SELECT
                                Id,
                                Trade_Instrument__c,
                                Supporting_Agreement__c
                        FROM
                                Agreement_Trade_Instrument__c
                        WHERE
                                Id =: atiRecordId
                ];
                agreementId = thisATI.Supporting_Agreement__c;
            }
        }

        if(isAgreement){
            List<Agreement_Trade_Instrument__c> existingATIList =
                [
                    SELECT
                    Id,
                    Trade_Instrument__c
                    FROM
                    Agreement_Trade_Instrument__c
                    WHERE
                    Agreement__c =: agreementId
                ];

            //add to set
            tradeInstrumentIdSet = new Set<String>();
            for(Agreement_Trade_Instrument__c ati : existingATIList)
            {
                tradeInstrumentIdSet.add('"' + ati.Trade_Instrument__c + '"');
            }
        }
        else if(isSuppAgreement){
            List<Agreement_Trade_Instrument__c> existingATIList =
            [
                    SELECT
                            Id,
                            Trade_Instrument__c
                    FROM
                            Agreement_Trade_Instrument__c
                    WHERE
                            Supporting_Agreement__c =: agreementId
            ];

            //add to set
            tradeInstrumentIdSet = new Set<String>();
            for(Agreement_Trade_Instrument__c ati : existingATIList)
            {
                tradeInstrumentIdSet.add('"' + ati.Trade_Instrument__c + '"');
            }
        }
    }

    public PageReference save(){
        if(mustBeAmended) {
            tradeInstrumentPanel = false;
            amendmentPanel = true;
        }
        else{
            try {
                 saveTradeInstruments();
                 PageReference pr = new PageReference('/' + agreementId);
                 return pr;
            }
            catch(exception e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        return null;
    }
    
   	public PageReference saveTradeInstruments() {
        if(isAgreement){
            //delete existing Agreement_Trade_Instrument__c
            agreementTradeInstrumentToDelete =
            [
                    SELECT
                            Id
                    FROM
                            Agreement_Trade_Instrument__c
                    WHERE
                            Agreement__c =: agreementId
            ];

            delete agreementTradeInstrumentToDelete;

            //add all selected trade intruments to a list to insert as an Agreement Trade Instrument
            for(String ti : selectedTradeInstruments)
            { 
                Agreement_Trade_Instrument__c ati = new Agreement_Trade_Instrument__c(Trade_Instrument__c = ti, Agreement__c = agreementId);
                agreementTradeInstrumentList.add(ati);
            }

            insert agreementTradeInstrumentList;

            matter.Netting_Complete__c = false;
            update matter;
        }
        else if(isSuppAgreement){
            //delete existing Agreement_Trade_Instrument__c
            agreementTradeInstrumentToDelete =
            [
                    SELECT
                            Id
                    FROM
                            Agreement_Trade_Instrument__c
                    WHERE
                            Supporting_Agreement__c =: agreementId
            ];

            delete agreementTradeInstrumentToDelete;

            //add all selected trade intruments to a list to insert as an Agreement Trade Instrument
            for(String ti : selectedTradeInstruments)
            {
                Agreement_Trade_Instrument__c ati = new Agreement_Trade_Instrument__c(Trade_Instrument__c = ti, Supporting_Agreement__c = agreementId);
                agreementTradeInstrumentList.add(ati);
            }

            insert agreementTradeInstrumentList;
        }
        
        return null;
    }

    public PageReference SaveAmendment() {
        amendment.Amendment_Reason__c = amendmentReason;
        amendment.Amendment_Reason_Type__c = amendmentType;
        amendment.Effective_date__c = amendmentDate;
        amendment.Name_of_Regulation__c = regulationName;
        amendment.Agreement__c = agreementId;

        amendment.Amendment_Document_Uploaded__c = amendmentDocument ? true : false;

        try {
            insert amendment;
            saveTradeInstruments();
        }
        catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }

        tradeInstrumentPanel = true;
        amendmentPanel = false;

        PageReference pr = new PageReference('/' + agreementId);
        return pr;
    }
    
    //Get Trade Instrument records to build up multiselect picklist
    public List<Selectoption> getTradeInstruments(){

        List<Trade_Instrument__c> tradeInstrumentList = new List<Trade_Instrument__c>();
        if(isAgreement){
            String agreementType = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosById().get(agreement.RecordTypeId).getName();

            tradeInstrumentList =
            [
                    SELECT
                            Id,
                            Name,
                            Trade_Instrument_ID__c,
                            Agreement_Type__c
                    FROM
                            Trade_Instrument__c
                    WHERE
                            Agreement_Type__c = :agreementType
            ];
        }
        else if(isSuppAgreement){

            Agreement__c agreement = [select id from Agreement__c where id = :suppAgreement.Agreement__c];

            List<Agreement_Trade_Instrument__c> agreementATIList =
            [
                    SELECT
                            Id,
                            Trade_Instrument__c
                    FROM
                            Agreement_Trade_Instrument__c
                    WHERE
                            Agreement__c =: agreement.id
            ];
            
            Set<Id> agreementTradeInstruments = new Set<Id>();
            for(Agreement_Trade_Instrument__c ati : agreementATIList){
                agreementTradeInstruments.add(ati.Trade_Instrument__c);
            }

            Map<Id, Trade_Instrument__c> tradeInstrumentsMap = new Map<Id, Trade_Instrument__c>([SELECT Id, Name, Trade_Instrument_ID__c FROM Trade_Instrument__c WHERE id IN :agreementTradeInstruments]);
            for(Agreement_Trade_Instrument__c ati : agreementATIList) {
                Trade_Instrument__c ti = new Trade_Instrument__c();
                tradeInstrumentList.add(tradeInstrumentsMap.get(ati.Trade_Instrument__c));
            }
        }

        List<Selectoption> tradeInstrumentSel = new List<selectoption>();
        for(Trade_Instrument__c ti : tradeInstrumentList){
			tradeInstrumentSel.add(new selectOption(ti.Id, ti.Name));
        }
                
        return tradeInstrumentSel; 
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