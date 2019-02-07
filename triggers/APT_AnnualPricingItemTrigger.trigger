trigger APT_AnnualPricingItemTrigger on Annual_Pricing_Item__c (before insert, after update) {
	if(Trigger.isBefore && Trigger.isInsert){
		APT_AnnualPricingUtils.copyStandardPrice(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isUpdate){
		APT_AnnualPricingUtils.updateApprovalStatus(Trigger.newMap, Trigger.oldMap);
	}
}