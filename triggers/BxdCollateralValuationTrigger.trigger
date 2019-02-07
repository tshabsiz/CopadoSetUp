trigger BxdCollateralValuationTrigger on Collateral_Valuation__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdCollateralValuationService.createBoxFolderTrigger(Trigger.new);
        }
    }
}