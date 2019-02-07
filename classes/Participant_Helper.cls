/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
*** CHANGE LOG ***
 
 26/10/2017 - PG    - Created Class.
 
**/
public class Participant_Helper 
{	
	public static final Map<String, RecordTypeInfo> MATTER_TYPES = new Map<String, RecordTypeInfo>(advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName());

	/**
	* After Insert Trigger Handler
	**/
	public static void afterInsert(List<advpm__Participant__c> inputNewList)
	{
		updateMatterSharing(inputNewList); 
	}

	/**
	* After Update Trigger Handler
	**/
	public static void afterUpdate(List<advpm__Participant__c> inputNewList)
	{
		updateMatterSharing(inputNewList);
	}

	/**
	* Before Delete Trigger Handler
	**/
	public static void beforeDelete(List<advpm__Participant__c> inputOldList)
	{
		updateMatterSharing(inputOldList, true);
	}

	private static void updateMatterSharing(List<advpm__Participant__c> inputNewList, Boolean removeOnly)
	{
		//Blank vars.
		List<advpm__Matter__Share> sharingRecords = new List<advpm__Matter__Share>();
		Map<Id, advpm__Matter__c> matters = new Map<Id, advpm__Matter__c>();
		Set<Id> userIds = new Set<Id>();
		Set<Id> matterIds = new Set<Id>();
		List<advpm__Matter__Share> shareRecords = new List<advpm__Matter__Share>();
		Map<Id, User> users = new Map<Id, User>();

		//Build users from participants.
		for(advpm__Participant__c participant : inputNewList)
		{
			//Is of type user.
			if(participant.advpm__Staff__c != null)
			{
				//Add to set.
				userIds.add(participant.advpm__Staff__c);
				matterIds.add(participant.advpm__Matter__c);
			}
		}

		//Fetch matter details.
		matters = new Map<Id, advpm__Matter__c>([
			SELECT
				Id,
				RecordTypeId
			FROM advpm__Matter__c
			WHERE 
				Id IN :matterIds
		]);

		//Fetch existing manual sharing records.
		sharingRecords = [
			SELECT
				Id,
				RowCause,
				UserOrGroupId
			FROM advpm__Matter__Share
			WHERE
				UserOrGroupId IN :userIds
				AND RowCause = 'Custom_Sharing__c'
				AND ParentId IN :matterIds
		];

		//User records
		users = new Map<Id, User>([
			SELECT
				Id,
				IsActive
			FROM User
			WHERE
				Id IN :userIds
		]);

		//Remove existing records.
		if(removeOnly == true)
		{
			//Delete records
			delete sharingRecords;
		}
		else
		{
			//Delete records
			delete sharingRecords;

			//Loop through participants.
			for(advpm__Participant__c participant : inputNewList)
			{
				//Is of type user.
				if(participant.advpm__Staff__c != null && users.get(participant.advpm__Staff__c).IsActive == true)
				{	
					//New Record.
					advpm__Matter__Share shareRecord = new advpm__Matter__Share();
					shareRecord.UserOrGroupId = participant.advpm__Staff__c;
					shareRecord.AccessLevel = 'Edit';
					shareRecord.ParentId = participant.advpm__Matter__c;
					shareRecord.RowCause = Schema.advpm__Matter__Share.RowCause.Custom_Sharing__c;

					//Add to list.
					shareRecords.add(shareRecord);
				}
			}

			//Insert records.
			insert shareRecords;
		}
	}

	private static void updateMatterSharing(List<advpm__Participant__c> inputNewList)
	{
		updateMatterSharing(inputNewList, false);
	}
}