trigger AccountTrigger on Account (before insert, after insert, before update, after update) {

	// before insert
    if(trigger.isBefore && trigger.isInsert){
		AccountTrigger_Helper.updateAccountSegment(Trigger.new, null);
    }

	// after insert
    if(trigger.isAfter && trigger.isInsert){
    	//SF2SFConnectionHandler.newAccountShare(trigger.new);
    }

    // after update
    if(trigger.isAfter && trigger.isUpdate){
        AccountTrigger_Helper.checkOpportunityCallReportShareParentChange(Trigger.NewMap,Trigger.oldmap);
		AccountTrigger_Helper.updateOpportunitySegmentAndIndustry(Trigger.new, Trigger.oldMap);
        AccountTrigger_Helper.updateClientPlanSharing(Trigger.new, Trigger.oldMap);
        AccountTrigger_Helper.updateOpportunityRelationshipOwnerRole(Trigger.new, Trigger.oldMap);
    }

    // before update
    if(trigger.isBefore && trigger.isUpdate){
        AccountTrigger_Helper.checkOpportunityCallReportShareOwnerChange(Trigger.NewMap,Trigger.oldmap);
		AccountTrigger_Helper.updateAccountSegment(Trigger.new, Trigger.oldMap);
    }

}