public class supportingAgreementExtension {
    public Supporting_Agreement__c supportingAgreement;
    private ApexPages.StandardController stdController;

    public Boolean suppAgreementPanel {get;set;}
    public Boolean amendmentPanel {get;set;}

    public Amendment__c amendment {get;set;}
    public String amendmentType {get;set;}
    public String amendmentReason {get;set;}
    public Date amendmentDate {get;set;}
    public String regulationName {get;set;}
    public Boolean amendmentDocument {get;set;}
    public Boolean isCSA {get;set;}
    public Boolean isOtherCSA {get;set;}
    public Boolean isCSD {get;set;}
    public Boolean isNext {get;set;}
    public Boolean isNewAgreement;
    public Boolean isNotRequired {get;set;}

    public supportingAgreementExtension(ApexPages.StandardController stdController) 
    {
        this.supportingAgreement = (Supporting_Agreement__c)stdController.getRecord();
        this.stdController = stdController;

        supportingAgreement.Active__c = true;
        isNext = false;

        Id suppAgreementId = ApexPages.currentPage().getParameters().get('id');
        String agreementType = ApexPages.currentPage().getParameters().get('type');
        Id AgreementId = ApexPages.currentPage().getParameters().get('agreementId');
        String isNewAgreementString = ApexPages.currentPage().getParameters().get('new');
        if(isNewAgreementString != 'true') 
        {
            isNewAgreementString = 'false';
        }
        isNewAgreement = Boolean.valueOf(isNewAgreementString);
        
        //Set Master Agreement Type for new Agreements
        if(isNewAgreement)
        {
            supportingAgreement.Master_Agreement_Type__c = agreementType;
            supportingAgreement.Agreement__c = AgreementId;

            supportingAgreement.Base_Currency__c = 'ZAR - South African Rand';
            supportingAgreement.Dist_Int_Amount_Eligible_Currency__c = 'ZAR - South African Rand';
            supportingAgreement.Bank_Collateral_Threshold_Amount_Eligibl__c = 'ZAR - South African Rand';
            supportingAgreement.Counterparty_Collateral_Threshold_Fixed__c = 'ZAR - South African Rand';
            supportingAgreement.Bank_Ind_Currency_Initial_Mg_Currency__c = 'ZAR - South African Rand';
            supportingAgreement.Counterparty_Ind_Curr_Initial_Mg_Curr__c = 'ZAR - South African Rand';

            supportingAgreement.Security_Chargor__c = 'N/A';
            supportingAgreement.Security_Provider__c = 'N/A';
        }

        if(!isNewAgreement) 
        {
            supportingAgreement = 
                [
                    SELECT 
                    Id, 
                    Agreement__c, 
                    Supporting_Agreement_Type__c, 
                    CSA_Type__c,
                    Agreement__r.Agreement_Status__c,
                    Security_Obligation_to_Absa__c,
                    Security_Obligation_to_Counterparty__c,
                    SO_Absa_Own_Amount__c,
                    SO_Counterparty_Own_Amount__c
                    FROM 
                    Supporting_Agreement__c 
                    WHERE 
                    Id = :suppAgreementId
                ];
            
            amendment = new Amendment__c();
            getCategories();

            checkSuppAgreementType();
        }

        suppAgreementPanel = true;
        amendmentPanel = false;
    }

    public void checkSuppAgreementType(){
        isCSA = false;
        isOtherCSA = false;
        isCSD = false;
        isNotRequired = false;

        if(supportingAgreement.Supporting_Agreement_Type__c == 'CSA (English Law)' || supportingAgreement.Supporting_Agreement_Type__c == 'CSA (New York Law)'
                || supportingAgreement.Supporting_Agreement_Type__c == 'IM CSA' || supportingAgreement.Supporting_Agreement_Type__c == 'VM CSA'
                || supportingAgreement.Supporting_Agreement_Type__c == 'Tri-party CSA') {

            isOtherCSA = true;
        }

        if(supportingAgreement.Supporting_Agreement_Type__c == 'CSA' || supportingAgreement.Supporting_Agreement_Type__c == 'CSA (English Law)'
                || supportingAgreement.Supporting_Agreement_Type__c == 'CSA (New York Law)' || supportingAgreement.Supporting_Agreement_Type__c == 'IM CSA'
                || supportingAgreement.Supporting_Agreement_Type__c == 'VM CSA' || supportingAgreement.Supporting_Agreement_Type__c == 'Tri-party CSA') {

            isCSA = true;
        }
        if(supportingAgreement.Supporting_Agreement_Type__c == 'CSD')
        {
            isCSD = true;
        }

        if(isNewAgreement && supportingAgreement.Supporting_Agreement_Type__c == 'CSA'){
            isNotRequired = true;
        }

        isNext = true;
    }

