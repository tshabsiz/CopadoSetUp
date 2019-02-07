trigger Deal_Party_Trigger on Deal_Party__c (after update, before insert, before delete) 
{
	if(Trigger.isAfter && Trigger.isUpdate)
	{
		Deal_Party_Helper.afterUpdate(Trigger.New, Trigger.oldMap); 
	} 

	if(Trigger.isBefore) {
       	if (Trigger.isInsert) {
			Deal_Party_Helper.beforeInsert(Trigger.new);
       	}
        
       	if(Trigger.isDelete){
            Deal_Party_Helper.beforeDelete(Trigger.old);
       	}
  	}
}