trigger ClientPlanTrigger on Client_Plan__c (before insert, after insert) {

	//before insert
	if (Trigger.isBefore && Trigger.isInsert) {
		ClientPlanTrigger_Helper.checkRightsToCreateNew(Trigger.new);
	}

    //after insert
    if (Trigger.isAfter && Trigger.isInsert) {
    	ClientPlanTrigger_Helper.shareWithAccOwnerAndAccTeam(Trigger.new, Trigger.newMap);
    }

}