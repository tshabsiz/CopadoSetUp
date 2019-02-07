public class ActionTrigger_Helper {

	public static void copyActionOwner(List<Action__c> actions){
		for(Action__c action : actions){
			action.OwnerId = action.Action_Owner__c;
		}
	}

	public static void updateFieldsBeforeInsert(List<Action__c> actions){
		Set<Id> meetingIds = new Set<Id>();
		Set<Id> sectionIds = new Set<Id>();
		List<Action__c> meetingActions = new List<Action__c>();
		List<Action__c> initiativeActions = new List<Action__c>();
		for(Action__c action : actions){
			if(String.isNotBlank(action.Meeting__c)){
				meetingActions.add(action);
				meetingIds.add(action.Meeting__c);
			} else if(String.isNotBlank(action.Section__c)){
				initiativeActions.add(action);
				sectionIds.add(action.Section__c);
			}
		}
		if(!meetingActions.isEmpty()){
			assignRelatedCommittee(meetingActions, meetingIds);
		}
		if(!initiativeActions.isEmpty()){
			assignRelatedInitiative(initiativeActions, sectionIds);
		}
	}

	public static void updateFieldsBeforeUpdate(Map<Id, Action__c> oldActions, Map<Id, Action__c> newActions){
		Set<Id> meetingIds = new Set<Id>();
		Set<Id> sectionIds = new Set<Id>();
		List<Action__c> meetingActions = new List<Action__c>();
		List<Action__c> initiativeActions = new List<Action__c>();
		for(Id actionId : newActions.keySet()){
			if(String.isNotBlank(newActions.get(actionId).Meeting__c) && newActions.get(actionId).Meeting__c != oldActions.get(actionId).Meeting__c){
				meetingActions.add(newActions.get(actionId));
				meetingIds.add(newActions.get(actionId).Meeting__c);
			} else if(String.isNotBlank(newActions.get(actionId).Section__c) && newActions.get(actionId).Section__c != oldActions.get(actionId).Section__c){
				initiativeActions.add(newActions.get(actionId));
				sectionIds.add(newActions.get(actionId).Section__c);
			}
		}
		if(!meetingActions.isEmpty()){
			assignRelatedCommittee(meetingActions, meetingIds);
		}
		if(!initiativeActions.isEmpty()){
			assignRelatedInitiative(initiativeActions, sectionIds);
		}
	}

	public static void assignActionToOwner(List<Action__c> actions){
		List<Action_Assignment__c> assignments = new List<Action_Assignment__c>();
		for(Action__c action : actions){
			assignments.add(new Action_Assignment__c(Action__c=action.Id,Assigned_to__c=action.OwnerId));
		}
		Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.insert(assignments, dml);
	}

	public static void followActionByCreator(List<Action__c> actions){
		List<Action_Follower__c> actionFollowers = new List<Action_Follower__c>();
		for(Action__c action : actions){
			if(action.CreatedById != action.OwnerId){
				actionFollowers.add(new Action_Follower__c(Action__c=action.Id,Follower__c=action.CreatedById));
			}
		}
		Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.insert(actionFollowers, dml);
	}

	public static void followActionByCreator(Map<Id, Action__c> oldActions, Map<Id, Action__c> newActions){
		List<Action_Follower__c> actionFollowers = new List<Action_Follower__c>();
		for(Id actionId : newActions.keySet()){
			if(newActions.get(actionId).OwnerId != oldActions.get(actionId).OwnerId && newActions.get(actionId).CreatedById != newActions.get(actionId).OwnerId){
				actionFollowers.add(new Action_Follower__c(Action__c=actionId,Follower__c=newActions.get(actionId).CreatedById));
			}
		}
		Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.insert(actionFollowers, dml);
	}
	
	public static void assignRelatedCommittee(List<Action__c> actions, Set<Id> meetingIds){
		Map<Id, Meeting__c> mapMeetings = new Map<Id, Meeting__c>([SELECT Id, Committee__c FROM Meeting__c WHERE Id IN :meetingIds]);
		for(Action__c action : actions){
			if(mapMeetings.containsKey(action.Meeting__c)){
				action.Committee__c = mapMeetings.get(action.Meeting__c).Committee__c;
			}
		}
	}

	public static void assignRelatedInitiative(List<Action__c> actions, Set<Id> sectionIds){
		Map<Id, Section__c> mapSections = new Map<Id, Section__c>([SELECT Id, Initiative__c FROM Section__c WHERE Id IN :sectionIds]);
		for(Action__c action : actions){
			if(mapSections.containsKey(action.Section__c)){
				action.Initiative__c = mapSections.get(action.Section__c).Initiative__c;
			}
		}
	}
}