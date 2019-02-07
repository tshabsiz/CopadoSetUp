trigger BxdMatterSpendScheduleTrigger on Matter_Spend_Schedule__c (after insert) {
    //After Insert
	if(Trigger.isAfter && Trigger.isInsert)
	{
		BxdMatterSpendScheduleService.createBoxFolderTrigger(Trigger.new);
	}
	//After Insert End
}