/**
* Author : Rudolf Niehaus
* Date   : 2017-08-09
* Desc   : The default trigger for Event_Team_Member__c records
**/
trigger evEventMemberTrigger on Event_Team_Member__c (before insert) {
    
    if(trigger.isInsert && trigger.isBefore){
        //validate member duplication
        evEventMemberTriggerFunctions.blockDuplicateMembers(trigger.new);
    }
}