/**
 * Created by KyleAlexander on 2018/03/05.
 */

public with sharing class SupportingAgreementDealsRelatedList_Cont {

    public Supporting_Agreement__c supportingAgreement {get;set;}
    public Id supportingAgreementId {get;set;}
    public List<Deal_Party__c> dealParties {get;set;}
    public List<Deal_Party__c> addedDealParties {get;set;}
    public id dealId {get;set;}
    public Boolean changesMade {get;set;}
    public Boolean mustBeAmended {get;set;}

    public Amendment__c amendment {get;set;}
    public String amendmentType {get;set;}
    public String amendmentReason {get;set;}
    public Date amendmentDate {get;set;}
    public String regulationName {get;set;}
    public Boolean amendmentDocument {get;set;}

    public Agreement__c agreement {get;set;}

    public Boolean dealsPanel {get;set;}
    public Boolean amendmentPanel {get;set;}

    public SupportingAgreementDealsRelatedList_Cont(ApexPages.StandardController controller) {
        changesMade = false;
        addedDealParties = new List<Deal_Party__c>();
        dealParties = new List<Deal_Party__c>();
        populateDealsList();

        amendment = new Amendment__c();

        getCategories();

        dealsPanel = true;
        amendmentPanel = false;
    }

    public void populateDealsList(){
        supportingAgreementId = ApexPages.currentPage().getParameters().get('id');
        supportingAgreement = [select id, Agreement__c, Supporting_Agreement_Type__c from Supporting_Agreement__c where id = :supportingAgreementId limit 1];

        //Gets all added deal parties for this supporting agreement
        addedDealParties = [select name, Relationship_SDS_ID__c, Relationship_Type__c, id, Deal__c, Supporting_Agreement__c from Deal_Party__c where Supporting_Agreement__c = :supportingAgreementId];

        //It should show only supporting agreements of type CSA and CSD
        if(supportingAgreement.Supporting_Agreement_Type__c == 'CSA' || supportingAgreement.Supporting_Agreement_Type__c == 'CSD'){
            //Since the deal parties are on the matter level, we need to get the agreement from the supporting agreement and then the matter from that (MATTER -> AGREEMENT -> SUPPORTING AGREEMENT)
            agreement = [select id, Matter_Deal__c, Agreement_Status__c from Agreement__c where id = :supportingAgreement.Agreement__c limit 1];

            if(agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended') {
                mustBeAmended = true;
            }
            else{
                mustBeAmended = false;
            }

            advpm__Matter__c matter = [select id from advpm__Matter__c where id = :agreement.Matter_Deal__c limit 1];

            //Gets all the deals on that specific Matter where the relationship type for the deal has been set to 'Disclosed principal'
            List<Deal_Party__c> allDeals = [select name, Relationship_SDS_ID__c, Relationship_Type__c, id, Deal__c, Supporting_Agreement__c from Deal_Party__c where Deal__c = :matter.id and Relationship_Type__c = 'Disclosed Principal'];

            //If there are deal parties that have been added then check if the added deals don't contain the current instance of all of the deals and then add it to the deal parties for the users to add
            //This checks for duplicates and doesn't add them if they've already been added
            //Else add all the deals to the deal parties list so that the users can add them
            if(!addedDealParties.isEmpty()) {
                if (!allDeals.isEmpty()) {
                    for (Integer i = 0; i < allDeals.size(); i++) {
                        if (!addedDealParties.contains(allDeals.get(i))) {
                            dealParties.add(allDeals.get(i));
                        }
                    }
                }
            }
            else{
                dealParties.addAll(allDeals);
            }
        }
    }

    public void updateDealParties(){
        List<Deal_Party__c> existingDealParties = [select name, Relationship_SDS_ID__c, Relationship_Type__c, id, Deal__c, Supporting_Agreement__c from Deal_Party__c where Supporting_Agreement__c = :supportingAgreementId];

        for (Deal_Party__c adp : addedDealParties) {
            if (!existingDealParties.contains(adp)) {
                //Add the supporting agreement to the deal and update it
                adp.Supporting_Agreement__c = supportingAgreementId;
                update adp;
            }
        }

        for (Deal_Party__c dp : dealParties) {
            if (existingDealParties.contains(dp)) {
                //Get the deal party to remove and set the deal parties supporting agreement to null
                dp.Supporting_Agreement__c = null;
                update dp;
            }
        }
    }

    public PageReference submitChanges(){
        if(mustBeAmended) {
            dealsPanel = false;
            amendmentPanel = true;
        }
        else{
            updateDealParties();
        }

        return null;
    }

    public void addDeal(){
        changesMade = true;

        //Gets the current instance of the deal party, passed by it's dealId from the vf page
        Deal_Party__c dealParty = [select name, Relationship_SDS_ID__c, Relationship_Type__c, id, Deal__c, Supporting_Agreement__c from Deal_Party__c where id = :dealId limit 1];
        //Add it to the added list
        addedDealParties.add(dealParty);

        //Get the deal to be added's index in the list and remove it from the deal parties list
        //This is so the users can't add it again
        Integer count = 0;
        for(Deal_Party__c dParty : dealParties){
            if(dParty.id == dealParty.id){
                break;
            }
            count++;
        }
        if(dealParties.size() > 0){
            try{
                dealParties.remove(count);
            }
            catch(Exception e){
                System.debug('Error removing deal party: ' + e.getMessage());
            }
        }
    }

    public void removeDeal(){
        changesMade = true;

        //Gets the current instance of the deal party, passed by it's dealId from the vf page
        Deal_Party__c dealParty = [select name, Relationship_SDS_ID__c, Relationship_Type__c, id, Deal__c, Supporting_Agreement__c from Deal_Party__c where id = :dealId limit 1];

        //Get the deal to be added's index in the list and remove it from the added parties list
        //This is so the users can't remove it again
        Integer count = 0;
        for(Deal_Party__c dParty : addedDealParties){
            if(dParty.id == dealParty.id){
                break;
            }
            count++;
        }
        addedDealParties.remove(count);
        //It is then added back to the deal party list so a user can add it again later if they choose to
        dealParties.add(dealParty);
    }

    public PageReference CancelAmendment() {
        PageReference pf = new PageReference('/' + supportingAgreementId);
        return pf;
    }

    public PageReference SaveAmendment() {
        amendment.Amendment_Reason__c = amendmentReason;
        amendment.Amendment_Reason_Type__c = amendmentType;
        amendment.Effective_date__c = amendmentDate;
        amendment.Name_of_Regulation__c = regulationName;
        amendment.Supporting_Agreement__c = supportingAgreementId;

        if (amendmentDocument) {
            amendment.Amendment_Document_Uploaded__c = true;
        } else {
            amendment.Amendment_Document_Uploaded__c = false;
        }

        try {
            updateDealParties();
            insert amendment;
        }
        catch(exception e) {
            ApexPages.addMessages(e);
            return null;
        }

        dealsPanel = true;
        amendmentPanel = false;

        changesMade = false;

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