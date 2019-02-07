/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_InviteParticipants page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_InviteParticipantsController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015	  Marta Malinowska	 Add Deal Team members to the list of JLOC attendees
*------------------------------------------------------------*/
public with sharing class JLOC_InviteParticipantsController {
	public static String APPROVE = 'Approve';
	public static String DEAL_TEAM = 'Deal Team';

	public static Map<String, String> chatterGroupNamesMap = new Map<String, String>{
		'JLOC Coverage' => 'Coverage',
		'JLOC Investment Banking' => 'Investment Banking',
		'JLOC Portfolio Management' => 'Portfolio Management',
		'JLOC Markets' => 'Markets',
		'JLOC Trade' => 'Trade'
	};

	private JLOC__c jloc;
	private Id currentUserId;
	private List<ProcessInstanceWorkItem> workItems;
	public Boolean areChaterGroupsCongigured { get; set; }
	public Boolean areChatterGroupsSelected { get; set; }
	public Boolean allGroupsSelected { get; set; }
	public Map<Id, ChatterGroupWrapper> chatterGroupsMap { get; set; }
	public List<ChatterGroupWrapper> chatterGroups { get; set; }
	public Boolean allDealTeamMembersSelected { get; set; }
	public List<DealTeamMemberWrapper> dealTeamMembers { get; set; }
	private Integer otherJlocAttendeesCounter;
	public Integer otherJlocAttendeeToDel { get; set; }
	public List<OtherAttendeeWrapper> otherJlocAttendees { get; set; }
	public Map<Integer, OtherAttendeeWrapper> otherJlocAttendeesMap { get; set; }
	public Boolean isOtherJlocAttendeesEmpty { get; set; }

	public JLOC_InviteParticipantsController(ApexPages.StandardController stdController) {
		jloc = (JLOC__c)stdController.getRecord();
		currentUserId = UserInfo.getUserId();

		workItems = [
			SELECT Id 
			FROM ProcessInstanceWorkItem 
			WHERE ProcessInstance.TargetObjectId = :jloc.Id AND ActorId = :currentUserId AND ProcessInstance.Status = 'Pending'
		];

		chatterGroupsMap = new Map<Id, ChatterGroupWrapper>();
		for(CollaborationGroup chatterGroup : [
			SELECT Id, Name 
			FROM CollaborationGroup 
			WHERE Name IN :chatterGroupNamesMap.keySet()
			ORDER BY Name
			]) {
			chatterGroupsMap.put(chatterGroup.Id, new ChatterGroupWrapper(chatterGroup));
		}

		if(chatterGroupsMap.size() > 0) {
			chatterGroups = chatterGroupsMap.values();
			areChaterGroupsCongigured = true;
		} else {
			chatterGroups = new List<ChatterGroupWrapper>();
			areChaterGroupsCongigured = false;
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There is no Chatter Groups.'));
		}

		allDealTeamMembersSelected = true;
		dealTeamMembers = new List<DealTeamMemberWrapper>();
		for(Opportunity opp : [SELECT Id, (SELECT UserId, User.Name, TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE JLOC__c = :jloc.Id]) {
			for(OpportunityTeamMember oppTeamMember : opp.OpportunityTeamMembers) {
				dealTeamMembers.add(new DealTeamMemberWrapper(oppTeamMember));
			}
		}

		otherJlocAttendeesCounter = 0;
		otherJlocAttendeesMap = new Map<Integer, OtherAttendeeWrapper>();
		otherJlocAttendees = otherJlocAttendeesMap.values();
		isOtherJlocAttendeesEmpty = otherJlocAttendees.isEmpty();

		areChatterGroupsSelected = false;
		allGroupsSelected = true;

		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please select JLOC Committe Voting Groups before proceed.'));
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to display users from each selected Chatter group.
    * @param        None
    * @Returns:     current page
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public PageReference next(){
        Set<Id> selectedChatterGroupIds = new Set<Id>();
        for(ChatterGroupWrapper chatterGroupWrapper : chatterGroups) {
        	if(chatterGroupWrapper.isSelected) {
        		selectedChatterGroupIds.add(chatterGroupWrapper.chatterGroup.Id);
        	}
        }
        if(selectedChatterGroupIds.isEmpty()) {
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'At Least one JLOC Committee Voting Group must be selected.'));
        	return null;
        } else {
        	areChatterGroupsSelected = true;
        }

        for(CollaborationGroupMember groupMember : [
        	SELECT Id, CollaborationGroupId, MemberId, Member.Name
			FROM CollaborationGroupMember 
			WHERE CollaborationRole != 'Admin' AND CollaborationGroupId IN :selectedChatterGroupIds
			]) {
        	if(chatterGroupsMap.containsKey(groupMember.CollaborationGroupId)) {
        		chatterGroupsMap.get(groupMember.CollaborationGroupId).chatterGroupMembers.add(new ChatterGroupMemberWrapper(groupMember));
        	}
        }

		return null;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to save selected and added JLOC Attendees.
    * @param        None
    * @Returns:     the view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference save() {
    	List<JLOC_Attendee__c> jlocAttendees = new List<JLOC_Attendee__c>();
		for(ChatterGroupWrapper chatterGroupWrapper : chatterGroups) {
        	for(ChatterGroupMemberWrapper chatterGroupMemberWrapper : chatterGroupWrapper.chatterGroupMembers) {
        		if(chatterGroupMemberWrapper.isSelected == true) {
        			JLOC_Attendee__c attendee = new JLOC_Attendee__c();
        			attendee.JLOC__c = jloc.Id;
        			attendee.User__c = chatterGroupMemberWrapper.chatterGroupMember.MemberId;
        			attendee.Group__c = chatterGroupWrapper.name;
        			jlocAttendees.add(attendee);
        		}
        	}
        }

        for(DealTeamMemberWrapper dealTeamMemberWrapper : dealTeamMembers) {
        	if(dealTeamMemberWrapper.isSelected == true) {
        		JLOC_Attendee__c attendee = new JLOC_Attendee__c();
        		attendee.JLOC__c = jloc.Id;
        		attendee.User__c = dealTeamMemberWrapper.dealTeamMember.UserId;
        		attendee.Group__c = DEAL_TEAM;
        		jlocAttendees.add(attendee);
        	}
        }

        for(OtherAttendeeWrapper otherAttendeeWrapper : otherJlocAttendees) {
        	jlocAttendees.add(otherAttendeeWrapper.otherJlocAttendee);
        }

        try {
        	JLOC_ApprovalProcessUtils.insertJlocAttendees(jlocAttendees);
        } catch(DmlException ex) {
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
        }

        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkItem workItem : workItems) {
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setAction(APPROVE);
			req.setWorkitemId(workItem.Id);
			requests.add(req);
		}
        
		try {
			List<Approval.ProcessResult> results = Approval.process(requests);
		} catch(Exception ex) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		return new ApexPages.StandardController(jloc).view();
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to create new JLOC Attendee.
    * @param        None
    * @Returns:     current page
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference addOtherAttendee() {
		if(String.isNotBlank(jloc.Id)) {
			JLOC_Attendee__c jlocAttendee = new JLOC_Attendee__c(JLOC__c=jloc.Id, Group__c='Other');
			OtherAttendeeWrapper otherJlocAttendee = new OtherAttendeeWrapper(otherJlocAttendeesCounter, jlocAttendee);
			otherJlocAttendeesMap.put(otherJlocAttendeesCounter, otherJlocAttendee);
			otherJlocAttendees = otherJlocAttendeesMap.values();
			isOtherJlocAttendeesEmpty = otherJlocAttendees.isEmpty();
			otherJlocAttendeesCounter++;
		}
        return null;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to remove selected JLOC Attendee.
    * @param        None
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void removeOtherAttendee() {
    	if(otherJlocAttendeeToDel != null && otherJlocAttendeesMap.containsKey(otherJlocAttendeeToDel)) {
    		otherJlocAttendeesMap.remove(otherJlocAttendeeToDel);
    		otherJlocAttendees = otherJlocAttendeesMap.values();
    		isOtherJlocAttendeesEmpty = otherJlocAttendees.isEmpty();
    	}
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This class is user to store information about Chatter Groups.
	* @ConstructorParam:    chatterGroup - Collaboration Group record
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public class ChatterGroupWrapper {
		public Boolean isSelected { get; set; }		//Indicates if Chatter Group is selected
		public Boolean allGroupMembersSelected { get; set; }	//Indicates if all Chatter Group Members /within this Chatter Group/ are selected
		public String name { get; set; }
		public CollaborationGroup chatterGroup { get; set; }
		public List<ChatterGroupMemberWrapper> chatterGroupMembers { get; set; }

		public ChatterGroupWrapper(CollaborationGroup chatterGroup) {
			this.isSelected = true;
			this.allGroupMembersSelected = true;
			if(chatterGroupNamesMap.containsKey(chatterGroup.Name)) {
				this.name = chatterGroupNamesMap.get(chatterGroup.Name);
			} else {
				this.name = chatterGroup.Name;
			}
			this.chatterGroup = chatterGroup;
			this.chatterGroupMembers = new List<ChatterGroupMemberWrapper>();
		}
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This class is user to store information about Chatter Group Member.
	* @ConstructorParam:    chatterGroupMember - Collaboration Group Member record
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public class ChatterGroupMemberWrapper {
		public Boolean isSelected { get; set; }
		public CollaborationGroupMember chatterGroupMember { get; set; }

		public ChatterGroupMemberWrapper(CollaborationGroupMember chatterGroupMember) {
			this.isSelected = true;
			this.chatterGroupMember = chatterGroupMember;
		}
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This class is user to store information about Opportunity Team Member.
	* @ConstructorParam:    dealTeamMember - Opportunity Team Member record
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public class DealTeamMemberWrapper {
		public Boolean isSelected { get; set; }
		public OpportunityTeamMember dealTeamMember { get; set; }

		public DealTeamMemberWrapper(OpportunityTeamMember dealTeamMember) {
			this.isSelected = true;
			this.dealTeamMember = dealTeamMember;
		}
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This class is user to store information about JLOC Attendee.
	* @ConstructorParam:    order - order of JLOC Attendee
	* @ConstructorParam:    otherJlocAttendee - JLOC Attendee record
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public class OtherAttendeeWrapper {
		public Integer order { get; set; }
		public JLOC_Attendee__c otherJlocAttendee { get; set; }

		public OtherAttendeeWrapper(Integer order, JLOC_Attendee__c otherJlocAttendee) {
			this.order = order;
			this.otherJlocAttendee = otherJlocAttendee;
		}
	}
}