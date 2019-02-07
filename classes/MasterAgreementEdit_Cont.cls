/**
 * Created by Kyle Alexander on 2018/02/20.
 */

public with sharing class MasterAgreementEdit_Cont {
    public Agreement__c agreement {get;set;}

    public Boolean agreementPanel {get;set;}
    public Boolean amendmentPanel {get;set;}
    public Boolean closurePanel {get;set;}

    public Amendment__c amendment {get;set;}
    public String amendmentType {get;set;}
    public String amendmentReason {get;set;}
    public Date amendmentDate {get;set;}
    public String regulationName {get;set;}
    public Boolean amendmentDocument {get;set;}

    public Boolean isdaPanel {get;set;}
    public Boolean gmraPanel {get;set;}
    public Boolean gmslaPanel {get;set;}
    public Boolean primeServPanel {get;set;}

    public String initialAgreementStatus;

    public Boolean collateralPanel {get;set;}
    public Boolean changePanel {get;set;}

    public List<Market_Collateral__c> collateralItems {get; set;}
    public List<Market_Collateral__c> addedCollateral {get; set;}
    public Id addedColId {get; set;}
    
    public Boolean mustShowStatusWarningMessage {get; set;}
    
    public MasterAgreementEdit_Cont (ApexPages.StandardController stdController) {

        Id agreementId = ApexPages.currentPage().getParameters().get('id');
        
        agreement = [Select id, Name, RecordTypeId, Master_Agreement_Type__c, Agreement_ID__c, Master_Agreement_Start_Date__c,
                Master_Agreement_Required_Prior_to_First__c, Break_Clause_days__c, Master_Agreement_Version__c,
                ExternalAgreementId__c, Agreement_Status__c, Master_Agreement_Name__c, Matter_Deal__c, Governing_Law__c,
                Country_of_Issue__c, Cross_Default_Threshold_Re_Absa__c, Cash_Amount__c, Equity_Percentage__c,
                Cross_Default_Threshold_Re_Counterparty__c, Cash_Amount_counterparty__c, Equity_Percentage_Counterparty__c,
                Business_Unit__c, Margin_Maintenance_Amount_Absa__c, Margin_Maintenance_Own_Amount_Absa__c,
                Margin_Maintenance_Amount_Counterparty__c, Margin_Maintenance_Own_Amount_Counter__c,
                Absa_as_Borrower_Lender__c, Absa_as_Agent_Principal__c, Counterparty_as_Borrower_Lender__c,
                Counterparty_as_Agent_Principal__c, Undisclosed__c, Principal_Type__c, Termination_Currency__c, Calculation_Agent__c, Currency_Re_Absa__c,
                Currency_Re_Counterparty__c, Closure_Reason__c, Agreement_Comments__c, Bank_Minimum_Transfer_Amount__c, Counterparty_Minimum_Transfer_Amount__c,
                Bilateral_Unilateral__c, Triparty_Agent__c, Base_Currency__c, Loan_Name__c, Loan_Linked__c, Facility_Loan_Name__c, Transaction_Exposure_Calculation_Method__c, 
                Buy_Sell_Back_Applies__c, Bank__c, Relationship__c
        from Agreement__c where id = :agreementId];

        String name = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosById().get(agreement.RecordTypeId).getName();
        System.debug(name);
        System.debug(agreement);

        //Agreement Status
        initialAgreementStatus = this.agreement.Agreement_Status__c;

        //Amendment
        amendment = new Amendment__c();

        getCategories();

        agreementPanel = true;
        amendmentPanel = false;
        closurePanel = false;
        changePanel = false;

        isdaPanel = false;
        gmraPanel = false;
        gmslaPanel = false;
        primeServPanel = false;
        
        mustShowStatusWarningMessage = false;

        if(agreement.Master_Agreement_Type__c == 'ISDA Agreement'){
            isdaPanel = true;
            advpm__Matter__c m = [select id, Relationship_Type_picklist__c, Netting_Complete__c from advpm__Matter__c where id = :agreement.Matter_Deal__c limit 1];
            if(m.Netting_Complete__c == false && (m.Relationship_Type_picklist__c == 'Collective Investment Scheme Manager' || m.Relationship_Type_picklist__c == 'Asset Manager')){
                mustShowStatusWarningMessage = true;
            }
        }
        else if(agreement.Master_Agreement_Type__c == 'GMRA Agreement'){
            gmraPanel = true;
        }
        else if(agreement.Master_Agreement_Type__c == 'GMSLA Agreement'){
            gmslaPanel = true;
        }
        else if(agreement.Master_Agreement_Type__c == 'Prime Services Agreement'){
            primeServPanel = true;
        }
    }

    public PageReference CancelPage() {
        PageReference pf = new PageReference('/' + agreement.id);
        return pf;
    }

    public PageReference SaveAgreement() {
        Boolean mustBeAmended = false;

        if(!(agreement.Master_Agreement_Required_Prior_to_First__c)){
            if(agreement.Break_Clause_days__c == null){
                apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'If Master Agreement Required Prior to First is selected, you have to enter a value for Break Clause (days)'));
                return null;
            }
        }

        /*Check if it must be ameneded*/
        if(agreement.Agreement_Status__c == 'Amended')
        {
            mustBeAmended = true;
        }
        else if(initialAgreementStatus == 'Confirmed/Completed' || initialAgreementStatus == 'Amended'){
            if(agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended'){
                mustBeAmended = true;
            }
            else{
                mustBeAmended = false;
            }
        }
        else{
            mustBeAmended = false;
        }

        /*Check if change panel must be shown*/
        if(initialAgreementStatus == 'Cancelled/Terminated'){
            if(agreement.Agreement_Status__c != 'Cancelled/Terminated'){
                agreementPanel = false;
                amendmentPanel = false;

                isdaPanel = false;
                gmraPanel = false;
                gmslaPanel = false;
                collateralPanel = false;
                closurePanel = false;

                changePanel = true;

                return null;
            }
        }
        /*Check if it must be closed*/
        if(agreement.Agreement_Status__c == 'Cancelled/Terminated'){
            agreementPanel = false;
            amendmentPanel = false;

            isdaPanel = false;
            gmraPanel = false;
            gmslaPanel = false;
            collateralPanel = false;

            closurePanel = true;

            return null;
        }
        else{
            if(mustBeAmended){
                agreementPanel = false;
                amendmentPanel = true;

                isdaPanel = false;
                gmraPanel = false;
                gmslaPanel = false;
                collateralPanel = false;

                closurePanel = false;

                return null;
            }
            else{
                try
                {
                    update agreement;
                    PageReference pf = new PageReference('/' + agreement.id);
                    return pf;
                }
                catch(Exception ex){
                    ApexPages.addMessages(ex);
                    return null;
                }

                
            }
        }
    }

    public PageReference CancelAmendment() {
        PageReference pf = new PageReference('/' + agreement.id);
        return pf;
    }

    public PageReference SaveAmendment() {
        amendment.Amendment_Reason__c = amendmentReason;
        amendment.Amendment_Reason_Type__c = amendmentType;
        amendment.Effective_date__c = amendmentDate;
        amendment.Name_of_Regulation__c = regulationName;
        amendment.Agreement__c = agreement.id;

        if (amendmentDocument) {
            amendment.Amendment_Document_Uploaded__c = true;
            agreement.Agreement_Status__c = 'Amended';
        } else {
            amendment.Amendment_Document_Uploaded__c = false;
        }

        try {
            update agreement;
            insert amendment;
        }
        catch(exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        PageReference pr = new PageReference('/' + agreement.id);
        pr.setRedirect(true);
        return pr;
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

    public PageReference CancelClosure() {
        PageReference pf = new PageReference('/' + agreement.id);
        return pf;
    }

    public PageReference SaveClosure() {
        try {
            update agreement;
        }
        catch(DMLException e) {
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There was an issue creating the closure please try again or contact a system administrator :' + e.getMessage()));
            return null;
        }

        PageReference pr = new PageReference('/' + agreement.id);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference CancelChange() {
        PageReference pf = new PageReference('/' + agreement.id);
        return pf;
    }
    
    public PageReference SaveChange() {
        try {
            update agreement;
        }
        catch(DMLException e) {
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There was an issue creating the change please try again or contact a system administrator :' + e.getMessage()));
            return null;
        }

        PageReference pr = new PageReference('/' + agreement.id);
        pr.setRedirect(true);
        return pr;
    }
}