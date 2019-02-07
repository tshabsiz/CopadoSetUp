trigger BxdMatter_Spend_Trigger on Matter_Spend_Document__c (after insert, after update) {    
    //After Insert
	if(Trigger.isAfter && Trigger.isInsert)
	{
		BxdMatterSpendDocumentService.createBoxFolderTrigger(Trigger.new);
	}
	//After Insert End

	//After Update
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		BxdMatterSpendDocumentService.afterUpdateBox(Trigger.new, Trigger.oldMap); 
	}
	//After Update End
}