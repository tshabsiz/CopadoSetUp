public with sharing class dealPartyOverride_Cont {

    public advpm__Matter__c matter {get;set;}
    public Id MatterId {get;set;}
    public Deal_Party__c dealParty {get;set;}
    
    public Amendment__c amendment {get;set;}
    public String amendmentType {get;set;}
    public String amendmentReason {get;set;}
    public Date amendmentDate {get;set;}
    public String regulationName {get;set;}
    public Boolean amendmentDocument {get;set;}
    
    public Boolean mustBeAmended {get;set;}
    public Boolean dealPartyPanel {get;set;}
    public Boolean amendmentPanel {get;set;}
    
    public Boolean isLibraDeal {get;set;}

    public dealPartyOverride_Cont (ApexPages.StandardController stdController) {
        MatterId = ApexPages.currentPage().getParameters().get('matterId');
        id tmgRecordId = Schema.SObjectType.Deal_Party__c.getRecordTypeInfosByName().get('TMG Deal Party').getRecordTypeId();
        id libraRecordId = Schema.SObjectType.Deal_Party__c.getRecordTypeInfosByName().get('CNSG Deal Party').getRecordTypeId();

        if(MatterId != null){
            matter = [select id, name, RecordTypeId, Netting_Complete__c from advpm__Matter__c where id = :MatterId limit 1];
            
            dealParty = new Deal_Party__c();
            dealParty.Deal__c = matter.id;
            
            //Check if the Matter is a Libra Matter or if it is a TMG Matter
            if(matter.RecordTypeId == Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Deal').getRecordTypeId()){
                isLibraDeal = false;
                dealParty.RecordTypeId = tmgRecordId;
            }
            else{
                isLibraDeal = true;
                dealParty.RecordTypeId = libraRecordId;
            }
            
            if(matter.Netting_Complete__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING,'If a Bank Branch, Counterparty Branch, Retail Hedge Fund, Qualified Investor Hedge Fund or Disclosed Principal is added, it will make Netting Incomplete.'));
            }
            
            if(isLibraDeal){
                amendment = new Amendment__c();
            
                mustBeAmended = false;
                dealPartyPanel = true;
                amendmentPanel = false;
                
                List<Agreement__c> agreements = [SELECT id, Agreement_Status__c from Agreement__c where Matter_Deal__c = :MatterId];
                for(Agreement__c agreement : agreements){
                    if(agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended'){
                        mustBeAmended = true;
                        break;
                    }
                }      
            }
            else{
                mustBeAmended = false;
                dealPartyPanel = false;
                amendmentPanel = false;
            }
		}
    }

    public PageReference cancel() {
        PageReference pf = new PageReference('/' + matter.id);
        return pf;
    }

    public PageReference save() {
        if(mustBeAmended) {
            dealPartyPanel = false;
            amendmentPanel = true;
            
            return null;
        }
        else{
            try{
                saveDealParty();
                PageReference pf = new PageReference('/' + matter.id);
        		return pf; 
            }
            catch (DmlException e){
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(0)));
            	return null;
        	}
        }
    }
    
    public PageReference saveTmgDealParty() {
        try{
            //Set record type to tmg specific one
            id tmgRecordId = Schema.SObjectType.Deal_Party__c.getRecordTypeInfosByName().get('TMG Deal Party').getRecordTypeId();
            dealParty.RecordTypeId = tmgRecordId;
            
            insert dealParty;
            
            PageReference pf = new PageReference('/' + matter.id);
        	return pf;
        }
        catch (DmlException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(0)));
            return null;
        }
    }
    
    public PageReference saveDealParty() {
        //Set record type to libra specific one
        id libraRecordId = Schema.SObjectType.Deal_Party__c.getRecordTypeInfosByName().get('CNSG Deal Party').getRecordTypeId();
        dealParty.RecordTypeId = libraRecordId;
        
        insert dealParty;
        if(dealParty.Relationship_Type__c == 'Counterparty Branch' || 
               dealParty.Relationship_Type__c == 'Bank Branch' || 
               dealParty.Relationship_Type__c == 'Disclosed Principal' || 
               dealParty.Relationship_Type__c == 'Retail Hedge Fund' || 
               dealParty.Relationship_Type__c == 'Qualified Investor Hedge Fund'){
            matter.Netting_Complete__c = false;
            update matter;
        }
        return null;
    }
    
    public PageReference SaveAmendment() {
        amendment.Amendment_Reason__c = amendmentReason;
        amendment.Amendment_Reason_Type__c = amendmentType;
        amendment.Effective_date__c = amendmentDate;
        amendment.Name_of_Regulation__c = regulationName;
        amendment.Matter__c = MatterId;

        amendment.Amendment_Document_Uploaded__c = amendmentDocument ? true : false;

        try {
            insert amendment;
            saveDealParty();
        }
        catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }

        PageReference pf = new PageReference('/' + matter.id);
        return pf;
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