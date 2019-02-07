/*====================================================
@CreatedDate : 2018-06-13
@CreatedBy : Mabhedle Tonga 
@Description : 
=====================================================*/
trigger CaseChecklistTrigger on Case_Checklist__c (After insert,after update) {

   	new CaseChecklistTriggerhandler().run();
}