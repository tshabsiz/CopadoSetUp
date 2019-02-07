trigger MartixLeadTrigger on Matrix_Lead__c (before insert, before update, after update) {

	if(Trigger.isBefore && Trigger.isInsert){
		MatrixLeadTriggerHelper.setStatusOpenAndAssignToQueue(Trigger.new);
	}

	if(Trigger.isBefore && Trigger.isUpdate){
		MatrixLeadTriggerHelper.validateIfNewOwnerHasUpTo5OpenLeads(Trigger.oldMap, Trigger.newMap);
		MatrixLeadTriggerHelper.setSectorHeadEmail(Trigger.oldMap, Trigger.newMap);
		MatrixLeadTriggerHelper.setContactedAndConversionDates(Trigger.oldMap, Trigger.newMap);
	}

	if(Trigger.isAfter && Trigger.isUpdate){
		MatrixLeadTriggerHelper.assignMatrixLeadOwnersWithinTheSameCompany(Trigger.oldMap, Trigger.newMap);
		MatrixLeadTriggerHelper.assignMatrixLeadStatusesWithinTheSameCompany(Trigger.oldMap, Trigger.newMap);
		MatrixLeadTriggerHelper.setCommentsWithinTheSameCompany(Trigger.oldMap, Trigger.newMap);
		MatrixLeadTriggerHelper.setConversionDeadlineWithinTheSameCompany(Trigger.oldMap, Trigger.newMap);
		MatrixLeadTriggerHelper.setReasonForUnqualifiedWithinTheSameCompany(Trigger.oldMap, Trigger.newMap);
	}
}