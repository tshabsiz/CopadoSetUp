/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a help class for trigger JlocAttendeeTrigger.
* @Date:        10/2015
* @ConstructorParam:    None
* @TestClass:   ZZTEST_JlocAttendeeTrigger
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class JlocAttendeeTriggerHelper {
	public static String AL_EDIT = 'Edit';
	public static String SR_JLOC_COMMITTEE_ATTENDEE = 'JLOC_Committee_Attendee__c'; //Apex Sharing Reason for JLOC Committee Attendee
	public static String STATUS_APPROVED = 'Approved';
	public static String STATUS_APPROVED_SUBJECT_TO = 'Approved Subject to';
	public static String STATUS_DECLINED = 'Declined';
	
	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to share JLOC with Committee Attendees.
	* @param 		The list of JLOC Attendees.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void shareJlocWithCommitteeAttendees(List<JLOC_Attendee__c> jlocAttendees){
		List<JLOC__Share> jlocSharings = new List<JLOC__Share>();
		for(JLOC_Attendee__c jlocAttendee : jlocAttendees){
			JLOC__Share jlocShare = createJlocShare(jlocAttendee.JLOC__c, jlocAttendee.User__c, SR_JLOC_COMMITTEE_ATTENDEE, AL_EDIT);
			jlocSharings.add(jlocShare);
		}

		insertRecords(jlocSharings);
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to stop sharing JLOC with Committee Attendees.
	* @param 		The list of JLOC Attendees.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void stopSharingJlocWithCommitteeAttendees(List<JLOC_Attendee__c> jlocAttendees){
		Set<Id> jlocIds = new Set<Id>();
		for(JLOC_Attendee__c jlocAttendee : jlocAttendees){
			jlocIds.add(jlocAttendee.JLOC__c);
		}
		Map<Id, Map<Id, JLOC__Share>> jlocSharingsMap = createJlocSharingsMap(jlocIds, SR_JLOC_COMMITTEE_ATTENDEE);

		List<JLOC__Share> jlocSharingsToDel = new List<JLOC__Share>();
		for(JLOC_Attendee__c jlocAttendee : jlocAttendees){
			if(jlocSharingsMap.containsKey(jlocAttendee.JLOC__c)){
				if(jlocSharingsMap.get(jlocAttendee.JLOC__c).containsKey(jlocAttendee.User__c)){
					jlocSharingsToDel.add(jlocSharingsMap.get(jlocAttendee.JLOC__c).get(jlocAttendee.User__c));
				}
			}
		}

		delete jlocSharingsToDel;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to check approval status for JLOC after Committee Attende vote.
	* @param 		The list of JLOC Attendees before and after update.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void checkJlocApprovalStatus(Map<Id, JLOC_Attendee__c> newJlocAttendees, Map<Id, JLOC_Attendee__c> oldJlocAttendees){
		Set<Id> jlocIds = new Set<Id>();
		for(Id jlocAttendeeId : newJlocAttendees.keySet()){
			if(newJlocAttendees.get(jlocAttendeeId).Vote__c != oldJlocAttendees.get(jlocAttendeeId).Vote__c){
				jlocIds.add(newJlocAttendees.get(jlocAttendeeId).JLOC__c);
			}
		}
		List<JLOC__c> jlocsToUpd = new List<JLOC__c>();
		for(JLOC__c jloc : [SELECT Id, Name, (SELECT Id, Name, Group__c, Vote__c FROM JLOC_Attendees__r WHERE Group__c != 'Other') 
							FROM JLOC__c WHERE Id IN :jlocIds]){
			Boolean isDeclined = false;
			Boolean isApproved = true;
			Boolean isApprovedSubjectTo = false;
			Map<String, String> mapApprovalStatusByGroup = new Map<String, String>();
			for(JLOC_Attendee__c jlocAttendee : jloc.JLOC_Attendees__r){
				if(jlocAttendee.Vote__c == STATUS_DECLINED){
					isDeclined = true;
					break;
				} else if(!mapApprovalStatusByGroup.containsKey(jlocAttendee.Group__c) || String.isBlank(mapApprovalStatusByGroup.get(jlocAttendee.Group__c))){
					mapApprovalStatusByGroup.put(jlocAttendee.Group__c, jlocAttendee.Vote__c);
				} else if(String.isNotBlank(jlocAttendee.Vote__c)){
					if(mapApprovalStatusByGroup.get(jlocAttendee.Group__c) == STATUS_APPROVED_SUBJECT_TO || jlocAttendee.Vote__c == STATUS_APPROVED_SUBJECT_TO){
						mapApprovalStatusByGroup.put(jlocAttendee.Group__c, STATUS_APPROVED_SUBJECT_TO);
					}
				} 
			}
			if(isDeclined == true){
				jlocsToUpd.add(new JLOC__c(Id=jloc.Id, JLOC_Status__c=STATUS_DECLINED));
				break;
			} else{
				for(String approvalStatus : mapApprovalStatusByGroup.values()){
					if(String.isBlank(approvalStatus)){
						isApproved = false;
						isApprovedSubjectTo = false;
						break;
					} else if(approvalStatus == STATUS_APPROVED_SUBJECT_TO){
						isApproved = false;
						isApprovedSubjectTo = true;
					}
				}
				if(isApproved == true){
					jlocsToUpd.add(new JLOC__c(Id=jloc.Id, JLOC_Status__c=STATUS_APPROVED));
				} else if(isApprovedSubjectTo == true){
					jlocsToUpd.add(new JLOC__c(Id=jloc.Id, JLOC_Status__c=STATUS_APPROVED_SUBJECT_TO));
				}
			}
		}

		try{
			update jlocsToUpd;
		} catch(DmlException ex){
			System.debug(ex.getMessage());
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to create map of existing JLOC sharings.
	* @param 		The Set of JLOC Ids.
	* @param 		Apex Sharing reason
	* @Returns:		Map of JLOC Sharings
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static Map<Id, Map<Id, JLOC__Share>> createJlocSharingsMap(Set<Id> jlocIds, String RowCause){
		Map<Id, Map<Id, JLOC__Share>> jlocSharingsMap = new Map<Id, Map<Id, JLOC__Share>>();
		for(JLOC__Share jlocSharing : [SELECT Id, ParentId, UserOrGroupId FROM JLOC__Share WHERE RowCause = :RowCause AND ParentId IN :jlocIds]){
			if(jlocSharingsMap.containsKey(jlocSharing.ParentId)){
				jlocSharingsMap.get(jlocSharing.ParentId).put(jlocSharing.UserOrGroupId, jlocSharing);
			} else{
				jlocSharingsMap.put(jlocSharing.ParentId, new Map<Id, JLOC__Share>{jlocSharing.UserOrGroupId => jlocSharing});
			}
		}

		return jlocSharingsMap;
	}

	public static JLOC__Share createJlocShare(Id JlocId, Id UserId, String RowCause, String AccessLevel){
		JLOC__Share jlocShare = new JLOC__Share();
		jlocShare.ParentId = JlocId;
		jlocShare.UserOrGroupId = UserId;
		jlocShare.RowCause = RowCause;
		jlocShare.AccessLevel = AccessLevel;
		return jlocShare;
	}

	public static void insertRecords(List<SObject> records){
		Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.insert(records, dml);
	}
}