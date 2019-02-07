public class CollaborationSharingUtils {

	public static String AL_READ = 'Read';
	public static String AL_EDIT = 'Edit';
	public static String SR_COMMITTEE_MEMBER = 'Committee_Member__c'; 				//Apex Sharing Reason for Committee
	public static String SR_COMMITTEE_FOLLOWER = 'Committee_Follower__c'; 			//Apex Sharing Reason for Committee
	public static String SR_MEETING_ATTENDEE = 'Meeting_Attendee__c'; 				//Apex Sharing Reason for Meeting and Agenda
	public static String SR_MEETING_FOLLOWER = 'Meeting_Follower__c'; 				//Apex Sharing Reason for Meeting
	public static String SR_PRESENTER = 'Presenter__c';								//Apex Sharing Reason for Agenda
	public static String SR_INITIATIVE_TEAM_MEMBER = 'Initiative_Team_Member__c'; 	//Apex Sharing Reason for Initiative
	public static String SR_INITIATIVE_FOLLOWER = 'Initiative_Follower__c'; 		//Apex Sharing Reason for Initiative
	public static String SR_ACTION_ASSIGNMENT = 'Action_Assignment__c'; 			//Apex Sharing Reason for Action
	public static String SR_ACTION_FOLLOWER = 'Action_Follower__c'; 				//Apex Sharing Reason for Action

	public static void shareCommitteesWithMembers(List<Committee_Member__c> committeeMembers){
		List<Committee__Share> committeeSharing = new List<Committee__Share>();
		for(Committee_Member__c committeeMember : committeeMembers){
			Committee__Share committeeShare = createCommitteeShare(committeeMember.Committee__c, committeeMember.Committee_Member__c, SR_COMMITTEE_MEMBER, AL_EDIT);
			committeeSharing.add(committeeShare);
		}

		insertRecords(committeeSharing);
	}

	public static void shareCommitteesWithFollowers(List<Committee_Follower__c> committeeFollowers){
		List<Committee__Share> committeeSharing = new List<Committee__Share>();
		for(Committee_Follower__c committeeFollower : committeeFollowers){
			Committee__Share committeeShare = createCommitteeShare(committeeFollower.Committee__c, committeeFollower.Follower__c, SR_COMMITTEE_FOLLOWER, AL_READ);
			committeeSharing.add(committeeShare);
		}

		insertRecords(committeeSharing);
	}

	public static void shareMeetingsWithAttendees(List<Meeting_Attendee__c> meetingAttendees){
		List<Meeting__Share> meetingSharing = new List<Meeting__Share>();
		for(Meeting_Attendee__c meetingAttendee : meetingAttendees){
			Meeting__Share meetingShare = createMeetingShare(meetingAttendee.Meeting__c, meetingAttendee.Attendee__c, SR_MEETING_ATTENDEE, AL_EDIT);
			meetingSharing.add(meetingShare);
		}

		insertRecords(meetingSharing);
	}

	public static void shareAgendasWithAttendees(List<Meeting_Attendee__c> meetingAttendees){
		Map<Id, Set<Id>> mapMeetingAttendees = new Map<Id, Set<Id>>();
		for(Meeting_Attendee__c meetingAttendee : meetingAttendees){
			if(mapMeetingAttendees.containsKey(meetingAttendee.Meeting__c)){
				mapMeetingAttendees.get(meetingAttendee.Meeting__c).add(meetingAttendee.Attendee__c);
			} else{
				mapMeetingAttendees.put(meetingAttendee.Meeting__c, new Set<Id>{meetingAttendee.Attendee__c});
			}
		}

		List<Agenda__Share> agendaSharing = new List<Agenda__Share>();
		for(Agenda__c agenda : [SELECT Id, Meeting__c FROM Agenda__c WHERE Meeting__c IN :mapMeetingAttendees.keySet()]){
			for(Id attendeeId : mapMeetingAttendees.get(agenda.Meeting__c)){
				Agenda__Share agendaShare = createAgendaShare(agenda.Id, attendeeId, SR_MEETING_ATTENDEE, AL_EDIT);
				agendaSharing.add(agendaShare);
			}
		}

		insertRecords(agendaSharing);
	}

	public static void shareAgendasWithAttendees(List<Agenda__c> agendas){
		Map<Id, Set<Id>> mapMeetingAgendas = new Map<Id, Set<Id>>();
		for(Agenda__c agenda : agendas){
			if(mapMeetingAgendas.containsKey(agenda.Meeting__c)){
				mapMeetingAgendas.get(agenda.Meeting__c).add(agenda.Id);
			} else{
				mapMeetingAgendas.put(agenda.Meeting__c, new Set<Id>{agenda.Id});
			}
		}

		List<Agenda__Share> agendaSharing = new List<Agenda__Share>();
		for(Meeting_Attendee__c meetingAttendee : [SELECT Attendee__c, Meeting__c FROM Meeting_Attendee__c WHERE Meeting__c IN :mapMeetingAgendas.keySet()]){
			for(Id agendaId : mapMeetingAgendas.get(meetingAttendee.Meeting__c)){
				Agenda__Share agendaShare = createAgendaShare(agendaId, meetingAttendee.Attendee__c, SR_MEETING_ATTENDEE, AL_EDIT);
				agendaSharing.add(agendaShare);
			}
		}

		insertRecords(agendaSharing);
	}

	public static void shareMeetingsWithFollowers(List<Meeting_Follower__c> meetingFollowers){
		List<Meeting__Share> meetingSharing = new List<Meeting__Share>();
		for(Meeting_Follower__c meetingFollower : meetingFollowers){
			Meeting__Share meetingShare = createMeetingShare(meetingFollower.Meeting__c, meetingFollower.Follower__c, SR_MEETING_FOLLOWER, AL_READ);
			meetingSharing.add(meetingShare);
		}

		insertRecords(meetingSharing);
	}

	public static void shareAgendasWithPresenter(List<Agenda__c> agendas){
		List<Agenda__Share> agendaSharing = new List<Agenda__Share>();
		for(Agenda__c agenda : agendas){
			if(String.isNotBlank(agenda.Presenter__c)){
				Agenda__Share agendaShare = createAgendaShare(agenda.Id, agenda.Presenter__c, SR_PRESENTER, AL_EDIT);
				agendaSharing.add(agendaShare);
			}
		}

		insertRecords(agendaSharing);
	}

	public static void shareInitiativesWithTeamMembers(List<Initiative_Team_Member__c> initiativeTeamMembers){
		List<Initiative__Share> initiativeSharing = new List<Initiative__Share>();
		for(Initiative_Team_Member__c initiativeTeamMember : initiativeTeamMembers){
			Initiative__Share initiativeShare = createInitiativeShare(initiativeTeamMember.Initiative__c, initiativeTeamMember.Team_member__c, SR_INITIATIVE_TEAM_MEMBER, AL_EDIT);
			initiativeSharing.add(initiativeShare);
		}

		insertRecords(initiativeSharing);
	}

	public static void shareInitiativesWithFollowers(List<Initiative_Follower__c> initiativeFollowers){
		List<Initiative__Share> initiativeSharing = new List<Initiative__Share>();
		for(Initiative_Follower__c initiativeFollower : initiativeFollowers){
			Initiative__Share initiativeShare = createInitiativeShare(initiativeFollower.Initiative__c, initiativeFollower.Follower__c, SR_INITIATIVE_FOLLOWER, AL_READ);
			initiativeSharing.add(initiativeShare);
		}

		insertRecords(initiativeSharing);
	}

	public static void shareActionsWithAssignedUsers(List<Action_Assignment__c> actionAssignments){
		List<Action__Share> actionSharing = new List<Action__Share>();
		for(Action_Assignment__c actionAssignment : actionAssignments){
			Action__Share actionShare = createActionShare(actionAssignment.Action__c, actionAssignment.Assigned_to__c, SR_ACTION_ASSIGNMENT, AL_EDIT);
			actionSharing.add(actionShare);
		}

		insertRecords(actionSharing);
	}

	public static void shareActionsWithFollowers(List<Action_Follower__c> actionFollowers){
		List<Action__Share> actionSharing = new List<Action__Share>();
		for(Action_Follower__c actionFollower : actionFollowers){
			Action__Share actionShare = createActionShare(actionFollower.Action__c, actionFollower.Follower__c, SR_ACTION_FOLLOWER, AL_READ);
			actionSharing.add(actionShare);
		}

		insertRecords(actionSharing);
	}

	public static void stopSharingCommitteesWithMembers(List<Committee_Member__c> committeeMembers){
		Set<Id> committeeIds = new Set<Id>();
		for(Committee_Member__c committeeMember : committeeMembers){
			committeeIds.add(committeeMember.Committee__c);
		}
		Map<Id, Map<Id, Committee__Share>> mapCommitteeSharings = createCommitteeSharingsMap(committeeIds, SR_COMMITTEE_MEMBER);

		List<Committee__Share> committeeSharingToDel = new List<Committee__Share>();
		for(Committee_Member__c committeeMember : committeeMembers){
			if(mapCommitteeSharings.containsKey(committeeMember.Committee__c)){
				if(mapCommitteeSharings.get(committeeMember.Committee__c).containsKey(committeeMember.Committee_Member__c)){
					committeeSharingToDel.add(mapCommitteeSharings.get(committeeMember.Committee__c).get(committeeMember.Committee_Member__c));
				}
			}
		}

		delete committeeSharingToDel;
	}

	public static void stopSharingCommitteesWithFollowers(List<Committee_Follower__c> committeeFollowers){
		Set<Id> committeeIds = new Set<Id>();
		for(Committee_Follower__c committeeFollower : committeeFollowers){
			committeeIds.add(committeeFollower.Committee__c);
		}
		Map<Id, Map<Id, Committee__Share>> mapCommitteeSharings = createCommitteeSharingsMap(committeeIds, SR_COMMITTEE_FOLLOWER);

		List<Committee__Share> committeeSharingToDel = new List<Committee__Share>();
		for(Committee_Follower__c committeeFollower : committeeFollowers){
			if(mapCommitteeSharings.containsKey(committeeFollower.Committee__c)){
				if(mapCommitteeSharings.get(committeeFollower.Committee__c).containsKey(committeeFollower.Follower__c)){
					committeeSharingToDel.add(mapCommitteeSharings.get(committeeFollower.Committee__c).get(committeeFollower.Follower__c));
				}
			}
		}

		delete committeeSharingToDel;
	}

	public static void stopSharingMeetingsWithAttendees(List<Meeting_Attendee__c> meetingAttendees){
		Set<Id> meetingIds = new Set<Id>();
		for(Meeting_Attendee__c meetingAttendee : meetingAttendees){
			meetingIds.add(meetingAttendee.Meeting__c);
		}
		Map<Id, Map<Id, Meeting__Share>> mapMeetingSharings = createMeetingSharingsMap(meetingIds, SR_MEETING_ATTENDEE);
		List<Meeting__Share> meetingSharingToDel = new List<Meeting__Share>();

		for(Meeting_Attendee__c meetingAttendee : meetingAttendees){
			if(mapMeetingSharings.containsKey(meetingAttendee.Meeting__c)){
				if(mapMeetingSharings.get(meetingAttendee.Meeting__c).containsKey(meetingAttendee.Attendee__c)){
					meetingSharingToDel.add(mapMeetingSharings.get(meetingAttendee.Meeting__c).get(meetingAttendee.Attendee__c));
				}
			}
		}

		delete meetingSharingToDel;
	}

	public static void stopSharingAgendasWithAttendees(List<Meeting_Attendee__c> meetingAttendees){
		Map<Id, Set<Id>> mapMeetingAttendees = new Map<Id, Set<Id>>();
		for(Meeting_Attendee__c meetingAttendee : meetingAttendees){
			if(mapMeetingAttendees.containsKey(meetingAttendee.Meeting__c)){
				mapMeetingAttendees.get(meetingAttendee.Meeting__c).add(meetingAttendee.Attendee__c);
			} else{
				mapMeetingAttendees.put(meetingAttendee.Meeting__c, new Set<Id>{meetingAttendee.Attendee__c});
			}
		}

		Map<Id, Set<Id>> mapAgendaAttendees = new Map<Id, Set<Id>>();
		for(Agenda__c agenda : [SELECT Id, Meeting__c FROM Agenda__c WHERE Meeting__c IN :mapMeetingAttendees.keySet()]){
			mapAgendaAttendees.put(agenda.Id, mapMeetingAttendees.get(agenda.Meeting__c));
		}

		Map<Id, Map<Id, Agenda__Share>> mapAgendaSharings = createAgendaSharingsMap(mapAgendaAttendees.keySet(), SR_MEETING_ATTENDEE);
		List<Agenda__Share> agendaSharingToDel = new List<Agenda__Share>();

		for(Id agendaId : mapAgendaAttendees.keySet()){
			for(Id attendeeId : mapAgendaAttendees.get(agendaId)){
				if(mapAgendaSharings.containsKey(agendaId)){
					if(mapAgendaSharings.get(agendaId).containsKey(attendeeId)){
						agendaSharingToDel.add(mapAgendaSharings.get(agendaId).get(attendeeId));
					}
				}
			}
		}

		delete agendaSharingToDel;
	}

	public static void stopSharingMeetingsWithFollowers(List<Meeting_Follower__c> meetingFollowers){
		Set<Id> meetingIds = new Set<Id>();
		for(Meeting_Follower__c meetingFollower : meetingFollowers){
			meetingIds.add(meetingFollower.Meeting__c);
		}
		Map<Id, Map<Id, Meeting__Share>> mapMeetingSharings = createMeetingSharingsMap(meetingIds, SR_MEETING_FOLLOWER);
		List<Meeting__Share> meetingSharingToDel = new List<Meeting__Share>();

		for(Meeting_Follower__c meetingFollower : meetingFollowers){
			if(mapMeetingSharings.containsKey(meetingFollower.Meeting__c)){
				if(mapMeetingSharings.get(meetingFollower.Meeting__c).containsKey(meetingFollower.Follower__c)){
					meetingSharingToDel.add(mapMeetingSharings.get(meetingFollower.Meeting__c).get(meetingFollower.Follower__c));
				}
			}
		}

		delete meetingSharingToDel;
	}

	public static void stopSharingAgendasWithPresenter(Map<Id, Agenda__c> agendas){
		Map<Id, Map<Id, Agenda__Share>> mapAgendaSharings = createAgendaSharingsMap(agendas.keySet(), SR_PRESENTER);
		List<Agenda__Share> agendaSharingToDel = new List<Agenda__Share>();

		for(Agenda__c agenda : agendas.values()){
			if(mapAgendaSharings.containsKey(agenda.Id)){
				if(mapAgendaSharings.get(agenda.Id).containsKey(agenda.Presenter__c)){
					agendaSharingToDel.add(mapAgendaSharings.get(agenda.Id).get(agenda.Presenter__c));
				}
			}
		}

		delete agendaSharingToDel;
	}

	public static void stopSharingInitiativesWithTeamMembers(List<Initiative_Team_Member__c> initiativeTeamMembers){
		Set<Id> initiativeIds = new Set<Id>();
		for(Initiative_Team_Member__c initiativeTeamMember : initiativeTeamMembers){
			initiativeIds.add(initiativeTeamMember.Initiative__c);
		}
		Map<Id, Map<Id, Initiative__Share>> mapInitiativeSharings = createInitiativeSharingsMap(initiativeIds, SR_INITIATIVE_TEAM_MEMBER);
		List<Initiative__Share> initiativeSharingToDel = new List<Initiative__Share>();

		for(Initiative_Team_Member__c initiativeTeamMember : initiativeTeamMembers){
			if(mapInitiativeSharings.containsKey(initiativeTeamMember.Initiative__c)){
				if(mapInitiativeSharings.get(initiativeTeamMember.Initiative__c).containsKey(initiativeTeamMember.Team_member__c)){
					initiativeSharingToDel.add(mapInitiativeSharings.get(initiativeTeamMember.Initiative__c).get(initiativeTeamMember.Team_member__c));
				}
			}
		}

		delete initiativeSharingToDel;
	}

	public static void stopSharingInitiativesWithFollowers(List<Initiative_Follower__c> initiativeFollowers){
		Set<Id> initiativeIds = new Set<Id>();
		for(Initiative_Follower__c initiativeFollower : initiativeFollowers){
			initiativeIds.add(initiativeFollower.Initiative__c);
		}
		Map<Id, Map<Id, Initiative__Share>> mapInitiativeSharings = createInitiativeSharingsMap(initiativeIds, SR_INITIATIVE_FOLLOWER);
		List<Initiative__Share> initiativeSharingToDel = new List<Initiative__Share>();

		for(Initiative_Follower__c initiativeFollower : initiativeFollowers){
			if(mapInitiativeSharings.containsKey(initiativeFollower.Initiative__c)){
				if(mapInitiativeSharings.get(initiativeFollower.Initiative__c).containsKey(initiativeFollower.Follower__c)){
					initiativeSharingToDel.add(mapInitiativeSharings.get(initiativeFollower.Initiative__c).get(initiativeFollower.Follower__c));
				}
			}
		}

		delete initiativeSharingToDel;
	}

	public static void stopSharingActionsWithAssignedUsers(List<Action_Assignment__c> actionAssignments){
		Set<Id> actionIds = new Set<Id>();
		for(Action_Assignment__c actionAssignment : actionAssignments){
			actionIds.add(actionAssignment.Action__c);
		}
		Map<Id, Map<Id, Action__Share>> mapActionSharings = createActionSharingsMap(actionIds, SR_ACTION_ASSIGNMENT);
		List<Action__Share> actionSharingToDel = new List<Action__Share>();

		for(Action_Assignment__c actionAssignment : actionAssignments){
			if(mapActionSharings.containsKey(actionAssignment.Action__c)){
				if(mapActionSharings.get(actionAssignment.Action__c).containsKey(actionAssignment.Assigned_to__c)){
					actionSharingToDel.add(mapActionSharings.get(actionAssignment.Action__c).get(actionAssignment.Assigned_to__c));
				}
			}
		}

		delete actionSharingToDel;
	}

	public static void stopSharingActionsWithFollowers(List<Action_Follower__c> actionFollowers){
		Set<Id> actionIds = new Set<Id>();
		for(Action_Follower__c actionFollower : actionFollowers){
			actionIds.add(actionFollower.Action__c);
		}
		Map<Id, Map<Id, Action__Share>> mapActionSharings = createActionSharingsMap(actionIds, SR_ACTION_FOLLOWER);
		List<Action__Share> actionSharingToDel = new List<Action__Share>();

		for(Action_Follower__c actionFollower : actionFollowers){
			if(mapActionSharings.containsKey(actionFollower.Action__c)){
				if(mapActionSharings.get(actionFollower.Action__c).containsKey(actionFollower.Follower__c)){
					actionSharingToDel.add(mapActionSharings.get(actionFollower.Action__c).get(actionFollower.Follower__c));
				}
			}
		}

		delete actionSharingToDel;
	}

	public static void updateSharingForAgendaPresenter(Map<Id, Agenda__c> oldAgendas, Map<Id, Agenda__c> newAgendas){
		List<Agenda__c> agendasToShare = new List<Agenda__c>();
		Map<Id, Agenda__c> agendasToStopShare = new Map<Id, Agenda__c>();
		for(Id agendaId : newAgendas.keySet()){
			if(newAgendas.get(agendaId).Presenter__c != oldAgendas.get(agendaId).Presenter__c){
				agendasToShare.add(newAgendas.get(agendaId));
				agendasToStopShare.put(agendaId, oldAgendas.get(agendaId));
			}
		}
		shareAgendasWithPresenter(agendasToShare);
		stopSharingAgendasWithPresenter(agendasToStopShare);
	}

	public static Map<Id, Map<Id, Committee__Share>> createCommitteeSharingsMap(Set<Id> committeeIds, String RowCause){
		Map<Id, Map<Id, Committee__Share>> mapCommitteeSharings = new Map<Id, Map<Id, Committee__Share>>();
		for(Committee__Share commShare : [SELECT Id, ParentId, UserOrGroupId FROM Committee__Share WHERE RowCause = :RowCause AND ParentId IN :committeeIds]){
			if(mapCommitteeSharings.containsKey(commShare.ParentId)){
				mapCommitteeSharings.get(commShare.ParentId).put(commShare.UserOrGroupId, commShare);
			} else{
				mapCommitteeSharings.put(commShare.ParentId, new Map<Id, Committee__Share>{commShare.UserOrGroupId => commShare});
			}
		}

		return mapCommitteeSharings;
	}

	public static Map<Id, Map<Id, Meeting__Share>> createMeetingSharingsMap(Set<Id> meetingIds, String RowCause){
		Map<Id, Map<Id, Meeting__Share>> mapMeetingSharings = new Map<Id, Map<Id, Meeting__Share>>();
		for(Meeting__Share meetShare : [SELECT Id, ParentId, UserOrGroupId FROM Meeting__Share WHERE RowCause = :RowCause AND ParentId IN :meetingIds]){
			if(mapMeetingSharings.containsKey(meetShare.ParentId)){
				mapMeetingSharings.get(meetShare.ParentId).put(meetShare.UserOrGroupId, meetShare);
			} else{
				mapMeetingSharings.put(meetShare.ParentId, new Map<Id, Meeting__Share>{meetShare.UserOrGroupId => meetShare});
			}
		}

		return mapMeetingSharings;
	}

	public static Map<Id, Map<Id, Agenda__Share>> createAgendaSharingsMap(Set<Id> agendaIds, String RowCause){
		Map<Id, Map<Id, Agenda__Share>> mapAgendaSharings = new Map<Id, Map<Id, Agenda__Share>>();
		for(Agenda__Share agendaShare : [SELECT Id, ParentId, UserOrGroupId FROM Agenda__Share WHERE RowCause = :RowCause AND ParentId IN :agendaIds]){
			if(mapAgendaSharings.containsKey(agendaShare.ParentId)){
				mapAgendaSharings.get(agendaShare.ParentId).put(agendaShare.UserOrGroupId, agendaShare);
			} else{
				mapAgendaSharings.put(agendaShare.ParentId, new Map<Id, Agenda__Share>{agendaShare.UserOrGroupId => agendaShare});
			}
		}

		return mapAgendaSharings;
	}

	public static Map<Id, Map<Id, Initiative__Share>> createInitiativeSharingsMap(Set<Id> initiativeIds, String RowCause){
		Map<Id, Map<Id, Initiative__Share>> mapInitiativeSharings = new Map<Id, Map<Id, Initiative__Share>>();
		for(Initiative__Share initShare : [SELECT Id, ParentId, UserOrGroupId FROM Initiative__Share WHERE RowCause = :RowCause AND ParentId IN :initiativeIds]){
			if(mapInitiativeSharings.containsKey(initShare.ParentId)){
				mapInitiativeSharings.get(initShare.ParentId).put(initShare.UserOrGroupId, initShare);
			} else{
				mapInitiativeSharings.put(initShare.ParentId, new Map<Id, Initiative__Share>{initShare.UserOrGroupId => initShare});
			}
		}

		return mapInitiativeSharings;
	}

	public static Map<Id, Map<Id, Action__Share>> createActionSharingsMap(Set<Id> actionIds, String RowCause){
		Map<Id, Map<Id, Action__Share>> mapActionSharings = new Map<Id, Map<Id, Action__Share>>();
		for(Action__Share actionShare : [SELECT Id, ParentId, UserOrGroupId FROM Action__Share WHERE RowCause = :RowCause AND ParentId IN :actionIds]){
			if(mapActionSharings.containsKey(actionShare.ParentId)){
				mapActionSharings.get(actionShare.ParentId).put(actionShare.UserOrGroupId, actionShare);
			} else{
				mapActionSharings.put(actionShare.ParentId, new Map<Id, Action__Share>{actionShare.UserOrGroupId => actionShare});
			}
		}

		return mapActionSharings;
	}

	public static Committee__Share createCommitteeShare(Id CommitteeId, Id UserId, String RowCause, String AccessLevel){
		Committee__Share committeeShare = new Committee__Share();
		committeeShare.ParentId = CommitteeId;
		committeeShare.UserOrGroupId = UserId;
		committeeShare.RowCause = RowCause;
		committeeShare.AccessLevel = AccessLevel;
		return committeeShare;
	}

	public static Meeting__Share createMeetingShare(Id MeetingId, Id UserId, String RowCause, String AccessLevel){
		Meeting__Share meetingShare = new Meeting__Share();
		meetingShare.ParentId = MeetingId;
		meetingShare.UserOrGroupId = UserId;
		meetingShare.RowCause = RowCause;
		meetingShare.AccessLevel = AccessLevel;
		return meetingShare;
	}

	public static Agenda__Share createAgendaShare(Id AgendaId, Id UserId, String RowCause, String AccessLevel){
		Agenda__Share agendaShare = new Agenda__Share();
		agendaShare.ParentId = AgendaId;
		agendaShare.UserOrGroupId = UserId;
		agendaShare.RowCause = RowCause;
		agendaShare.AccessLevel = AccessLevel;
		return agendaShare;
	}

	public static Initiative__Share createInitiativeShare(Id InitiativeId, Id UserId, String RowCause, String AccessLevel){
		Initiative__Share initiativeShare = new Initiative__Share();
		initiativeShare.ParentId = InitiativeId;
		initiativeShare.UserOrGroupId = UserId;
		initiativeShare.RowCause = RowCause;
		initiativeShare.AccessLevel = AccessLevel;
		return initiativeShare;
	}

	public static Action__Share createActionShare(Id ActionId, Id UserId, String RowCause, String AccessLevel){
		Action__Share actionShare = new Action__Share();
		actionShare.ParentId = ActionId;
		actionShare.UserOrGroupId = UserId;
		actionShare.RowCause = RowCause;
		actionShare.AccessLevel = AccessLevel;
		return actionShare;
	}

	public static void insertRecords(List<SObject> records){
		Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.insert(records, dml);
	}
}