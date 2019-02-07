trigger AcmCollateralTriggerAfter on Collateral__c (after insert, after update) {
    // This trigger is now obselete
    if(Trigger.newMap.size() == 0) {
        List<Collateral__c> collaterals = [SELECT Id, Name, Collateral_Group__c,Facility_Client__c, AcmFacility__c, Scope__c, Saved_To_Acm__c, Beneficiary__c, Account__c, CurrencyIsoCode, /*Collateral_Type__c,*/ Expiry_Date__c, Country__c, Signature_Date__c, Physical_Location__c,
                                           Status__c, Comments__c, Asset_Description__c, Value__c, Value_Type__c, Value_Limit__c, Asset__c,
                                           Asset_Type__c, Collateral_No__c, Document_Type__c, Document_Name__c, Document_Expiry_Date__c, Manager__c,
                                           Document_Description__c, Document_Status__c, Supporting_Documentation_Uploaded__c, 
                                           Has_Underlying_Assets__c FROM Collateral__c WHERE Id IN :Trigger.newMap.keySet()];
        
        if(Trigger.isInsert)
        {
            System.debug('Insert Trigger');
            AcmCollateralHelper.createRelationshipForCollateral(collaterals);
            AcmCollateralHelper.CreateCollateralFacilities(collaterals);
        }
        
        if(Trigger.isUpdate) {
            System.debug('Update Trigger');
            List<Collateral__c> oldCollaterals = new List<Collateral__c>();
            for(Collateral__c collateral : collaterals) {
                oldCollaterals.add(trigger.oldMap.get(collateral.Id));
            }
            
            System.debug('New Collaterals : ' + collaterals);
            System.debug('Old Collaterals : ' + oldCollaterals);
            AcmCollateralHelper.ValidateBeneficiaryAndFacility(collaterals, oldCollaterals);
            AcmCollateralHelper.updateRelationshipForCollateral(collaterals, oldCollaterals);
            AcmCollateralHelper.UpdateCollateralFacilities(collaterals, oldCollaterals);
        }
    }
}