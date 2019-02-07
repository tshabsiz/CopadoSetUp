/**
 * Created by KyleAlexander on 2018/03/14.
 */

public with sharing class MarketCollateralOverride_Cont {
    public Boolean collateralPanel {get;set;}
    public List<Market_Collateral__c> collateralItems {get; set;}
    public List<Market_Collateral__c> addedCollateral {get; set;}
    public Id addedColId {get; set;}

    public Boolean isCSA {get;set;}
    public List<Market_Collateral__c> eligibleCollateralItems {get; set;}
    public List<Market_Collateral__c> eligibleAddedCollateral {get; set;}
    public Id eligibleAddedColId {get; set;}

    public List<Market_Collateral__c> regulatoryCollateralItems {get; set;}
    public List<Market_Collateral__c> regulatoryAddedCollateral {get; set;}
    public Id regulatoryAddedColId {get; set;}

    public String retURL;
    public Id agreementId;

    public MarketCollateralOverride_Cont (ApexPages.StandardController stdController) {
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        retURL = retURL.substring(1);
        agreementId = Id.ValueOf(retURL);

        Agreement__c agreement;
        Supporting_Agreement__c suppAgreement;

        try{
            agreement = [select id, name, Agreement_Type__c from Agreement__c where id = :agreementId limit 1];
        }
        catch (Exception e){
            System.debug('Agreement is of type Supporting Agreement');
        }

        try{
            suppAgreement = [select id, name, Supporting_Agreement_Type__c from Supporting_Agreement__c where id = :agreementId limit 1];
        }
        catch (Exception e){
            System.debug('Agreement is of type Agreement');
        }

        Boolean isValid = false;

        if(agreement != null){
            collateralPanel = true;
            //Collateral
            collateralItems = new List<Market_Collateral__c>();
            addedCollateral = new List<Market_Collateral__c>();
            addedCollateral = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Market_Collateral_Type__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Agreement__c from Market_Collateral__c where Agreement__c = :agreementId AND Market_Collateral_Type__c = 'Acceptable Collateral'];

            Market_Collateral__c tempCol = new Market_Collateral__c();
            collateralItems.add(tempCol);

            isValid = true;
        }
        else if(suppAgreement != null){
            if(suppAgreement.Supporting_Agreement_Type__c == 'CSA'){
                isCSA = true;

                eligibleAddedCollateral = new List<Market_Collateral__c>();
                regulatoryAddedCollateral = new List<Market_Collateral__c>();

                eligibleCollateralItems = new List<Market_Collateral__c>();
                eligibleCollateralItems.add(new Market_Collateral__c());

                regulatoryCollateralItems = new List<Market_Collateral__c>();
                regulatoryCollateralItems.add(new Market_Collateral__c());
 
                List<Market_Collateral__c> tempCollaterals = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Market_Collateral_Type__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Supporting_Agreement__c from Market_Collateral__c where Supporting_Agreement__c = :agreementId];
                if(!tempCollaterals.isEmpty()){
                    for(Market_Collateral__c mc : tempCollaterals){
                        if(mc.Market_Collateral_Type__c == 'Eligible Collateral'){
                            eligibleAddedCollateral.add(mc);
                        }
                        if(mc.Market_Collateral_Type__c == 'Regulatory Collateral'){
                            regulatoryAddedCollateral.add(mc);
                        }
                    }
                }
             
                isValid = true;
            }
        }

        if(isValid == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Collateral is only valid for GMSLA and CSA Agreements'));
        }
    }

    public PageReference AddCollateral() {
        for(Market_Collateral__c col : collateralItems){
            if(col.Collateral_Type__c != null){
                col.Agreement__c = agreementId;
                col.Market_Collateral_Type__c = 'Acceptable Collateral';
                insert col;
                Market_Collateral__c marketCollateral = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Agreement__c from Market_Collateral__c where id = :col.id limit 1];
                addedCollateral.add(marketCollateral);
            }
            else{
                apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Acceptable Collateral Type cannot be --None--'));
                return null;
            }
        }

        collateralItems.clear();
        collateralItems.add(new Market_Collateral__c());

        return null;
    }

    public PageReference RemoveCollateral() {
        //Gets the current instance of the collateral, passed by it's dealId from the vf page
        Market_Collateral__c c = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Agreement__c from Market_Collateral__c where id = :addedColId limit 1];

        //Get the collateral to be added's index in the list and remove it from the collateral list
        //This is so the users can't remove it again
        Integer count = 0;
        if(addedCollateral.size() > 0){
            for(Market_Collateral__c col : addedCollateral){
                if(c.id == col.id){
                    break;
                }
                count++;
            }
            addedCollateral.remove(count);

            delete c;
        }
        return null;
    }

    public PageReference AddEligibleCollateral() {
        for(Market_Collateral__c col : eligibleCollateralItems){
            if(col.Collateral_Type__c != null){
                col.Supporting_Agreement__c = agreementId;
                col.Market_Collateral_Type__c = 'Eligible Collateral';
                insert col;
                Market_Collateral__c c = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Supporting_Agreement__c from Market_Collateral__c where id = :col.id limit 1];
                eligibleAddedCollateral.add(c);
            }
            else{
                apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Eligible Collateral Type cannot be --None--'));
                return null;
            }
        }

        eligibleCollateralItems.clear();
        eligibleCollateralItems.add(new Market_Collateral__c());

        return null;
    }

    public PageReference RemoveEligibleCollateral() {
        //Gets the current instance of the collateral, passed by it's dealId from the vf page
        Market_Collateral__c c = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Supporting_Agreement__c from Market_Collateral__c where id = :eligibleAddedColId limit 1];

        //Get the collateral to be added's index in the list and remove it from the collateral list
        //This is so the users can't remove it again
        Integer count = 0;
        if(eligibleAddedCollateral.size() > 0){
            for(Market_Collateral__c col : eligibleAddedCollateral){
                if(c.id == col.id){
                    break;
                }
                count++;
            }
            eligibleAddedCollateral.remove(count);

            delete c;
        }
        return null;
    }

    public PageReference AddRegulatoryCollateral() {
        for(Market_Collateral__c col : regulatoryCollateralItems){
            if(col.Collateral_Type__c != null){
                col.Supporting_Agreement__c = agreementId;
                col.Market_Collateral_Type__c = 'Regulatory Collateral';
                insert col;
                Market_Collateral__c c = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Supporting_Agreement__c from Market_Collateral__c where id = :col.id limit 1];
                regulatoryAddedCollateral.add(c);
            }
            else{
                apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Regulatory Collateral Type cannot be --None--'));
                return null;
            }
        }

        regulatoryCollateralItems.clear();
        regulatoryCollateralItems.add(new Market_Collateral__c());

        return null;
    }

    public PageReference RemoveRegulatoryCollateral() {
        //Gets the current instance of the collateral, passed by it's dealId from the vf page
        Market_Collateral__c c = [select name, id, Collateral_Type__c, Sub_Type__c, Value__c, Margin__c, Collateral_Comments__c, Currency__c, Country_of_Issue__c, Applicable_Party__c, Supporting_Agreement__c from Market_Collateral__c where id = :regulatoryAddedColId limit 1];

        //Get the collateral to be added's index in the list and remove it from the collateral list
        //This is so the users can't remove it again
        Integer count = 0;
        if(regulatoryAddedCollateral.size() > 0){
            for(Market_Collateral__c col : regulatoryAddedCollateral){
                if(c.id == col.id){
                    break;
                }
                count++;
            }
            regulatoryAddedCollateral.remove(count);

            delete c;
        }
        return null;
    }

    public PageReference CancelPage() {
        PageReference pf = new PageReference('/' + agreementId);
        return pf;
    }

    public PageReference SavePage() {
        PageReference pf = new PageReference('/' + agreementId);
        return pf;
    }
}