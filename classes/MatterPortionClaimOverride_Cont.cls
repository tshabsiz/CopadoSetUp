public class MatterPortionClaimOverride_Cont {

    public List<Business_Unit_Claim__c> addedBusinessUnitClaims { get; set; }
    public Id MatterId { get; set; }
    public Id claimId { get; set; }
    public Business_Unit_Claim__c addBusinessUnitClaims { get; set; }
    public Boolean showClaimButton { get; set; }
    public Decimal claimTotal { get; set; }

    public MatterPortionClaimOverride_Cont(ApexPages.StandardController stdController) {
        MatterId = ApexPages.currentPage().getParameters().get('id');
        addedBusinessUnitClaims = [select id, Cluster_Function__c, Segment__c, Business_Unit__c, Portion_of_Claim__c, Matter__c from Business_Unit_Claim__c where Matter__c = :MatterId];
        showClaimButton = true;
    }

    public Decimal CheckClaimTotal() {
        Decimal count = 0;
        for (Business_Unit_Claim__c bu : addedBusinessUnitClaims) {
            count += bu.Portion_of_Claim__c;
        }
        claimTotal = count;
        return count;
    }

    public PageReference save() {
        Decimal newTotalClaim = CheckClaimTotal() + addBusinessUnitClaims.Portion_of_Claim__c;
        if (newTotalClaim == 100) {
            addBusinessUnitClaims.Matter__c = MatterId;
            insert addBusinessUnitClaims;
            addedBusinessUnitClaims.add(addBusinessUnitClaims);
            showClaimButton = true;

            try {
                update addedBusinessUnitClaims;
            } catch (Exception e) {
                apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Error adding business units: ' + e));
            }
        } else {
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Total Portions of Claim must add up to 100. Please amend the Added Claims before a new Business Unit'));
        }
        return null;
    }

    public PageReference removeClaim() {
        Business_Unit_Claim__c busUnit = [select id, Cluster_Function__c, Segment__c, Business_Unit__c, Portion_of_Claim__c, Matter__c from Business_Unit_Claim__c where id = :claimId];

        Integer count = 0;
        for (Business_Unit_Claim__c bu : addedBusinessUnitClaims) {
            if (bu.id == busUnit.id) {
                break;
            }
            count++;
        }
        delete busUnit;
        addedBusinessUnitClaims.remove(count);

        //Adding rest of portions to claims
        Decimal newTotal = 100 - CheckClaimTotal();
        Integer numBusUnits = 0;
        for (Business_Unit_Claim__c bu : addedBusinessUnitClaims) {
            numBusUnits++;
        }

        Decimal amountToAddToEachClaim = newTotal / numBusUnits;
        for (Business_Unit_Claim__c bu : addedBusinessUnitClaims) {
            bu.Portion_of_Claim__c += amountToAddToEachClaim;
        }

        update addedBusinessUnitClaims;

        return null;
    }

    public PageReference addClaimButton() {
        addBusinessUnitClaims = new Business_Unit_Claim__c();
        showClaimButton = false;
        return null;
    }

    public PageReference updateClaims() {
        Decimal totalClaim = CheckClaimTotal();
        if (totalClaim == 100) {
            update addedBusinessUnitClaims;
        } else {
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Total Portions of Claim must add up to 100'));
        }
        return null;
    }
}