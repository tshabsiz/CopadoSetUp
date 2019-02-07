trigger DrawdownsTrigger on Drawdowns__c (after insert, after update, after delete) {
	// after insert
    if(trigger.isAfter && trigger.isInsert){
    	DrawdownsTrigger_Helper.UpdateFirstDrawdown(trigger.New, Trigger.Old, Trigger.oldMap);    
    }

    //after update
    if(trigger.isAfter && trigger.isUpdate){
    	DrawdownsTrigger_Helper.UpdateFirstDrawdown(trigger.New, Trigger.Old, Trigger.oldMap);
    }

    // after delete
    if(trigger.isAfter && trigger.isDelete){
        DrawdownsTrigger_Helper.UpdateFirstDrawdown(trigger.New, Trigger.Old, Trigger.oldMap);
    }
}