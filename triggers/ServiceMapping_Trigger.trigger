/**
* Date   : 2016-12-20
* Author : RN - CloudSmiths
* Desc   : Controller that links complaint type cases to existing cases
**/
trigger ServiceMapping_Trigger on Service_Mapping__c (before insert, before update) {
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
         ServiceMapping_Trigger_Methods.validateData(trigger.new);
    }
}