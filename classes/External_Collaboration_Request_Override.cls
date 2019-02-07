/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 14/03/2018 - PG    - Created initial class.
 20/03/2018 - PG 	- Added ability to edit (add / remove) members.
 					- Added redirect back to record after save.
 28/03/2018 - KK    - Added Folder_Id__c to stdController soqlFields
 02/04/2018 - KK    - Added Collaboration_Id__c to existingMembers list
 
**/ 
public with sharing class External_Collaboration_Request_Override 
{ 
	/**
	* Vars.
	**/
	public External_Collaboration_Request__c externalCollaborationRequest { get; set; }
	public List<advpm__Participant__c> dealParticipants;
	private static final Map<String, Schema.RecordTypeInfo> PARTICIPANT_TYPES = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
	public advpm__Participant__c memberLookupControl { get; set; }
	public String selectedMemberType { get; set; }
	public Map<String, Request_Member__c> existingRequestMembers { get; set; }
	public List<Request_Member__c> existingMembers { get; set; }
	
	/**
	* Wrapper vars.
	**/
	public List<Participant_Wrapper> participantsWrapper { get; set; }
	public List<Request_Member__c> membersWrapper { get; set; } 

	/**
	* Property - Used to dynamically show or hide user / contact lookup.
	**/
	public String memberControl 
	{
		get 
		{
			//Build list of record types.
			for(String recordTypeName : PARTICIPANT_TYPES.keySet())
			{
				//Only display user or contact.
				if(PARTICIPANT_TYPES.get(recordTypeName).getRecordTypeId() == selectedMemberType)
				{
					return recordTypeName;
				}
			}
			return '';
		}
	}

	/**
	* Constructor
	**/
	public External_Collaboration_Request_Override(ApexPages.StandardController stdController) 
	{
		//Blank variables.
		participantsWrapper = new List<Participant_Wrapper>();
		memberLookupControl = new advpm__Participant__c();
		membersWrapper = new List<Request_Member__c>();
		existingRequestMembers = new Map<String, Request_Member__c>();

		//Only if edit.
		if(stdController.getId() != null)
		{		
			//Controller fields
			List<String> soqlFields = new List<String>{
				'Deal__c',
				'Folder_Name__c',
                'Folder_Id__c',
				'Access_Level__c',
				'Status__c',
				'Access_Valid_Until__c',
				'Parent_Request__c'
			};

			if(!Test.isRunningTest())
			{
				//Add fields.
				stdController.addFields(soqlFields);
			}
		}

		//Assign record.
		this.externalCollaborationRequest = (External_Collaboration_Request__c)stdController.getRecord(); 

		//Set the default memberType
		selectedMemberType = PARTICIPANT_TYPES.get('Contact').getRecordTypeId();

		//Fetch existing deal parties.
		dealParticipants = new List<advpm__Participant__c>([
			SELECT
				Id,
				Name,
				RecordTypeId,
				advpm__Role__c, 
				advpm__Staff__c
			FROM advpm__Participant__c
			WHERE
				advpm__Matter__c = :externalCollaborationRequest.Deal__c
			ORDER BY 
				Name ASC
		]);

		//Fetch existing request members.
		existingMembers = new List<Request_Member__c>([
			SELECT
				Id,
				Member_Type__c,
				Member_ID__c,
				User__c,
				Contact__c,
            	Collaboration_Id__c
			FROM Request_Member__c
			WHERE
				External_Collaboration_Request__c = :externalCollaborationRequest.Id
		]);

		//Build a useful map of request member ids.
		for(Request_Member__c existingMember : existingMembers)
		{
			System.debug('existingMembers : '+existingMember.Member_ID__c);

			//Add to Map.
			existingRequestMembers.put((Id)existingMember.Member_ID__c, existingMember);
		}

		//Populate the participant wrapper.
		populateWrappers();
	}

	/**
	* Populates the initial wrapper lists.
	**/
	private void populateWrappers()
	{
		Set<String> userIds = new Set<String>();

		//Populate participants.
		for(advpm__Participant__c dealParticipant : dealParticipants)
		{
			System.debug('dealParticipants : '+dealParticipant.Id);

			//Add to wrapper
			participantsWrapper.add( new Participant_Wrapper( existingRequestMembers.containsKey(dealParticipant.Id) ? true : false, dealParticipant) ); 
		}

		//Populate request members with any existing.
		for(String key : existingRequestMembers.keySet())
		{
			if(existingRequestMembers.get(key).Member_Type__c != 'Participant')
			{
				//Add to wrapper list.
				membersWrapper.add(existingRequestMembers.get(key));
			}
		}
	}

	/**
	* Page action for "Add Member" button, also clears the lookups.
	**/
	public void clearMemberControl()
	{
		memberLookupControl.advpm__Staff__c = null;
		memberLookupControl.advpm__Contact__c = null;
	}

	/**
	* Build a list of select options based on record type names.
	**/
	public List<SelectOption> getMemberTypes()
	{
		//Blank list.
		List<SelectOption> options = new List<SelectOption>(); 

		//Build list of record types.
		for(String recordTypeName : PARTICIPANT_TYPES.keySet())
		{
			//Only display user or contact.
			if(recordTypeName == 'User' || recordTypeName == 'Contact')
			{
				options.add( new SelectOption(PARTICIPANT_TYPES.get(recordTypeName).getRecordTypeId(), recordTypeName) );
			}
		}

		return options;
	}

	/**
	* Used to add non-deal participant members to list.
	**/
	public void addMember() 
	{
		//Added user.
		if(memberLookupControl.advpm__Staff__c != null)
		{
			membersWrapper.add( new Request_Member__c(User__c = memberLookupControl.advpm__Staff__c, Member_Type__c = 'User') );
		}

		//Added contact.
		if(memberLookupControl.advpm__Contact__c != null)
		{
			membersWrapper.add( new Request_Member__c(Contact__c = memberLookupControl.advpm__Contact__c, Member_Type__c = 'Contact') );
		}
	}

	/**
	* Used to remove non-deal participant members to list.
	**/
	public void removeMember()
	{
		Integer removeIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('removeIndex'));
		membersWrapper.remove(removeIndex);
	}

	/**
	* Wrapper Class for Participant Selection. 
	**/
	public PageReference actionSave()
	{	
		//Blank list.
		List<Request_Member__c> addedMembers 	= new List<Request_Member__c>();

        //Determine record approver.
        String approverId = CloudSmiths_Utils.determineApprover();

        //Make sure we found one.
        if(approverId == null)
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to locate a request approver. Please contact the Salesforce Support team.'));
        	return null;
        }
        else
        {
        	//Allocate approver.
        	externalCollaborationRequest.Approver__c = approverId;
        }

		try 
		{
			if(externalCollaborationRequest.Status__c == 'Approved')
			{
				//Clone record and set fields.
				External_Collaboration_Request__c tempRequest = externalCollaborationRequest.clone(false);
				tempRequest.Status__c = 'New';
				tempRequest.Parent_Request__c = externalCollaborationRequest.Id;

				//Insert record.
				insert tempRequest;
                
				externalCollaborationRequest = tempRequest;
			}
			else
			{
				//Upsert external collaborate item.
				upsert externalCollaborationRequest;

				//Delete exist request members.
				delete existingMembers;
			}			

			//Loop over particpants and get selected.
			for(Participant_Wrapper wrapperItem : participantsWrapper)
			{
				//Add participants.
				if(wrapperItem.selected)
				{
					addedMembers.add(new Request_Member__c(External_Collaboration_Request__c = externalCollaborationRequest.Id, Participant__c = wrapperItem.record.Id, Member_Type__c = 'Participant') );
				}
			}

			//Clone list.
			List<Request_Member__c> membersWrapperClone = membersWrapper.deepClone(false, false, false);

			//Loop of the additional request members.
			for(Request_Member__c wrapperItem : membersWrapperClone)
			{
				//New User
				if(wrapperItem.Member_Type__c == 'User' || wrapperItem.Member_Type__c == 'Contact')
				{
					wrapperItem.External_Collaboration_Request__c = externalCollaborationRequest.Id;
					addedMembers.add(wrapperItem);
				}
			}

			//Insert request members.
			insert addedMembers;

			//Redirect back to record.
			PageReference page = new PageReference('/'+externalCollaborationRequest.Id);
   			page.setRedirect(true);
    		return page;
		}
		catch(Exception e)
		{
			//Show exception.
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}
	}

	/**
	* Wrapper Class for Participant Selection. 
	**/
	public class Participant_Wrapper
	{
		public Boolean selected { get; set; }
		public advpm__Participant__c record { get; set; } 

		public Participant_Wrapper(Boolean inputSelected, advpm__Participant__c inputRecord)
		{
			this.selected = inputSelected;
			this.record = inputRecord;
		}
	}	
}