trigger AgendaTrigger on Agenda__c (before insert, after insert, before update, after update) {

	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		for(Agenda__c agenda : Trigger.new){
			agenda.Name = agenda.Order__c + ' ' + agenda.Description__c;
		}
	}

	if(Trigger.isAfter && Trigger.isInsert){
		CollaborationSharingUtils.shareAgendasWithAttendees(Trigger.new);
		CollaborationSharingUtils.shareAgendasWithPresenter(Trigger.new);
	}

	if(Trigger.isAfter && Trigger.isUpdate){
		CollaborationSharingUtils.updateSharingForAgendaPresenter(Trigger.oldMap, Trigger.newMap);
	}
}