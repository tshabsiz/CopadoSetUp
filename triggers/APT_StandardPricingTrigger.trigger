trigger APT_StandardPricingTrigger on Standard_Pricing__c (before insert, before update, before delete) {

	if(Trigger.isBefore && Trigger.isInsert){
		APT_AnnualPricingUtils.validateStandardPricingBeforeInsert(Trigger.new);
	}

	if(Trigger.isBefore && Trigger.isUpdate){
		APT_AnnualPricingUtils.validateStandardPricingBeforeUpdate(Trigger.new);
	}

	if(Trigger.isBefore && Trigger.isDelete){
		APT_AnnualPricingUtils.validateStandardPricingBeforeDelete(Trigger.old);
	}
}