    public PageReference next()
    {
        if(checkAgreementType()){
            checkSuppAgreementType();
            setRecordType();
        }
        else{
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'If Other is selected for Supporting Agreement Type then a value must be entered in the Other field'));
        }
        return null;
    }
    
    public PageReference save()
    {
        if(checkValuationAgent()){
            if(checkOwnAmount()) {
                if (isNewAgreement) {
                    Supporting_Agreement__c sa = (Supporting_Agreement__c) stdController.getRecord();

                    try {
                        insert sa;
                    }
                    catch (Exception e) {
                        ApexPages.addMessages(e);
                        return null;
                    }
                    PageReference pf = new PageReference('/' + supportingAgreement.id);
                    return pf;
                }
                else {
                    Agreement__c agreement = [
                            select
                                    Id,
                                    Agreement_Status__c
                            FROM
                                    Agreement__c
                            WHERE
                                    Id = :supportingAgreement.Agreement__c
                            LIMIT 1
                    ];

                    if (agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended') {
                        suppAgreementPanel = false;
                        amendmentPanel = true;
                    } else {
                        Supporting_Agreement__c sa = (Supporting_Agreement__c) stdController.getRecord();
                        try {
                            update sa;
                        }
                        catch (Exception e) {
                            ApexPages.addMessages(e);
                            return null;
                        }
                        
                        

                        PageReference pf = new PageReference('/' + supportingAgreement.id);
                        return pf;
                    }
                    return null;
                }
            }
            else {
                apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'If Own Amount is selected for Security Obligation to Absa or Security Obligation to Counterparty then a value must be entered in the Own Amount field'));
                return null;
            }
        }
        else {
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'If Other is selected for Valuation Agent then a value must be entered in the Other field'));
            return null;
        }

    }

    public Boolean checkAgreementType(){
        Supporting_Agreement__c sa = (Supporting_Agreement__c)stdController.getRecord();
        if(sa.Supporting_Agreement_Type__c == 'Other'){
            if(sa.Other_Agreement__c == null){
                return false;
            }
        }
        return true;
    }

    public Boolean checkValuationAgent(){
        Supporting_Agreement__c sa = (Supporting_Agreement__c)stdController.getRecord();
        if(sa.Valuation_Agent__c == 'Other'){
            if(sa.Other_Valuation_Agent__c == null){
                return false;
            }
        }
        return true;
    }

    public Boolean checkOwnAmount(){
        Supporting_Agreement__c sa = (Supporting_Agreement__c)stdController.getRecord();
        if(sa.Security_Obligation_to_Absa__c == 'Own Amount'){
            if(sa.SO_Absa_Own_Amount__c == null){
                return false;
            }
        }
        if(sa.Security_Obligation_to_Counterparty__c == 'Own Amount'){
            if(sa.SO_Counterparty_Own_Amount__c == null){
                return false;
            }
        }
        return true;
    }

    public void setRecordType(){
        Supporting_Agreement__c sa = (Supporting_Agreement__c)stdController.getRecord();
        if(sa.Supporting_Agreement_Type__c == 'CSA' || sa.Supporting_Agreement_Type__c == 'CSA (English Law)' || sa.Supporting_Agreement_Type__c == 'CSA (New York Law)' || sa.Supporting_Agreement_Type__c == 'IM CSA' || sa.Supporting_Agreement_Type__c == 'VM CSA' || sa.Supporting_Agreement_Type__c == 'Tri-party CSA'){
            sa.RecordTypeId = Supporting_Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('CSA Supporting Agreement').getRecordTypeId();
        }
        else if(sa.Supporting_Agreement_Type__c == 'CSD'){
            sa.RecordTypeId = Supporting_Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('CSD Supporting Agreement').getRecordTypeId();
        }
        else{
            sa.RecordTypeId = Supporting_Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Default Supporting Agreement').getRecordTypeId();
        }
    }

    public PageReference CancelAmendment() {
        PageReference pf = new PageReference('/' + supportingAgreement.id);
        return pf;
    }

    public PageReference SaveAmendment() {
        amendment.Amendment_Reason__c = amendmentReason;
        amendment.Amendment_Reason_Type__c = amendmentType;
        amendment.Effective_date__c = amendmentDate;
        amendment.Name_of_Regulation__c = regulationName;
        amendment.Supporting_Agreement__c = supportingAgreement.id;

        if (amendmentDocument) {
            amendment.Amendment_Document_Uploaded__c = true;
        } else {
            amendment.Amendment_Document_Uploaded__c = false;
        }

        try {
            Supporting_Agreement__c sa = (Supporting_Agreement__c)stdController.getRecord();
            if(isNewAgreement){
                insert sa;
            }
            else{
                update sa;
            }
            insert amendment;
            PageReference pf = new PageReference('/' + supportingAgreement.id);
            return pf;
        }
        catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }

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